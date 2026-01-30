import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// InMobi Ad Service for Qibla Compass App
///
/// Account ID: 9f55f3fd055c4688acd6d882a07523d9
/// Banner Placement ID: 10000592528
/// Interstitial Placement ID: 10000592527
///
/// This service integrates InMobi ads alongside existing AdMob ads
/// to provide fallback monetization and increased fill rates.
class InMobiAdService extends GetxController {
  static InMobiAdService get instance => Get.find<InMobiAdService>();

  // ══════════════════════════════════════════════════════════════════════════
  // INMOBI CONFIGURATION
  // ══════════════════════════════════════════════════════════════════════════

  /// InMobi Account ID
  static const String accountId = '9f55f3fd055c4688acd6d882a07523d9';

  /// Placement IDs
  static const String interstitialPlacementId = '10000592527';
  static const String bannerPlacementId = '10000592528';

  // TODO: Add these placement IDs when you create them in InMobi dashboard
  // static const String nativePlacementId = 'YOUR_NATIVE_PLACEMENT_ID';
  // static const String rewardedPlacementId = 'YOUR_REWARDED_PLACEMENT_ID';

  // ══════════════════════════════════════════════════════════════════════════
  // DISABLE/ENABLE FLAG
  // ══════════════════════════════════════════════════════════════════════════

  /// Set to TRUE to disable InMobi ads (for testing or store review)
  /// Set to FALSE to enable InMobi ads for production
  ///
  /// NOTE: InMobi placements can take 24-48 hours to become active.
  /// If you see "internal error", wait for placement activation or use test mode.
  /// Set to TRUE temporarily until your placement is approved and active.
  static const bool _disableInMobiAds = false; // ENABLED - InMobi ads active for production

  /// Check if InMobi ads are disabled
  static bool get areAdsDisabled => _disableInMobiAds;

  // ══════════════════════════════════════════════════════════════════════════
  // METHOD CHANNEL FOR NATIVE COMMUNICATION
  // ══════════════════════════════════════════════════════════════════════════

  static const MethodChannel _channel = MethodChannel('com.qibla_compass_offline.app/inmobi');

  // ══════════════════════════════════════════════════════════════════════════
  // AD STATES
  // ══════════════════════════════════════════════════════════════════════════

  var isInitialized = false.obs;
  var isInterstitialLoaded = false.obs;
  var isBannerLoaded = false.obs;
  var isNativeLoaded = false.obs;
  var isRewardedLoaded = false.obs;

  /// Track if interstitial is currently showing
  bool _isInterstitialShowing = false;

  /// Last time interstitial was shown
  DateTime _lastInterstitialShowTime = DateTime.now().subtract(const Duration(minutes: 5));

  // ══════════════════════════════════════════════════════════════════════════
  // DAILY AD LIMIT (Shared with AdMob - 3 total per day)
  // ══════════════════════════════════════════════════════════════════════════

  final GetStorage _storage = GetStorage();
  static const String _keyInMobiAdCount = 'inmobi_daily_interstitial_count';
  static const String _keyInMobiLastResetDate = 'inmobi_last_ad_reset_date';
  static const int _maxInterstitialAdsPerDay = 3;
  static const int _resetHour = 5; // 5 AM reset time

  // ══════════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ══════════════════════════════════════════════════════════════════════════

  @override
  void onInit() {
    super.onInit();
    _checkAndResetDailyLimit();
    _initializeInMobi();
    _setupMethodChannelHandler();
  }

  /// Initialize InMobi SDK
  Future<void> _initializeInMobi() async {
    if (_disableInMobiAds) {
      return;
    }

    if (!Platform.isAndroid) {
      return;
    }

    try {
      final result = await _channel.invokeMethod('initialize', {'accountId': accountId});

      if (result == true) {
        isInitialized.value = true;

        // Preload interstitial ad
        await _loadInterstitialAd();
      }
    } on PlatformException catch (_) {
      // Initialization failed silently
    } catch (_) {
      // Initialization failed silently
    }
  }

