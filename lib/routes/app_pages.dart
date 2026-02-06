import 'package:get/get.dart';
import 'package:qibla_compass_offline/views/Prayers_views/prayer_times_screen.dart';

import '../core/middleware/ad_tracking_middleware.dart';
import '../views/hadith_views/daily_hadith_screen.dart';
import '../views/ramadan_views/ramadan_screen.dart';
import '../views/zakat_views/zakat_calculator_screen.dart';
import '../views/home_view/Diker/dhikr_counter_screen.dart';
import '../views/home_view/common_view/islamic_calendar_screen.dart';
import '../views/home_view/dua_view/dua_collection_screen.dart';

import '../views/main_navigation_screen.dart';

import '../views/Compass_view/compass_screen.dart';
import '../views/onboarding/spiritual_goal_screen.dart';
import '../views/onboarding/notification_permission_screen.dart';
import '../views/onboarding/location_permission_screen.dart';
import '../views/test/notification_test_screen.dart';
import '../views/test/ad_test_screen.dart';
// import '../views/home_view/dua_view/Prayers_views/prayer_times_screen.dart';
import '../views/Quran_views/quran_list_screen.dart';
import '../views/Quran_views/quran_reader_screen.dart';
import '../views/settings_views/settings_screen.dart';
import '../views/settings_views/notification_settings_screen.dart';
import '../views/splash_screen.dart';
import '../views/auth/sign_in_screen.dart';
import '../views/auth/sign_up_screen.dart';
import '../views/subscription/subscription_screen.dart';

abstract class Routes {
  static const SPLASH = '/splash';
  static const SPIRITUAL_GOAL = '/spiritual-goal';
  static const NOTIFICATION_PERMISSION = '/notification-permission';
  static const LOCATION_PERMISSION = '/location-permission';
  static const HOME = '/home';
  static const MAIN = '/main';
  static const PRAYER_TIMES = '/prayer-times';
  static const QURAN_LIST = '/quran-list';
  static const QURAN_READER = '/quran-reader';
  static const ABOUT = '/about';
  static const SETTINGS = '/settings';
  static const NOTIFICATION_SETTINGS = '/notification-settings';
  static const FEEDBACK = '/feedback';
  // New Islamic features
  static const ISLAMIC_CALENDAR = '/islamic-calendar';
  static const DUA_COLLECTION = '/dua-collection';
  static const NAMES_OF_ALLAH = '/names-of-allah';
  static const MOSQUE_FINDER = '/mosque-finder';
  static const DHIKR_COUNTER = '/dhikr-counter';
  static const ISLAMIC_FEATURES = '/islamic-features';
  static const ENHANCED_ISLAMIC_FEATURES = '/enhanced-islamic-features';
  static const DAILY_HADITH = '/daily-hadith';
  static const RAMADAN = '/ramadan';
  static const ZAKAT_CALCULATOR = '/zakat-calculator';
  static const NOTIFICATION_TEST = '/notification-test';
  static const AD_TEST = '/ad-test';
  // Auth routes
  static const SIGN_IN = '/sign-in';
  static const SIGN_UP = '/sign-up';
  // Subscription
  static const SUBSCRIPTION = '/subscription';
}

class AppPages {
  static final routes = [
    GetPage(name: Routes.SPLASH, page: () => const SplashScreen()),
    GetPage(name: Routes.SPIRITUAL_GOAL, page: () => const SpiritualGoalScreen()),
    GetPage(name: Routes.NOTIFICATION_PERMISSION, page: () => const NotificationPermissionScreen()),
    GetPage(name: Routes.LOCATION_PERMISSION, page: () => const LocationPermissionScreen()),
    GetPage(
      name: Routes.HOME,
      page: () => OptimizedHomeScreen(),
      middlewares: [AdTrackingMiddleware()],
    ),
    GetPage(
      name: Routes.MAIN,
      page: () => const MainNavigationScreen(),
      middlewares: [AdTrackingMiddleware()],
    ),
    GetPage(
      name: Routes.PRAYER_TIMES,
      page: () => const PrayerTimesScreen(),
      middlewares: [AdTrackingMiddleware()],
    ),
    GetPage(
      name: Routes.QURAN_LIST,
      page: () => const QuranListScreen(),
      middlewares: [AdTrackingMiddleware()],
    ),
    GetPage(
      name: Routes.QURAN_READER,
      page: () => const QuranReaderScreen(),
      middlewares: [AdTrackingMiddleware()],
    ),
    GetPage(
      name: Routes.SETTINGS,
      page: () => const SettingsScreen(),
      middlewares: [AdTrackingMiddleware()],
    ),
    GetPage(
      name: Routes.NOTIFICATION_SETTINGS,
      page: () => const NotificationSettingsScreen(),
      middlewares: [AdTrackingMiddleware()],
    ),
    // New Islamic features
    GetPage(
      name: Routes.ISLAMIC_CALENDAR,
      page: () => const IslamicCalendarScreen(),
      middlewares: [AdTrackingMiddleware()],
    ),
    GetPage(
      name: Routes.DUA_COLLECTION,
      page: () => const DuaCollectionScreen(),
      middlewares: [AdTrackingMiddleware()],
    ),

    GetPage(
      name: Routes.DHIKR_COUNTER,
      page: () => const DhikrCounterScreen(),
      middlewares: [AdTrackingMiddleware()],
    ),

    GetPage(
      name: Routes.DAILY_HADITH,
      page: () => const DailyHadithScreen(),
      middlewares: [AdTrackingMiddleware()],
    ),
    GetPage(
      name: Routes.RAMADAN,
      page: () => RamadanScreen(),
      middlewares: [AdTrackingMiddleware()],
    ),
    GetPage(
      name: Routes.ZAKAT_CALCULATOR,
      page: () => ZakatCalculatorScreen(),
      middlewares: [AdTrackingMiddleware()],
    ),
    GetPage(name: Routes.NOTIFICATION_TEST, page: () => const NotificationTestScreen()),
    GetPage(name: Routes.AD_TEST, page: () => const AdTestScreen()),
    // Auth routes
    GetPage(name: Routes.SIGN_IN, page: () => const SignInScreen()),
    GetPage(name: Routes.SIGN_UP, page: () => const SignUpScreen()),
    // Subscription
    GetPage(name: Routes.SUBSCRIPTION, page: () => const SubscriptionScreen()),
  ];
}
