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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => Get.toNamed(Routes.LOCATION_PERMISSION),
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

                const SizedBox(height: 20),

                // Notification icon
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryPurple.withOpacity(0.2), lightPurple.withOpacity(0.1)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_active_rounded, size: 80, color: primaryPurple),
                ),

                const SizedBox(height: 30),

                // Title
                Text(
                  'Never Miss Prayer Time',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  'Get timely notifications for all prayer times with beautiful Azan sounds. Stay connected to your prayers throughout the day.',
                  style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[600], height: 1.5),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Features list
                _buildFeature(
                  icon: Icons.access_time_rounded,
                  title: 'Accurate Prayer Times',
                  description: 'Based on your location',
                ),
                const SizedBox(height: 16),
                _buildFeature(
                  icon: Icons.volume_up_rounded,
                  title: 'Beautiful Azan',
                  description: 'Traditional call to prayer',
                ),
                const SizedBox(height: 16),
                _buildFeature(
                  icon: Icons.calendar_today_rounded,
                  title: 'Daily Reminders',
                  description: 'Never forget to pray',
                ),

                const SizedBox(height: 40),

                // Allow button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _requestNotificationPermission(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      'Allow Notifications',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Later button
                TextButton(
                  onPressed: () => Get.toNamed(Routes.LOCATION_PERMISSION),
                  child: Text(
                    'Maybe Later',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
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