  /// Setup method channel handler for callbacks from native
  void _setupMethodChannelHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onInterstitialLoaded':
          isInterstitialLoaded.value = true;
          break;

        case 'onInterstitialLoadFailed':
          isInterstitialLoaded.value = false;
          // Retry after delay
          Future.delayed(const Duration(seconds: 60), _loadInterstitialAd);
          break;

        case 'onInterstitialShown':
          _isInterstitialShowing = true;
          _incrementDailyAdCount();
          break;

        case 'onInterstitialClicked':
          break;

        case 'onInterstitialDismissed':
          _isInterstitialShowing = false;
          isInterstitialLoaded.value = false;
          _lastInterstitialShowTime = DateTime.now();
          // Preload next ad
          Future.delayed(const Duration(seconds: 5), _loadInterstitialAd);
          break;

        case 'onBannerLoaded':
          isBannerLoaded.value = true;
          break;

        case 'onBannerLoadFailed':
          isBannerLoaded.value = false;
          break;

        case 'onRewardedLoaded':
          isRewardedLoaded.value = true;
          break;

        case 'onRewardedLoadFailed':
          isRewardedLoaded.value = false;
          break;

        case 'onRewardedCompleted':
          break;
      }
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INTERSTITIAL AD METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Load interstitial ad
  Future<void> _loadInterstitialAd() async {
    if (_disableInMobiAds || !isInitialized.value) return;

    try {
      await _channel.invokeMethod('loadInterstitial', {'placementId': interstitialPlacementId});
    } on PlatformException catch (_) {
      // Load failed silently
    }
  }

  /// Show interstitial ad
  /// Returns true if ad was shown, false otherwise
  Future<bool> showInterstitialAd({VoidCallback? onAdClosed}) async {
    if (_disableInMobiAds) {
      onAdClosed?.call();
      return false;
    }

    // Check daily limit
    if (!_canShowAd()) {
      onAdClosed?.call();
      return false;
    }

    // Check if already showing
    if (_isInterstitialShowing) {
      onAdClosed?.call();
      return false;
    }

    // Check minimum interval (2 minutes between ads)
    final timeSinceLastAd = DateTime.now().difference(_lastInterstitialShowTime);
    if (timeSinceLastAd.inMinutes < 2) {
      onAdClosed?.call();
      return false;
    }

    // Check if loaded
    if (!isInterstitialLoaded.value) {
      _loadInterstitialAd(); // Try to load
      onAdClosed?.call();
      return false;
    }

    try {
      final result = await _channel.invokeMethod('showInterstitial');

      if (result == true) {
        // Wait for dismissal callback, then call onAdClosed
        Future.delayed(const Duration(seconds: 30), () {
          if (!_isInterstitialShowing) {
            onAdClosed?.call();
          }
        });

        return true;
      } else {
        onAdClosed?.call();
        return false;
      }
    } on PlatformException catch (_) {
      onAdClosed?.call();
      return false;
    }
  }

  /// Check if interstitial is ready to show
  bool isInterstitialReady() {
    return isInitialized.value &&
        isInterstitialLoaded.value &&
        !_isInterstitialShowing &&
        _canShowAd();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DAILY LIMIT MANAGEMENT
  // ══════════════════════════════════════════════════════════════════════════

  /// Check and reset daily limit at 5 AM
  void _checkAndResetDailyLimit() {
    final now = DateTime.now();
    final lastResetDateStr = _storage.read<String>(_keyInMobiLastResetDate);

    if (lastResetDateStr == null) {
      _storage.write(_keyInMobiAdCount, 0);
      _storage.write(_keyInMobiLastResetDate, _getResetDateKey(now));
      print('🔄 InMobi: Initialized daily ad limit tracker');
      return;
    }

    final currentResetKey = _getResetDateKey(now);

    if (lastResetDateStr != currentResetKey) {
      _storage.write(_keyInMobiAdCount, 0);
      _storage.write(_keyInMobiLastResetDate, currentResetKey);
      print('🔄 InMobi: Daily ad count reset');
    }
  }

  /// Get reset date key (changes at 5 AM)
  String _getResetDateKey(DateTime date) {
    DateTime effectiveDate = date;
    if (date.hour < _resetHour) {
      effectiveDate = date.subtract(const Duration(days: 1));
    }
    return '${effectiveDate.year}-${effectiveDate.month}-${effectiveDate.day}';
  }

  /// Check if can show more ads today
  bool _canShowAd() {
    _checkAndResetDailyLimit();
    final currentCount = _storage.read<int>(_keyInMobiAdCount) ?? 0;
    return currentCount < _maxInterstitialAdsPerDay;
  }

  /// Increment daily ad count
  void _incrementDailyAdCount() {
    final currentCount = _storage.read<int>(_keyInMobiAdCount) ?? 0;
    _storage.write(_keyInMobiAdCount, currentCount + 1);
    print('📊 InMobi: Daily ad count: ${currentCount + 1}/$_maxInterstitialAdsPerDay');
  }

  /// Get remaining ads for today
  int getRemainingAdsToday() {
    _checkAndResetDailyLimit();
    final currentCount = _storage.read<int>(_keyInMobiAdCount) ?? 0;
    return (_maxInterstitialAdsPerDay - currentCount).clamp(0, _maxInterstitialAdsPerDay);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BANNER AD METHODS (For future use when you add Banner placement)
  // ══════════════════════════════════════════════════════════════════════════

  /// Load banner ad
  /// Note: Requires banner placement ID to be configured
  Future<void> loadBannerAd(String placementId) async {
    if (_disableInMobiAds || !isInitialized.value) return;

    try {
      await _channel.invokeMethod('loadBanner', {'placementId': placementId});
    } on PlatformException catch (e) {
      print('❌ Error loading InMobi Banner: ${e.message}');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REWARDED AD METHODS (For future use when you add Rewarded placement)
  // ══════════════════════════════════════════════════════════════════════════

  /// Load rewarded ad
  /// Note: Requires rewarded placement ID to be configured
  Future<void> loadRewardedAd(String placementId) async {
    if (_disableInMobiAds || !isInitialized.value) return;

    try {
      await _channel.invokeMethod('loadRewarded', {'placementId': placementId});
    } on PlatformException catch (e) {
      print('❌ Error loading InMobi Rewarded: ${e.message}');
    }
  }

  /// Show rewarded ad
  Future<bool> showRewardedAd({VoidCallback? onRewarded, VoidCallback? onAdClosed}) async {
    if (_disableInMobiAds || !isRewardedLoaded.value) {
      onAdClosed?.call();
      return false;
    }

    try {
      final result = await _channel.invokeMethod('showRewarded');
      if (result == true) {
        return true;
      }
    } on PlatformException catch (e) {
      print('❌ Error showing InMobi Rewarded: ${e.message}');
    }

    onAdClosed?.call();
    return false;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ══════════════════════════════════════════════════════════════════════════

  @override
  void onClose() {
    _disposeAllAds();
    super.onClose();
  }

  Future<void> _disposeAllAds() async {
    try {
      await _channel.invokeMethod('dispose');
    } catch (e) {
      print('Error disposing InMobi ads: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DEBUG INFO
  // ══════════════════════════════════════════════════════════════════════════

  /// Get debug info for troubleshooting
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': isInitialized.value,
      'isInterstitialLoaded': isInterstitialLoaded.value,
      'isInterstitialShowing': _isInterstitialShowing,
      'remainingAdsToday': getRemainingAdsToday(),
      'accountId': accountId,
      'interstitialPlacementId': interstitialPlacementId,
      'adsDisabled': _disableInMobiAds,
    };
  }
}
