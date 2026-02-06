import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';
import '../../services/ads/ad_service.dart';
import '../../services/ads/ironsource_ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  // AdMob (primary)
  BannerAd? _admobBannerAd;
  bool _admobLoaded = false;
  bool _admobFailed = false;

  // IronSource (fallback)
  final _bannerKey = GlobalKey<LevelPlayBannerAdViewState>();
  final _adSize = LevelPlayAdSize.BANNER;
  bool _ironSourceReady = false;
  LevelPlayBannerAdViewListener? _ironSourceListener;

  @override
  void initState() {
    super.initState();
    _loadAdMobBanner();
  }

  // Step 1: Load AdMob banner first
  void _loadAdMobBanner() {
    if (!Get.isRegistered<AdService>()) return;

    final adService = Get.find<AdService>();
    _admobBannerAd = adService.createUniqueBannerAd(
      onAdLoaded: () {
        if (mounted) {
          print('✅ AdMob banner loaded (legacy widget)');
          setState(() => _admobLoaded = true);
        }
      },
      onAdFailed: () {
        if (mounted) {
          print('❌ AdMob banner failed (legacy widget), trying IronSource...');
          setState(() {
            _admobFailed = true;
            _admobBannerAd = null;
          });
          _loadIronSourceBanner();
        }
      },
    );
    _admobBannerAd?.load();
  }

  // Step 2: If AdMob fails, try IronSource
  void _loadIronSourceBanner() {
    if (!Get.isRegistered<IronSourceAdService>()) return;

    final adService = Get.find<IronSourceAdService>();
    if (!adService.isInitialized) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _admobFailed) _loadIronSourceBanner();
      });
      return;
    }

    _ironSourceListener = adService.createBannerListener(
      onLoaded: () {
        print('✅ IronSource banner loaded (legacy fallback)');
      },
      onFailed: () {
        print('❌ IronSource banner also failed (legacy)');
      },
    );

    if (mounted) setState(() => _ironSourceReady = true);
  }

  @override
  void dispose() {
    _admobBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Priority 1: AdMob banner
    if (_admobLoaded && _admobBannerAd != null) {
      return SizedBox(
        width: _admobBannerAd!.size.width.toDouble(),
        height: _admobBannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _admobBannerAd!),
      );
    }

    // Priority 2: IronSource fallback
    if (_admobFailed && _ironSourceReady && _ironSourceListener != null) {
      return SizedBox(
        width: _adSize.width.toDouble(),
        height: _adSize.height.toDouble(),
        child: LevelPlayBannerAdView(
          key: _bannerKey,
          adUnitId: IronSourceAdService.bannerAdUnitId,
          adSize: _adSize,
          listener: _ironSourceListener!,
          placementName: 'LegacyFallbackBanner',
          onPlatformViewCreated: () {
            _bannerKey.currentState?.loadAd();
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
