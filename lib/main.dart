import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';

import 'bindings/qibla_binding.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'routes/app_pages.dart';
import 'services/notifications/notification_service.dart';
import 'services/ads/inmobi_ad_service.dart';
import 'services/ads/ironsource_ad_service.dart';
import 'services/auth/auth_service.dart';
import 'services/shorebird/shorebird_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handler for better crash handling
  FlutterError.onError = (FlutterErrorDetails details) {
    Logger.error(
      'Flutter Error Caught',
      tag: 'GLOBAL_ERROR',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Catch async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    Logger.error('Async Error Caught', tag: 'GLOBAL_ERROR', error: error, stackTrace: stack);
    return true;
  };

  // Initialize essential services
  try {
    // Initialize Firebase (critical for auth)
    await Firebase.initializeApp().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw Exception('Firebase initialization timeout');
      },
    );

    // Initialize AuthService (depends on Firebase)
    Get.put(AuthService(), permanent: true);

    // Initialize GetStorage (critical for app preferences)
    await GetStorage.init().timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        return false;
      },
    );
  } catch (e) {
    Logger.error('Critical initialization failed', tag: 'MAIN', error: e);
  }

  // Run app immediately - don't block on other initializations
  runApp(const MyApp());

  // Initialize other services AFTER app is running (non-blocking)
  _initializeServicesInBackground();
}

/// Initialize non-critical services in background after app starts
Future<void> _initializeServicesInBackground() async {
  try {
    // Small delay to let UI render first
    await Future.delayed(const Duration(milliseconds: 100));

    // Initialize ads SDK
    MobileAds.instance.initialize().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        return InitializationStatus({});
      },
    );

    // Initialize notification service
    await NotificationService.instance.initialize().timeout(
      const Duration(seconds: 3),
      onTimeout: () {},
    );

    // Initialize InMobi Ad Service
    if (!Get.isRegistered<InMobiAdService>()) {
      Get.put(InMobiAdService(), permanent: true);
    }

    // Initialize IronSource / LevelPlay Ad Service
    if (!Get.isRegistered<IronSourceAdService>()) {
      final ironSource = Get.put(IronSourceAdService(), permanent: true);
      await ironSource.initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          Logger.log('IronSource initialization timeout', tag: 'IRONSOURCE');
        },
      );
    }

    // Initialize Shorebird for code push updates
    await ShorebirdService().initializeAndCheck().timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        Logger.log('Shorebird initialization timeout', tag: 'SHOREBIRD');
      },
    );

    // TODO: Uncomment for premium features in next version
    // Initialize Subscription Service
    // if (!Get.isRegistered<SubscriptionService>()) {
    //   Get.put(SubscriptionService(), permanent: true);
    // }
  } catch (e, stackTrace) {
    Logger.error('Background initialization error', tag: 'MAIN', error: e, stackTrace: stackTrace);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Notification permissions are now handled in onboarding flow
    // Removed automatic permission request to avoid conflicts
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      initialBinding: QiblaBinding(),
    );
  }
}
