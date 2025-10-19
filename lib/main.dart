import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'bindings/qibla_binding.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'routes/app_pages.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize essential services with timeout protection for physical devices
    await GetStorage.init().timeout(
      AppConfig.storageTimeout,
      onTimeout: () {
        Logger.warning('GetStorage init timeout - continuing anyway', tag: 'MAIN');
        return false;
      },
    );

    // Initialize Notification Service and request permissions immediately
    await NotificationService.instance.initialize();

    // Request notification permissions immediately on app start
    await NotificationService.instance.requestPermissions();
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
