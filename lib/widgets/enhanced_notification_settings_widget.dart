import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notifications/enhanced_notification_service.dart';

/// Enhanced Notification Settings Widget
/// Add this to your settings screen to enable/disable new notification features
class EnhancedNotificationSettingsWidget extends StatefulWidget {
  const EnhancedNotificationSettingsWidget({super.key});

  @override
  State<EnhancedNotificationSettingsWidget> createState() =>
      _EnhancedNotificationSettingsWidgetState();
}

class _EnhancedNotificationSettingsWidgetState extends State<EnhancedNotificationSettingsWidget> {
  final enhancedService = EnhancedNotificationService.instance;

  // Theme colors
  static const Color primaryPurple = Color(0xFF8F66FF);
  static const Color darkPurple = Color(0xFF2D1B69);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color moonWhite = Color(0xFFF8F4E9);
  static const Color cardBg = Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.notifications_active, color: goldAccent, size: 28),
              const SizedBox(width: 12),
              Text(
                'Enhanced Notifications',
                style: GoogleFonts.cinzel(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: goldAccent,
                ),
              ),
            ],
          ),
        ),

        // Pre-Prayer Reminders
        _buildSettingCard(
          icon: Icons.alarm,
          iconColor: primaryPurple,
          title: 'Pre-Prayer Reminders',
          subtitle: 'Get notified before prayer time',
          value: enhancedService.prePrayerEnabled,
          onChanged: (value) async {
            await enhancedService.setPrePrayerEnabled(value);
            setState(() {});
          },
          child: enhancedService.prePrayerEnabled ? _buildTimingSelector() : null,
        ),

        // Post-Prayer Check-in
        _buildSettingCard(
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF4CAF50),
          title: 'Post-Prayer Check-in',
          subtitle: 'Remind me to mark prayers completed',
          value: enhancedService.postPrayerEnabled,
          onChanged: (value) async {
            await enhancedService.setPostPrayerEnabled(value);
            setState(() {});
          },
        ),

        // Jummah Special
        _buildSettingCard(
          icon: Icons.mosque,
          iconColor: goldAccent,
          title: 'Jummah Special Reminder',
          subtitle: 'Friday prayer with Surah Al-Kahf',
          value: enhancedService.jummahEnabled,
          onChanged: (value) async {
            await enhancedService.setJummahEnabled(value);
            setState(() {});
          },
        ),

        // Daily Dhikr
        _buildSettingCard(
          icon: Icons.auto_awesome,
          iconColor: const Color(0xFF00897B),
          title: 'Daily Dhikr Reminders',
          subtitle: 'Morning and evening adhkar',
          value: enhancedService.dhikrEnabled,
          onChanged: (value) async {
            await enhancedService.setDhikrEnabled(value);
            if (value) {
              await enhancedService.scheduleDailyDhikrReminders();
            }
            setState(() {});
          },
        ),

        // Optional Prayers Section
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
          child: Text(
            'Optional Prayers',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: moonWhite.withOpacity(0.7),
            ),
          ),
        ),

        // Tahajjud
        _buildSettingCard(
          icon: Icons.nightlight_round,
          iconColor: darkPurple,
          title: 'Tahajjud Reminder',
          subtitle: 'Night prayer in last third of night',
          value: enhancedService.tahajjudEnabled,
          onChanged: (value) async {
            await enhancedService.setTahajjudEnabled(value);
            setState(() {});
          },
        ),

        // Duha
        _buildSettingCard(
          icon: Icons.wb_sunny,
          iconColor: const Color(0xFFFF9800),
          title: 'Duha Prayer Reminder',
          subtitle: 'Morning optional prayer',
          value: enhancedService.duhaEnabled,
          onChanged: (value) async {
            await enhancedService.setDuhaEnabled(value);
            setState(() {});
          },
        ),

        // Tracking & Reports Section
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
          child: Text(
            'Tracking & Reports',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: moonWhite.withOpacity(0.7),
            ),
          ),
        ),

        // Qada Tracking
        _buildSettingCard(
          icon: Icons.list_alt,
          iconColor: const Color(0xFFD4AF37),
          title: 'Qada Prayer Tracker',
          subtitle: 'Track and remind about missed prayers',
          value: enhancedService.qadaTrackingEnabled,
          onChanged: (value) async {
            await enhancedService.setQadaTrackingEnabled(value);
            setState(() {});
          },
        ),

        // Streak Notifications
        _buildSettingCard(
          icon: Icons.local_fire_department,
          iconColor: Colors.orange,
          title: 'Streak Notifications',
          subtitle: 'Celebrate prayer milestones',
          value: enhancedService.streaksEnabled,
          onChanged: (value) async {
            await enhancedService.setStreaksEnabled(value);
            setState(() {});
          },
        ),

        // Current Streak Display
        if (enhancedService.streaksEnabled) _buildStreakDisplay(),

        // Islamic Dates
        _buildSettingCard(
          icon: Icons.event_note,
          iconColor: const Color(0xFFFF9800),
          title: 'Islamic Date Notifications',
          subtitle: 'Special Islamic dates and events',
          value: enhancedService.islamicDatesEnabled,
          onChanged: (value) async {
            await enhancedService.setIslamicDatesEnabled(value);
            setState(() {});
          },
        ),

        // Monthly Reports
        _buildSettingCard(
          icon: Icons.assessment,
          iconColor: const Color(0xFF4CAF50),
          title: 'Monthly Prayer Reports',
          subtitle: 'Get monthly statistics',
          value: enhancedService.monthlyReportEnabled,
          onChanged: (value) async {
            await enhancedService.setMonthlyReportEnabled(value);
            setState(() {});
          },
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Future<void> Function(bool) onChanged,
    Widget? child,
  }) {
    // Use StatefulBuilder to manage local state for this card
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setCardState) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: darkPurple.withOpacity(0.3), width: 1),
          ),
          elevation: 2,
          child: Column(
            children: [
              SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                title: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: moonWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  style: GoogleFonts.poppins(color: moonWhite.withOpacity(0.7), fontSize: 12),
                ),
                value: value,
                activeThumbColor: primaryPurple,
                activeTrackColor: primaryPurple.withOpacity(0.5),
                onChanged: (newValue) async {
                  // Call the async callback and wait for completion
                  await onChanged(newValue);
                  // Rebuild both the card and parent widget
                  setCardState(() {});
                  setState(() {});
                },
              ),
              if (child != null) child,
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimingSelector() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Reminder Time:',
            style: GoogleFonts.poppins(color: moonWhite.withOpacity(0.8), fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: darkPurple.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryPurple.withOpacity(0.3)),
            ),
            child: DropdownButton<int>(
              value: enhancedService.prePrayerMinutes,
              dropdownColor: cardBg,
              underline: const SizedBox(),
              style: GoogleFonts.orbitron(
                color: goldAccent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              items: [5, 10, 15, 30].map((minutes) {
                return DropdownMenuItem(value: minutes, child: Text('$minutes min before'));
              }).toList(),
              onChanged: (value) async {
                if (value != null) {
                  await enhancedService.setPrePrayerMinutes(value);
                  setState(() {});
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakDisplay() {
    final streak = enhancedService.getCurrentStreak();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkPurple, darkPurple.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldAccent.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Streak',
                  style: GoogleFonts.poppins(
                    color: moonWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Keep up the great work!',
                  style: GoogleFonts.poppins(color: moonWhite.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '$streak',
            style: GoogleFonts.orbitron(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: goldAccent,
              shadows: [Shadow(color: goldAccent.withOpacity(0.5), blurRadius: 10)],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'days',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: moonWhite.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
