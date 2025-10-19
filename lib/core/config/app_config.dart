/// App Configuration
/// Contains all app-level configuration constants
class AppConfig {
  static const String appName = 'Qibla Compass';
  static const String appVersion = '2.0.0';
  static const int buildNumber = 9;

  // API Configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration storageTimeout = Duration(seconds: 15);

  // Feature Flags
  static const bool enableAds = true;
  static const bool enableNotifications = true;
  static const bool enableAutoUpdate = true;

  // Performance
  static const int maxCacheSize = 100; // MB
  static const Duration cacheExpiry = Duration(days: 7);
}
