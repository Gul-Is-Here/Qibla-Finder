import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'bindings/qibla_binding.dart';
import 'controller/qibla_controller.dart';
import 'routes/app_pages.dart';
import 'services/ad_service.dart';
import 'services/connectivity_service.dart';
import 'services/location_service.dart';
import 'services/performance_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize Notification Service
  await NotificationService.instance.initialize();

  // Initialize services
  Get.put(PerformanceService());
  Get.put(AdService());
  Get.put(LocationService());
  Get.put(ConnectivityService());
  Get.put(
    QiblaController(
      locationService: Get.find(),
      connectivityService: Get.find(),
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Qibla Compass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF8BC34A),
          secondary: Color(0xFF4CAF50),
          surface: Color(0xFF00332F),
          background: Color(0xFF00332F),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF00332F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00332F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white.withOpacity(0.1),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8BC34A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color?>((
            Set<MaterialState> states,
          ) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF8BC34A);
            }
            return Colors.grey;
          }),
          trackColor: MaterialStateProperty.resolveWith<Color?>((
            Set<MaterialState> states,
          ) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF8BC34A).withOpacity(0.5);
            }
            return Colors.grey.withOpacity(0.3);
          }),
        ),
      ),
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      initialBinding: QiblaBinding(),
    );
  }
}
