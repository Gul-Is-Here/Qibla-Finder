import 'package:get/get.dart';
import '../views/about_screen.dart';
import '../views/dhikr_counter_screen.dart';
import '../views/dua_collection_screen.dart';
import '../views/enhanced_mosque_finder_screen.dart';
import '../views/enhanced_islamic_features_screen.dart';
import '../views/feedback_screen.dart';
import '../views/islamic_calendar_screen.dart';
import '../views/islamic_features_index_screen.dart';
import '../views/main_navigation_screen.dart';
import '../views/names_of_allah_screen.dart';
import '../views/compass_screen.dart';
import '../views/prayer_times_screen.dart';
import '../views/quran_list_screen.dart';
import '../views/quran_reader_screen.dart';
import '../views/settings_screen.dart';
import '../views/splash_screen.dart';

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
  // New Islamic features
  static const ISLAMIC_CALENDAR = '/islamic-calendar';
  static const DUA_COLLECTION = '/dua-collection';
  static const NAMES_OF_ALLAH = '/names-of-allah';
  static const MOSQUE_FINDER = '/mosque-finder';
  static const DHIKR_COUNTER = '/dhikr-counter';
  static const ISLAMIC_FEATURES = '/islamic-features';
  static const ENHANCED_ISLAMIC_FEATURES = '/enhanced-islamic-features';
}

class AppPages {
  static final routes = [
    GetPage(name: Routes.SPLASH, page: () => const SplashScreen()),
    GetPage(name: Routes.HOME, page: () =>  OptimizedHomeScreen()),
    GetPage(name: Routes.MAIN, page: () => const MainNavigationScreen()),
    GetPage(name: Routes.PRAYER_TIMES, page: () => const PrayerTimesScreen()),
    GetPage(name: Routes.QURAN_LIST, page: () => const QuranListScreen()),
    GetPage(name: Routes.QURAN_READER, page: () => const QuranReaderScreen()),
    GetPage(name: Routes.ABOUT, page: () => const AboutScreen()),
    GetPage(name: Routes.SETTINGS, page: () => const SettingsScreen()),
    GetPage(name: Routes.FEEDBACK, page: () => const FeedbackScreen()),
    // New Islamic features
    GetPage(name: Routes.ISLAMIC_CALENDAR, page: () => const IslamicCalendarScreen()),
    GetPage(name: Routes.DUA_COLLECTION, page: () => const DuaCollectionScreen()),
    GetPage(name: Routes.NAMES_OF_ALLAH, page: () => const NamesOfAllahScreen()),
    GetPage(name: Routes.MOSQUE_FINDER, page: () => const EnhancedMosqueFinderScreen()),
    GetPage(name: Routes.DHIKR_COUNTER, page: () => const DhikrCounterScreen()),
    GetPage(name: Routes.ISLAMIC_FEATURES, page: () => const IslamicFeaturesIndexScreen()),
    GetPage(
      name: Routes.ENHANCED_ISLAMIC_FEATURES,
      page: () => const EnhancedIslamicFeaturesScreen(),
    ),
  ];
}
