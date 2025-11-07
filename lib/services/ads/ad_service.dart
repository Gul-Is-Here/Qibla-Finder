import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService extends GetxController {
  static AdService get instance => Get.find<AdService>();

  /* 
   * PLAY STORE DEPLOYMENT SETUP:
   * 
   * FOR PLAY STORE SUBMISSION (Review Phase):
   * - Set _disableAdsForStore = true
   * - This will disable all ads during app store review
   * 
   * FOR PRODUCTION RELEASE (Live Users):
   * - Set _disableAdsForStore = false  
   * - This will enable all ads for live users
   * 
   * FAMILY-FRIENDLY AD COMPLIANCE:
   * - Native Ad in Prayer Times screen for better integration
   * - First Banner: ca-app-pub-2744970719381152/8104539777
   * - Native Ad: ca-app-pub-2744970719381152/6171882056
   * - Interstitial ads have NO immersive mode (close button always visible)
   * - Reduced ad frequency for family-friendly experience
   * 
   * AD UNIT IDS (Production):
   * - Banner 1: ca-app-pub-2744970719381152/8104539777
   * - Banner 2: ca-app-pub-2744970719381152/2687383872
   * - Native Ad: ca-app-pub-2744970719381152/6171882056
   * - Interstitial: ca-app-pub-2744970719381152/1432331975
   * 
   * INSTRUCTIONS:
   * 1. Upload to Play Store with _disableAdsForStore = true
   * 2. After approval, update to _disableAdsForStore = false
   * 3. Release update to enable monetization
   */

  // PLAY STORE SUBMISSION:
  // Set to TRUE to disable ads for store review/submission
  // Set to FALSE to enable ads for production release
  static const bool _disableAdsForStore = false; // DISABLED - Content rating mismatch issue
  static final String _bannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-2744970719381152/8104539777' // Production Android Banner Ad Unit ID
      : 'ca-app-pub-2744970719381152/8104539777'; // Production iOS Banner Ad Unit ID

  static final String _bottomBannerAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-2744970719381152/2687383872' // Second Banner Ad Unit ID for Android
      : 'ca-app-pub-2744970719381152/2687383872'; // Second Banner Ad Unit ID for iOS

  static final String _interstitialAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-2744970719381152/1432331975' // Production Android Interstitial Ad Unit ID
      : 'ca-app-pub-2744970719381152/1432331975'; // Production iOS Interstitial Ad Unit ID

  static final String _rewardedAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-2744970719381152/1432331975' // Using interstitial ID for rewarded (create separate if needed)
      : 'ca-app-pub-2744970719381152/1432331975'; // Using interstitial ID for rewarded (create separate if needed)

  static final String _nativeAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-2744970719381152/6171882056' // Production Android Native Ad Unit ID
      : 'ca-app-pub-2744970719381152/6171882056'; // Production iOS Native Ad Unit ID

  // Getters for ad unit IDs
  static String get bannerAdUnitId => _bannerAdUnitId;
  static String get bottomBannerAdUnitId => _bottomBannerAdUnitId;
  static String get nativeAdUnitId => _nativeAdUnitId;

  // Getter to check if ads are disabled for store submission
  static bool get areAdsDisabled => _disableAdsForStore;

  // Ad instances
  BannerAd? _bannerAd;
  BannerAd? _bottomBannerAd; // Second banner ad for bottom placement
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Ad states
  var isBannerAdLoaded = false.obs;
  var isBottomBannerAdLoaded = false.obs; // State for bottom banner
  var isInterstitialAdLoaded = false.obs;
  var isRewardedAdLoaded = false.obs;

  // Ad click tracking for optimization
  var adClickCount = 0.obs;
  var lastAdClickTime = DateTime.now().obs;

  // Automatic interstitial ad showing
  DateTime _lastInterstitialShowTime = DateTime.now();
  final DateTime _appStartTime = DateTime.now();
  int _screenNavigationCount = 0;
  bool _isInterstitialShowing = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeAds();
  }

  Future<void> _initializeAds() async {
    await MobileAds.instance.initialize();

    // Set request configuration for better performance
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
      ),
    );

    _loadBannerAd();
    _loadBottomBannerAd(); // Load second banner ad
    _loadInterstitialAd();
    _loadRewardedAd();

    // Start automatic interstitial ad timer
    print('🚀 Starting automatic interstitial ad timer');
    startAutoInterstitialTimer();
  }

  // Banner Ad Methods
  void _loadBannerAd() {
    // Don't load ads if disabled for store submission
    if (_disableAdsForStore) {
      print('Ads disabled for Play Store submission');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerAdLoaded.value = true;
          print('Banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          isBannerAdLoaded.value = false;
          ad.dispose();
          print('Banner ad failed to load: $error');

          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            _loadBannerAd();
          });
        },
        onAdClicked: (ad) {
          _trackAdClick();
        },
      ),
    );
    _bannerAd?.load();
  }

  BannerAd? get bannerAd => _bannerAd;
  BannerAd? get bottomBannerAd => _bottomBannerAd;

  // Create a new unique banner ad instance for each widget
  BannerAd? createUniqueBannerAd({String? customKey}) {
    if (_disableAdsForStore) {
      return null;
    }

    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Unique banner ad loaded: ${ad.hashCode}');
        },
        onAdFailedToLoad: (ad, error) {
          print('Unique banner ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (ad) => print('Unique banner ad opened'),
        onAdClosed: (ad) => print('Unique banner ad closed'),
      ),
    );
  }

  // Create a new unique second banner ad instance for each widget
  BannerAd? createUniqueSecondBannerAd({String? customKey}) {
    if (_disableAdsForStore) {
      return null;
    }

    return BannerAd(
      adUnitId: _bottomBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Unique second banner ad loaded: ${ad.hashCode}');
        },
        onAdFailedToLoad: (ad, error) {
          print('Unique second banner ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (ad) => print('Unique second banner ad opened'),
        onAdClosed: (ad) => print('Unique second banner ad closed'),
      ),
    );
  }

  // Create a new unique native ad instance for each widget
  NativeAd? createUniqueNativeAd({String? customKey}) {
    if (_disableAdsForStore) {
      return null;
    }

    return NativeAd(
      adUnitId: _nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          print('✅ Unique native ad loaded: ${ad.hashCode}');
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ Unique native ad failed to load: $error');
          ad.dispose();
        },
        onAdOpened: (ad) => print('📱 Unique native ad opened'),
        onAdClosed: (ad) => print('🔙 Unique native ad closed'),
        onAdClicked: (ad) {
          print('👆 Unique native ad clicked');
          _trackAdClick();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: const Color(0xFF8F66FF), // Purple theme
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: const Color(0xFF2D1B69), // Dark purple
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    );
  }

  // Load Bottom Banner Ad
  void _loadBottomBannerAd() {
    // Don't load ads if disabled for store submission
    if (_disableAdsForStore) {
      print('Bottom banner ads disabled for Play Store submission');
      return;
    }

    _bottomBannerAd = BannerAd(
      adUnitId: _bottomBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBottomBannerAdLoaded.value = true;
          print('Bottom banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          isBottomBannerAdLoaded.value = false;
          ad.dispose();
          print('Bottom banner ad failed to load: $error');

          // Retry after 30 seconds
          Future.delayed(const Duration(seconds: 30), () {
            _loadBottomBannerAd();
          });
        },
        onAdClicked: (ad) {
          _trackAdClick();
        },
      ),
    );
    _bottomBannerAd?.load();
  }

  // Interstitial Ad Methods
  void _loadInterstitialAd() {
    // Don't load ads if disabled for store submission
    if (_disableAdsForStore) {
      print('Interstitial ads disabled for Play Store submission');
      return;
    }

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          isInterstitialAdLoaded.value = true;

          // Remove immersive mode to ensure close button is always visible
          // _interstitialAd?.setImmersiveMode(true); // Commented out for family compliance
          print('Interstitial ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          isInterstitialAdLoaded.value = false;
          print('Interstitial ad failed to load: $error');

          // Retry after 60 seconds
          Future.delayed(const Duration(seconds: 60), () {
            _loadInterstitialAd();
          });
        },
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onAdClosed}) {
    // Don't show ads if disabled for store submission
    if (_disableAdsForStore) {
      onAdClosed?.call(); // Still call the callback
      return;
    }

    if (_isInterstitialShowing) {
      print('⚠️ Interstitial ad already showing, skipping...');
      onAdClosed?.call();
      return;
    }

    if (_interstitialAd != null && isInterstitialAdLoaded.value) {
      _isInterstitialShowing = true;
      print('📺 Showing interstitial ad...');

      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print('✅ Interstitial ad dismissed');
          ad.dispose();
          isInterstitialAdLoaded.value = false;
          _isInterstitialShowing = false;
          _lastInterstitialShowTime = DateTime.now();
          _loadInterstitialAd(); // Load next ad
          onAdClosed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('❌ Interstitial ad failed to show: $error');
          ad.dispose();
          isInterstitialAdLoaded.value = false;
          _isInterstitialShowing = false;
          _loadInterstitialAd();
        },
        onAdClicked: (ad) {
          _trackAdClick();
        },
        onAdShowedFullScreenContent: (ad) {
          print('📺 Interstitial ad showing full screen content');
        },
      );

      _interstitialAd?.show();
    } else {
      print('⚠️ Interstitial ad not ready to show');
      onAdClosed?.call();
    }
  }

  /// Check if enough time has passed to show interstitial ad
  bool shouldShowInterstitialAdByTime() {
    // Don't show if ads are disabled
    if (_disableAdsForStore) return false;

    // Don't show if already showing
    if (_isInterstitialShowing) return false;

    // Don't show if ad is not loaded
    if (!isInterstitialAdLoaded.value) return false;

    // Show interstitial ad every 3 minutes (family-friendly frequency)
    final timeSinceLastShow = DateTime.now().difference(_lastInterstitialShowTime);
    final timeSinceAppStart = DateTime.now().difference(_appStartTime);

    // Don't show in first 60 seconds of app start
    if (timeSinceAppStart.inSeconds < 60) {
      return false;
    }

    // Show every 3 minutes (180 seconds)
    return timeSinceLastShow.inSeconds >= 180;
  }

  /// Track screen navigation for showing interstitial ads
  void trackScreenNavigation() {
    _screenNavigationCount++;

    // Show interstitial ad every 5 screen navigations
    if (_screenNavigationCount % 5 == 0 && shouldShowInterstitialAdByTime()) {
      print('🎯 Auto-showing interstitial ad after 5 screen navigations');
      showInterstitialAd();
    }
  }

  /// Automatically show interstitial ad based on time
  void autoShowInterstitialAd() {
    if (shouldShowInterstitialAdByTime()) {
      print('⏰ Auto-showing interstitial ad based on time');
      showInterstitialAd();
    }
  }

  /// Start automatic interstitial ad timer
  void startAutoInterstitialTimer() {
    if (_disableAdsForStore) return;

    // Check every minute if we should show interstitial ad
    Future.delayed(const Duration(minutes: 1), () {
      if (shouldShowInterstitialAdByTime()) {
        autoShowInterstitialAd();
      }
      // Continue the timer
      startAutoInterstitialTimer();
    });
  }

  // Rewarded Ad Methods
  void _loadRewardedAd() {
    // Don't load ads if disabled for store submission
    if (_disableAdsForStore) {
      print('Rewarded ads disabled for Play Store submission');
      return;
    }

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          isRewardedAdLoaded.value = true;
          print('Rewarded ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          isRewardedAdLoaded.value = false;
          print('Rewarded ad failed to load: $error');

          // Retry after 90 seconds
          Future.delayed(const Duration(seconds: 90), () {
            _loadRewardedAd();
          });
        },
      ),
    );
  }

  void showRewardedAd({
    required OnUserEarnedRewardCallback onUserEarnedReward,
    VoidCallback? onAdClosed,
  }) {
    // Don't show ads if disabled for store submission
    if (_disableAdsForStore) {
      onAdClosed?.call(); // Still call the callback
      return;
    }

    if (_rewardedAd != null && isRewardedAdLoaded.value) {
      _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          isRewardedAdLoaded.value = false;
          _loadRewardedAd(); // Load next ad
          onAdClosed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          isRewardedAdLoaded.value = false;
          _loadRewardedAd();
          print('Rewarded ad failed to show: $error');
        },
        onAdClicked: (ad) {
          _trackAdClick();
        },
      );

      _rewardedAd?.show(onUserEarnedReward: onUserEarnedReward);
    } else {
      onAdClosed?.call();
    }
  }

  // Ad optimization methods
  void _trackAdClick() {
    adClickCount.value++;
    lastAdClickTime.value = DateTime.now();
  }

  bool shouldShowInterstitialAd() {
    // This method is kept for backward compatibility
    // Use shouldShowInterstitialAdByTime() for more control
    return shouldShowInterstitialAdByTime();
  }

  // Smart ad loading based on network conditions
  void optimizeAdLoading() {
    // Only load ads when on WiFi for better user experience
    // This can be integrated with your connectivity service
  }

  // Method to refresh banner ads - disposes old ones and creates new ones
  void refreshBannerAds() {
    // Dispose existing banner ads
    _bannerAd?.dispose();
    _bottomBannerAd?.dispose();

    // Reset loading states
    isBannerAdLoaded.value = false;
    isBottomBannerAdLoaded.value = false;

    // Load new banner ads
    _loadBannerAd();
    _loadBottomBannerAd();
  }

  @override
  void onClose() {
    _bannerAd?.dispose();
    _bottomBannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.onClose();
  }
}
