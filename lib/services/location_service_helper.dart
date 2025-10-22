import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationServiceHelper {
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Location Services',
          'Location services are disabled. Please enable them to find nearby mosques.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Location Permission',
            'Location permissions are denied. Grant permission to find nearby mosques.',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Location Permission',
          'Location permissions are permanently denied. Please enable them in settings.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      Get.snackbar(
        'Location Error',
        'Failed to get current location: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      return null;
    }
  }

  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude) /
        1000; // Convert to kilometers
  }

  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()} m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      return '${distanceInKm.round()} km';
    }
  }

  static Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}

// Sample mosque data with Pakistani locations
class MosqueDataService {
  static List<Map<String, dynamic>> getSampleMosques() {
    return [
      {
        'id': '1',
        'name': 'Badshahi Mosque',
        'address': 'Fort Road, Walled City, Lahore, Punjab',
        'latitude': 31.5878,
        'longitude': 74.3089,
        'category': 'Jamia Masjid',
        'phone': '+92-42-99213187',
        'description':
            'One of the largest mosques in the world, built by the Mughal Emperor Aurangzeb in 1673.',
        'features': ['Historic Architecture', 'Guided Tours', 'Large Capacity'],
        'prayerTimes': ['5:30 AM', '1:15 PM', '5:45 PM', '7:30 PM', '8:45 PM'],
      },
      {
        'id': '2',
        'name': 'Faisal Mosque',
        'address': 'Islamabad, Federal Capital Territory',
        'latitude': 33.7297,
        'longitude': 73.0372,
        'category': 'Jamia Masjid',
        'phone': '+92-51-9261045',
        'description':
            'The national mosque of Pakistan, designed by Turkish architect Vedat Dalokay.',
        'features': ['Modern Architecture', 'National Mosque', 'Islamic Research'],
        'prayerTimes': ['5:25 AM', '1:10 PM', '5:40 PM', '7:25 PM', '8:40 PM'],
      },
      {
        'id': '3',
        'name': 'Data Darbar Mosque',
        'address': 'Data Darbar Road, Lahore, Punjab',
        'latitude': 31.5925,
        'longitude': 74.3095,
        'category': 'Shrine Mosque',
        'phone': '+92-42-37636789',
        'description': 'Shrine of Sufi saint Data Ganj Bakhsh, a major pilgrimage site.',
        'features': ['Sufi Heritage', 'Pilgrimage Site', '24/7 Open'],
        'prayerTimes': ['5:30 AM', '1:15 PM', '5:45 PM', '7:30 PM', '8:45 PM'],
      },
      {
        'id': '4',
        'name': 'Masjid-e-Tooba',
        'address': 'Defence Housing Authority, Karachi, Sindh',
        'latitude': 24.8138,
        'longitude': 67.0713,
        'category': 'Masjid',
        'phone': '+92-21-35390123',
        'description': 'Known as the Gol Mosque, famous for its unique round architecture.',
        'features': ['Unique Design', 'No Pillars', 'Single Dome'],
        'prayerTimes': ['5:35 AM', '1:20 PM', '5:50 PM', '7:35 PM', '8:50 PM'],
      },
      {
        'id': '5',
        'name': 'Masjid Wazir Khan',
        'address': 'Wazir Khan Chowk, Lahore, Punjab',
        'latitude': 31.5825,
        'longitude': 74.3167,
        'category': 'Historic Mosque',
        'phone': '+92-42-37654321',
        'description':
            'A 17th-century mosque famous for its elaborate Mughal architecture and tile work.',
        'features': ['Mughal Architecture', 'Tile Work', 'Historic Site'],
        'prayerTimes': ['5:30 AM', '1:15 PM', '5:45 PM', '7:30 PM', '8:45 PM'],
      },
      {
        'id': '6',
        'name': 'Masjid Shah Faisal',
        'address': 'Gulberg, Lahore, Punjab',
        'latitude': 31.5497,
        'longitude': 74.3436,
        'category': 'Community Mosque',
        'phone': '+92-42-35714298',
        'description': 'Modern community mosque serving the Gulberg area with various facilities.',
        'features': ['Community Center', 'Islamic School', 'Prayer Hall'],
        'prayerTimes': ['5:30 AM', '1:15 PM', '5:45 PM', '7:30 PM', '8:45 PM'],
      },
      {
        'id': '7',
        'name': 'Grand Jamia Mosque',
        'address': 'Bahria Town, Karachi, Sindh',
        'latitude': 24.8607,
        'longitude': 67.1011,
        'category': 'Jamia Masjid',
        'phone': '+92-21-34570901',
        'description': 'Large modern mosque complex with educational and community facilities.',
        'features': ['Modern Facilities', 'Educational Complex', 'Community Services'],
        'prayerTimes': ['5:35 AM', '1:20 PM', '5:50 PM', '7:35 PM', '8:50 PM'],
      },
      {
        'id': '8',
        'name': 'Masjid-e-Nabvi',
        'address': 'Model Town, Lahore, Punjab',
        'latitude': 31.4881,
        'longitude': 74.3436,
        'category': 'Community Mosque',
        'phone': '+92-42-35923456',
        'description': 'Well-maintained community mosque with regular Islamic programs.',
        'features': ['Regular Programs', 'Youth Activities', 'Quranic Classes'],
        'prayerTimes': ['5:30 AM', '1:15 PM', '5:45 PM', '7:30 PM', '8:45 PM'],
      },
    ];
  }

  static List<Map<String, dynamic>> getMosquesNearLocation(
    double latitude,
    double longitude, {
    double radiusKm = 50.0,
  }) {
    final allMosques = getSampleMosques();
    final nearbyMosques = <Map<String, dynamic>>[];

    for (var mosque in allMosques) {
      double distance = LocationServiceHelper.calculateDistance(
        latitude,
        longitude,
        mosque['latitude'],
        mosque['longitude'],
      );

      if (distance <= radiusKm) {
        mosque['distance'] = distance;
        nearbyMosques.add(mosque);
      }
    }

    // Sort by distance
    nearbyMosques.sort((a, b) => a['distance'].compareTo(b['distance']));
    return nearbyMosques;
  }
}
