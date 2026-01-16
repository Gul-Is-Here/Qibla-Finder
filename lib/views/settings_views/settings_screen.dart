import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/compass_controller/qibla_controller.dart';
import '../../services/ads/ad_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QiblaController controller = Get.find<QiblaController>();
    final AdService adService = Get.find<AdService>();

    // Color palette
    const Color primary = Color(0xFF8F66FF);
    const Color darkPurple = Color(0xFF2D1B69);
    const Color goldAccent = Color(0xFFD4AF37);
    const Color moonWhite = Color(0xFFF8F4E9);
    const Color darkBg = Color(0xFF1A1A2E);
    const Color cardBg = Color(0xFF2A2A3E);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [darkPurple, darkBg, darkBg],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced App Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [darkPurple.withOpacity(0.9), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [goldAccent.withOpacity(0.2), Colors.transparent],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_rounded, color: moonWhite),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: GoogleFonts.cinzel(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: moonWhite,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Customize your experience',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: moonWhite.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Settings Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Compass Settings Card
                    _buildSettingsCard(
                      context: context,
                      title: 'Compass Settings',
                      icon: Icons.explore_rounded,
                      children: [
                        Obx(
                          () => _buildModernSwitch(
                            title: 'Vibration Feedback',
                            subtitle: 'Vibrate when pointing to Qibla',
                            icon: Icons.vibration_rounded,
                            value: controller.isVibrationEnabled.value,
                            onChanged: controller.toggleVibration,
                            activeColor: goldAccent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => _buildModernSwitch(
                            title: 'Sound Effects',
                            subtitle: 'Play sound when pointing to Qibla',
                            icon: Icons.volume_up_rounded,
                            value: controller.isSoundEnabled.value,
                            onChanged: controller.toggleSound,
                            activeColor: goldAccent,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Prayer Notifications Card - Navigate to dedicated screen
                    _buildSettingsCard(
                      context: context,
                      title: 'Prayer Notifications',
                      icon: Icons.notifications_active_rounded,
                      children: [
                        _buildActionTile(
                          icon: Icons.alarm_add_rounded,
                          title: 'Notification Settings',
                          subtitle: 'Customize prayer reminders & tracking',
                          onTap: () {
                            Get.toNamed('/notification-settings');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Ad Settings Card
                    _buildSettingsCard(
                      context: context,
                      title: 'Advertisement Info',
                      icon: Icons.ad_units_rounded,
                      children: [
                        Builder(
                          builder: (context) {
                            final remaining = adService.getRemainingAdsToday();
                            return _buildInfoTile(
                              icon: Icons.ads_click_rounded,
                              title: 'Daily Ad Limit',
                              subtitle: '$remaining ads remaining today',
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: remaining > 0
                                        ? [goldAccent, goldAccent.withOpacity(0.8)]
                                        : [Colors.grey, Colors.grey.withOpacity(0.8)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: remaining > 0
                                      ? [
                                          BoxShadow(
                                            color: goldAccent.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  '$remaining/3',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: darkPurple,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildInfoTile(
                          icon: Icons.schedule_rounded,
                          title: 'Reset Time',
                          subtitle: 'Ads reset daily at 5:00 AM',
                          trailing: Icon(Icons.access_time_rounded, color: goldAccent, size: 24),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Appearance Card
                    _buildSettingsCard(
                      context: context,
                      title: 'Appearance',
                      icon: Icons.palette_rounded,
                      children: [
                        _buildActionTile(
                          icon: Icons.dark_mode_rounded,
                          title: 'Theme',
                          subtitle: 'Dark purple theme with gold accents',
                          onTap: () {
                            Get.snackbar(
                              '',
                              '',
                              backgroundColor: cardBg,
                              colorText: moonWhite,
                              borderRadius: 16,
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(20),
                              borderColor: goldAccent.withOpacity(0.5),
                              borderWidth: 2,
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [goldAccent, goldAccent.withOpacity(0.8)],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: darkPurple,
                                  size: 24,
                                ),
                              ),
                              titleText: Text(
                                'Active Theme',
                                style: GoogleFonts.cinzel(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: goldAccent,
                                ),
                              ),
                              messageText: Text(
                                'Premium Islamic theme is currently applied',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: moonWhite.withOpacity(0.9),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // About Card
                    _buildSettingsCard(
                      context: context,
                      title: 'About',
                      icon: Icons.info_rounded,
                      children: [
                        _buildInfoTile(
                          icon: Icons.app_settings_alt_rounded,
                          title: 'Version',
                          subtitle: '1.0.0',
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: primary.withOpacity(0.5), width: 1),
                            ),
                            child: Text(
                              'Latest',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    const Color goldAccent = Color(0xFFD4AF37);
    const Color moonWhite = Color(0xFFF8F4E9);
    const Color cardBg = Color(0xFF2A2A3E);
    const Color primary = Color(0xFF8F66FF);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardBg.withOpacity(0.8), cardBg.withOpacity(0.6)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: primary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [goldAccent.withOpacity(0.3), goldAccent.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: goldAccent, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.cinzel(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: moonWhite,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Card Content
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildModernSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
    required Color activeColor,
  }) {
    const Color moonWhite = Color(0xFFF8F4E9);
    const Color darkBg = Color(0xFF1A1A2E);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? activeColor.withOpacity(0.3) : moonWhite.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: value
                    ? [activeColor.withOpacity(0.3), activeColor.withOpacity(0.1)]
                    : [moonWhite.withOpacity(0.1), Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: value ? activeColor : moonWhite.withOpacity(0.5), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: moonWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(fontSize: 12, color: moonWhite.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: activeColor,
              activeTrackColor: activeColor.withOpacity(0.5),
              inactiveThumbColor: moonWhite.withOpacity(0.5),
              inactiveTrackColor: moonWhite.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    const Color moonWhite = Color(0xFFF8F4E9);
    const Color goldAccent = Color(0xFFD4AF37);

    return Row(
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
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: moonWhite,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 12, color: moonWhite.withOpacity(0.6)),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    const Color moonWhite = Color(0xFFF8F4E9);
    const Color goldAccent = Color(0xFFD4AF37);
    const Color darkBg = Color(0xFF1A1A2E);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: darkBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: moonWhite.withOpacity(0.1), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [goldAccent.withOpacity(0.3), goldAccent.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: goldAccent, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: moonWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 12, color: moonWhite.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: goldAccent, size: 24),
          ],
        ),
      ),
    );
  }
}
