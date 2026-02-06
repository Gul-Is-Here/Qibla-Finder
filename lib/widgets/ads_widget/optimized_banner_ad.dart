import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';
import '../../services/ads/ad_service.dart';
import '../../services/ads/ironsource_ad_service.dart';
// TODO: Uncomment for premium features in next version
// import '../../services/subscription_service.dart';
// import 'subscription_prompt_banner.dart';

class OptimizedBannerAdWidget extends StatefulWidget {
  final EdgeInsets? padding;
  final bool showOnlyWhenLoaded;
  final bool isBottomBanner;

  const OptimizedBannerAdWidget({
    super.key,
    this.padding,
    this.showOnlyWhenLoaded = true,
    this.isBottomBanner = false,
  });

  @override
  State<OptimizedBannerAdWidget> createState() => _OptimizedBannerAdWidgetState();
}

class _OptimizedBannerAdWidgetState extends State<OptimizedBannerAdWidget> {
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
    if (AdService.areAdsDisabled) return;

    final adService = Get.find<AdService>();
    _admobBannerAd = adService.createUniqueBannerAd(
      customKey: widget.key.toString(),
      onAdLoaded: () {
        if (mounted) {
          print('✅ AdMob banner loaded successfully');
          setState(() => _admobLoaded = true);
        }
      },
      onAdFailed: () {
        if (mounted) {
          print('❌ AdMob banner failed, trying IronSource...');
          setState(() {
            _admobFailed = true;
            _admobBannerAd = null;
          });
          // Fallback to IronSource
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
      // Retry after 3s if not initialized yet
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _admobFailed) _loadIronSourceBanner();
      });
      return;
    }

    _ironSourceListener = adService.createBannerListener(
      onLoaded: () {
        print('✅ IronSource banner loaded (fallback)');
      },
      onFailed: () {
        print('❌ IronSource banner also failed');
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
    if (AdService.areAdsDisabled) {
      return const SizedBox.shrink();
    }

    // TODO: Uncomment for premium features in next version
    // Check if user is premium
    // try {
    //   if (Get.isRegistered<SubscriptionService>()) {
    //     final subscriptionService = Get.find<SubscriptionService>();
    //     if (subscriptionService.isPremium) {
    //       return const SizedBox.shrink();
    //     }
    //   }
    // } catch (e) {
    //   // Subscription service not ready yet
    // }

    final padding = widget.padding ?? const EdgeInsets.all(8.0);

    // Priority 1: Show AdMob banner
    if (_admobLoaded && _admobBannerAd != null) {
      return Container(
        padding: padding,
        child: SizedBox(
          width: _admobBannerAd!.size.width.toDouble(),
          height: _admobBannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _admobBannerAd!),
        ),
      );
    }

    // Priority 2: Show IronSource banner as fallback
    if (_admobFailed && _ironSourceReady && _ironSourceListener != null) {
      return Container(
        padding: padding,
        child: SizedBox(
          width: _adSize.width.toDouble(),
          height: _adSize.height.toDouble(),
          child: LevelPlayBannerAdView(
            key: _bannerKey,
            adUnitId: IronSourceAdService.bannerAdUnitId,
            adSize: _adSize,
            listener: _ironSourceListener!,
            placementName: 'FallbackBanner',
            onPlatformViewCreated: () {
              _bannerKey.currentState?.loadAd();
            },
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
