import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ads/ad_service.dart';
import '../../services/subscription_service.dart';
import 'subscription_prompt_banner.dart';

class OptimizedBannerAdWidget extends StatefulWidget {
  final EdgeInsets? padding;
  final bool showOnlyWhenLoaded;
  final bool isBottomBanner; // New parameter to specify which banner to use

  const OptimizedBannerAdWidget({
    super.key,
    this.padding,
    this.showOnlyWhenLoaded = true,
    this.isBottomBanner = false, // Default to top banner
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
      return const SubscriptionPromptBanner();
    }

    // Check if user is premium (safe check - service might not be initialized yet)
    try {
      if (Get.isRegistered<SubscriptionService>()) {
        final subscriptionService = Get.find<SubscriptionService>();
        if (subscriptionService.isPremium) {
          return const SizedBox.shrink();
        }
      }
    } catch (e) {
      // Subscription service not ready yet, continue to show ads/prompts
    }

    // Use local banner ad instead of shared service ads
    if (_localBannerAd == null && widget.showOnlyWhenLoaded) {
      return const SubscriptionPromptBanner();
    }

    // Additional safety check to ensure ad is loaded
    if (_localBannerAd == null) {
      return const SubscriptionPromptBanner();
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
