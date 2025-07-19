import 'package:get/get.dart';

import '../controller/qibla_controller.dart' show QiblaController;
import '../services/connectivity_service.dart';
import '../services/location_service.dart';


class QiblaBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LocationService());
    Get.lazyPut(() => ConnectivityService());
    Get.lazyPut(() => QiblaController(
          locationService: Get.find(),
          connectivityService: Get.find(),
        ));
  }
}