import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentPosition({
    bool forceAndroidFusedLocation = false,
  }) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw _LocationException(
        'Location services are disabled',
        'Please enable your location for more accurate results',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw _LocationException(
          'Location permissions denied',
          'Please grant location permissions to use this feature',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw _LocationException(
        'Location permissions permanently denied',
        'Please enable location permissions in app settings',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
        forceAndroidLocationManager: !forceAndroidFusedLocation,
      );
    } catch (e) {
      throw _LocationException(
        'Failed to get location',
        'Could not determine your current location. Please try again',
      );
    }
  }

  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition(
        forceAndroidLocationManager: true,
      );
    } catch (e) {
      return null;
    }
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
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
