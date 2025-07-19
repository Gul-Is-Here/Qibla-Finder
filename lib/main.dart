import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'bindings/qibla_binding.dart';
import 'controller/qibla_controller.dart';
import 'routes/app_pages.dart';
import 'services/connectivity_service.dart';
import 'services/location_service.dart';

void main() async {
  await GetStorage.init();
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006D6D),
          primary: const Color(0xFF006D6D),
        ),
      ),
      initialRoute: Routes.SPLASH,
      getPages: AppPages.routes,
      initialBinding: QiblaBinding(),
    );
  }
}
