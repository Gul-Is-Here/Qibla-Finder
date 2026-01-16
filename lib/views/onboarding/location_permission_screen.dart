import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import '../../routes/app_pages.dart';
import '../../services/location/location_service.dart';
import '../../controllers/prayer_controller/prayer_times_controller.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  // App Theme Colors
  static const Color primaryPurple = Color(0xFF8F66FF);
  static const Color lightPurple = Color(0xFFAB80FF);
  static const Color darkPurple = Color(0xFF2D1B69);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SizedBox(height: isSmallScreen ? 20 : 30),

              // Title at top
              SizedBox(height: isSmallScreen ? 10 : 20),

              // Location icon
              Container(
                width: isSmallScreen ? 120 : 150,
                height: isSmallScreen ? 120 : 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryPurple.withOpacity(0.2), lightPurple.withOpacity(0.1)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: isSmallScreen ? 60 : 80,
                  color: primaryPurple,
                ),
              ),

              SizedBox(height: isSmallScreen ? 20 : 30),

              // Title
              Text(
                'Find Qibla Direction',
                style: GoogleFonts.poppins(
                  fontSize: isSmallScreen ? 24 : 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isSmallScreen ? 8 : 12),

              // Description
              Text(
                'We need your location to show accurate Qibla direction and prayer times for your area.',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600], height: 1.4),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isSmallScreen ? 20 : 30),

              // Features list
              _buildFeature(
                icon: Icons.explore_rounded,
                title: 'Accurate Qibla',
                description: 'Find Kaaba direction from anywhere',
              ),
              const SizedBox(height: 14),
              _buildFeature(
                icon: Icons.mosque_rounded,
                title: 'Local Prayer Times',
                description: 'Precise times for your location',
              ),
              const SizedBox(height: 14),
              _buildFeature(
                icon: Icons.map_rounded,
                title: 'Nearby Mosques',
                description: 'Discover mosques around you',
              ),

              SizedBox(height: isSmallScreen ? 30 : 40),

              // Allow button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => _requestLocationPermission(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Allow Location Access',
                    style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              SizedBox(height: isSmallScreen ? 20 : 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryPurple, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(description, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _requestLocationPermission(BuildContext context) async {
    try {
      final locationService = Get.find<LocationService>();

      // Request location permission
      Position? position;
      try {
        position = await locationService.getCurrentPosition();
      } catch (e) {
        // Permission denied - show mandatory dialog
        print('📍 Location access required for app functionality');
        _showLocationRequiredDialog(context);
        return;
      }

      // Permission granted - show loading dialog and preload data
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF8F66FF)),
                  const SizedBox(height: 20),
                  Text(
                    'Setting Up Your App...',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D1B69),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Loading prayer times and Qibla direction for your location',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600], height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Get or initialize prayer times controller
      PrayerTimesController prayerController;
      if (Get.isRegistered<PrayerTimesController>()) {
        prayerController = Get.find<PrayerTimesController>();
      } else {
        prayerController = Get.put(PrayerTimesController());
      }

      // Fetch and cache prayer times (including monthly data)
      await prayerController.fetchPrayerTimes();
      await prayerController.fetchAndCacheMonthlyPrayerTimes();

      // Cache Qibla direction
      await _cacheQiblaDirection(position);

      // Close loading dialog
      Get.back();

      // Check if data was loaded successfully
      if (prayerController.prayerTimes.value != null) {
        // Success - save location permission flag and complete onboarding
        final storage = GetStorage();
        await storage.write('location_permission_granted', true);
        print('✅ Location permission granted flag set to: true');
        print('🔍 Current storage keys: ${storage.getKeys()}');
        _completeOnboarding();
      } else {
        // Failed to load - show error and stay on this screen
        _showDataLoadErrorDialog(context);
      }
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print('Error requesting location permission: $e');

      // Show error dialog
      _showDataLoadErrorDialog(context);
    }
  }

  Future<void> _cacheQiblaDirection(position) async {
    try {
      // Calculate Qibla angle
      const double kaabaLat = 21.422487;
      const double kaabaLng = 39.826206;

      final lat1 = position.latitude * (3.141592653589793 / 180);
      final lng1 = position.longitude * (3.141592653589793 / 180);
      final lat2 = kaabaLat * (3.141592653589793 / 180);
      final lng2 = kaabaLng * (3.141592653589793 / 180);

      final dLng = lng2 - lng1;
      final y = sin(dLng) * cos(lat2);
      final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
      final qiblaAngle = atan2(y, x) * (180 / 3.141592653589793);

      // Save to storage for offline use
      final storage = GetStorage();
      await storage.write('cachedQiblaAngle', qiblaAngle);
      await storage.write('cachedUserLatitude', position.latitude);
      await storage.write('cachedUserLongitude', position.longitude);

      print('✅ Qibla direction cached: ${qiblaAngle.toStringAsFixed(2)}°');
    } catch (e) {
      print('⚠️ Error caching Qibla direction: $e');
    }
  }

  void _showLocationRequiredDialog(BuildContext context) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.location_off, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Text(
                'Location Required',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'This app needs your location to:\n\n'
            '• Show accurate Qibla direction\n'
            '• Calculate prayer times for your area\n'
            '• Find nearby mosques\n\n'
            'Without location access, the app cannot function properly.\n\n'
            'Please enable location permission in your device settings.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Get.back();

                // Show helpful message
                Get.snackbar(
                  'Opening Settings',
                  'Please enable location permission and return to the app',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: primaryPurple,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 3),
                  icon: const Icon(Icons.settings, color: Colors.white),
                );

                // Open app settings
                await Geolocator.openAppSettings();

                // Wait for user to return from settings (give them time)
                await Future.delayed(const Duration(seconds: 2));

                // Retry permission request after settings
                _requestLocationPermission(context);
              },
              child: Text(
                'Open Settings',
                style: GoogleFonts.poppins(
                  color: primaryPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _showDataLoadErrorDialog(BuildContext context) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              Text(
                'Setup Failed',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Unable to load prayer times. Please check your internet connection and try again.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                // Retry data loading
                _requestLocationPermission(context);
              },
              child: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  color: primaryPurple,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _completeOnboarding() async {
    // Mark onboarding as completed
    final storage = GetStorage();
    await storage.write('onboarding_completed', true);

    // Add small delay to ensure storage write completes
    await Future.delayed(const Duration(milliseconds: 100));

    print('✅ Onboarding completed flag set to: true');
    print('🔍 Final storage state:');
    print('   onboarding_completed: ${storage.read('onboarding_completed')}');
    print('   location_permission_granted: ${storage.read('location_permission_granted')}');

    // Navigate to main screen
    Get.offAllNamed(Routes.MAIN);
  }
}
