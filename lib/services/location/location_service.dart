import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';

class LocationService {
  final storage = GetStorage();

  // Save last known location to persistent storage
  Future<void> _saveLastLocation(Position position) async {
    await storage.write('last_latitude', position.latitude);
    await storage.write('last_longitude', position.longitude);
    await storage.write('last_location_time', DateTime.now().toIso8601String());
  }

  // Get last saved location from storage
  Position? _getSavedLocation() {
    try {
      final lat = storage.read('last_latitude');
      final lon = storage.read('last_longitude');
      final timeStr = storage.read('last_location_time');

      if (lat != null && lon != null) {
        return Position(
          latitude: lat,
          longitude: lon,
          timestamp: timeStr != null ? DateTime.parse(timeStr) : DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
    } catch (e) {
      print('Error getting saved location: $e');
    }
    return null;
  }

  Future<Position> getCurrentPosition({bool forceAndroidFusedLocation = false}) async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Try to get last known position
        final lastPos = await getLastKnownPosition();
        if (lastPos != null) {
          print('📍 Using last known position (location service disabled)');
          return lastPos;
        }

        throw _LocationException(
          'Location services are disabled',
          'Please enable your location for more accurate results',
        );
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Try last known position
          final lastPos = await getLastKnownPosition();
          if (lastPos != null) {
            print('📍 Using last known position (permission denied)');
            return lastPos;
          }

          throw _LocationException(
            'Location permissions denied',
            'Please grant location permissions to use this feature',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Try last known position
        final lastPos = await getLastKnownPosition();
        if (lastPos != null) {
          print('📍 Using last known position (permission denied forever)');
          return lastPos;
        }

        throw _LocationException(
          'Location permissions permanently denied',
          'Please enable location permissions in app settings',
        );
      }

      // Try to get current position with timeout
      try {
        final position =
            await Geolocator.getCurrentPosition(
              locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
              forceAndroidLocationManager: !forceAndroidFusedLocation,
            ).timeout(
              const Duration(seconds: 10),
              onTimeout: () async {
                print('⏱️ Location request timed out, using last known position');
                final lastPos = await getLastKnownPosition();
                if (lastPos != null) {
                  return lastPos;
                }
                throw Exception('Location timeout');
              },
            );

        // Save this location for future use
        await _saveLastLocation(position);
        print('✅ Got current location: ${position.latitude}, ${position.longitude}');
        return position;
      } catch (e) {
        // Fallback to last known position
        print('⚠️ Error getting current position: $e');
        final lastPos = await getLastKnownPosition();
        if (lastPos != null) {
          print('📍 Using last known position as fallback');
          return lastPos;
        }
        rethrow;
      }
    } catch (e) {
      // Final fallback - try last known position
      final lastPos = await getLastKnownPosition();
      if (lastPos != null) {
        print('📍 Using last known position (final fallback)');
        return lastPos;
      }

      throw _LocationException(
        'Failed to get location',
        'Could not determine your current location. Please check your location settings and try again',
      );
    }
  }

  Future<Position?> getLastKnownPosition() async {
    try {
      // Try Geolocator's last known position first
      final geoPos = await Geolocator.getLastKnownPosition(forceAndroidLocationManager: true);

      if (geoPos != null) {
        await _saveLastLocation(geoPos);
        return geoPos;
      }

      // Fallback to saved location from storage
      return _getSavedLocation();
    } catch (e) {
      print('Error getting last known position: $e');
      // Return saved location as last resort
      return _getSavedLocation();
    }
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 10),
    ).handleError((error) {
      throw _LocationException(
        'Location tracking error',
        'Could not track your location. Please ensure location services are enabled',
      );
    });
  }
}

class _LocationException implements Exception {
  final String title;
  final String userMessage;

  _LocationException(this.title, this.userMessage);

  @override
  String toString() => title;
}
