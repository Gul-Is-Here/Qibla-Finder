import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';
import '../../core/utils/logger.dart';

/// IronSource / LevelPlay Ad Service for Qibla Compass App
///
/// Interstitial Ad Unit ID: r22jb5cewizo6unh
/// Banner Ad Unit ID: 0hg7dbqqoq82y7i0
///
/// This service integrates IronSource LevelPlay ads for
/// interstitial and banner ad formats.
class IronSourceAdService extends GetxService implements LevelPlayInitListener {
  static IronSourceAdService get instance => Get.find<IronSourceAdService>();

  // ══════════════════════════════════════════════════════════════════════════
  // 🔑 APP KEY - Replace with your actual IronSource App Key
  // ══════════════════════════════════════════════════════════════════════════
  static const String _androidAppKey = '2501b1cd5';
  static const String _iosAppKey = '252ace6cd';

  // ══════════════════════════════════════════════════════════════════════════
  // 📊 AD UNIT IDS (LevelPlay) - Platform specific
  // ══════════════════════════════════════════════════════════════════════════
  // Android
  static const String _androidInterstitialAdUnitId = 'r22jb5cewizo6unh';
  static const String _androidBannerAdUnitId = '0hg7dbqqoq82y7i0';
  // iOS
  static const String _iosInterstitialAdUnitId = 'wj0qcv1o5mwey3u4';
  static const String _iosBannerAdUnitId = 'j5xzwe80lnwpkxge';

  static String get _interstitialAdUnitId =>
      Platform.isAndroid ? _androidInterstitialAdUnitId : _iosInterstitialAdUnitId;
  static String get _bannerAdUnitId =>
      Platform.isAndroid ? _androidBannerAdUnitId : _iosBannerAdUnitId;

  /// Public getter for banner ad unit ID (used by banner widgets)
  static String get bannerAdUnitId => _bannerAdUnitId;

  // ══════════════════════════════════════════════════════════════════════════
  // 📦 STATE
  // ══════════════════════════════════════════════════════════════════════════
  final _isInitialized = false.obs;
  final _isInterstitialReady = false.obs;
  final _isBannerLoaded = false.obs;

  // Last loaded ad source info (from ImpressionData)
  final lastInterstitialAdInfo = Rxn<LevelPlayAdInfo>();
  final lastBannerAdInfo = Rxn<LevelPlayAdInfo>();

  bool get isInitialized => _isInitialized.value;
  bool get isInterstitialReady => _isInterstitialReady.value;
  bool get isBannerLoaded => _isBannerLoaded.value;

  LevelPlayInterstitialAd? _interstitialAd;

  // Callbacks
  VoidCallback? _onInterstitialClosed;

