import 'dart:async';
import 'dart:math';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

/// QiblaService - Simplified wrapper for Qibla direction detection
/// Works both online (network location) and offline (GPS + magnetometer)
class QiblaService {
  // Kaaba coordinates (Mecca, Saudi Arabia)
  static const double kaabaLat = 21.422487;
  static const double kaabaLng = 39.826206;

  // Observables for reactive UI updates
  final qiblaAngle = 0.0.obs; // Direction to Qibla from North (0-360°)
  final heading = 0.0.obs; // Current phone heading from North (0-360°)
  final isLocationReady = false.obs; // Whether GPS location is available
  final isCompassReady = false.obs; // Whether magnetometer is working
  final isOnline = false.obs; // Online (network) vs Offline (GPS only)

  // Stream subscriptions
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<Position>? _positionSubscription;

  // Current position
  Position? _currentPosition;

  /// Initialize the Qibla service
  /// This starts listening to compass and location updates
  Future<void> init() async {
    print('🧭 QiblaService: Initializing...');

    // Start compass first (always works offline)
    await _initCompass();

    // Then try to get location (may need permission)
    await _initLocation();

    print('✅ QiblaService: Initialization complete');
  }

  /// Initialize compass/magnetometer
  Future<void> _initCompass() async {
    print('🧭 Initializing compass...');

    if (FlutterCompass.events == null) {
      print('❌ Compass not available on this device');
      return;
    }

    _compassSubscription = FlutterCompass.events!.listen(
      (CompassEvent event) {
        heading.value = event.heading ?? 0.0;
        isCompassReady.value = true;

        // Recalculate Qibla angle whenever heading changes
        _calculateQiblaDirection();
      },
      onError: (error) {
        print('❌ Compass error: $error');
        isCompassReady.value = false;
      },
    );
  }

  /// Initialize location service
  /// Tries online mode first, falls back to offline GPS
  Future<void> _initLocation() async {
    print('📍 Initializing location...');

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Location services are disabled');
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('⚠️ Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('⚠️ Location permission denied forever');
        return;
      }

      // Get current position
      // Try online mode first (uses network + GPS), then fallback to offline GPS
      try {
        // First, try to get last known position immediately (instant offline mode)
        _currentPosition = await Geolocator.getLastKnownPosition();

        if (_currentPosition != null) {
          isLocationReady.value = true;
          isOnline.value = false;
          _calculateQiblaDirection();
          print('✅ Using cached position (instant offline mode)');
        }

        // Then try to get current position (may use network or pure GPS)
        try {
          final newPosition = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).timeout(const Duration(seconds: 8));

          _currentPosition = newPosition;
          isOnline.value = true;
          isLocationReady.value = true;
          _calculateQiblaDirection();
          print('✅ Location updated (online mode)');
        } catch (e) {
          // Online mode failed, but we already have offline position
          print('ℹ️ Using offline GPS mode: $e');
          if (_currentPosition == null) {
            print('❌ No location available');
            return;
          }
        }
      } catch (e) {
        print('❌ Location error: $e');
        return;
      }

      if (_currentPosition != null) {
        isLocationReady.value = true;
        _calculateQiblaDirection();

        // Listen for position updates
        _positionSubscription =
            Geolocator.getPositionStream(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 10, // Update every 10 meters
              ),
            ).listen(
              (Position position) {
                _currentPosition = position;
                isLocationReady.value = true;
                _calculateQiblaDirection();
              },
              onError: (error) {
                print('❌ Position stream error: $error');
              },
            );
      }
    } catch (e) {
      print('❌ Location initialization error: $e');
      isLocationReady.value = false;
    }
  }

  /// Calculate Qibla direction from current location
  /// Uses spherical trigonometry for accurate bearing calculation
  void _calculateQiblaDirection() {
    if (_currentPosition == null) {
      // No location available, default to North
      qiblaAngle.value = 0.0;
      return;
    }

    final double lat = _currentPosition!.latitude;
    final double lng = _currentPosition!.longitude;

    // Convert to radians
    final double phiK = kaabaLat * pi / 180.0;
    final double lambdaK = kaabaLng * pi / 180.0;
    final double phi = lat * pi / 180.0;
    final double lambda = lng * pi / 180.0;

    // Calculate bearing to Kaaba using spherical trigonometry
    final double psi =
        180.0 /
        pi *
        atan2(sin(lambdaK - lambda), cos(phi) * tan(phiK) - sin(phi) * cos(lambdaK - lambda));

    // Normalize to 0-360 degrees
    qiblaAngle.value = (psi + 360) % 360;
  }

  /// Get the rotation difference between current heading and Qibla
  /// This is useful for rotating compass needle visually
  /// Returns angle in radians
  double get difference {
    final diff = (heading.value - qiblaAngle.value);
    return diff * (pi / 180);
  }

  /// Get the absolute angle difference (0-180°)
  /// Useful for checking if user is facing Qibla
  double get absoluteDifference {
    double diff = (heading.value - qiblaAngle.value).abs();
    if (diff > 180) diff = 360 - diff;
    return diff;
  }

  /// Check if user is facing Qibla (within tolerance)
  /// Default tolerance is 5 degrees
  bool isFacingQibla({double tolerance = 5.0}) {
    return absoluteDifference <= tolerance;
  }

  /// Get current location details
  Position? get currentPosition => _currentPosition;

  /// Refresh location (useful for manual refresh button)
  Future<void> refreshLocation() async {
    print('🔄 Refreshing location...');
    await _initLocation();
  }

  /// Clean up resources
  void dispose() {
    print('🗑️ QiblaService: Disposing...');
    _compassSubscription?.cancel();
    _positionSubscription?.cancel();
  }
}
