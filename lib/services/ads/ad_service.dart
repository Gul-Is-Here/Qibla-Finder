import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../subscription_service.dart';
import 'ironsource_ad_service.dart';

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

  // Last loaded ad source info (for testing/debugging)
  final lastInterstitialSource = ''.obs;
  final lastBannerSource = ''.obs;

  // Ad click tracking for optimization
  var adClickCount = 0.obs;
  var lastAdClickTime = DateTime.now().obs;

  // Automatic interstitial ad showing
  DateTime _lastInterstitialShowTime = DateTime.now();
  final DateTime _appStartTime = DateTime.now();
  int _screenNavigationCount = 0;
  bool _isInterstitialShowing = false;
  Timer? _autoInterstitialTimer;
  Timer? _bannerRetryTimer;
  Timer? _bottomBannerRetryTimer;
  Timer? _interstitialRetryTimer;
  Timer? _rewardedRetryTimer;

  // Daily interstitial ad limit (3 per day, reset at 5 AM)
  final GetStorage _storage = GetStorage();
  static const int _maxInterstitialAdsPerDay = 3;
  static const int _resetHour = 5; // 5 AM reset time
  final bool _dailyLimitCheckedThisMinute = false;
  DateTime? _lastDailyLimitCheck;

  // Storage keys
  static const String _keyAdCount = 'daily_interstitial_count';
  static const String _keyLastResetDate = 'last_ad_reset_date';

  @override
  Future<void> onInit() async {
    super.onInit();
    _checkAndResetDailyLimit();
    await _initializeAds();
  }

  Future<void> _initializeAds() async {
    try {
      // Skip MobileAds.instance.initialize() — already called in main.dart
      // Just configure request settings
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
          tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
          testDeviceIds: [],
        ),
      );

      print('✅ Mobile Ads SDK configured');

      // Load ads with staggered delays to avoid blocking the main thread
      _loadBannerAd();

      _bottomBannerRetryTimer = Timer(const Duration(seconds: 3), () {
        _loadBottomBannerAd();
      });

      _interstitialRetryTimer = Timer(const Duration(seconds: 5), () {
        _loadInterstitialAd();
      });

      _rewardedRetryTimer = Timer(const Duration(seconds: 8), () {
        _loadRewardedAd();
      });

      // Start automatic interstitial ad timer (single periodic timer, not recursive)
      print('🚀 Starting automatic interstitial ad timer');
      startAutoInterstitialTimer();
    } catch (e) {
      print('❌ Error initializing ads: $e');
    }
  }

  // Banner Ad Methods
  void _loadBannerAd() {
    // Don't load ads if disabled for store submission
    if (_disableAdsForStore) {
      print('Ads disabled for Play Store submission');
      return;
    }

    // Check if user has premium subscription
    if (_isPremiumUser()) {
      print('⭐ User is premium - skipping banner ad');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBannerAdLoaded.value = true;
          // Extract ad source/network info
          final info = ad.responseInfo;
          final loaded = info?.loadedAdapterResponseInfo;
          lastBannerSource.value = loaded?.adSourceName ?? 'unknown';
          print(
            '✅ Banner ad loaded | source: ${lastBannerSource.value} | adapter: ${info?.mediationAdapterClassName ?? "—"}',
          );
        },
        onAdFailedToLoad: (ad, error) {
          isBannerAdLoaded.value = false;
          ad.dispose();

          // More specific error handling
          if (error.code == 3) {
            print(
              'ℹ️ Banner ad: No fill available (error code 3) - This is normal when no ads are available',
            );
          } else {
            print('❌ Banner ad failed to load: ${error.message} (code: ${error.code})');
          }

          // Retry with exponential backoff — cancel previous timer to avoid stacking
          final retryDelay = _bannerAd == null ? 30 : 60;
          _bannerRetryTimer?.cancel();
          _bannerRetryTimer = Timer(Duration(seconds: retryDelay), () {
            if (!isBannerAdLoaded.value) {
              _loadBannerAd();
            }
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
  BannerAd? createUniqueBannerAd({
    String? customKey,
    VoidCallback? onAdLoaded,
    VoidCallback? onAdFailed,
  }) {
    if (_disableAdsForStore) {
      return null;
    }

    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('✅ AdMob banner loaded: ${ad.hashCode}');
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ AdMob banner failed to load: $error');
          ad.dispose();
          onAdFailed?.call();
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

    // Check if user has premium subscription
    if (_isPremiumUser()) {
      print('⭐ User is premium - skipping bottom banner ad');
      return;
    }

    _bottomBannerAd = BannerAd(
      adUnitId: _bottomBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isBottomBannerAdLoaded.value = true;
          print('✅ Bottom banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          isBottomBannerAdLoaded.value = false;
          ad.dispose();

          // More specific error handling
          if (error.code == 3) {
            print(
              'ℹ️ Bottom banner ad: No fill/HTTP 403 (error code 3) - Common when testing or low ad inventory',
            );
          } else {
            print('❌ Bottom banner ad failed: ${error.message} (code: ${error.code})');
          }

          // Retry with longer delay for 403 errors — cancel previous timer
          final retryDelay = error.code == 3 ? 60 : 30;
          _bottomBannerRetryTimer?.cancel();
          _bottomBannerRetryTimer = Timer(Duration(seconds: retryDelay), () {
            if (!isBottomBannerAdLoaded.value) {
              _loadBottomBannerAd();
            }
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

    // Check if user has premium subscription
    if (_isPremiumUser()) {
      print('⭐ User is premium - skipping interstitial ad');
      return;
    }

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          isInterstitialAdLoaded.value = true;

          // Extract ad source/network info
          final info = ad.responseInfo;
          final loaded = info?.loadedAdapterResponseInfo;
          lastInterstitialSource.value = loaded?.adSourceName ?? 'unknown';
          print(
            '✅ Interstitial ad loaded | source: ${lastInterstitialSource.value} | adapter: ${info?.mediationAdapterClassName ?? "—"}',
          );

          // Remove immersive mode to ensure close button is always visible
          // _interstitialAd?.setImmersiveMode(true); // Commented out for family compliance
          print('✅ Interstitial ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          isInterstitialAdLoaded.value = false;

          // Better error logging with specific messages
          if (error.message.contains('InMobi')) {
            print('ℹ️ InMobi Interstitial load failed: ${error.message}');
            print('   This is normal if InMobi mediation is not configured or has issues');
          } else if (error.code == 3) {
            print('ℹ️ Interstitial: No fill available (code 3) - AdMob will try again');
          } else {
            print('❌ Interstitial load failed: ${error.message} (code: ${error.code})');
          }

          // Retry with longer delay — cancel previous timer to prevent stacking
          final retryDelay = error.message.contains('InMobi') ? 120 : 60;
          _interstitialRetryTimer?.cancel();
          _interstitialRetryTimer = Timer(Duration(seconds: retryDelay), () {
            if (!isInterstitialAdLoaded.value) {
              _loadInterstitialAd();
            }
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

    // Check if user has premium subscription
    if (_isPremiumUser()) {
      print('⭐ User is premium - skipping interstitial ad');
      onAdClosed?.call();
      return;
    }

    // Check daily limit (3 ads per day)
    if (_hasReachedDailyLimit()) {
      print('⛔ Daily interstitial ad limit reached (3/3). Skipping ad.');
      _showNoMoreAdsDialog();
      onAdClosed?.call();
      return;
    }

    if (_isInterstitialShowing) {
      print('⚠️ Interstitial ad already showing, skipping...');
      onAdClosed?.call();
      return;
    }

    // Priority 1: AdMob interstitial FIRST
    if (_interstitialAd != null && isInterstitialAdLoaded.value) {
      _isInterstitialShowing = true;
      print('📺 Showing AdMob interstitial (primary)...');

      _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print('✅ AdMob interstitial dismissed');
          ad.dispose();
          isInterstitialAdLoaded.value = false;
          _isInterstitialShowing = false;
          _lastInterstitialShowTime = DateTime.now();
          _incrementDailyAdCount();
          _showAdCompletedDialog();
          _loadInterstitialAd();
          onAdClosed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('❌ AdMob interstitial failed to show: $error');
          ad.dispose();
          isInterstitialAdLoaded.value = false;
          _isInterstitialShowing = false;
          _loadInterstitialAd();
          onAdClosed?.call();
        },
        onAdClicked: (ad) {
          _trackAdClick();
        },
        onAdShowedFullScreenContent: (ad) {
          print('📺 AdMob interstitial showing full screen content');
        },
      );

      _interstitialAd?.show();
      return;
    }

    // Priority 2: IronSource interstitial FALLBACK
    if (Get.isRegistered<IronSourceAdService>()) {
      final ironSource = Get.find<IronSourceAdService>();
      if (ironSource.isInterstitialReady) {
        _isInterstitialShowing = true;
        print('📺 Showing IronSource interstitial (fallback)...');
        ironSource.showInterstitial(
          onClosed: () {
            _isInterstitialShowing = false;
            _lastInterstitialShowTime = DateTime.now();
            _incrementDailyAdCount();
            _showAdCompletedDialog();
            onAdClosed?.call();
          },
        );
        return;
      }
    }

    // Neither ready — pre-load both for next time
    print('⚠️ No interstitial ready (AdMob & IronSource both unavailable)');
    _loadInterstitialAd();
    if (Get.isRegistered<IronSourceAdService>()) {
      Get.find<IronSourceAdService>().loadInterstitial();
    }
    onAdClosed?.call();
  }

  /// Show beautiful dialog after ad completion
  void _showAdCompletedDialog() {
    final currentCount = _storage.read<int>(_keyAdCount) ?? 0;
    final remaining = _maxInterstitialAdsPerDay - currentCount;

    if (remaining <= 0) {
      // Show congratulations - no more ads!
      _showNoMoreAdsDialog();
    } else {
      // Show ad completed dialog with remaining count
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF8F66FF), Color(0xFF6B4EE6)]),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.check_circle, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 20),
              const Text(
                'Thank You! 🤲',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1B69),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your support helps keep this app free for the Ummah.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF8F66FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF8F66FF), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '$remaining ad${remaining == 1 ? '' : 's'} remaining today',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8F66FF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8F66FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: true,
      );
    }
  }

  /// Show congratulations dialog - no more ads for today!
  void _showNoMoreAdsDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.celebration, color: Colors.white, size: 56),
            ),
            const SizedBox(height: 24),
            const Text(
              '🎉 Congratulations! 🎉',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D1B69)),
            ),
            const SizedBox(height: 12),
            const Text(
              'No More Ads Today!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 16),
            Text(
              'You\'ve watched all 3 ads for today. Enjoy ad-free browsing until tomorrow!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('🌙', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'JazakAllah Khair!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D1B69),
                          ),
                        ),
                        Text(
                          'Resets at 5:00 AM',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Alhamdulillah! ✨',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  /// Check and reset daily interstitial ad limit at 5 AM
  void _checkAndResetDailyLimit() {
    final now = DateTime.now();
    final lastResetDateStr = _storage.read<String>(_keyLastResetDate);

    if (lastResetDateStr == null) {
      // First time - initialize
      _storage.write(_keyAdCount, 0);
      _storage.write(_keyLastResetDate, _getResetDateKey(now));
      print('🔄 Initialized daily ad limit tracker');
      return;
    }

    final lastResetDate = DateTime.parse(lastResetDateStr);

    // Calculate today's 5 AM reset time
    final todayResetTime = DateTime(now.year, now.month, now.day, _resetHour, 0, 0);

    // Calculate last reset date's 5 AM
    final lastResetDateTime = DateTime(
      lastResetDate.year,
      lastResetDate.month,
      lastResetDate.day,
      _resetHour,
      0,
      0,
    );

    // Check if we've passed a 5 AM since the last reset
    // Reset if: current time is after today's 5 AM AND last reset was before today's 5 AM
    if (now.isAfter(todayResetTime) && lastResetDateTime.isBefore(todayResetTime)) {
      _storage.write(_keyAdCount, 0);
      _storage.write(_keyLastResetDate, _getResetDateKey(now));
      print(
        '🔄 Daily ad limit reset at ${now.hour}:${now.minute.toString().padLeft(2, '0')} - Count: 0/$_maxInterstitialAdsPerDay',
      );
    } else {
      final currentCount = _storage.read<int>(_keyAdCount) ?? 0;
      print(
        '📊 Current daily ad count: $currentCount/$_maxInterstitialAdsPerDay (Next reset: ${_getNextResetTimeFormatted(now)})',
      );
    }
  }

  /// Get formatted next reset time for display
  String _getNextResetTimeFormatted(DateTime now) {
    final todayReset = DateTime(now.year, now.month, now.day, _resetHour, 0, 0);

    if (now.isBefore(todayReset)) {
      return 'Today at 5:00 AM';
    } else {
      return 'Tomorrow at 5:00 AM';
    }
  }

  /// Get a date key for storage (format: YYYY-MM-DD)
  String _getResetDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Check if daily interstitial ad limit has been reached
  /// Throttled — only re-checks storage once per minute
  bool _hasReachedDailyLimit() {
    final now = DateTime.now();
    // Only re-check storage at most once per minute to reduce I/O
    if (_lastDailyLimitCheck == null || now.difference(_lastDailyLimitCheck!).inSeconds >= 60) {
      _checkAndResetDailyLimit();
      _lastDailyLimitCheck = now;
    }
    final currentCount = _storage.read<int>(_keyAdCount) ?? 0;
    return currentCount >= _maxInterstitialAdsPerDay;
  }

  /// Increment daily interstitial ad count (no redundant reset check)
  void _incrementDailyAdCount() {
    final currentCount = _storage.read<int>(_keyAdCount) ?? 0;
    final newCount = currentCount + 1;
    _storage.write(_keyAdCount, newCount);
    _lastDailyLimitCheck = null; // Force re-check next time
    print('📈 Daily ad count increased: $newCount/$_maxInterstitialAdsPerDay');
  }

  /// Get remaining interstitial ads for today
  int getRemainingAdsToday() {
    _checkAndResetDailyLimit();
    final currentCount = _storage.read<int>(_keyAdCount) ?? 0;
    return (_maxInterstitialAdsPerDay - currentCount).clamp(0, _maxInterstitialAdsPerDay);
  }

  /// Check if enough time has passed to show interstitial ad
  bool shouldShowInterstitialAdByTime() {
    // Don't show if ads are disabled
    if (_disableAdsForStore) return false;

    // Don't show if daily limit reached
    if (_hasReachedDailyLimit()) {
      print('⛔ Daily interstitial ad limit reached (3/3). Will reset at 5:00 AM.');
      return false;
    }

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

  /// Start automatic interstitial ad timer — uses a single periodic Timer
  void startAutoInterstitialTimer() {
    if (_disableAdsForStore) return;

    // Cancel any existing timer to prevent duplicates
    _autoInterstitialTimer?.cancel();

    // Single periodic timer — checks every 60 seconds
    _autoInterstitialTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (shouldShowInterstitialAdByTime()) {
        autoShowInterstitialAd();
      }
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

          // Retry after 90 seconds — cancel previous timer
          _rewardedRetryTimer?.cancel();
          _rewardedRetryTimer = Timer(const Duration(seconds: 90), () {
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

  // Cleanup method for explicit resource disposal
  void disposeAds() {
    print('🗑️ Disposing AdService ads...');

    // Cancel all retry/auto timers to prevent orphaned callbacks
    _autoInterstitialTimer?.cancel();
    _autoInterstitialTimer = null;
    _bannerRetryTimer?.cancel();
    _bannerRetryTimer = null;
    _bottomBannerRetryTimer?.cancel();
    _bottomBannerRetryTimer = null;
    _interstitialRetryTimer?.cancel();
    _interstitialRetryTimer = null;
    _rewardedRetryTimer?.cancel();
    _rewardedRetryTimer = null;

    _bannerAd?.dispose();
    _bannerAd = null;

    _bottomBannerAd?.dispose();
    _bottomBannerAd = null;

    _interstitialAd?.dispose();
    _interstitialAd = null;

    _rewardedAd?.dispose();
    _rewardedAd = null;

    // Reset states
    isBannerAdLoaded.value = false;
    isBottomBannerAdLoaded.value = false;
    isInterstitialAdLoaded.value = false;
    isRewardedAdLoaded.value = false;

    print('✅ AdService disposed - all ads and timers cleaned up');
  }

  // Helper method to check if user is premium
  bool _isPremiumUser() {
    try {
      final subscriptionService = Get.find<SubscriptionService>();
      return subscriptionService.isPremium;
    } catch (e) {
      // Subscription service not initialized or not found
      return false;
    }
  }

  @override
  void onClose() {
    disposeAds();
    super.onClose();
  }
}
