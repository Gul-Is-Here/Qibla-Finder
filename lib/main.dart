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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Mobile Ads SDK
  await MobileAds.instance.initialize();

  try {
    // Initialize essential services with timeout protection for physical devices
    await GetStorage.init().timeout(
      AppConfig.storageTimeout,
      onTimeout: () {
        Logger.warning('GetStorage init timeout - continuing anyway', tag: 'MAIN');
        return false;
      },
    );

    // Initialize Notification Service only (without requesting permissions yet)
    // Permissions will be requested after the app UI is ready
    await NotificationService.instance.initialize();
  } catch (e, stackTrace) {
    Logger.error(
      'Main initialization error - continuing with app startup',
      tag: 'MAIN',
      error: e,
      stackTrace: stackTrace,
    );
  }

  runApp(const MyApp());
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
    // Request notification permissions after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestNotificationPermissions();
    });
  }

  Future<void> _requestNotificationPermissions() async {
    try {
      await NotificationService.instance.requestPermissions();
      Logger.info('Notification permissions requested', tag: 'MAIN');
    } catch (e) {
      Logger.warning('Failed to request notification permissions: $e', tag: 'MAIN');
    }
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
