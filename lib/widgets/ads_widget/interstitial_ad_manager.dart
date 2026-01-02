import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isLoaded = false;

  void loadAd({Function()? onAdLoaded, Function()? onAdFailedToLoad}) {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-2744970719381152/7693580112',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _isLoaded = true;
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoaded = false;
          onAdFailedToLoad?.call();
        },
      ),
    );
  }

  void showAd({Function()? onAdDismissed}) {
    if (_isLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _isLoaded = false;
          onAdDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _isLoaded = false;
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }
}
