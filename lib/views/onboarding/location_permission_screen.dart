import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
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

              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _completeOnboarding(),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

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

              const SizedBox(height: 12),

              // Later button
              TextButton(
                onPressed: () => _completeOnboarding(),
                child: Text(
                  'Maybe Later',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
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

      // Try to get current position which will request permission if needed
      await locationService.getCurrentPosition();

      // Show loading dialog
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF8F66FF)),
                  const SizedBox(height: 16),
                  Text(
                    'Loading Prayer Times...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D1B69),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while we fetch your prayer times and Qibla direction',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
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

      // Fetch prayer times and Qibla data
      await prayerController.fetchPrayerTimes();

      // Close loading dialog
      Get.back();

      // Check if fetch was successful
      if (prayerController.errorMessage.value.isNotEmpty) {
        // Show error but allow user to continue
        Get.snackbar(
          'Notice',
          'Could not load prayer times. You can try again from the app.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        // Show success message
        Get.snackbar(
          'Success',
          'Prayer times loaded successfully',
          backgroundColor: primaryPurple,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }

      // Complete onboarding and navigate to main screen
      _completeOnboarding();
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print('Error requesting location permission: $e');

      Get.snackbar(
        'Location Required',
        'Please enable location to use all features',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Still complete onboarding even if error occurs
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    // Mark onboarding as completed
    final storage = GetStorage();
    storage.write('onboarding_completed', true);

    // Navigate to main screen
    Get.offAllNamed(Routes.MAIN);
  }
}
