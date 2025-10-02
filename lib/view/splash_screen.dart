import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qibla_compass_offline/constants/strings.dart';
import '../routes/app_pages.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(GetNumUtils(3).seconds, () {
      // Extended duration for animations
      Get.offNamed(Routes.HOME);
    });

    return Scaffold(
      backgroundColor: Color(0xFF00332F),
      body: Container(
        decoration: BoxDecoration(
          gradient: SweepGradient(
            center: Alignment.center,
            colors: [
              const Color(0xFF00332F),
              const Color(0xFF00332F).withOpacity(0.8),
              const Color(0xFF00332F),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Animated compass icon with multiple effects
              Image.asset(qiblaIcon2, width: 200)
                  .animate()
                  .scale(duration: 800.ms)
                  .then()
                  .shake(hz: 2, duration: 1000.ms),

              const SizedBox(height: 20),

              // Text with sequential animations
              Text(
                    'Qibla Compass',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.5)
                  .then()
                  .blurXY(end: 0) // Text comes into focus
                  .then()
                  .shakeX(hz: 3, amount: 0.5), // Subtle shake effect

              const Spacer(),

              // Animated progress indicator with glow effect
              const SizedBox(height: 32),

              // Subtle footer animation
              Text(
                    'Finding your direction...',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 1000.ms)
                  .then()
                  .blurXY(end: 0)
                  .then()
                  .slideY(begin: 0.2),
              SizedBox(height: 50),
            ],
          ),
        ),
        // Very subtle rotation
      ),
    );
  }
}
