import 'package:get/get.dart';

import '../controller/qibla_controller.dart';
import '../controller/quran_controller.dart';
import '../services/ad_service.dart';
import '../services/connectivity_service.dart';
import '../services/location_service.dart';
import '../services/performance_service.dart';

class QiblaBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize services lazily (only when needed)
    Get.lazyPut<LocationService>(() => LocationService());
    Get.lazyPut<ConnectivityService>(() => ConnectivityService());
    Get.lazyPut<PerformanceService>(() => PerformanceService());
    Get.lazyPut<AdService>(() => AdService());

    // Initialize controllers lazily
    Get.lazyPut<QuranController>(() => QuranController());
    Get.lazyPut<QiblaController>(
      () => QiblaController(
        locationService: Get.find<LocationService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
    );
  }
}
