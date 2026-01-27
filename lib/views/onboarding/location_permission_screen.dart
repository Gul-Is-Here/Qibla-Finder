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
  static const Color goldAccent = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D1B69), // Dark purple
              Color(0xFF8F66FF), // Primary purple
              Color(0xFFAB80FF), // Light purple
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(height: isSmallScreen ? 20 : 30),

                  // Location icon with glow
                  Container(
                    width: isSmallScreen ? 100 : 120,
                    height: isSmallScreen ? 100 : 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: primaryPurple)],
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      size: isSmallScreen ? 80 : 80,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 30),

                  // Title
                  Text(
                    'Find Qibla Direction',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 24 : 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isSmallScreen ? 8 : 12),

                  // Description
                  Text(
                    'We need your location to show accurate Qibla direction and prayer times for your area.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Additional prominent disclosure notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: goldAccent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Location used only for Qibla, prayer times & mosque finder',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.95),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: () => _requestLocationPermission(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldAccent,
                        foregroundColor: darkPurple,
                        elevation: 8,
                        shadowColor: goldAccent.withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.location_on, size: 22, color: Colors.white),
                      label: Text(
                        'Allow Location Access',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Privacy policy link
                  TextButton(
                    onPressed: () => _showPrivacyDetails(),
                    child: Text(
                      'Learn more about how we use your location',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Show detailed privacy information
  void _showPrivacyDetails() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [goldAccent.withOpacity(0.2), goldAccent.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.privacy_tip_outlined, color: goldAccent, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Privacy & Data Usage',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkPurple,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How We Use Your Location:',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: darkPurple,
                ),
              ),
              const SizedBox(height: 12),
              _buildPrivacyPoint('Your location is used ONLY when the app is active (foreground)'),
              _buildPrivacyPoint(
                'We calculate Qibla direction using your coordinates and Kaaba location',
              ),
              _buildPrivacyPoint(
                'Prayer times are fetched from Islamic APIs based on your location',
              ),
              _buildPrivacyPoint('Nearby mosques are found using your current position'),
              const SizedBox(height: 16),
              Text(
                'Data Protection:',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: darkPurple,
                ),
              ),
              const SizedBox(height: 12),
              _buildPrivacyPoint('Location data is NOT stored on external servers'),
              _buildPrivacyPoint('We do NOT share your location with third parties'),
              _buildPrivacyPoint('We do NOT sell your personal information'),
              _buildPrivacyPoint('Location is cached locally only for offline access'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryPurple.withOpacity(0.1), lightPurple.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryPurple.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_user, color: goldAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your privacy is our priority. We collect only what\'s necessary for app functionality.',
                        style: GoogleFonts.poppins(fontSize: 12, color: darkPurple, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Got it',
              style: GoogleFonts.poppins(
                color: goldAccent,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: goldAccent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700], height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: primaryPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryPurple, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryPurple, primaryPurple],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
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
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingLine(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isActive ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive ? goldAccent.withOpacity(0.3) : Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(goldAccent),
              ),
            )
          else
            Icon(Icons.check_circle_rounded, color: goldAccent.withOpacity(0.5), size: 14),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(isActive ? 0.95 : 0.7),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestLocationPermission(BuildContext context) async {
    // FIRST: Show Prominent Disclosure Dialog (Google Play Requirement)
    final accepted = await _showProminentDisclosureDialog();
    if (accepted != true) {
      // User declined - don't proceed
      return;
    }

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

      // Permission granted - show beautiful loading dialog and preload data
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2D1B69), // Dark purple
                    Color(0xFF8F66FF), // Primary purple
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: primaryPurple.withOpacity(0.4), blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated loading indicator with golden ring
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(goldAccent),
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.mosque_rounded, color: goldAccent, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Setting Up Everything...',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Loading prayer times and Qibla direction for your location',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.5,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Progress lines
                  _buildLoadingLine('Fetching location data', true),
                  const SizedBox(height: 8),
                  _buildLoadingLine('Calculating Qibla direction', true),
                  const SizedBox(height: 8),
                  _buildLoadingLine('Loading prayer times', true),
                  const SizedBox(height: 8),
                  _buildLoadingLine('Setting up your preferences', false),
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

  /// GOOGLE PLAY REQUIREMENT: Prominent Disclosure Dialog
  /// This dialog must be shown BEFORE requesting location permission
  /// to explain HOW location data will be used
  Future<bool?> _showProminentDisclosureDialog() async {
    return await Get.dialog<bool>(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryPurple.withOpacity(0.2), lightPurple.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.privacy_tip_rounded, color: goldAccent, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Location Data Usage',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This app collects your location data to:',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDisclosureItem(
                  icon: Icons.explore,
                  title: 'Qibla Direction',
                  description:
                      'Calculate accurate direction to Makkah (Kaaba) from your current location',
                ),
                const SizedBox(height: 12),
                _buildDisclosureItem(
                  icon: Icons.access_time,
                  title: 'Prayer Times',
                  description:
                      'Provide precise Islamic prayer times (Fajr, Dhuhr, Asr, Maghrib, Isha) based on your geographic coordinates',
                ),
                const SizedBox(height: 12),
                _buildDisclosureItem(
                  icon: Icons.mosque,
                  title: 'Nearby Mosques',
                  description: 'Show mosques and Islamic centers near your location with distances',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryPurple.withOpacity(0.1), lightPurple.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryPurple.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.verified_user, color: goldAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your location is used ONLY while the app is active. We do NOT share, sell, or store your location data on external servers.',
                          style: GoogleFonts.poppins(fontSize: 12, color: darkPurple, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Decline',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: goldAccent,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: goldAccent.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Accept & Continue',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: darkPurple,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildDisclosureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [goldAccent.withOpacity(0.2), goldAccent.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: goldAccent, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkPurple,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700], height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.withOpacity(0.2), Colors.red.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.location_off_rounded, color: Colors.red[700], size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Location Required',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
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
            ElevatedButton.icon(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: goldAccent,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: goldAccent.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.settings, size: 20, color: Colors.white),
              label: Text(
                'Open Settings',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                  decoration: TextDecoration.none,
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.error_outline_rounded, color: Colors.orange[700], size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Setup Failed',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Unable to load prayer times. Please check your internet connection and try again.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], height: 1.5),
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                // Retry data loading
                _requestLocationPermission(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: goldAccent,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: goldAccent.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.white),
              label: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                  decoration: TextDecoration.none,
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
    // Mark onboarding as completed with new flag name
    final storage = GetStorage();
    await storage.write('hasCompletedOnboarding', true);

    // Add small delay to ensure storage write completes
    await Future.delayed(const Duration(milliseconds: 100));

    print('✅ Onboarding completed flag set to: true');
    print('🔍 Final storage state:');
    print('   hasCompletedOnboarding: ${storage.read('hasCompletedOnboarding')}');
    print('   location_permission_granted: ${storage.read('location_permission_granted')}');

    // Navigate to sign in screen after onboarding
    Get.offAllNamed(Routes.SIGN_IN);
  }
}
