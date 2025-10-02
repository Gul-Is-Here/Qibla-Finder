// Ad Configuration Constants
class AdConstants {
  // Replace these with your actual AdMob App IDs from Google AdMob Console
  static const String androidAppId =
      'ca-app-pub-2744970719381152~YOUR_ANDROID_APP_ID'; // Your actual Android App ID
  static const String iosAppId =
      'ca-app-pub-2744970719381152~YOUR_IOS_APP_ID'; // Your actual iOS App ID

  // Replace these with your actual Ad Unit IDs from Google AdMob Console
  static const String androidBannerAdUnitId =
      'ca-app-pub-2744970719381152/YOUR_ANDROID_BANNER_AD_UNIT_ID'; // Your actual Android Banner Ad Unit ID
  static const String iosBannerAdUnitId =
      'ca-app-pub-2744970719381152/YOUR_IOS_BANNER_AD_UNIT_ID'; // Your actual iOS Banner Ad Unit ID

  static const String androidInterstitialAdUnitId =
      'ca-app-pub-2744970719381152/YOUR_ANDROID_INTERSTITIAL_AD_UNIT_ID'; // Your actual Android Interstitial Ad Unit ID
  static const String iosInterstitialAdUnitId =
      'ca-app-pub-2744970719381152/YOUR_IOS_INTERSTITIAL_AD_UNIT_ID'; // Your actual iOS Interstitial Ad Unit ID

  static const String androidRewardedAdUnitId =
      'ca-app-pub-2744970719381152/YOUR_ANDROID_REWARDED_AD_UNIT_ID'; // Your actual Android Rewarded Ad Unit ID
  static const String iosRewardedAdUnitId =
      'ca-app-pub-2744970719381152/YOUR_IOS_REWARDED_AD_UNIT_ID'; // Your actual iOS Rewarded Ad Unit ID

  // Ad frequency settings
  static const int interstitialAdFrequency = 3; // Show every 3rd action
  static const int bannerAdRefreshRate = 60; // Refresh every 60 seconds
  static const int rewardedAdCooldown = 300; // 5 minutes cooldown
}

// Performance Optimization Constants
class PerformanceConstants {
  static const int compassUpdateInterval = 100; // milliseconds
  static const int locationUpdateInterval = 5000; // milliseconds
  static const int cacheExpiryTime = 86400; // 24 hours in seconds
  static const int maxCacheSize = 100; // Maximum number of cached items
  static const int imageMaxSize = 100; // Maximum number of cached images
  static const int imageMaxSizeBytes = 52428800; // 50MB in bytes

  // Battery optimization settings
  static const int batteryOptimizedCompassInterval = 200; // milliseconds
  static const int batteryOptimizedLocationInterval = 10000; // milliseconds
}

// App Feature Constants
class AppConstants {
  static const String appName = 'Qibla Compass - Offline';
  static const String appVersion = '1.0.0';
  static const double kaabaLatitude = 21.422487;
  static const double kaabaLongitude = 39.826206;

  // Qibla alignment threshold
  static const double qiblaAlignmentThreshold = 5.0; // degrees

  // Animation durations
  static const int compassAnimationDuration = 1000; // milliseconds
  static const int shimmerAnimationDuration = 2000; // milliseconds

  // Vibration settings
  static const int vibrationDuration = 300; // milliseconds
  static const int vibrationCooldown = 3000; // milliseconds
}
