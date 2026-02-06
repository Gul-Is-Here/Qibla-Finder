import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';
import '../../services/ads/ad_service.dart';
import '../../services/ads/inmobi_ad_service.dart';
import '../../services/ads/ironsource_ad_service.dart';

/// Test screen to verify all ad networks are working correctly.
/// Navigate to: Routes.AD_TEST or '/ad-test'
class AdTestScreen extends StatefulWidget {
  const AdTestScreen({super.key});

  @override
  State<AdTestScreen> createState() => _AdTestScreenState();
}

class _AdTestScreenState extends State<AdTestScreen> {
  // AdMob
  AdService? _adMobService;
  BannerAd? _testBannerAd;
  final _adMobBannerLoaded = false.obs;

  // IronSource
  IronSourceAdService? _ironSourceService;
  final _bannerKey = GlobalKey<LevelPlayBannerAdViewState>();
  LevelPlayBannerAdView? _ironSourceBannerAdView;

  // InMobi
  InMobiAdService? _inMobiService;

  // IronSource SDK debug toggle
  bool _adaptersDebugEnabled = false;

  // Ad source tracking
  final _adMobBannerSource = ''.obs;
  final _adMobInterstitialSource = ''.obs;

  // Logs
  final _logs = <String>[].obs;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  void _initServices() {
    // AdMob
    if (Get.isRegistered<AdService>()) {
      _adMobService = Get.find<AdService>();
      _log('✅ AdMob service found');
    } else {
      _log('❌ AdMob service NOT registered');
    }

    // IronSource
    if (Get.isRegistered<IronSourceAdService>()) {
      _ironSourceService = Get.find<IronSourceAdService>();
      _log('✅ IronSource service found | initialized: ${_ironSourceService!.isInitialized}');
    } else {
      _log('❌ IronSource service NOT registered');
    }

    // IronSource — watch ad info changes to log source
    if (_ironSourceService != null) {
      _ironSourceService!.lastInterstitialAdInfo.listen((adInfo) {
        if (adInfo != null) {
          _logAdSourceInfo('LP Interstitial', adInfo);
        }
      });
      _ironSourceService!.lastBannerAdInfo.listen((adInfo) {
        if (adInfo != null) {
          _logAdSourceInfo('LP Banner', adInfo);
        }
      });
    }

    // InMobi
    if (Get.isRegistered<InMobiAdService>()) {
      _inMobiService = Get.find<InMobiAdService>();
      _log('✅ InMobi service found | initialized: ${_inMobiService!.isInitialized.value}');
    } else {
      _log('❌ InMobi service NOT registered');
    }
  }

  void _log(String message) {
    final time = DateTime.now();
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
    _logs.insert(0, '[$timeStr] $message');
    debugPrint('[AD_TEST] $message');
  }

  /// Logs detailed ad source information from LevelPlay ImpressionData
  void _logAdSourceInfo(String label, LevelPlayAdInfo adInfo) {
    final imp = adInfo.impressionData;
    if (imp == null) {
      _log('🔎 $label source → no impression data available');
      return;
    }
    _log('🔎 $label source ─────────────────');
    _log('   📡 Ad Network: ${imp.adNetwork ?? "unknown"}');
    _log('   🏷️ Instance: ${imp.instanceName ?? "—"} (${imp.instanceId ?? "—"})');
    _log('   💰 Revenue: ${imp.revenue ?? "—"} (${imp.precision ?? "—"})');
    _log('   🌍 Country: ${imp.country ?? "—"}');
    _log('   📐 Ad Format: ${imp.adFormat ?? "—"}');
    _log('   🎨 Creative ID: ${imp.creativeId ?? "—"}');
    _log('   📦 Placement: ${imp.placement ?? "—"}');
    _log('   🔐 Encrypted CPM: ${imp.encryptedCPM ?? "—"}');
    _log('   🆔 Auction ID: ${imp.auctionId ?? "—"}');
  }

