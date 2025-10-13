import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view/optimized_home_screen.dart';
import '../view/prayer_times_screen.dart';
import '../view/quran_list_screen.dart';
import '../view/settings_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

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
                blurRadius: 10,
                offset: const Offset(0, -2),
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.explore),
                activeIcon: Icon(Icons.explore, size: 28),
                label: 'Qibla',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.access_time),
                activeIcon: Icon(Icons.access_time, size: 28),
                label: 'Prayer Times',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_outlined),
                activeIcon: Icon(Icons.book, size: 28),
                label: 'Quran',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                activeIcon: Icon(Icons.settings, size: 28),
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
