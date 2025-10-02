import 'package:get/get.dart';
import '../view/about_screen.dart';
import '../view/feedback_screen.dart';
import '../view/optimized_home_screen.dart';
import '../view/settings_screen.dart';
import '../view/splash_screen.dart';

abstract class Routes {
  static const SPLASH = '/splash';
  static const HOME = '/home';
  static const ABOUT = '/about';
  static const SETTINGS = '/settings';
  static const FEEDBACK = '/feedback';
}

class AppPages {
  static final routes = [
    GetPage(name: Routes.SPLASH, page: () => const SplashScreen()),
    GetPage(name: Routes.HOME, page: () => const OptimizedHomeScreen()),
    GetPage(name: Routes.ABOUT, page: () => const AboutScreen()),
    GetPage(name: Routes.SETTINGS, page: () => const SettingsScreen()),
    GetPage(name: Routes.FEEDBACK, page: () => const FeedbackScreen()),
  ];
}
