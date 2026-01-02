import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import '../routes/app_pages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Start essential services in background during splash
    try {
      // Minimal delay for splash effect
      await Future.delayed(const Duration(milliseconds: 800));

      // Pre-warm services without blocking UI
      Future.microtask(() async {
        // Warm up GetStorage and other services
        await Future.delayed(const Duration(milliseconds: 100));
      });

      // Additional delay for visual effect
      await Future.delayed(const Duration(milliseconds: 700));

      // Check if onboarding is completed
      if (mounted) {
        final storage = GetStorage();
        final onboardingCompleted = storage.read('onboarding_completed') ?? false;

        if (onboardingCompleted) {
          // User has already completed onboarding, go to main screen
          Get.offNamed(Routes.MAIN);
        } else {
          // First time user, show onboarding screens
          Get.offNamed(Routes.NOTIFICATION_PERMISSION);
        }
      }
    } catch (e) {
      print('Splash initialization error: $e');
      // Fallback navigation even if initialization fails
      if (mounted) {
        Get.offNamed(Routes.NOTIFICATION_PERMISSION);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFF2D1B69),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D1B69), Color(0xFF8F66FF), Color(0xFFAB80FF)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Responsive compass icon
              Container(
                width: isTablet ? 250 : 180,
                height: isTablet ? 250 : 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isTablet ? 125 : 90),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9F70FF).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Image.asset("assets/images/Quraniocn.png", fit: BoxFit.contain)
                    .animate()
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 800.ms,
                    )
                    .fadeIn(duration: 600.ms),
              ),

              SizedBox(height: isTablet ? 40 : 30),

              // Responsive title text
              Text(
                'Muslim Pro - Qibla Prayer',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: isTablet ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),

              SizedBox(height: isTablet ? 20 : 15),

              // Subtitle
              Text(
                'Find Your Direction',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isTablet ? 18 : 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 300.ms).fadeIn(duration: 600.ms).slideY(begin: 0.3),

              const Spacer(flex: 2),

              // Loading indicator
              Container(
                width: isTablet ? 80 : 60,
                height: 4,
                margin: EdgeInsets.only(bottom: isTablet ? 60 : 40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.white.withOpacity(0.2),
                ),
                child:
                    Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8F66FF), Color(0xFFAB80FF)],
                            ),
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scaleX(begin: 0.0, end: 1.0, duration: 1500.ms, curve: Curves.easeInOut),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