  // ══════════════════════════════════════════════════════════════════════════
  // 🚀 INITIALIZATION
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> initialize() async {
    try {
      final appKey = Platform.isAndroid ? _androidAppKey : _iosAppKey;

      // Set consent (GDPR)
      await LevelPlay.setConsent(true);

      // Enable debug mode for adapters
      await LevelPlay.setAdaptersDebug(true);

      // Initialize LevelPlay (official SDK pattern - no legacyAdFormats)
      final initRequest = LevelPlayInitRequest.builder(appKey).build();

      await LevelPlay.init(initRequest: initRequest, initListener: this);

      Logger.log('🟡 IronSource initialization started', tag: 'IRONSOURCE');
    } on PlatformException catch (e) {
      Logger.error('❌ IronSource init platform error', tag: 'IRONSOURCE', error: e);
    } catch (e, stackTrace) {
      Logger.error('❌ IronSource init failed', tag: 'IRONSOURCE', error: e, stackTrace: stackTrace);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📡 INIT LISTENER
  // ══════════════════════════════════════════════════════════════════════════

  @override
  void onInitSuccess(LevelPlayConfiguration configuration) {
    _isInitialized.value = true;
    Logger.log(
      '✅ IronSource initialized | isAdQualityEnabled: ${configuration.isAdQualityEnabled}',
      tag: 'IRONSOURCE',
    );

    // Pre-load interstitial after initialization
    loadInterstitial();
  }

  @override
  void onInitFailed(LevelPlayInitError error) {
    Logger.error('❌ IronSource init failed: ${error.errorMessage}', tag: 'IRONSOURCE');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🎯 INTERSTITIAL ADS
  // ══════════════════════════════════════════════════════════════════════════

  void loadInterstitial() {
    if (!_isInitialized.value) return;

    _interstitialAd?.dispose();
    _interstitialAd = LevelPlayInterstitialAd(adUnitId: _interstitialAdUnitId);
    _interstitialAd!.setListener(_InterstitialListener(this));
    _interstitialAd!.loadAd();

    Logger.log('📥 Loading interstitial ad...', tag: 'IRONSOURCE');
  }

  Future<bool> showInterstitial({VoidCallback? onClosed}) async {
    if (!_isInterstitialReady.value || _interstitialAd == null) {
      Logger.log('⚠️ Interstitial not ready, loading...', tag: 'IRONSOURCE');
      loadInterstitial();
      return false;
    }

    _onInterstitialClosed = onClosed;

    try {
      final isReady = await _interstitialAd!.isAdReady();
      if (isReady) {
        _interstitialAd!.showAd(placementName: 'DefaultInterstitial');
        return true;
      } else {
        Logger.log('⚠️ Interstitial isAdReady returned false', tag: 'IRONSOURCE');
        loadInterstitial();
        return false;
      }
    } catch (e) {
      Logger.error('❌ Failed to show interstitial', tag: 'IRONSOURCE', error: e);
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📰 BANNER ADS
  // ══════════════════════════════════════════════════════════════════════════

  /// Creates a LevelPlayBannerAdView widget to embed in your screen.
  ///
  /// Usage:
  /// ```dart
  /// final adService = Get.find<IronSourceAdService>();
  /// final bannerWidget = adService.createBannerAdView(
  ///   onPlatformViewCreated: () {
  ///     // Banner view is ready, load the ad
  ///   },
  /// );
  /// ```
  LevelPlayBannerAdView createBannerAdView({
    LevelPlayAdSize? adSize,
    String? placementName,
    GlobalKey<LevelPlayBannerAdViewState>? bannerKey,
    VoidCallback? onPlatformViewCreated,
  }) {
    final listener = IronSourceBannerAdListener(this);
    return LevelPlayBannerAdView(
      key: bannerKey,
      adUnitId: _bannerAdUnitId,
      adSize: adSize ?? LevelPlayAdSize.BANNER,
      listener: listener,
      placementName: placementName ?? 'DefaultBanner',
      onPlatformViewCreated: onPlatformViewCreated,
    );
  }

  /// Public banner listener for use in banner widgets
  LevelPlayBannerAdViewListener get bannerListener => IronSourceBannerAdListener(this);

  /// Banner listener with callbacks for fallback support
  LevelPlayBannerAdViewListener createBannerListener({
    VoidCallback? onLoaded,
    VoidCallback? onFailed,
  }) => IronSourceBannerAdListener(this, onBannerLoaded: onLoaded, onBannerFailed: onFailed);

  // ══════════════════════════════════════════════════════════════════════════
  // 🧹 CLEANUP
  // ══════════════════════════════════════════════════════════════════════════

  void disposeAll() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialReady.value = false;
    _isBannerLoaded.value = false;
    Logger.log('🧹 All IronSource ads disposed', tag: 'IRONSOURCE');
  }

  @override
  void onClose() {
    disposeAll();
    super.onClose();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 🎯 INTERSTITIAL AD LISTENER (Separate class to avoid mixin conflicts)
// ══════════════════════════════════════════════════════════════════════════════

class _InterstitialListener implements LevelPlayInterstitialAdListener {
  final IronSourceAdService _service;

  _InterstitialListener(this._service);

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    _service._isInterstitialReady.value = true;
    _service.lastInterstitialAdInfo.value = adInfo;
    final network = adInfo.impressionData?.adNetwork ?? 'unknown';
    final instance = adInfo.impressionData?.instanceName ?? '';
    final revenue = adInfo.impressionData?.revenue;
    Logger.log(
      '✅ Interstitial loaded | adUnit: ${adInfo.adUnitId} | network: $network | instance: $instance | revenue: $revenue',
      tag: 'IRONSOURCE',
    );
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    _service._isInterstitialReady.value = false;
    Logger.error('❌ Interstitial load failed: ${error.errorMessage}', tag: 'IRONSOURCE');
    // Retry after delay
    Future.delayed(const Duration(seconds: 30), () => _service.loadInterstitial());
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    _service.lastInterstitialAdInfo.value = adInfo;
    final network = adInfo.impressionData?.adNetwork ?? 'unknown';
    Logger.log('📺 Interstitial displayed | network: $network', tag: 'IRONSOURCE');
  }

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    _service._isInterstitialReady.value = false;
    _service.lastInterstitialAdInfo.value = adInfo;
    Logger.error('❌ Interstitial display failed: ${error.errorMessage}', tag: 'IRONSOURCE');
    _service.loadInterstitial();
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    final network = adInfo.impressionData?.adNetwork ?? 'unknown';
    Logger.log('👆 Interstitial clicked | network: $network', tag: 'IRONSOURCE');
  }

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) {
    _service._isInterstitialReady.value = false;
    _service.lastInterstitialAdInfo.value = adInfo;
    final network = adInfo.impressionData?.adNetwork ?? 'unknown';
    Logger.log('🚪 Interstitial closed | network: $network', tag: 'IRONSOURCE');
    _service._onInterstitialClosed?.call();
    _service._onInterstitialClosed = null;
    _service.loadInterstitial(); // Pre-load next ad
  }

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {
    _service.lastInterstitialAdInfo.value = adInfo;
    final network = adInfo.impressionData?.adNetwork ?? 'unknown';
    Logger.log('ℹ️ Interstitial info changed | network: $network', tag: 'IRONSOURCE');
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 📰 BANNER AD LISTENER (Separate class to avoid mixin conflicts)
// ══════════════════════════════════════════════════════════════════════════════

class IronSourceBannerAdListener implements LevelPlayBannerAdViewListener {
  final IronSourceAdService _service;
  final VoidCallback? onBannerLoaded;
  final VoidCallback? onBannerFailed;

  IronSourceBannerAdListener(this._service, {this.onBannerLoaded, this.onBannerFailed});

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    _service._isBannerLoaded.value = true;
    _service.lastBannerAdInfo.value = adInfo;
    final network = adInfo.impressionData?.adNetwork ?? 'unknown';
    final instance = adInfo.impressionData?.instanceName ?? '';
    final revenue = adInfo.impressionData?.revenue;
    Logger.log(
      '✅ Banner loaded | adUnit: ${adInfo.adUnitId} | network: $network | instance: $instance | revenue: $revenue',
      tag: 'IRONSOURCE',
    );
    onBannerLoaded?.call();
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    _service._isBannerLoaded.value = false;
    Logger.error('❌ Banner load failed: ${error.errorMessage}', tag: 'IRONSOURCE');
    onBannerFailed?.call();
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    _service.lastBannerAdInfo.value = adInfo;
    final network = adInfo.impressionData?.adNetwork ?? 'unknown';
    Logger.log('📺 Banner displayed | network: $network', tag: 'IRONSOURCE');
  }

  @override
  void onAdDisplayFailed(LevelPlayAdInfo adInfo, LevelPlayAdError error) {
    _service._isBannerLoaded.value = false;
    _service.lastBannerAdInfo.value = adInfo;
    Logger.error('❌ Banner display failed: ${error.errorMessage}', tag: 'IRONSOURCE');
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    final network = adInfo.impressionData?.adNetwork ?? 'unknown';
    Logger.log('👆 Banner clicked | network: $network', tag: 'IRONSOURCE');
  }

  @override
  void onAdExpanded(LevelPlayAdInfo adInfo) {
    final network = adInfo.impressionData?.adNetwork ?? 'unknown';
    Logger.log('📏 Banner expanded | network: $network', tag: 'IRONSOURCE');
  }

  @override
  void onAdCollapsed(LevelPlayAdInfo adInfo) {
    Logger.log('📐 Banner collapsed', tag: 'IRONSOURCE');
  }

  @override
  void onAdLeftApplication(LevelPlayAdInfo adInfo) {
    Logger.log('🚪 Banner left app', tag: 'IRONSOURCE');
  }
}
