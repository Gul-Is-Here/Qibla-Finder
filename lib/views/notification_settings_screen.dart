import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/notification_settings_controller.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationSettingsController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00332F),
        title: Text(
          'Notification Settings',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Master Toggle
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00332F), Color(0xFF00332F)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00332F).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        controller.notificationsEnabled.value
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prayer Notifications',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.notificationsEnabled.value
                                ? 'Notifications are enabled'
                                : 'Tap to enable notifications',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: controller.notificationsEnabled.value,
                      onChanged: (value) =>
                          controller.toggleNotifications(value),
                      activeColor: Colors.white,
                      activeTrackColor: Colors.white.withOpacity(0.5),
                    ),
                  ],
                ),
              ),

              if (controller.notificationsEnabled.value) ...[
                // Sound Settings
                _buildSectionHeader('Sound Settings'),
                _buildSoundSettingsCard(controller),

                // Individual Prayer Settings
                _buildSectionHeader('Prayer Notifications'),
                _buildPrayerSettingsCard(
                  controller,
                  'Fajr',
                  Icons.nightlight_round,
                ),
                _buildPrayerSettingsCard(
                  controller,
                  'Dhuhr',
                  Icons.wb_sunny_outlined,
                ),
                _buildPrayerSettingsCard(controller, 'Asr', Icons.light_mode),
                _buildPrayerSettingsCard(
                  controller,
                  'Maghrib',
                  Icons.wb_twilight,
                ),
                _buildPrayerSettingsCard(controller, 'Isha', Icons.dark_mode),

                // Advanced Settings
                _buildSectionHeader('Advanced Settings'),
                _buildAdvancedSettingsCard(controller),

                const SizedBox(height: 80),
              ] else ...[
                _buildEnableNotificationsPrompt(controller),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF00897B),
        ),
      ),
    );
  }

  Widget _buildSoundSettingsCard(NotificationSettingsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Azan Sound Toggle
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00332F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.volume_up, color: Color(0xFF00897B)),
            ),
            title: Text(
              'Play Azan',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Play Azan audio with notifications',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Switch(
              value: controller.playAzan.value,
              onChanged: (value) => controller.toggleAzan(value),
              activeColor: const Color(0xFF00897B),
            ),
          ),

          Divider(height: 1, color: Colors.grey[300]),

          // Silent Notifications Toggle
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00332F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_none,
                color: Color(0xFF00897B),
              ),
            ),
            title: Text(
              'Silent Notifications',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Show notifications without sound',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Switch(
              value: controller.silentMode.value,
              onChanged: (value) => controller.toggleSilentMode(value),
              activeColor: const Color(0xFF00332F),
            ),
          ),

          if (!controller.silentMode.value && controller.playAzan.value) ...[
            Divider(height: 1, color: Colors.grey[300]),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Volume',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(controller.volume.value * 100).toInt()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00332F),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: controller.volume.value,
                    onChanged: (value) => controller.setVolume(value),
                    activeColor: const Color(0xFF00332F),
                    inactiveColor: Colors.grey[300],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrayerSettingsCard(
    NotificationSettingsController controller,
    String prayer,
    IconData icon,
  ) {
    final isEnabled = controller.isPrayerEnabled(prayer);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isEnabled
              ? const Color(0xFF00897B).withOpacity(0.3)
              : Colors.grey[300]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isEnabled
                ? const Color(0xFF00332F).withOpacity(0.1)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isEnabled ? const Color(0xFF00897B) : Colors.grey,
            size: 24,
          ),
        ),
        title: Text(
          prayer,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isEnabled ? Colors.black87 : Colors.grey,
          ),
        ),
        subtitle: Text(
          isEnabled ? 'Notification enabled' : 'Notification disabled',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isEnabled ? const Color(0xFF00332F) : Colors.grey[500],
          ),
        ),
        trailing: Switch(
          value: isEnabled,
          onChanged: (value) => controller.togglePrayer(prayer, value),
          activeColor: const Color(0xFF00332F),
        ),
      ),
    );
  }

  Widget _buildAdvancedSettingsCard(NotificationSettingsController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00332F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.vibration, color: Color(0xFF00897B)),
            ),
            title: Text(
              'Vibration',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Vibrate on notification',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Switch(
              value: controller.vibration.value,
              onChanged: (value) => controller.toggleVibration(value),
              activeColor: const Color(0xFF00332F),
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00897B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.phone_android, color: Color(0xFF00897B)),
            ),
            title: Text(
              'Full Screen Alert',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Show full screen notification',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Switch(
              value: controller.fullScreenIntent.value,
              onChanged: (value) => controller.toggleFullScreenIntent(value),
              activeColor: const Color(0xFF00332F),
            ),
          ),
          Divider(height: 1, color: Colors.grey[300]),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_sweep, color: Colors.red),
            ),
            title: Text(
              'Clear All Notifications',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            subtitle: Text(
              'Cancel all scheduled notifications',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showClearNotificationsDialog(controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnableNotificationsPrompt(
    NotificationSettingsController controller,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Notifications are disabled',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enable notifications to receive Azan reminders at prayer times',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.toggleNotifications(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00897B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.notifications_active),
            label: Text(
              'Enable Notifications',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTestNotificationDialog(
    NotificationSettingsController controller,
  ) async {
    await showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.play_circle_outline, color: Color(0xFF00897B)),
            const SizedBox(width: 12),
            Text(
              'Test Notification',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send a test notification to preview how it will look and sound.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00897B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF00332F),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The notification will appear in 5 seconds',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF00332F),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await controller.sendTestNotification();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00332F),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.send),
            label: Text(
              'Send Test',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showClearNotificationsDialog(
    NotificationSettingsController controller,
  ) async {
    await showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 12),
            Text(
              'Clear Notifications',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel all scheduled prayer notifications? You will need to reschedule them manually.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await controller.clearAllNotifications();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Clear All',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
