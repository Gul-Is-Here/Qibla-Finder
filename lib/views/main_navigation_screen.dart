import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qibla_compass_offline/views/Compass_view/compass_screen.dart'
    show OptimizedHomeScreen;

import 'home_view/IslamicResource/enhanced_islamic_features_screen.dart';
import 'Prayers_views/prayer_times_screen.dart';
import 'Quran_views/quran_list_screen.dart';
import 'settings_views/settings_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Obx(
        () => IndexedStack(index: controller.selectedIndex.value, children: controller.screens),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: isTablet ? 15 : 10,
                offset: Offset(0, isTablet ? -3 : -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.changePage,
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF9F70FF), // Dark purple
            selectedItemColor: Colors.white, // Main purple
            unselectedItemColor: Colors.white60,
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: isTablet ? 12 : 11,
              fontWeight: FontWeight.w400,
            ),
            elevation: 0,
            iconSize: isTablet ? 26 : 24,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.explore),
                activeIcon: Icon(Icons.explore, size: isTablet ? 32 : 28),
                label: 'Qibla',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.access_time),
                activeIcon: Icon(Icons.access_time, size: isTablet ? 32 : 28),
                label: 'Prayer Times',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/Quraniocn.png',
                  width: isTablet ? 28 : 24,
                  height: isTablet ? 28 : 24,
                ),
                activeIcon: Image.asset(
                  'assets/images/Quraniocn.png',
                  width: isTablet ? 32 : 28,
                  height: isTablet ? 32 : 28,
                ),
                label: 'Quran',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.star_outline),
                activeIcon: Icon(Icons.star, size: isTablet ? 32 : 28),
                label: 'Islamic',
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                activeIcon: Icon(Icons.settings, size: isTablet ? 32 : 28),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationController extends GetxController {
  var selectedIndex = 1.obs; // Default to Prayer Times (index 1)

  final List<Widget> screens = [
    OptimizedHomeScreen(),
    const PrayerTimesScreen(),
    const QuranListScreen(),
    const EnhancedIslamicFeaturesScreen(),
    const SettingsScreen(),
  ];

  void changePage(int index) {
    selectedIndex.value = index;
  }
}
