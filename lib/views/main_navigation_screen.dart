import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qibla_compass_offline/views/optimized_home_screen.dart' show OptimizedHomeScreen;

import 'prayer_times_screen.dart';
import 'quran_list_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.selectedIndex.value,
          children: controller.screens,
        ),
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
            backgroundColor: const Color(0xFF004D40),
            selectedItemColor: const Color(0xFF8BC34A),
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
                icon: const Icon(Icons.book_outlined),
                activeIcon: Icon(Icons.book, size: isTablet ? 32 : 28),
                label: 'Quran',
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
  var selectedIndex = 0.obs;

  final List<Widget> screens = [
    const OptimizedHomeScreen(),
    const PrayerTimesScreen(),
    const QuranListScreen(),
    const SettingsScreen(),
  ];

  void changePage(int index) {
    selectedIndex.value = index;
  }
}
