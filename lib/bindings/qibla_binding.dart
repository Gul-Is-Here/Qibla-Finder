import 'package:get/get.dart';

import '../controllers/qibla_controller.dart';
import '../controllers/quran_controller.dart';
import '../services/ad_service.dart';
import '../services/connectivity_service.dart';
import '../services/location_service.dart';
import '../services/performance_service.dart';

class QiblaBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize core services immediately to prevent "not found" errors
    Get.put<LocationService>(LocationService(), permanent: true);
    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);
    Get.put<PerformanceService>(PerformanceService(), permanent: true);
    Get.put<AdService>(AdService(), permanent: true);

    // Initialize controllers immediately for navigation screens
    Get.put<QuranController>(QuranController(), permanent: true);
    Get.put<QiblaController>(
      QiblaController(
        locationService: Get.find<LocationService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      permanent: true,
    );
  }
}
