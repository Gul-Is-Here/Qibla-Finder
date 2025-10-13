import 'package:get/get.dart';
import '../view/about_screen.dart';
import '../view/feedback_screen.dart';
import '../view/main_navigation_screen.dart';
import '../view/optimized_home_screen.dart';
import '../view/prayer_times_screen.dart';
import '../view/quran_list_screen.dart';
import '../view/quran_reader_screen.dart';
import '../view/settings_screen.dart';
import '../view/splash_screen.dart';

abstract class Routes {
  static const SPLASH = '/splash';
  static const HOME = '/home';
  static const MAIN = '/main';
  static const PRAYER_TIMES = '/prayer-times';
  static const QURAN_LIST = '/quran-list';
  static const QURAN_READER = '/quran-reader';
  static const ABOUT = '/about';
  static const SETTINGS = '/settings';
  static const FEEDBACK = '/feedback';
}

class AppPages {
  static final routes = [
    GetPage(name: Routes.SPLASH, page: () => const SplashScreen()),
    GetPage(name: Routes.HOME, page: () => const OptimizedHomeScreen()),
    GetPage(name: Routes.MAIN, page: () => const MainNavigationScreen()),
    GetPage(name: Routes.PRAYER_TIMES, page: () => const PrayerTimesScreen()),
    GetPage(name: Routes.QURAN_LIST, page: () => const QuranListScreen()),
    GetPage(name: Routes.QURAN_READER, page: () => const QuranReaderScreen()),
    GetPage(name: Routes.ABOUT, page: () => const AboutScreen()),
    GetPage(name: Routes.SETTINGS, page: () => const SettingsScreen()),
    GetPage(name: Routes.FEEDBACK, page: () => const FeedbackScreen()),
  ];
}
