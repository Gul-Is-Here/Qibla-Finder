import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import '../../services/notifications/enhanced_notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EnhancedNotificationService _notificationService = EnhancedNotificationService.instance;
  final GetStorage _storage = GetStorage();

  // Color palette
  static const Color primary = Color(0xFF8F66FF);
  static const Color darkPurple = Color(0xFF2D1B69);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color moonWhite = Color(0xFFF8F4E9);
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color cardBg = Color(0xFF2A2A3E);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [darkPurple, darkBg],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced App Bar
              _buildAppBar(),

              // Tab Bar
              _buildTabBar(),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPrayerNotificationsTab(),
                    _buildOptionalPrayersTab(),
                    _buildTrackingTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [cardBg.withOpacity(0.8), cardBg.withOpacity(0.5)]),
        boxShadow: [
          BoxShadow(color: primary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary.withOpacity(0.3), primary.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: primary.withOpacity(0.5), width: 1.5),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: moonWhite, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prayer Notifications',
                  style: GoogleFonts.cinzel(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: goldAccent,
                    shadows: [Shadow(color: goldAccent.withOpacity(0.5), blurRadius: 10)],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customize your prayer reminders',
                  style: GoogleFonts.poppins(fontSize: 12, color: moonWhite.withOpacity(0.7)),
                ),
              ],
            ),
          ),

          // Notification Bell Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [goldAccent, goldAccent.withOpacity(0.8)]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: goldAccent.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(Icons.notifications_active_rounded, color: darkPurple, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.3), width: 1),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(colors: [primary, primary.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(14),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: moonWhite,
        unselectedLabelColor: moonWhite.withOpacity(0.5),
        labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(icon: Icon(Icons.access_time_rounded, size: 20), text: 'Prayer Times'),
          Tab(icon: Icon(Icons.nights_stay_rounded, size: 20), text: 'Optional'),
          Tab(icon: Icon(Icons.analytics_rounded, size: 20), text: 'Tracking'),
        ],
      ),
    );
  }

  // Tab 1: Main Prayer Notifications
  Widget _buildPrayerNotificationsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Streak Display Card
        _buildStreakCard(),
        const SizedBox(height: 20),

        // Pre-Prayer Reminders
        _buildFeatureCard(
          icon: Icons.alarm_rounded,
          title: 'Pre-Prayer Reminders',
          subtitle: 'Get notified before prayer time',
          storageKey: 'pre_prayer_enabled',
          onChanged: (value) => _notificationService.setPrePrayerEnabled(value),
          child: _buildPrePrayerTimingSelector(),
        ),

        const SizedBox(height: 16),

        // Post-Prayer Check-in
        _buildFeatureCard(
          icon: Icons.check_circle_outline_rounded,
          title: 'Post-Prayer Check-in',
          subtitle: 'Confirm you prayed & build streaks',
          storageKey: 'post_prayer_enabled',
          onChanged: (value) => _notificationService.setPostPrayerEnabled(value),
        ),

        const SizedBox(height: 16),

        // Jummah Special
        _buildFeatureCard(
          icon: Icons.mosque_rounded,
          title: 'Jummah Special',
          subtitle: 'Friday prayer + Surah Al-Kahf reminder',
          storageKey: 'jummah_enabled',
          onChanged: (value) => _notificationService.setJummahEnabled(value),
        ),

        const SizedBox(height: 16),

        // Daily Dhikr
        _buildFeatureCard(
          icon: Icons.auto_awesome_rounded,
          title: 'Daily Dhikr Reminders',
          subtitle: 'Morning & evening remembrance',
          storageKey: 'dhikr_enabled',
          onChanged: (value) => _notificationService.setDhikrEnabled(value),
        ),

        const SizedBox(height: 16),

        // Islamic Dates
        _buildFeatureCard(
          icon: Icons.calendar_today_rounded,
          title: 'Islamic Date Notifications',
          subtitle: 'Ramadan, Eid, and special occasions',
          storageKey: 'islamic_dates_enabled',
          onChanged: (value) => _notificationService.setIslamicDatesEnabled(value),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  // Tab 2: Optional Prayers
  Widget _buildOptionalPrayersTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoBanner('Strengthen your faith with optional prayers', Icons.favorite_rounded),
        const SizedBox(height: 20),

        // Tahajjud
        _buildFeatureCard(
          icon: Icons.nightlight_round_rounded,
          title: 'Tahajjud Reminder',
          subtitle: 'Last third of the night prayer',
          storageKey: 'tahajjud_enabled',
          onChanged: (value) => _notificationService.setTahajjudEnabled(value),
        ),

        const SizedBox(height: 16),

        // Duha
        _buildFeatureCard(
          icon: Icons.wb_sunny_rounded,
          title: 'Duha Prayer',
          subtitle: 'Morning prayer after sunrise',
          storageKey: 'duha_enabled',
          onChanged: (value) => _notificationService.setDuhaEnabled(value),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  // Tab 3: Tracking & Reports
  Widget _buildTrackingTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoBanner('Track your progress and stay motivated', Icons.trending_up_rounded),
        const SizedBox(height: 20),

        // Qada Tracker
        _buildFeatureCard(
          icon: Icons.playlist_add_check_rounded,
          title: 'Qada Prayer Tracker',
          subtitle: 'Track & pray missed prayers',
          storageKey: 'qada_tracking_enabled',
          onChanged: (value) => _notificationService.setQadaTrackingEnabled(value),
        ),

        const SizedBox(height: 16),

        // Monthly Reports
        _buildFeatureCard(
          icon: Icons.assessment_rounded,
          title: 'Monthly Reports',
          subtitle: 'Get prayer statistics every month',
          storageKey: 'monthly_report_enabled',
          onChanged: (value) => _notificationService.setMonthlyReportEnabled(value),
        ),

        const SizedBox(height: 16),

        // Streak Notifications
        _buildFeatureCard(
          icon: Icons.local_fire_department_rounded,
          title: 'Streak Milestones',
          subtitle: 'Celebrate 7, 30, 100-day streaks',
          storageKey: 'streaks_enabled',
          onChanged: (value) => _notificationService.setStreaksEnabled(value),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [goldAccent.withOpacity(0.2), primary.withOpacity(0.2)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldAccent.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: goldAccent.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.local_fire_department_rounded, color: goldAccent, size: 48),
          const SizedBox(height: 12),
          Text(
            'Current Streak',
            style: GoogleFonts.poppins(fontSize: 14, color: moonWhite.withOpacity(0.8)),
          ),
          const SizedBox(height: 8),
          Text(
            '${_notificationService.getCurrentStreak()} Days',
            style: GoogleFonts.orbitron(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: goldAccent,
              shadows: [Shadow(color: goldAccent.withOpacity(0.5), blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep praying to maintain your streak!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: moonWhite.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String storageKey,
    required Function(bool) onChanged,
    Widget? child,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isEnabled = _storage.read(storageKey) ?? false;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cardBg.withOpacity(0.8), cardBg.withOpacity(0.6)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isEnabled ? goldAccent.withOpacity(0.5) : primary.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isEnabled ? goldAccent.withOpacity(0.1) : primary.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isEnabled
                              ? [goldAccent.withOpacity(0.3), goldAccent.withOpacity(0.1)]
                              : [primary.withOpacity(0.3), primary.withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: isEnabled ? goldAccent : primary, size: 28),
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
                              color: moonWhite,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: moonWhite.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 0.9,
                      child: Switch(
                        value: isEnabled,
                        onChanged: (value) async {
                          // Update storage first
                          await onChanged(value);
                          // Then update UI
                          setState(() {});
                        },
                        activeThumbColor: goldAccent,
                        activeTrackColor: goldAccent.withOpacity(0.5),
                        inactiveThumbColor: moonWhite.withOpacity(0.5),
                        inactiveTrackColor: cardBg,
                      ),
                    ),
                  ],
                ),
              ),
              if (child != null && isEnabled)
                Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: child),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrePrayerTimingSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkPurple.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: goldAccent.withOpacity(0.3), width: 1),
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          int currentMinutes = _notificationService.prePrayerMinutes;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remind me before:',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: goldAccent,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [5, 10, 15, 30].map((minutes) {
                  bool isSelected = currentMinutes == minutes;
                  return InkWell(
                    onTap: () async {
                      // Update storage first
                      await _notificationService.setPrePrayerMinutes(minutes);
                      // Then update UI
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(colors: [goldAccent, goldAccent.withOpacity(0.8)])
                            : null,
                        color: isSelected ? null : cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? goldAccent : moonWhite.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '$minutes min',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? darkPurple : moonWhite,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoBanner(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary.withOpacity(0.2), primary.withOpacity(0.1)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 13, color: moonWhite.withOpacity(0.9)),
            ),
          ),
        ],
      ),
    );
  }
}
