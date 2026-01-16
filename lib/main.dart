import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'bindings/qibla_binding.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'routes/app_pages.dart';
import 'services/notifications/notification_service.dart';
import 'services/ads/inmobi_ad_service.dart';

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

  // FAST STARTUP: Initialize only essential services synchronously
  // Other services will be initialized lazily
  try {
    // Initialize GetStorage with short timeout (critical for app)
    await GetStorage.init().timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        Logger.warning('GetStorage init timeout - using defaults', tag: 'MAIN');
        return false;
      },
    );
  } catch (e) {
    Logger.error('GetStorage init failed', tag: 'MAIN', error: e);
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

    // Initialize ads SDK (can be slow)
    MobileAds.instance.initialize().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        Logger.warning('Ads SDK init timeout', tag: 'MAIN');
        return InitializationStatus({});
      },
    );

    // Initialize notification service
    await NotificationService.instance.initialize().timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        Logger.warning('Notification init timeout', tag: 'MAIN');
      },
    );

    // Initialize InMobi Ad Service lazily
    if (!Get.isRegistered<InMobiAdService>()) {
      Get.put(InMobiAdService(), permanent: true);
    }

    Logger.info('Background services initialized', tag: 'MAIN');
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
