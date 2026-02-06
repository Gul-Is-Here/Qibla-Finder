import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/compass_controller/qibla_controller.dart';
import '../../services/ads/ad_service.dart';
import '../../services/auth/auth_service.dart';
// TODO: Uncomment for premium features in next version
// import '../../services/subscription_service.dart';
import '../../routes/app_pages.dart';
import '../test_views/ad_test_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // App Theme Colors
  static const Color primaryPurple = Color(0xFF8F66FF);
  static const Color lightPurple = Color(0xFFAB80FF);
  static const Color darkPurple = Color(0xFF2D1B69);
  static const Color goldAccent = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final QiblaController controller = Get.find<QiblaController>();
    final AdService adService = Get.find<AdService>();
    final AuthService authService = Get.find<AuthService>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Beautiful App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryPurple,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
              ),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryPurple, darkPurple],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -30,
                      top: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: 10,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: goldAccent.withOpacity(0.15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(
                'Settings',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              centerTitle: false,
            ),
          ),

          // Settings Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section: Compass
                  _buildSectionHeader('Compass', Icons.explore_rounded),
                  const SizedBox(height: 8),
                  _buildSettingsCard([
                    Obx(
                      () => _buildSwitchTile(
                        icon: Icons.vibration_rounded,
                        title: 'Vibration',
                        subtitle: 'Vibrate when pointing to Qibla',
                        value: controller.isVibrationEnabled.value,
                        onChanged: controller.toggleVibration,
                      ),
                    ),
                    _buildDivider(),
                    Obx(
                      () => _buildSwitchTile(
                        icon: Icons.volume_up_rounded,
                        title: 'Sound',
                        subtitle: 'Play sound at Qibla direction',
                        value: controller.isSoundEnabled.value,
                        onChanged: controller.toggleSound,
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Section: Notifications
                  _buildSectionHeader('Notifications', Icons.notifications_rounded),
                  const SizedBox(height: 8),
                  _buildSettingsCard([
                    _buildNavigationTile(
                      icon: Icons.alarm_rounded,
                      title: 'Prayer Alerts',
                      subtitle: 'Manage prayer reminders',
                      onTap: () => Get.toNamed('/notification-settings'),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Section: Ads Info
                  _buildSectionHeader('Daily Rewards', Icons.card_giftcard_rounded),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final remaining = adService.getRemainingAdsToday();
                      return _buildAdsInfoCard(remaining);
                    },
                  ),

                  const SizedBox(height: 24),

                  // TODO: Premium section - Uncomment in next version
                  // Section: Premium
                  // _buildSectionHeader('Premium', Icons.workspace_premium_rounded),
                  // const SizedBox(height: 8),
                  // _buildPremiumCard(),
                  // const SizedBox(height: 24),

                  // Section: Account
                  _buildSectionHeader('Account', Icons.person_rounded),
                  const SizedBox(height: 8),
                  _buildSettingsCard([
                    Obx(() {
                      final user = authService.currentUser.value;
                      final isGuest = authService.isGuest.value;

                      // Show guest tile when user is guest OR there is no authenticated user
                      if (isGuest || user == null) {
                        return _buildNavigationTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Guest User',
                          subtitle: 'Tap to sign in and unlock all features',
                          // Use push to Sign In so user can return; replace-all wasn't necessary here
                          onTap: () => Get.toNamed(Routes.SIGN_IN),
                        );
                      }

                      // If logged in, show email with badge
                      return _buildInfoTile(
                        icon: Icons.email_rounded,
                        title: user.email ?? 'User',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Signed In',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryPurple,
                            ),
                          ),
                        ),
                      );
                    }),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      subtitle: 'Sign out from your account',
                      onTap: () => _showLogoutDialog(context, authService),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Section: About
                  _buildSectionHeader('About', Icons.info_outline_rounded),
                  const SizedBox(height: 8),
                  _buildSettingsCard([
                    _buildInfoTile(
                      icon: Icons.apps_rounded,
                      title: 'App Version',
                      trailing: Text(
                        '1.0.0',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryPurple,
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.star_rounded,
                      title: 'Rate App',
                      subtitle: 'Love the app? Rate us!',
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                            'https://play.google.com/store/apps/details?id=com.qibla_compass_offline.app',
                          ),
                        );
                      },
                    ),
                  ]),

                  // ElevatedButton(
                  //   onPressed: () {
                  //     Get.to(() => AdTestScreen());
                  //   },
                  //   child: Text(
                  //     'Test Ad Screen',
                  //     style: GoogleFonts.poppins(
                  //       fontSize: 14,
                  //       fontWeight: FontWeight.w600,
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primaryPurple),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.1), indent: 56);
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value ? primaryPurple.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: value ? primaryPurple : Colors.grey[500]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[850],
                  ),
                ),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: primaryPurple,
            activeTrackColor: primaryPurple.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: primaryPurple),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[850],
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: primaryPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[850],
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildAdsInfoCard(int remaining) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryPurple, darkPurple],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.ads_click_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ad Views Today',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Resets at 5:00 AM',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: goldAccent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: goldAccent.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              '$remaining / 3',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: darkPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TODO: Premium features - Uncomment in next version
  /*
  Widget _buildPremiumCard() {
    // Check if subscription service is registered
    if (!Get.isRegistered<SubscriptionService>()) {
      return _buildPremiumCardUI(false);
    }

    final subscriptionService = Get.find<SubscriptionService>();

    return Obx(() {
      final isPremium = subscriptionService.isPremium;
      return _buildPremiumCardUI(isPremium);
    });
  }

  Widget _buildPremiumCardUI(bool isPremium) {
    return InkWell(
      onTap: isPremium ? null : () => Get.toNamed(Routes.SUBSCRIPTION),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPremium ? [goldAccent, const Color(0xFFFFD700)] : [primaryPurple, darkPurple],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isPremium ? goldAccent : primaryPurple).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isPremium ? Icons.workspace_premium_rounded : Icons.star_rounded,
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
                    isPremium ? '⭐ Premium Active' : 'Go Premium',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPremium ? 'Enjoy ad-free experience' : 'Remove ads from Rs. 50/month',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            if (!isPremium)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Upgrade',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: primaryPurple,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  */

  void _showLogoutDialog(BuildContext context, AuthService authService) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, size: 40, color: primaryPurple),
              ),
              const SizedBox(height: 20),
              Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[850],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to sign out from your account?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); // Close dialog

                        final error = await authService.signOut();

                        if (error == null) {
                          // Success - navigate to sign in
                          Get.offAllNamed(Routes.SIGN_IN);
                        } else {
                          // Error - show error message
                          Get.snackbar(
                            'Logout Failed',
                            error,
                            backgroundColor: Colors.red[400],
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: primaryPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
