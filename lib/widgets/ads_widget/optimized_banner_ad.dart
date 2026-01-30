import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ads/ad_service.dart';
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
  BannerAd? _localBannerAd;

  @override
  void initState() {
    super.initState();
    _loadLocalBannerAd();
  }

  void _loadLocalBannerAd() {
    // Don't load ads if disabled for store submission
    if (AdService.areAdsDisabled) {
      return;
    }

    // Create a unique banner ad instance using AdService
    final adService = Get.find<AdService>();
    _localBannerAd = adService.createUniqueBannerAd(customKey: widget.key.toString());

    if (_localBannerAd != null) {
      _localBannerAd!.load();
    }
  }

  @override
  void dispose() {
    _localBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show ads if disabled for store submission
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

    // Use local banner ad
    if (_localBannerAd == null && widget.showOnlyWhenLoaded) {
      return const SizedBox.shrink();
    }

    if (_localBannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: widget.padding ?? const EdgeInsets.all(8.0),
      child: SizedBox(
        width: _localBannerAd!.size.width.toDouble(),
        height: _localBannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _localBannerAd!),
      ),
    );
  }
}
