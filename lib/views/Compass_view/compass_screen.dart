import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/compass_controller/qibla_controller.dart';
import '../../services/ads/ad_service.dart';
import '../../services/performance_service.dart';
import '../../widgets/compass_widget/compass_widget.dart';
import '../../widgets/ads_widget/optimized_banner_ad.dart';

class OptimizedHomeScreen extends StatelessWidget {
  OptimizedHomeScreen({super.key});

  final QiblaController controller = Get.find<QiblaController>();
  final AdService adService = Get.find<AdService>();
  final PerformanceService performanceService = Get.find<PerformanceService>();

  // --- Theme Colors (Matching Prayer Times Screen) ---
  static const Color bgGradientStart = Color(0xFFEEE9FF);
  static const Color bgGradientMid = Color(0xFFE8E4F3);
  static const Color bgGradientEnd = Color(0xFFDAD4FF);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color accentTeal = Color(0xFF8F66FF);
  static const Color pill = Color(0xFF8F66FF);
  static const Color textPrimary = Color(0xFF2D1B69);
  static const Color textSecondary = Color(0xFF5E4B89);
  static const Color cardBg = Colors.white;
  static const Color borderLight = Color(0xFFE8E4F3);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Qibla Finder",
          style: GoogleFonts.poppins(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [bgGradientStart, bgGradientMid, bgGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            children: [
              // 🕌 Header Section
              Center(
                child: Column(
                  children: [
                    Text(
                      'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
                      style: GoogleFonts.amiri(
                        fontSize: 22,
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _chip(
                          icon: performanceService.isOptimizationEnabled.value
                              ? Icons.flash_on
                              : Icons.flash_off,
                          label: performanceService.isOptimizationEnabled.value
                              ? 'Optimized'
                              : 'Standard',
                        ),
                        Obx(
                          () => _chip(
                            icon: controller.isOnline.value ? Icons.wifi : Icons.wifi_off,
                            label: controller.isOnline.value ? 'Online' : 'Offline',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const OptimizedBannerAdWidget(padding: EdgeInsets.symmetric(horizontal: 10)),

              const SizedBox(height: 20),
              _sectionTitle("Qibla Direction"),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => _statCard(
                        "Your Angle to Qibla",
                        "${controller.qiblaAngle.value.round()}°",
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => _statCard(
                        "Qibla Angle from North",
                        "${controller.qiblaAngle.value.round()}°",
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // 🧭 Enhanced Compass Widget with Glassmorphism
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, cardBg],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: pill.withOpacity(0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: pill.withOpacity(0.3),
                      blurRadius: 25,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Decorative top border
                    Container(
                      height: 3,
                      width: 80,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [pill, pill.withOpacity(0.6)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    CompassWidget(controller: controller, compassSize: min(size.width * 0.7, 300))
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(
                          duration: 3000.ms,
                          colors: [Colors.transparent, pill.withOpacity(0.2), Colors.transparent],
                        )
                        .animate()
                        .scale(duration: 800.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [pill, pill.withOpacity(0.8)]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: pill.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Obx(
                        () => Text(
                          'Qibla: ${controller.qiblaAngle.value.round()}°',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Obx(() => _statusBox(controller.locationReady.value, controller.locationError.value)),
            ],
          ),
        ),
      ),
    );
  }

  // ----- ENHANCED COMPONENTS -----
  Widget _chip({required IconData icon, required String label}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white, cardBg],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: pill.withOpacity(0.3), width: 1.5),
      boxShadow: [
        BoxShadow(color: pill.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: pill, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String text) => Text(
    text,
    textAlign: TextAlign.center,
    style: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: textPrimary,
      letterSpacing: 0.5,
    ),
  );

  Widget _statCard(String title, String value) => Container(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white, cardBg],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: pill.withOpacity(0.3), width: 1.5),
      boxShadow: [
        BoxShadow(color: pill.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5)),
      ],
    ),
    child: Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [pill, pill.withOpacity(0.7)],
              ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _statusBox(bool ready, String error) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 10),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Colors.white, cardBg]),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: ready ? Colors.green.withOpacity(0.5) : Colors.orange.withOpacity(0.5),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: (ready ? Colors.green : Colors.orange).withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (ready ? Colors.green : Colors.orange).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            ready ? Icons.location_on : Icons.location_off,
            color: ready ? Colors.green : Colors.orange,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            ready
                ? 'Location Ready — Accurate Qibla'
                : error.isEmpty
                ? 'Using Manual Qibla Mode'
                : error,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
