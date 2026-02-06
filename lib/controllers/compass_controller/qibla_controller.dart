import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vibration/vibration.dart';
import '../../services/connectivity/connectivity_service.dart';
import '../../services/location/location_service.dart';

class QiblaController extends GetxController {
  final LocationService locationService;
  final ConnectivityService connectivityService;

  QiblaController({required this.locationService, required this.connectivityService});

  // Kaaba coordinates
  static const double kaabaLat = 21.422487;
  static const double kaabaLng = 39.826206;
  bool hasVibrated = false;
  // List of Qibla icons
  static const List<String> qiblaIconsList = ["assets/icons/qibla1.png", "assets/icons/qibla2.png"];

  // Observables
  var heading = 0.0.obs;
  var qiblaAngle = 0.0.obs;
  var manualQiblaAngle = 0.0.obs; // For manual Qibla direction when no location
  var useManualQibla = false.obs; // Flag to use manual Qibla angle
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

  // Compass state management
  var isCompassPaused = false.obs;
  DateTime? _lastCompassUpdate;
  int _compassUpdateInterval = 100; // milliseconds, adaptive

  // Vibration caching — avoid platform call every tick
  bool? _hasVibratorCached;

  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
    _initCompass();
    // Initialize Qibla with manual angle (will be overridden if location becomes available)
    _calculateQiblaDirection();
    // Initialize connectivity and location in background to prevent blocking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initConnectivity();
      _checkLocationPermissionStatus();
    });
  }

  void _checkLocationPermissionStatus() async {
    try {
      // Add longer timeout for physical devices
      LocationPermission permission = await Geolocator.checkPermission().timeout(
        const Duration(seconds: 8),
        onTimeout: () => LocationPermission.denied,
      );

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
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

    // Load manual Qibla angle (default to 0 degrees - North)
    manualQiblaAngle.value = storage.read('manualQiblaAngle') ?? 0.0;

    // Load cached Qibla angle for instant offline display
    final cachedQibla = storage.read('cachedQiblaAngle');
    if (cachedQibla != null) {
      qiblaAngle.value = cachedQibla;
    }

    // Load selected city for offline mode
    final savedCityIndex = storage.read('selectedCityIndex') ?? -1;
    selectedCityIndex.value = savedCityIndex;

    // If a city was previously selected, load its coordinates immediately
    if (savedCityIndex >= 0 && savedCityIndex < popularCities.length) {
      final city = popularCities[savedCityIndex];
      final lat = city['lat'] as double;
      final lng = city['lng'] as double;

      // Update current location with saved city coordinates
      currentLocation.value = Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      locationReady.value = true;
      locationError.value = 'Using ${city['name']}';
      _calculateDistanceToKaaba();
      print('✅ Loaded saved city: ${city['name']}');
    } else {
      // If no city is selected, try to load cached GPS location
      final cachedLat = storage.read('lastKnownLat');
      final cachedLng = storage.read('lastKnownLng');

      if (cachedLat != null && cachedLng != null) {
        currentLocation.value = Position(
          latitude: cachedLat,
          longitude: cachedLng,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );

        locationReady.value = true;
        locationError.value = 'Using cached location';
        _calculateDistanceToKaaba();
        print('✅ Loaded cached GPS location: ($cachedLat, $cachedLng)');
      }
    }
  }

  // Popular cities with coordinates for offline Qibla calculation
  static const List<Map<String, dynamic>> popularCities = [
    {'name': 'New York, USA', 'lat': 40.7128, 'lng': -74.0060},
    {'name': 'London, UK', 'lat': 51.5074, 'lng': -0.1278},
    {'name': 'Paris, France', 'lat': 48.8566, 'lng': 2.3522},
    {'name': 'Dubai, UAE', 'lat': 25.2048, 'lng': 55.2708},
    {'name': 'Karachi, Pakistan', 'lat': 24.8607, 'lng': 67.0011},
    {'name': 'Lahore, Pakistan', 'lat': 31.5497, 'lng': 74.3436},
    {'name': 'Islamabad, Pakistan', 'lat': 33.6844, 'lng': 73.0479},
    {'name': 'Istanbul, Turkey', 'lat': 41.0082, 'lng': 28.9784},
    {'name': 'Cairo, Egypt', 'lat': 30.0444, 'lng': 31.2357},
    {'name': 'Jakarta, Indonesia', 'lat': -6.2088, 'lng': 106.8456},
    {'name': 'Kuala Lumpur, Malaysia', 'lat': 3.1390, 'lng': 101.6869},
    {'name': 'Riyadh, Saudi Arabia', 'lat': 24.7136, 'lng': 46.6753},
    {'name': 'Jeddah, Saudi Arabia', 'lat': 21.5433, 'lng': 39.1728},
    {'name': 'Mumbai, India', 'lat': 19.0760, 'lng': 72.8777},
    {'name': 'Delhi, India', 'lat': 28.7041, 'lng': 77.1025},
    {'name': 'Dhaka, Bangladesh', 'lat': 23.8103, 'lng': 90.4125},
    {'name': 'Toronto, Canada', 'lat': 43.6532, 'lng': -79.3832},
    {'name': 'Sydney, Australia', 'lat': -33.8688, 'lng': 151.2093},
    {'name': 'Berlin, Germany', 'lat': 52.5200, 'lng': 13.4050},
    {'name': 'Los Angeles, USA', 'lat': 34.0522, 'lng': -118.2437},
  ];

  var selectedCityIndex = (-1).obs;
  var distanceToKaaba = 0.0.obs;

  // Select city for offline Qibla calculation
  void selectCity(int index) {
    if (index >= 0 && index < popularCities.length) {
      selectedCityIndex.value = index;
      storage.write('selectedCityIndex', index);

      final city = popularCities[index];
      final lat = city['lat'] as double;
      final lng = city['lng'] as double;

      // Update current location with city coordinates
      currentLocation.value = Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

      locationReady.value = true;
      locationError.value = 'Using ${city['name']}';
      _calculateQiblaDirection();
      _calculateDistanceToKaaba();
    }
  }

  // Use current GPS location instead of offline city
  Future<void> useCurrentLocation() async {
    try {
      // Clear selected city
      selectedCityIndex.value = -1;
      storage.remove('selectedCityIndex');

      locationError.value = 'Getting current location...';

      // Check location service
      if (!await Geolocator.isLocationServiceEnabled()) {
        locationError.value = 'Location services are disabled';
        _showErrorSnackbar('Please enable location services');
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationError.value = 'Location permission denied';
          _showErrorSnackbar('Location permission is required');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationError.value = 'Enable location in settings';
        _showErrorSnackbar('Please enable location in settings');
        return;
      }

      // Get current position
      currentLocation.value = await locationService
          .getCurrentPosition(forceAndroidFusedLocation: isOnline.value)
          .timeout(const Duration(seconds: 10));

      locationReady.value = true;
      locationError.value = '';
      _calculateQiblaDirection();
      _calculateDistanceToKaaba();
      lastUpdateTime.value = DateTime.now();

      // Cache the GPS location
      storage.write('lastKnownLat', currentLocation.value.latitude);
      storage.write('lastKnownLng', currentLocation.value.longitude);

      Get.snackbar(
        'Success',
        'Using your current location',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      print('✅ Switched to current GPS location');
    } catch (e) {
      locationError.value = 'Failed to get location: $e';
      _showErrorSnackbar('Could not get current location. Please try again.');
      print('❌ Error getting current location: $e');
    }
  }

  // Refresh Qibla direction
  Future<void> refreshQibla() async {
    try {
      locationError.value = 'Refreshing...';

      // If a city is selected, just recalculate
      if (selectedCityIndex.value >= 0) {
        _calculateQiblaDirection();
        _calculateDistanceToKaaba();
        locationError.value = 'Using ${popularCities[selectedCityIndex.value]['name']}';

        Get.snackbar(
          'Refreshed',
          'Qibla direction updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF8F66FF),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // Otherwise get fresh GPS location
      if (!await Geolocator.isLocationServiceEnabled()) {
        locationError.value = 'Location services are disabled';
        _showErrorSnackbar('Please enable location services');
        return;
      }

      currentLocation.value = await locationService
          .getCurrentPosition(forceAndroidFusedLocation: isOnline.value)
          .timeout(const Duration(seconds: 10));

      locationReady.value = true;
      locationError.value = '';
      _calculateQiblaDirection();
      _calculateDistanceToKaaba();
      lastUpdateTime.value = DateTime.now();

      // Cache the GPS location
      storage.write('lastKnownLat', currentLocation.value.latitude);
      storage.write('lastKnownLng', currentLocation.value.longitude);

      Get.snackbar(
        'Refreshed',
        'Qibla direction updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF8F66FF),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      print('✅ Qibla direction refreshed');
    } catch (e) {
      locationError.value = 'Failed to refresh';
      _showErrorSnackbar('Could not refresh. Please try again.');
      print('❌ Error refreshing Qibla: $e');
    }
  }

  // Calculate distance to Kaaba using Haversine formula
  void _calculateDistanceToKaaba() {
    if (!locationReady.value) {
      distanceToKaaba.value = 0;
      return;
    }

    const double R = 6371; // Earth's radius in km
    final double lat1 = currentLocation.value.latitude * pi / 180;
    final double lat2 = kaabaLat * pi / 180;
    final double dLat = (kaabaLat - currentLocation.value.latitude) * pi / 180;
    final double dLon = (kaabaLng - currentLocation.value.longitude) * pi / 180;

    final double a =
        sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    distanceToKaaba.value = R * c;
  }

  // Get formatted distance string
  String get formattedDistance {
    if (distanceToKaaba.value == 0) return 'Unknown';
    if (distanceToKaaba.value < 1) {
      return '${(distanceToKaaba.value * 1000).round()} m';
    }
    return '${distanceToKaaba.value.round()} km';
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

  // Manual Qibla angle adjustment methods
  void setManualQiblaAngle(double angle) {
    manualQiblaAngle.value = (angle + 360) % 360;
    storage.write('manualQiblaAngle', manualQiblaAngle.value);
    if (!locationReady.value) {
      _calculateQiblaDirection(); // Update display
    }
    update();
  }

  void adjustManualQiblaAngle(double delta) {
    setManualQiblaAngle(manualQiblaAngle.value + delta);
  }

  void _initCompass() {
    if (FlutterCompass.events == null) {
      compassError.value = 'Compass not available on this device';
      _showErrorSnackbar(compassError.value);
      return;
    }

    _compassSubscription = FlutterCompass.events?.listen(
      (event) {
        // Adaptive refresh rate - throttle updates based on movement
        final now = DateTime.now();
        if (_lastCompassUpdate != null) {
          final timeSinceLastUpdate = now.difference(_lastCompassUpdate!).inMilliseconds;

          // Skip update if too frequent (adaptive throttling)
          if (timeSinceLastUpdate < _compassUpdateInterval) {
            return;
          }
        }
        _lastCompassUpdate = now;

        // Store old heading for comparison
        final oldHeading = heading.value;
        final newHeading = event.heading ?? 0.0;

        // Calculate heading change
        final headingChange = (newHeading - oldHeading).abs();

        // Skip tiny changes to avoid unnecessary rebuilds
        if (headingChange < 0.5) return;

        heading.value = newHeading;

        // Adaptive interval based on movement
        if (headingChange > 5) {
          _compassUpdateInterval = 100; // Fast updates when turning
        } else if (headingChange > 1) {
          _compassUpdateInterval = 300; // Medium updates
        } else {
          _compassUpdateInterval = 1000; // Slow updates when stable
        }

        _calculateQiblaDirection();
        _checkQiblaAlignmentAndVibrate();
        lastUpdateTime.value = now;

        // Check compass accuracy
        calibrationNeeded.value = event.accuracy != null && event.accuracy! <= 0.3;

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
    // No update() here — Obx will react to heading.value changes automatically
  }

  Future<void> _checkQiblaAlignmentAndVibrate() async {
    if (!isVibrationEnabled.value || hasVibrated) return;

    double difference = (heading.value - qiblaAngle.value).abs();
    if (difference > 180) difference = 360 - difference;

    if (difference <= 5) {
      // Cache vibrator check — only query platform once
      _hasVibratorCached ??= await Vibration.hasVibrator();
      if (_hasVibratorCached == true) {
        Vibration.vibrate(duration: 300);
        hasVibrated = true;

        // Reset vibration flag after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          hasVibrated = false;
        });
      }
    }
    // Removed update() — Obx handles reactive updates automatically
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

      // First, try to get last known position immediately (instant offline mode)
      Position? lastPosition = await locationService.getLastKnownPosition();
      if (lastPosition != null) {
        currentLocation.value = lastPosition;
        locationReady.value = true;
        locationError.value = 'Using offline mode';
        _calculateQiblaDirection();
        lastUpdateTime.value = DateTime.now();
        print('✅ Instant offline mode activated');
      }

      // Then try to get current position (online or pure GPS)
      try {
        currentLocation.value = await locationService
            .getCurrentPosition(forceAndroidFusedLocation: isOnline.value)
            .timeout(const Duration(seconds: 8));

        locationReady.value = true;
        locationError.value = '';
        _calculateQiblaDirection();
        lastUpdateTime.value = DateTime.now();

        // Cache the GPS location for next app start
        storage.write('lastKnownLat', currentLocation.value.latitude);
        storage.write('lastKnownLng', currentLocation.value.longitude);

        print('✅ Location updated (${isOnline.value ? "online" : "GPS"} mode)');
      } catch (e) {
        // If we already have last known position, just continue with it
        if (lastPosition != null) {
          print('ℹ️ Continuing with offline mode: $e');
        } else {
          throw Exception('Could not get location');
        }
      }

      // Start listening for location updates (throttled storage writes)
      DateTime lastLocationSave = DateTime.now();
      _locationSubscription = locationService.getPositionStream().listen(
        (position) {
          currentLocation.value = position;
          locationReady.value = true;
          _calculateQiblaDirection();
          lastUpdateTime.value = DateTime.now();

          // Throttle storage writes — save at most once per 30 seconds
          final now = DateTime.now();
          if (now.difference(lastLocationSave).inSeconds >= 30) {
            storage.write('lastKnownLat', position.latitude);
            storage.write('lastKnownLng', position.longitude);
            lastLocationSave = now;
          }
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
    if (!locationReady.value) {
      // Use manual Qibla angle when location is not available
      useManualQibla.value = true;
      qiblaAngle.value = manualQiblaAngle.value;
      return;
    }

    // Location is available, calculate accurate Qibla
    useManualQibla.value = false;
    final double lat = currentLocation.value.latitude;
    final double lng = currentLocation.value.longitude;

    final double phiK = kaabaLat * pi / 180.0;
    final double lambdaK = kaabaLng * pi / 180.0;
    final double phi = lat * pi / 180.0;
    final double lambda = lng * pi / 180.0;

    final double psi =
        180.0 /
        pi *
        atan2(sin(lambdaK - lambda), cos(phi) * tan(phiK) - sin(phi) * cos(lambdaK - lambda));

    qiblaAngle.value = (psi + 360) % 360; // Normalize to 0-360 degrees

    // Cache the calculated Qibla angle for offline use
    storage.write('cachedQiblaAngle', qiblaAngle.value);

    // Calculate distance to Kaaba
    _calculateDistanceToKaaba();

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

  // Pause compass updates to save battery
  void pauseCompass() {
    if (!isCompassPaused.value) {
      _compassSubscription?.pause();
      isCompassPaused.value = true;
      print('⏸️ Compass stream paused');
    }
  }

  // Resume compass updates
  void resumeCompass() {
    if (isCompassPaused.value) {
      _compassSubscription?.resume();
      isCompassPaused.value = false;
      print('▶️ Compass stream resumed');
    }
  }

  // Clean up all resources
  void disposeResources() {
    _compassSubscription?.cancel();
    _locationSubscription?.cancel();
    _connectivitySubscription?.cancel();
    print('✅ QiblaController disposed - all streams canceled');
  }

  @override
  void onClose() {
    disposeResources();
    super.onClose();
  }
}
