import 'package:get/get.dart';

import '../controllers/compass_controller/qibla_controller.dart';
import '../controllers/quran_controller/quran_controller.dart';
import '../services/ads/ad_service.dart';
import '../services/connectivity/connectivity_service.dart';
import '../services/location/location_service.dart';
import '../services/performance_service.dart';

class QiblaBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize core services immediately (lightweight)
    Get.put<LocationService>(LocationService(), permanent: true);
    Get.put<ConnectivityService>(ConnectivityService(), permanent: true);

    // Initialize performance service lazily
    Get.lazyPut<PerformanceService>(() => PerformanceService(), fenix: true);

    // Initialize ad service lazily (heavy)
    Get.lazyPut<AdService>(() => AdService(), fenix: true);

    // Initialize controllers LAZILY to speed up startup
    // They will be created when first accessed
    Get.lazyPut<QuranController>(() => QuranController(), fenix: true);

    Get.lazyPut<QiblaController>(
      () => QiblaController(
        locationService: Get.find<LocationService>(),
        connectivityService: Get.find<ConnectivityService>(),
      ),
      fenix: true,
    );
  }
}
