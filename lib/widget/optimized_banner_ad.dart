import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class OptimizedBannerAdWidget extends StatefulWidget {
  final EdgeInsets? padding;
  final bool showOnlyWhenLoaded;
  final bool isBottomBanner; // New parameter to specify which banner to use

  const OptimizedBannerAdWidget({
    Key? key,
    this.padding,
    this.showOnlyWhenLoaded = true,
    this.isBottomBanner = false, // Default to top banner
  }) : super(key: key);

  @override
  State<OptimizedBannerAdWidget> createState() =>
      _OptimizedBannerAdWidgetState();
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

    // Get the appropriate ad unit ID directly from AdService static getters
    final adUnitId = widget.isBottomBanner
        ? AdService.bottomBannerAdUnitId
        : AdService.bannerAdUnitId;

    _localBannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              // Ad loaded successfully
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _localBannerAd = null;
            });
          }
        },
      ),
    );
    _localBannerAd?.load();
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

    // Use local banner ad instead of shared service ads
    if (_localBannerAd == null && widget.showOnlyWhenLoaded) {
      return const SizedBox.shrink();
    }

    // Additional safety check to ensure ad is loaded
    if (_localBannerAd == null) {
      return Container(
        padding: widget.padding ?? const EdgeInsets.all(8.0),
        width: 320,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('Ad Loading...', style: TextStyle(color: Colors.grey)),
          ),
        ),
      );
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
