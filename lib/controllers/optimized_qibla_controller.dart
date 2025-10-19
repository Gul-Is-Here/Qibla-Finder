import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vibration/vibration.dart';
import '../services/connectivity_service.dart';
import '../services/location_service.dart';
import '../services/performance_service.dart';

class OptimizedQiblaController extends GetxController {
  final LocationService locationService;
  final ConnectivityService connectivityService;

  OptimizedQiblaController({
    required this.locationService,
    required this.connectivityService,
  });

  // Kaaba coordinates
  static const double kaabaLat = 21.422487;
  static const double kaabaLng = 39.826206;
  bool hasVibrated = false;

  // List of Qibla icons
  static const List<String> qiblaIconsList = [
    "assets/icons/qibla1.png",
    "assets/icons/qibla2.png",
  ];

  // Observables
  var heading = 0.0.obs;
  var qiblaAngle = 0.0.obs;
  var currentLocation = Position(
    latitude: 0,
    longitude: 0,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  ).obs;
  var isOnline = false.obs;
  var compassReady = false.obs;
  var locationReady = false.obs;
  var calibrationNeeded = false.obs;
  var selectedQiblaIcon = qiblaIconsList[0].obs;
  var lastUpdateTime = DateTime.now().obs;
  var locationError = ''.obs;
  var compassError = ''.obs;
  var isPerformanceMode = false.obs;

  // Stream subscriptions
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<bool>? _connectivitySubscription;

