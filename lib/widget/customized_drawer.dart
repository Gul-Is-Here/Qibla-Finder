import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qibla_compass_offline/constants/strings.dart';
import 'package:qibla_compass_offline/view/main_navigation_screen.dart';
import 'package:qibla_compass_offline/view/optimized_home_screen.dart';

import '../view/about_screen.dart';
import '../view/feedback_screen.dart';
import '../view/home_screen.dart';
import '../view/settings_screen.dart' show SettingsScreen;
import 'drawer_item.dart';

Widget buildDrawer(BuildContext context) {
  return Drawer(
    width: MediaQuery.of(context).size.width * 0.75,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
    ),
    elevation: 16,
    backgroundColor: const Color(0xFF0A3A35),
    child: SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header with gradient and animation
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00695C),
                  const Color(0xFF004D40).withOpacity(0.9),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    qiblaIcon2,
                    width: 100,
                  ).animate().scale(duration: 500.ms).then().shake(),
                ),

                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Qibla Compass',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Find your direction',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ).paddingSymmetric(horizontal: 24),
          ),

          // Menu Items
          Column(
            children: [
              const SizedBox(height: 16),
              buildDrawerItem(
                context,
                icon: Icons.home,
                title: 'Home',
                onTap: () {
                  Get.off(
                    () => MainNavigationScreen(),
                  ); // Use offAll to prevent going back to previous screen
                },
              ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.5),

              buildDrawerItem(
                context,
                icon: Icons.info,
                title: 'About',
                onTap: () {
                  Get.to(() => AboutScreen());
                },
              ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.5),

              // buildDrawerItem(
              //   context,
              //   icon: Icons.settings,
              //   title: 'Settings',
              //   onTap: () {
              //     Get.to(() => SettingsScreen());
              //   },
              // ).animate(delay: 300.ms).fadeIn().slideX(begin: -0.5),

              // buildDrawerItem(
              //   context,
              //   icon: Icons.feedback,
              //   title: 'Feedback',
              //   onTap: () {
              //     Get.to(() => FeedbackScreen());
              //   },
              // ).animate(delay: 400.ms).fadeIn().slideX(begin: -0.5),
              const Divider(height: 32, indent: 24, endIndent: 24),
            ],
          ),

          // Footer with version info
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Version 1.0.0',
              style: GoogleFonts.poppins(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ),
  );
}
