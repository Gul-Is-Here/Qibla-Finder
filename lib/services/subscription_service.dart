import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../models/subscription_model.dart';

class SubscriptionService extends GetxService {
  static SubscriptionService get instance => Get.find();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetStorage _storage = GetStorage();

  // Observables
  Rx<SubscriptionStatus> subscriptionStatus = SubscriptionStatus().obs;
  RxList<SubscriptionProduct> availableProducts = <SubscriptionProduct>[].obs;
  RxBool isLoading = false.obs;
  RxBool isPurchasing = false.obs;
  RxString errorMessage = ''.obs;

  late StreamSubscription<List<PurchaseDetails>> _purchaseUpdateSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeSubscriptions();
  }

  @override
  void onClose() {
    _purchaseUpdateSubscription.cancel();
    super.onClose();
  }

  /// Initialize in-app purchase system
  Future<void> _initializeSubscriptions() async {
    try {
      print('🛒 Initializing subscription service...');

      // Check if in-app purchase is available
      final available = await _inAppPurchase.isAvailable();
      if (!available) {
        errorMessage.value = 'In-app purchases not available on this device';
        print('❌ In-app purchases not available');
        return;
      }

      print('✅ In-app purchases available');

      // Listen to purchase updates
      _purchaseUpdateSubscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
        onError: (error) {
          print('❌ Purchase stream error: $error');
          errorMessage.value = error.toString();
        },
      );

      // Load subscription status from cache and Firestore
      await _loadSubscriptionStatus();

      // Load available products
      await loadProducts();

      print('✅ Subscription service initialized');
    } catch (e) {
      print('❌ Error initializing subscriptions: $e');
      errorMessage.value = e.toString();
    }
  }

  /// Load subscription products from Play Store
  Future<void> loadProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('📦 Loading subscription products...');

      // Determine user's country (simplified - you can use a package for actual geolocation)
      final isPakistan = await _isPakistanUser();
      print('🌍 User location: ${isPakistan ? 'Pakistan' : 'International'}');

      // Get relevant product IDs based on location
      final productIds = isPakistan
          ? SubscriptionIds.getPakistanIds()
          : SubscriptionIds.getInternationalIds();

      // Query products from store
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(
        productIds.toSet(),
      );

      if (response.error != null) {
        throw Exception('Failed to load products: ${response.error}');
      }

      if (response.notFoundIDs.isNotEmpty) {
        print('⚠️ Products not found in store: ${response.notFoundIDs.join(", ")}');
      }

      // Convert to our model
      availableProducts.value = response.productDetails.map((product) {
        return SubscriptionProduct(
          id: product.id,
          title: product.title,
          description: product.description,
          price: product.price,
          currencyCode: product.currencyCode,
          priceInMicros: int.parse(product.rawPrice.toString().replaceAll('.', '')), // Simplified
          duration: product.id.contains('yearly')
              ? const Duration(days: 365)
              : const Duration(days: 30),
          isPakistanPrice: isPakistan,
        );
      }).toList();

      // Sort: Monthly first, then Yearly
      availableProducts.sort((a, b) => a.isMonthly ? -1 : 1);

      print('✅ Loaded ${availableProducts.length} products');
      for (var product in availableProducts) {
        print('  - ${product.title}: ${product.price} (${product.durationText})');
      }
    } catch (e) {
      print('❌ Error loading products: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Purchase a subscription
  Future<bool> purchaseSubscription(String productId) async {
    try {
      isPurchasing.value = true;
      errorMessage.value = '';

      print('💳 Initiating purchase for: $productId');

      // Find the product
      final product = availableProducts.firstWhereOrNull((p) => p.id == productId);
      if (product == null) {
        throw Exception('Product not found: $productId');
      }

      // Get the product details from store
      final response = await _inAppPurchase.queryProductDetails({productId});
      if (response.productDetails.isEmpty) {
        throw Exception('Product details not found');
      }

      final productDetails = response.productDetails.first;

      // Create purchase param
      final purchaseParam = PurchaseParam(productDetails: productDetails);

      // Start purchase flow
      final success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      print(success ? '✅ Purchase flow started' : '❌ Purchase flow failed to start');
      return success;
    } catch (e) {
      print('❌ Error purchasing subscription: $e');
      errorMessage.value = e.toString();
      Get.snackbar('Purchase Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isPurchasing.value = false;
    }
  }

  /// Handle purchase updates from the store
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      print('📦 Purchase update: ${purchaseDetails.status}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          print('⏳ Purchase pending...');
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          print('✅ Purchase successful!');
          _handleSuccessfulPurchase(purchaseDetails);
          break;

        case PurchaseStatus.error:
          print('❌ Purchase error: ${purchaseDetails.error}');
          errorMessage.value = purchaseDetails.error?.message ?? 'Purchase failed';
          Get.snackbar('Purchase Failed', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
          break;

        case PurchaseStatus.canceled:
          print('🚫 Purchase canceled by user');
          break;
      }

      // Complete the purchase on Android
      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  /// Handle successful purchase
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
    try {
      print('💾 Saving purchase to Firestore...');

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Calculate expiry date
      final purchaseDate = DateTime.now();
      final isYearly = purchase.productID.contains('yearly');
      final expiryDate = purchaseDate.add(Duration(days: isYearly ? 365 : 30));

      // Create subscription status
      final status = SubscriptionStatus(
        isPremium: true,
        productId: purchase.productID,
        purchaseDate: purchaseDate,
        expiryDate: expiryDate,
        isAutoRenewing: true,
      );

      // Save to Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'subscription': status.toMap(),
        'isPremium': true,
      });

      // Save to local storage
      _storage.write('subscription_status', status.toMap());

      // Update observable
      subscriptionStatus.value = status;

      print('✅ Purchase saved successfully');
      print('📅 Expires on: ${expiryDate.toString()}');

      Get.snackbar(
        'Premium Activated! 🎉',
        'You now have ad-free access to all features',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('❌ Error handling purchase: $e');
      errorMessage.value = e.toString();
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('🔄 Restoring purchases...');

      await _inAppPurchase.restorePurchases();

      print('✅ Restore initiated (updates will come via stream)');

      Get.snackbar(
        'Restore Purchases',
        'Checking for previous purchases...',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('❌ Error restoring purchases: $e');
      errorMessage.value = e.toString();
      Get.snackbar('Restore Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Load subscription status from Firestore and cache
  Future<void> _loadSubscriptionStatus() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('⚠️ No authenticated user');
        return;
      }

      print('📥 Loading subscription status...');

      // Try Firestore first
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['subscription'] != null) {
        final status = SubscriptionStatus.fromMap(doc.data()!['subscription']);

        // Check if subscription is still active
        if (status.isActive) {
          subscriptionStatus.value = status;
          _storage.write('subscription_status', status.toMap());
          print('✅ Active subscription found: ${status.productId}');
          return;
        } else {
          print('⚠️ Subscription expired');
        }
      }

      // Fallback to local cache
      final cached = _storage.read('subscription_status');
      if (cached != null) {
        final status = SubscriptionStatus.fromMap(cached);
        if (status.isActive) {
          subscriptionStatus.value = status;
          print('✅ Loaded from cache');
          return;
        }
      }

      print('ℹ️ No active subscription found');
    } catch (e) {
      print('❌ Error loading subscription status: $e');
    }
  }

  /// Check if user is from Pakistan (simplified)
  Future<bool> _isPakistanUser() async {
    try {
      // Method 1: Check from user's Firestore profile if you store country
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()?['country'] != null) {
          return doc.data()!['country'] == 'PK';
        }
      }

      // Method 2: Check from local storage
      final savedCountry = _storage.read('user_country');
      if (savedCountry != null) {
        return savedCountry == 'PK';
      }

      // Method 3: Default based on device timezone (simplified)
      // In production, use a proper geolocation package
      return false; // Default to international pricing
    } catch (e) {
      print('⚠️ Error detecting country: $e');
      return false;
    }
  }

  /// Check if user has premium access
  bool get isPremium => subscriptionStatus.value.isActive;

  /// Check if ads should be shown
  bool get shouldShowAds => !isPremium;
}
