import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routes/app_pages.dart';
import '../../services/notifications/notification_service.dart';

class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({super.key});

  // App Theme Colors
  static const Color primaryPurple = Color(0xFF8F66FF);
  static const Color lightPurple = Color(0xFFAB80FF);
  static const Color darkPurple = Color(0xFF2D1B69);
  static const Color goldAccent = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 20),

                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () => Get.toNamed(Routes.LOCATION_PERMISSION),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Notification icon with glow
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primaryPurple, primaryPurple],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_active_rounded, size: 70, color: Colors.white),
                  ),

                  const SizedBox(height: 15),

                  // Title
                  Text(
                    'Never Miss Prayer Time',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
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

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    'Get timely notifications for all prayer times with beautiful Azan sounds. Stay connected to your prayers throughout the day.',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 15),

                  // Features list
                  _buildFeature(
                    icon: Icons.access_time_rounded,
                    title: 'Accurate Prayer Times',
                    description: 'Based on your location',
                  ),
                  const SizedBox(height: 14),
                  _buildFeature(
                    icon: Icons.volume_up_rounded,
                    title: 'Beautiful Azan',
                    description: 'Traditional call to prayer',
                  ),
                  const SizedBox(height: 14),
                  _buildFeature(
                    icon: Icons.calendar_today_rounded,
                    title: 'Daily Reminders',
                    description: 'Never forget to pray',
                  ),
                  const SizedBox(height: 14),
                  _buildFeature(
                    icon: Icons.star_rounded,
                    title: 'Minimal Ads',
                    description: 'Only 3 short ads per day',
                  ),
                  const SizedBox(height: 15),

                  // Allow button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () => _requestNotificationPermission(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldAccent,
                        foregroundColor: darkPurple,
                        elevation: 12,
                        shadowColor: goldAccent.withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_active_rounded, size: 24, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            'Allow Notifications',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Later button
                  TextButton(
                    onPressed: () => Get.toNamed(Routes.LOCATION_PERMISSION),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      'Maybe Later',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: primaryPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
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
            width: 60,
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
                const SizedBox(height: 2),
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

  Future<void> _requestNotificationPermission(BuildContext context) async {
    try {
      final notificationService = NotificationService.instance;
      final granted = await notificationService.requestPermissions();

      if (granted) {
        Get.snackbar(
          'Notifications Enabled',
          'You will receive prayer time reminders',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: primaryPurple,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }

      // Navigate to location permission screen
      Get.toNamed(Routes.LOCATION_PERMISSION);
    } catch (e) {
      print('Error requesting notification permission: $e');
      // Still navigate even if error occurs
      Get.toNamed(Routes.LOCATION_PERMISSION);
    }
  }
}
