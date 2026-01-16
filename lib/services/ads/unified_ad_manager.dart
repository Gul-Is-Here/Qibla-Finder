import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ad_service.dart';
import 'inmobi_ad_service.dart';

/// Unified Ad Manager for Qibla Compass App
///
/// This service manages both AdMob and InMobi ads with intelligent fallback:
/// 1. Primary: AdMob (higher fill rate in most regions)
/// 2. Fallback: InMobi (when AdMob fails to load)
///
/// Features:
/// - Automatic fallback between ad networks
/// - Combined daily limit (3 interstitials per day total)
/// - Smart ad selection based on availability
class UnifiedAdManager extends GetxController {
  static UnifiedAdManager get instance => Get.find<UnifiedAdManager>();

  // Services
  late AdService _adMobService;
  InMobiAdService? _inMobiService;

  // State
  var isInitialized = false.obs;
  var lastAdNetwork = ''.obs; // 'admob' or 'inmobi'

  // Configuration
  /// Set to true to prefer InMobi over AdMob
  static const bool preferInMobi = false;

  /// Set to true to use only AdMob
  static const bool adMobOnly = false;

  /// Set to true to use only InMobi
  static const bool inMobiOnly = false;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  void _initialize() {
    // Get existing services
    try {
      _adMobService = AdService.instance;
    } catch (e) {
      print('⚠️ AdMob service not found');
    }

    try {
      _inMobiService = InMobiAdService.instance;
    } catch (e) {
      print('⚠️ InMobi service not found');
    }

    isInitialized.value = true;
    print('✅ UnifiedAdManager initialized');
    print('   - AdMob: ${!AdService.areAdsDisabled}');
    print('   - InMobi: ${_inMobiService != null && !InMobiAdService.areAdsDisabled}');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INTERSTITIAL AD METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Check if any interstitial is ready
  bool isInterstitialReady() {
    if (adMobOnly) {
      return _adMobService.isInterstitialAdLoaded.value;
    }

    if (inMobiOnly) {
      return _inMobiService?.isInterstitialReady() ?? false;
    }

    return _adMobService.isInterstitialAdLoaded.value ||
        (_inMobiService?.isInterstitialReady() ?? false);
  }

  /// Show interstitial ad with automatic fallback
  /// Returns true if ad was shown
  Future<bool> showInterstitialAd({VoidCallback? onAdClosed}) async {
    bool shown = false;

    // Determine primary network
    bool useInMobiFirst = preferInMobi || inMobiOnly;

    if (inMobiOnly) {
      // Only InMobi
      shown = await _tryShowInMobiInterstitial(onAdClosed);
    } else if (adMobOnly) {
      // Only AdMob
      _tryShowAdMobInterstitial(onAdClosed);
      shown = _adMobService.isInterstitialAdLoaded.value;
    } else if (useInMobiFirst) {
      // Try InMobi first, fallback to AdMob
      shown = await _tryShowInMobiInterstitial(onAdClosed);
      if (!shown) {
        _tryShowAdMobInterstitial(onAdClosed);
        shown = _adMobService.isInterstitialAdLoaded.value;
      }
    } else {
      // Try AdMob first (default), fallback to InMobi
      if (_adMobService.isInterstitialAdLoaded.value) {
        _tryShowAdMobInterstitial(onAdClosed);
        shown = true;
      } else {
        shown = await _tryShowInMobiInterstitial(onAdClosed);
      }
    }

    if (!shown) {
      onAdClosed?.call();
    }

    return shown;
  }

  void _tryShowAdMobInterstitial(VoidCallback? onAdClosed) {
    if (!AdService.areAdsDisabled && _adMobService.isInterstitialAdLoaded.value) {
      lastAdNetwork.value = 'admob';
      print('📺 Showing AdMob interstitial');
      _adMobService.showInterstitialAd(onAdClosed: onAdClosed);
    }
  }

  Future<bool> _tryShowInMobiInterstitial(VoidCallback? onAdClosed) async {
    if (_inMobiService != null && !InMobiAdService.areAdsDisabled) {
      final shown = await _inMobiService!.showInterstitialAd(onAdClosed: onAdClosed);
      if (shown) {
        lastAdNetwork.value = 'inmobi';
        print('📺 Showing InMobi interstitial');
      }
      return shown;
    }
    return false;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BANNER AD METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Get AdMob banner ad (InMobi banner requires native view integration)
  get bannerAd => _adMobService.bannerAd;

  /// Get AdMob bottom banner ad
  get bottomBannerAd => _adMobService.bottomBannerAd;

  /// Check if banner is loaded
  bool get isBannerLoaded => _adMobService.isBannerAdLoaded.value;

  // ══════════════════════════════════════════════════════════════════════════
  // NATIVE AD METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Create unique native ad (AdMob only for now)
  createUniqueNativeAd({String? customKey}) {
    return _adMobService.createUniqueNativeAd(customKey: customKey);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STATUS & DEBUG
  // ══════════════════════════════════════════════════════════════════════════

  /// Get combined status info
  Map<String, dynamic> getStatus() {
    return {
      'admob': {
        'enabled': !AdService.areAdsDisabled,
        'interstitialLoaded': _adMobService.isInterstitialAdLoaded.value,
        'bannerLoaded': _adMobService.isBannerAdLoaded.value,
      },
      'inmobi': {
        'enabled': _inMobiService != null && !InMobiAdService.areAdsDisabled,
        'initialized': _inMobiService?.isInitialized.value ?? false,
        'interstitialLoaded': _inMobiService?.isInterstitialLoaded.value ?? false,
      },
      'lastAdNetwork': lastAdNetwork.value,
      'anyInterstitialReady': isInterstitialReady(),
    };
  }

  /// Print debug status
  void printDebugStatus() {
    final status = getStatus();
    print('═══════════════════════════════════════════════════════════');
    print('📊 UNIFIED AD MANAGER STATUS');
    print('═══════════════════════════════════════════════════════════');
    print('AdMob:');
    print('  - Enabled: ${status['admob']['enabled']}');
    print('  - Interstitial Loaded: ${status['admob']['interstitialLoaded']}');
    print('  - Banner Loaded: ${status['admob']['bannerLoaded']}');
    print('InMobi:');
    print('  - Enabled: ${status['inmobi']['enabled']}');
    print('  - Initialized: ${status['inmobi']['initialized']}');
    print('  - Interstitial Loaded: ${status['inmobi']['interstitialLoaded']}');
    print('Last Ad Network Used: ${status['lastAdNetwork']}');
    print('Any Interstitial Ready: ${status['anyInterstitialReady']}');
    print('═══════════════════════════════════════════════════════════');
  }
}
