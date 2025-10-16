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

  // Settings toggles
  var isVibrationEnabled = true.obs;
  var isSoundEnabled = false.obs;

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
    // Initialize connectivity and location in background to prevent blocking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initConnectivity();
      _checkLocationPermissionStatus();
    });
  }

  void _checkLocationPermissionStatus() async {
    try {
      // Add longer timeout for physical devices
      LocationPermission permission = await Geolocator.checkPermission()
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => LocationPermission.denied,
          );

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Permission already granted, initialize location with delay for physical devices
        Future.delayed(const Duration(milliseconds: 500), () {
          try {
            _initLocation();
          } catch (e) {
            print('Location initialization error: $e');
          }
        });
      } else {
        // Permission not granted, show message but don't auto-request
        locationError.value = 'Tap Recalibrate to enable location';
      }
    } catch (e) {
      print('Location permission check error: ${e.toString()}');
      locationError.value = 'Location not available';
      // Don't block the app even if location fails
    }
  }

  void _loadPreferences() {
    final savedIcon = storage.read('selectedQiblaIcon');
    if (savedIcon != null && qiblaIconsList.contains(savedIcon)) {
      selectedQiblaIcon.value = savedIcon;
    }

    // Load vibration and sound settings
    isVibrationEnabled.value = storage.read('isVibrationEnabled') ?? true;
    isSoundEnabled.value = storage.read('isSoundEnabled') ?? false;
  }

  // Toggle methods for settings
  void toggleVibration(bool value) {
    isVibrationEnabled.value = value;
    storage.write('isVibrationEnabled', value);
  }

  void toggleSound(bool value) {
    isSoundEnabled.value = value;
    storage.write('isSoundEnabled', value);
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

    if (difference <= 5 && !hasVibrated && isVibrationEnabled.value) {
      if (await Vibration.hasVibrator()) {
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
        return;
      }

      // Check permissions without auto-requesting
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        locationError.value = 'Location permission needed';
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        locationError.value = 'Enable location in settings';
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
    try {
      // Use timeout to prevent hanging
      isOnline.value = await connectivityService.hasConnection().timeout(
        const Duration(seconds: 3),
        onTimeout: () => false,
      );

      _connectivitySubscription = connectivityService.connectionStream.listen(
        (status) {
          isOnline.value = status;
          if (status) {
            // When coming online, refresh location
            _initLocation();
          }
        },
        onError: (error) {
          print('Connectivity error: ${error.toString()}');
          isOnline.value = false;
        },
      );
    } catch (e) {
      print('Connectivity initialization error: ${e.toString()}');
      isOnline.value = false;
    }
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

  void retryLocation() async {
    locationError.value = '';

    try {
      // Check location service
      if (!await Geolocator.isLocationServiceEnabled()) {
        locationError.value = 'Please enable location services';
        return;
      }

      // Check and request permissions when user manually triggers
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationError.value = 'Location permission denied';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationError.value = 'Enable location in device settings';
        return;
      }

      // Now initialize location with permission granted
      _initLocation();
    } catch (e) {
      locationError.value = 'Failed to get location';
    }

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

    if (difference <= 5 && !hasVibrated && isVibrationEnabled.value) {
      if (await Vibration.hasVibrator()) {
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