  // Performance optimization variables
  Timer? _updateThrottleTimer;
  DateTime _lastCompassUpdate = DateTime.now();
  DateTime _lastLocationUpdate = DateTime.now();
  static const Duration _compassUpdateInterval = Duration(milliseconds: 100);
  static const Duration _locationUpdateInterval = Duration(seconds: 5);

  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
    _initPerformanceMode();
    _initCompass();
    _initLocation();
    _initConnectivity();
  }

  void _loadPreferences() {
    final savedIcon = storage.read('selectedQiblaIcon');
    if (savedIcon != null && qiblaIconsList.contains(savedIcon)) {
      selectedQiblaIcon.value = savedIcon;
    }

    isPerformanceMode.value = storage.read('performance_mode') ?? false;
  }

  void _initPerformanceMode() {
    // Listen to performance mode changes
    ever(isPerformanceMode, (bool enabled) {
      storage.write('performance_mode', enabled);
      if (enabled) {
        _enablePerformanceOptimizations();
      } else {
        _disablePerformanceOptimizations();
      }
    });
  }

  void _enablePerformanceOptimizations() {
    // Reduce update frequency in performance mode
    // This will be handled in the compass and location listeners
  }

  void _disablePerformanceOptimizations() {
    // Reset to normal update frequency
  }

  void _initCompass() {
    if (FlutterCompass.events == null) {
      compassError.value = 'Compass not available on this device';
      _showErrorSnackbar(compassError.value);
      return;
    }

    _compassSubscription = FlutterCompass.events?.listen(
      (event) {
        _handleCompassUpdate(event);
      },
      onError: (error) {
        compassError.value = 'Compass error: $error';
        _showErrorSnackbar(compassError.value);
      },
    );
  }

  void _handleCompassUpdate(CompassEvent event) {
    final now = DateTime.now();

    // Throttle compass updates for performance
    if (isPerformanceMode.value) {
      if (now.difference(_lastCompassUpdate) < _compassUpdateInterval) {
        return;
      }
    }

    _lastCompassUpdate = now;

    // Use performance service throttle
    PerformanceService.throttle(() {
      heading.value = event.heading ?? 0.0;
      _calculateQiblaDirection();
      _checkQiblaAlignmentAndVibrate();
      lastUpdateTime.value = now;

      // Check compass accuracy
      calibrationNeeded.value =
          event.accuracy != null && event.accuracy! <= 0.3;

      if (!compassReady.value) {
        compassReady.value = true;
        compassError.value = '';
      }
    });
  }

  void _initLocation() {
    _locationSubscription = locationService.getPositionStream().listen(
      (position) {
        _handleLocationUpdate(position);
      },
      onError: (error) {
        locationError.value = 'Location error: $error';
        _showErrorSnackbar(locationError.value);
      },
    );

    // Initial location fetch
    _getCurrentLocation();
  }

  void _handleLocationUpdate(Position position) {
    final now = DateTime.now();

    // Throttle location updates for performance
    if (isPerformanceMode.value) {
      if (now.difference(_lastLocationUpdate) < _locationUpdateInterval) {
        return;
      }
    }

    _lastLocationUpdate = now;

    currentLocation.value = position;
    _calculateQiblaDirection();

    if (!locationReady.value) {
      locationReady.value = true;
      locationError.value = '';
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await locationService.getCurrentPosition();
      currentLocation.value = position;
      _calculateQiblaDirection();
      locationReady.value = true;
      locationError.value = '';
    } catch (e) {
      locationError.value = 'Failed to get location: $e';
      _showErrorSnackbar(locationError.value);
    }
  }

  void _initConnectivity() {
    _connectivitySubscription = connectivityService.connectionStream.listen((
      hasConnection,
    ) {
      isOnline.value = hasConnection;
    });

    // Initial connectivity check
    connectivityService.hasConnection().then((hasConnection) {
      isOnline.value = hasConnection;
    });
  }

  void _calculateQiblaDirection() {
    if (currentLocation.value.latitude == 0 &&
        currentLocation.value.longitude == 0) {
      return;
    }

    // Use performance service for background calculation if heavy
    final userLat = currentLocation.value.latitude * (pi / 180);
    final userLng = currentLocation.value.longitude * (pi / 180);
    final kaabaLatRad = kaabaLat * (pi / 180);
    final kaabaLngRad = kaabaLng * (pi / 180);

    final deltaLng = kaabaLngRad - userLng;

    final y = sin(deltaLng) * cos(kaabaLatRad);
    final x =
        cos(userLat) * sin(kaabaLatRad) -
        sin(userLat) * cos(kaabaLatRad) * cos(deltaLng);

    double qiblaBearing = atan2(y, x);
    qiblaBearing = qiblaBearing * (180 / pi);
    qiblaBearing = (qiblaBearing + 360) % 360;

    qiblaAngle.value = qiblaBearing;
  }

  void _checkQiblaAlignmentAndVibrate() {
    if (!hasVibrated && compassReady.value && locationReady.value) {
      final alignmentDifference = (heading.value - qiblaAngle.value).abs();
      final normalizedDifference = alignmentDifference > 180
          ? 360 - alignmentDifference
          : alignmentDifference;

      if (normalizedDifference <= 5) {
        _triggerVibration();
        hasVibrated = true;

        // Reset vibration flag after a delay
        Timer(const Duration(seconds: 3), () {
          hasVibrated = false;
        });
      }
    }
  }

  Future<void> _triggerVibration() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 300);
    }
  }

  void _showErrorSnackbar(String message) {
    if (Get.context != null) {
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  // Public methods for UI interaction
  void togglePerformanceMode() {
    isPerformanceMode.value = !isPerformanceMode.value;
  }

  void selectQiblaIcon(String iconPath) {
    if (qiblaIconsList.contains(iconPath)) {
      selectedQiblaIcon.value = iconPath;
      storage.write('selectedQiblaIcon', iconPath);
    }
  }

  void refreshLocation() {
    locationReady.value = false;
    _getCurrentLocation();
  }

  void refreshCompass() {
    compassReady.value = false;
    _initCompass();
  }

  // Getters for computed values
  double get qiblaDirection {
    return (qiblaAngle.value - heading.value) % 360;
  }

  bool get isQiblaAligned {
    final difference = (heading.value - qiblaAngle.value).abs();
    final normalizedDifference = difference > 180
        ? 360 - difference
        : difference;
    return normalizedDifference <= 5;
  }

  String get distanceToKaaba {
    if (currentLocation.value.latitude == 0 &&
        currentLocation.value.longitude == 0) {
      return 'Unknown';
    }

    final distance = Geolocator.distanceBetween(
      currentLocation.value.latitude,
      currentLocation.value.longitude,
      kaabaLat,
      kaabaLng,
    );

    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  @override
  void onClose() {
    _updateThrottleTimer?.cancel();
    _compassSubscription?.cancel();
    _locationSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
