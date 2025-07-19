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

class QiblaController extends GetxController {
  final LocationService locationService;
  final ConnectivityService connectivityService;

  QiblaController({
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

  // Stream subscriptions
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<bool>? _connectivitySubscription;

  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
    _initCompass();
    _initLocation();
    _initConnectivity();
  }

  void _loadPreferences() {
    final savedIcon = storage.read('selectedQiblaIcon');
    if (savedIcon != null && qiblaIconsList.contains(savedIcon)) {
      selectedQiblaIcon.value = savedIcon;
    }
  }

  void _initCompass() {
    if (FlutterCompass.events == null) {
      compassError.value = 'Compass not available on this device';
      _showErrorSnackbar(compassError.value);
      return;
    }

    _compassSubscription = FlutterCompass.events?.listen(
      (event) async {
        heading.value = event.heading ?? 0.0;
        _calculateQiblaDirection();
        _checkQiblaAlignmentAndVibrate(); // 👈 add this line
        lastUpdateTime.value = DateTime.now();

        // Check compass accuracy
        calibrationNeeded.value =
            event.accuracy != null && event.accuracy! <= 0.3;

        if (!compassReady.value) {
          compassReady.value = true;
          compassError.value = '';
        }
      },
      onError: (error) {
        compassError.value = 'Compass error: ${error.toString()}';
        _showErrorSnackbar(compassError.value);
      },
    );
    update(); // Force UI update
  }

  Future<void> _checkQiblaAlignmentAndVibrate() async {
    double difference = (heading.value - qiblaAngle.value).abs();
    if (difference > 180) difference = 360 - difference;

    if (difference <= 5 && !hasVibrated) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 300);
        hasVibrated = true;

        // Reset vibration flag after 5 seconds to allow another vibration later
        Future.delayed(Duration(seconds: 5), () {
          hasVibrated = false;
        });
      }
    }
    update(); // Force UI update
  }

  void _initLocation() async {
    try {
      // Check location service
      if (!await Geolocator.isLocationServiceEnabled()) {
        locationError.value = 'Location services are disabled';
        _showErrorSnackbar(locationError.value);
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationError.value = 'Location permissions denied';
          _showErrorSnackbar(locationError.value);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationError.value = 'Location permissions permanently denied';
        _showErrorSnackbar(locationError.value);
        return;
      }

      // Try to get current position
      try {
        currentLocation.value = await locationService.getCurrentPosition(
          forceAndroidFusedLocation: isOnline.value,
        );
      } catch (e) {
        // Fallback to last known position
        Position? lastPosition = await locationService.getLastKnownPosition();
        if (lastPosition != null) {
          currentLocation.value = lastPosition;
          locationError.value = 'Using last known location (offline mode)';
        } else {
          throw Exception('Could not get location');
        }
      }

      locationReady.value = true;
      locationError.value = '';
      _calculateQiblaDirection();
      lastUpdateTime.value = DateTime.now();

      // Start listening for location updates
      _locationSubscription = locationService.getPositionStream().listen(
        (position) {
          currentLocation.value = position;
          _calculateQiblaDirection();
          lastUpdateTime.value = DateTime.now();
        },
        onError: (error) {
          locationError.value = 'Location error: ${error.toString()}';
          _showErrorSnackbar(locationError.value);
        },
      );
    } catch (e) {
      locationError.value = 'Location initialization failed: ${e.toString()}';
      _showErrorSnackbar(locationError.value);
    }
    update(); // Force UI update
  }

  void _initConnectivity() async {
    isOnline.value = await connectivityService.hasConnection();

    _connectivitySubscription = connectivityService.connectionStream.listen(
      (status) {
        isOnline.value = status;
        if (status) {
          // When coming online, refresh location
          _initLocation();
        }
      },
      onError: (error) {
        _showErrorSnackbar('Connectivity error: ${error.toString()}');
      },
    );
    update(); // Force UI update
  }

  void _calculateQiblaDirection() {
    if (!locationReady.value) return;

    final double lat = currentLocation.value.latitude;
    final double lng = currentLocation.value.longitude;

    final double phiK = kaabaLat * pi / 180.0;
    final double lambdaK = kaabaLng * pi / 180.0;
    final double phi = lat * pi / 180.0;
    final double lambda = lng * pi / 180.0;

    final double psi =
        180.0 /
        pi *
        atan2(
          sin(lambdaK - lambda),
          cos(phi) * tan(phiK) - sin(phi) * cos(lambdaK - lambda),
        );

    qiblaAngle.value = (psi + 360) % 360; // Normalize to 0-360 degrees
    update();
  }

  void retryLocation() {
    locationError.value = '';
    _initLocation();
    update(); // Force UI update
  }

  void retryCompass() {
    compassError.value = '';
    _initCompass();
    update(); // Force UI update
  }

  void _showErrorSnackbar(String message) {
    if (message.isNotEmpty) {
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[700],
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> checkQiblaAlignmentAndVibrate() async {
    double difference = (heading.value - qiblaAngle.value).abs();
    if (difference > 180) difference = 360 - difference;

    if (difference <= 5 && !hasVibrated) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 300);
        hasVibrated = true;

        // Cooldown reset after a few seconds
        Future.delayed(Duration(seconds: 5), () {
          hasVibrated = false;
        });
      }
    }
  }

  double get compassRotation => (heading.value - qiblaAngle.value) * (pi / 180);

  @override
  void onClose() {
    _compassSubscription?.cancel();
    _locationSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
