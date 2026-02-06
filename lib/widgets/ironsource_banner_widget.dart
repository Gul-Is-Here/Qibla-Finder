import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';
import '../services/ads/ironsource_ad_service.dart';

/// A ready-to-use IronSource LevelPlay banner ad widget.
///
/// Usage:
/// ```dart
/// IronSourceBannerWidget(
///   placementName: 'HomeBanner',
/// )
/// ```
class IronSourceBannerWidget extends StatefulWidget {
  final LevelPlayAdSize? adSize;
  final String? placementName;

  const IronSourceBannerWidget({super.key, this.adSize, this.placementName});

  @override
  State<IronSourceBannerWidget> createState() => _IronSourceBannerWidgetState();
}

class _IronSourceBannerWidgetState extends State<IronSourceBannerWidget> {
  final _bannerKey = GlobalKey<LevelPlayBannerAdViewState>();
  late final LevelPlayAdSize _adSize;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _adSize = widget.adSize ?? LevelPlayAdSize.BANNER;
    _checkInit();
  }

  void _checkInit() {
    if (!Get.isRegistered<IronSourceAdService>()) return;
    final adService = Get.find<IronSourceAdService>();
    if (!adService.isInitialized) {
      // Retry after 3s if not initialized yet
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) _checkInit();
      });
      return;
    }
    if (mounted) setState(() => _isReady = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) return const SizedBox.shrink();
    if (!Get.isRegistered<IronSourceAdService>()) return const SizedBox.shrink();

    final adService = Get.find<IronSourceAdService>();

    return SizedBox(
      width: _adSize.width.toDouble(),
      height: _adSize.height.toDouble(),
      child: LevelPlayBannerAdView(
        key: _bannerKey,
        adUnitId: IronSourceAdService.bannerAdUnitId,
        adSize: _adSize,
        listener: adService.bannerListener,
        placementName: widget.placementName ?? 'DefaultBanner',
        onPlatformViewCreated: () {
          _bannerKey.currentState?.loadAd();
        },
      ),
    );
  }
}