  @override
  void dispose() {
    _testBannerAd?.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ADMOB ACTIONS
  // ══════════════════════════════════════════════════════════════════════════

  void _loadAdMobBanner() {
    _log('📥 Loading AdMob banner...');
    _testBannerAd?.dispose();
    _testBannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _adMobBannerLoaded.value = true;
          // Extract ad source info
          final info = ad.responseInfo;
          final loaded = info?.loadedAdapterResponseInfo;
          final source = loaded?.adSourceName ?? 'unknown';
          final adapter = info?.mediationAdapterClassName ?? 'unknown';
          _adMobBannerSource.value = source;
          _log('✅ AdMob banner loaded | source: $source');
          _log('   🏷️ Adapter: $adapter');
          _log('   ⏱️ Latency: ${loaded?.latencyMillis ?? 0}ms');
          // Log all waterfall adapters
          if (info?.adapterResponses != null) {
            for (final resp in info!.adapterResponses!) {
              final status = resp.adError == null ? '✅' : '❌';
              _log(
                '   $status ${resp.adSourceName} (${resp.latencyMillis}ms)${resp.adError != null ? " — ${resp.adError!.message}" : ""}',
              );
            }
          }
          setState(() {});
        },
        onAdFailedToLoad: (ad, error) {
          _adMobBannerLoaded.value = false;
          final source = error.responseInfo?.loadedAdapterResponseInfo?.adSourceName;
          _log('❌ AdMob banner failed: ${error.message} | last source: $source');
          ad.dispose();
        },
        onAdClicked: (ad) => _log('👆 AdMob banner clicked'),
        onAdImpression: (ad) => _log('👁️ AdMob banner impression'),
      ),
    );
    _testBannerAd!.load();
  }

  void _showAdMobInterstitial() {
    if (_adMobService == null) {
      _log('❌ AdMob service not available');
      return;
    }
    _log('📺 Showing AdMob interstitial...');
    _adMobService!.showInterstitialAd(
      onAdClosed: () {
        _adMobInterstitialSource.value = 'shown (source in logs)';
        _log('🚪 AdMob interstitial closed');
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LEVELPLAY ACTIONS (New LevelPlay API - Interstitial & Banner)
  // ══════════════════════════════════════════════════════════════════════════

  void _loadLevelPlayInterstitial() {
    if (_ironSourceService == null) {
      _log('❌ LevelPlay service not available');
      return;
    }
    _log('📥 Loading LevelPlay interstitial...');
    _ironSourceService!.loadInterstitial();
  }

  void _showLevelPlayInterstitial() {
    if (_ironSourceService == null) {
      _log('❌ LevelPlay service not available');
      return;
    }
    _log('📺 Showing LevelPlay interstitial...');
    _ironSourceService!.showInterstitial(onClosed: () => _log('🚪 LevelPlay interstitial closed'));
  }

  void _loadLevelPlayBanner() {
    if (_ironSourceService == null || !_ironSourceService!.isInitialized) {
      _log('❌ LevelPlay not initialized');
      return;
    }
    _log('📥 Loading LevelPlay banner...');
    _ironSourceBannerAdView = _ironSourceService!.createBannerAdView(
      bannerKey: _bannerKey,
      onPlatformViewCreated: () {
        _bannerKey.currentState?.loadAd();
        _log('📦 LevelPlay banner platform view created, loading ad...');
      },
    );
    setState(() {});
  }

  // ══════════════════════════════════════════════════════════════════════════
  // IRONSOURCE SDK ACTIONS (SDK-level tools & legacy API)
  // ══════════════════════════════════════════════════════════════════════════

  void _ironSourceValidateIntegration() async {
    _log('🔍 Running IronSource integration validation...');
    try {
      await IronSource.validateIntegration();
      _log('✅ Validate integration called — check native logs');
    } catch (e) {
      _log('❌ Validate integration failed: $e');
    }
  }

  void _ironSourceLaunchTestSuite() async {
    _log('🧪 Launching IronSource Test Suite...');
    try {
      await IronSource.launchTestSuite();
      _log('✅ Test Suite launched');
    } catch (e) {
      _log('❌ Test Suite failed: $e');
    }
  }

  void _ironSourceGetSdkInfo() {
    try {
      final pluginVersion = IronSource.getPluginVersion();
      final nativeVersion = IronSource.getNativeSDKVersion(Platform.isAndroid ? 'android' : 'ios');
      _log('📦 Plugin: $pluginVersion | Native SDK: $nativeVersion');
    } catch (e) {
      _log('❌ Failed to get SDK info: $e');
    }
  }

  void _ironSourceGetAdvertiserId() async {
    _log('🆔 Getting advertiser ID...');
    try {
      final advId = await IronSource.getAdvertiserId();
      _log('🆔 Advertiser ID: ${advId.isNotEmpty ? advId : "empty/restricted"}');
    } catch (e) {
      _log('❌ Get Advertiser ID failed: $e');
    }
  }

  void _ironSourceToggleAdaptersDebug() async {
    _adaptersDebugEnabled = !_adaptersDebugEnabled;
    _log('🐛 Setting adapters debug: $_adaptersDebugEnabled');
    try {
      await IronSource.setAdaptersDebug(_adaptersDebugEnabled);
      _log('✅ Adapters debug set to $_adaptersDebugEnabled');
    } catch (e) {
      _log('❌ Set adapters debug failed: $e');
    }
  }

  void _ironSourceReinitialize() async {
    if (_ironSourceService == null) {
      _log('❌ IronSource service not available');
      return;
    }
    _log('🔄 Re-initializing IronSource...');
    try {
      await _ironSourceService!.initialize();
      _log('✅ IronSource re-initialization triggered');
    } catch (e) {
      _log('❌ Re-initialization failed: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INMOBI ACTIONS
  // ══════════════════════════════════════════════════════════════════════════

  void _showInMobiInterstitial() {
    if (_inMobiService == null) {
      _log('❌ InMobi service not available');
      return;
    }
    _log('📺 Showing InMobi interstitial...');
    _inMobiService!.showInterstitialAd(onAdClosed: () => _log('🚪 InMobi interstitial closed'));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UI
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('🧪 Ad Test Screen'),
        backgroundColor: const Color(0xFF2D1B69),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _logs.clear(),
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Cards
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Platform Info ──
                  _buildInfoCard(),
                  const SizedBox(height: 12),

                  // ── AdMob Section ──
                  _buildSectionCard(
                    title: '📱 Google AdMob',
                    color: const Color(0xFF4285F4),
                    children: [
                      _buildStatusRow(
                        'Service',
                        _adMobService != null ? '✅ Registered' : '❌ Not found',
                      ),
                      _buildStatusRow('Banner Loaded', _adMobBannerLoaded.value ? '✅ Yes' : '⏳ No'),
                      if (_adMobService != null) ...[
                        _buildStatusRow(
                          'Interstitial',
                          _adMobService!.isInterstitialAdLoaded.value ? '✅ Ready' : '⏳ Not loaded',
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildButton(
                              'Load Banner',
                              _loadAdMobBanner,
                              const Color(0xFF4285F4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildButton(
                              'Show Interstitial',
                              _showAdMobInterstitial,
                              const Color(0xFF34A853),
                            ),
                          ),
                        ],
                      ),
                      // AdMob Banner Preview
                      Obx(() {
                        if (_adMobBannerLoaded.value && _testBannerAd != null) {
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            height: 50,
                            alignment: Alignment.center,
                            child: AdWidget(ad: _testBannerAd!),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── LevelPlay Section (New API) ──
                  _buildSectionCard(
                    title: '🎮 LevelPlay',
                    color: const Color(0xFF8F66FF),
                    children: [
                      Obx(() {
                        final svc = _ironSourceService;
                        return Column(
                          children: [
                            _buildStatusRow(
                              'Service',
                              svc != null ? '✅ Registered' : '❌ Not found',
                            ),
                            if (svc != null) ...[
                              _buildStatusRow('Initialized', svc.isInitialized ? '✅ Yes' : '⏳ No'),
                              _buildStatusRow(
                                'Interstitial Ready',
                                svc.isInterstitialReady ? '✅ Yes' : '⏳ No',
                              ),
                              _buildStatusRow(
                                'Banner Loaded',
                                svc.isBannerLoaded ? '✅ Yes' : '⏳ No',
                              ),
                              _buildStatusRow(
                                'Interstitial Ad Unit',
                                Platform.isAndroid ? 'r22jb5cewizo6unh' : 'wj0qcv1o5mwey3u4',
                              ),
                              _buildStatusRow(
                                'Banner Ad Unit',
                                Platform.isAndroid ? '0hg7dbqqoq82y7i0' : 'j5xzwe80lnwpkxge',
                              ),
                            ],
                          ],
                        );
                      }),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildButton(
                              'Load Interstitial',
                              _loadLevelPlayInterstitial,
                              const Color(0xFF8F66FF),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildButton(
                              'Show Interstitial',
                              _showLevelPlayInterstitial,
                              const Color(0xFF6B4ECC),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildButton('Load Banner', _loadLevelPlayBanner, const Color(0xFFA980FF)),
                      // LevelPlay Banner Preview
                      if (_ironSourceBannerAdView != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          height: 50,
                          alignment: Alignment.center,
                          child: _ironSourceBannerAdView!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Ad Source Info (Which network served the ad) ──
                  _buildSectionCard(
                    title: '🔎 Ad Source Info',
                    color: const Color(0xFFFFD700),
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Shows which ad network actually served each ad. Load ads above to see results.',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ),
                      // AdMob Source
                      Obx(() {
                        final bannerSource = _adMobBannerSource.value;
                        final interstitialSource =
                            _adMobService?.lastInterstitialSource.value ?? '';
                        final svcBannerSource = _adMobService?.lastBannerSource.value ?? '';
                        return Column(
                          children: [
                            _buildStatusRow(
                              '📱 AdMob Banner Source',
                              bannerSource.isNotEmpty
                                  ? bannerSource
                                  : svcBannerSource.isNotEmpty
                                  ? svcBannerSource
                                  : '—',
                            ),
                            _buildStatusRow(
                              '📱 AdMob Interstitial Source',
                              interstitialSource.isNotEmpty ? interstitialSource : '—',
                            ),
                          ],
                        );
                      }),
                      const Divider(color: Colors.white12, height: 12),
                      // LevelPlay Interstitial Source
                      Obx(() {
                        final adInfo = _ironSourceService?.lastInterstitialAdInfo.value;
                        final imp = adInfo?.impressionData;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatusRow('🎮 LP Interstitial Network', imp?.adNetwork ?? '—'),
                            if (imp != null) ...[
                              _buildStatusRow('   Instance', imp.instanceName ?? '—'),
                              _buildStatusRow(
                                '   Revenue',
                                '${imp.revenue ?? "—"} (${imp.precision ?? "—"})',
                              ),
                              _buildStatusRow('   Country', imp.country ?? '—'),
                              _buildStatusRow('   Creative ID', imp.creativeId ?? '—'),
                            ],
                          ],
                        );
                      }),
                      const Divider(color: Colors.white12, height: 12),
                      // LevelPlay Banner Source
                      Obx(() {
                        final adInfo = _ironSourceService?.lastBannerAdInfo.value;
                        final imp = adInfo?.impressionData;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatusRow('🎮 LP Banner Network', imp?.adNetwork ?? '—'),
                            if (imp != null) ...[
                              _buildStatusRow('   Instance', imp.instanceName ?? '—'),
                              _buildStatusRow(
                                '   Revenue',
                                '${imp.revenue ?? "—"} (${imp.precision ?? "—"})',
                              ),
                              _buildStatusRow('   Country', imp.country ?? '—'),
                              _buildStatusRow('   Creative ID', imp.creativeId ?? '—'),
                            ],
                          ],
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── IronSource SDK Section ──
                  _buildSectionCard(
                    title: '⚙️ IronSource SDK',
                    color: const Color(0xFF00C9A7),
                    children: [
                      Obx(() {
                        final svc = _ironSourceService;
                        return Column(
                          children: [
                            _buildStatusRow(
                              'SDK Status',
                              svc != null && svc.isInitialized
                                  ? '✅ Initialized'
                                  : '⏳ Not initialized',
                            ),
                            _buildStatusRow(
                              'App Key',
                              Platform.isAndroid ? '2501b1cd5' : '252ace6cd',
                            ),
                            _buildStatusRow('Platform', Platform.isAndroid ? 'Android' : 'iOS'),
                            _buildStatusRow(
                              'Adapters Debug',
                              _adaptersDebugEnabled ? '🐛 ON' : '⚪ OFF',
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildButton(
                              'SDK Info',
                              _ironSourceGetSdkInfo,
                              const Color(0xFF00C9A7),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildButton(
                              'Advertiser ID',
                              _ironSourceGetAdvertiserId,
                              const Color(0xFF00A88F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildButton(
                              'Validate Integration',
                              _ironSourceValidateIntegration,
                              const Color(0xFF009B84),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildButton(
                              'Test Suite',
                              _ironSourceLaunchTestSuite,
                              const Color(0xFF008E78),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildButton(
                              'Toggle Debug',
                              _ironSourceToggleAdaptersDebug,
                              const Color(0xFF00806C),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildButton(
                              'Re-initialize',
                              _ironSourceReinitialize,
                              const Color(0xFF007360),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── InMobi Section ──
                  _buildSectionCard(
                    title: '🌐 InMobi',
                    color: const Color(0xFFFF6B35),
                    children: [
                      Obx(() {
                        final svc = _inMobiService;
                        return Column(
                          children: [
                            _buildStatusRow(
                              'Service',
                              svc != null ? '✅ Registered' : '❌ Not found',
                            ),
                            if (svc != null) ...[
                              _buildStatusRow(
                                'Initialized',
                                svc.isInitialized.value ? '✅ Yes' : '⏳ No',
                              ),
                              _buildStatusRow(
                                'Interstitial',
                                svc.isInterstitialLoaded.value ? '✅ Ready' : '⏳ Not loaded',
                              ),
                              _buildStatusRow(
                                'Banner',
                                svc.isBannerLoaded.value ? '✅ Ready' : '⏳ Not loaded',
                              ),
                            ],
                          ],
                        );
                      }),
                      const SizedBox(height: 8),
                      _buildButton(
                        'Show Interstitial',
                        _showInMobiInterstitial,
                        const Color(0xFFFF6B35),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Logs Section ──
                  _buildSectionCard(
                    title: '📋 Event Logs',
                    color: const Color(0xFF555555),
                    children: [
                      Obx(() {
                        if (_logs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No logs yet. Tap buttons above to test ads.',
                              style: TextStyle(color: Colors.white54),
                            ),
                          );
                        }
                        return SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                child: Text(
                                  _logs[index],
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D4A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          _buildStatusRow('Platform', Platform.isAndroid ? '🤖 Android' : '🍎 iOS'),
          _buildStatusRow(
            'Debug Mode',
            const bool.fromEnvironment('dart.vm.product') ? 'Production' : 'Debug',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D4A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.white12, height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed, Color color) {
    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}
