import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/compass_controller/qibla_controller.dart';
import '../../services/ads/ad_service.dart';
import '../../widgets/ads_widget/optimized_banner_ad.dart';

/// Enhanced Compass Screen with improved design
/// Features:
/// - Beautiful gradient background
/// - Smooth animations
/// - Online/Offline indicators
/// - Compass calibration guide
/// - Manual adjustment mode
class EnhancedCompassScreen extends StatelessWidget {
  EnhancedCompassScreen({super.key});

  final QiblaController controller = Get.find<QiblaController>();
  final AdService adService = Get.find<AdService>();

  // Theme Colors - Beautiful purple gradient
  static const Color primaryPurple = Color(0xFF8F66FF);
  static const Color darkPurple = Color(0xFF2D1B69);
  static const Color lightPurple = Color(0xFFEEE9FF);
  static const Color accentTeal = Color(0xFF00897B);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final compassSize = min(size.width * 0.75, 350.0);

    return Scaffold(
      backgroundColor: lightPurple,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Qibla Compass',
          style: GoogleFonts.poppins(color: darkPurple, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: darkPurple),
            onPressed: () => controller.retryLocation(),
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [lightPurple, Colors.white, lightPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: primaryPurple,
            onRefresh: () async {
              controller.retryLocation();
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Bismillah
                _buildBismillah(),
                const SizedBox(height: 20),

                // Status Chips Row
                _buildStatusChips(),
                const SizedBox(height: 20),

                // Banner Ad
                const OptimizedBannerAdWidget(padding: EdgeInsets.symmetric(horizontal: 0)),
                const SizedBox(height: 20),

                // Stats Cards
                _buildStatsCards(),
                const SizedBox(height: 30),

                // Main Compass Widget
                _buildCompassCard(compassSize),
                const SizedBox(height: 25),

                // Calibration Warning (if needed)
                Obx(
                  () => controller.calibrationNeeded.value
                      ? _buildCalibrationWarning()
                      : const SizedBox.shrink(),
                ),

                // Location Status
                _buildLocationStatus(),
                const SizedBox(height: 20),

                // Manual Adjustment (if location not available)
                Obx(
                  () => !controller.locationReady.value
                      ? _buildManualAdjustment()
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.retryLocation(),
        backgroundColor: primaryPurple,
        icon: const Icon(Icons.my_location, color: Colors.white),
        label: Text(
          'Recalibrate',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBismillah() {
    return Center(
      child: Text(
        'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
        style: GoogleFonts.amiri(
          fontSize: 24,
          color: darkPurple,
          fontWeight: FontWeight.w700,
          height: 1.8,
        ),
        textAlign: TextAlign.center,
      ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.3, end: 0),
    );
  }

  Widget _buildStatusChips() {
    return Obx(() {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          _statusChip(
            icon: controller.isOnline.value ? Icons.wifi : Icons.wifi_off,
            label: controller.isOnline.value ? 'Online' : 'Offline',
            color: controller.isOnline.value ? successGreen : warningOrange,
          ),
          _statusChip(
            icon: controller.compassReady.value ? Icons.explore : Icons.explore_off,
            label: controller.compassReady.value ? 'Compass Ready' : 'Compass Off',
            color: controller.compassReady.value ? successGreen : errorRed,
          ),
          _statusChip(
            icon: controller.locationReady.value ? Icons.location_on : Icons.location_off,
            label: controller.locationReady.value ? 'Location Active' : 'Location Off',
            color: controller.locationReady.value ? successGreen : warningOrange,
          ),
        ],
      );
    });
  }

  Widget _statusChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: darkPurple,
            ),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut);
  }

  Widget _buildStatsCards() {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: _statCard(
              title: 'Your Heading',
              value: '${controller.heading.value.round()}°',
              icon: Icons.navigation,
              color: accentTeal,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _statCard(
              title: 'Qibla Direction',
              value: '${controller.qiblaAngle.value.round()}°',
              icon: Icons.mosque,
              color: primaryPurple,
            ),
          ),
        ],
      );
    });
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: darkPurple,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: darkPurple.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }

  Widget _buildCompassCard(double compassSize) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '🕋 Face the Qibla',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: darkPurple,
            ),
          ),
          const SizedBox(height: 20),

          // Compass visualization
          Obx(() {
            return SizedBox(
                  width: compassSize,
                  height: compassSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring with degree markers
                      _buildCompassRing(compassSize),

                      // Rotating compass face
                      _buildCompassFace(compassSize),

                      // Qibla indicator
                      _buildQiblaIndicator(compassSize),

                      // Center angle display
                      _buildCenterDisplay(),
                    ],
                  ),
                )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(
                  duration: 3000.ms,
                  colors: [Colors.transparent, primaryPurple.withOpacity(0.1), Colors.transparent],
                );
          }),

          const SizedBox(height: 20),

          // Alignment indicator
          Obx(() {
            final diff = (controller.heading.value - controller.qiblaAngle.value).abs();
            final normalizedDiff = diff > 180 ? 360 - diff : diff;
            final isAligned = normalizedDiff <= 5;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isAligned ? successGreen.withOpacity(0.1) : warningOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: isAligned ? successGreen : warningOrange, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAligned ? Icons.check_circle : Icons.adjust,
                    color: isAligned ? successGreen : warningOrange,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isAligned ? '✅ Aligned with Qibla!' : '↻ ${normalizedDiff.round()}° off',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isAligned ? successGreen : warningOrange,
                    ),
                  ),
                ],
              ),
            ).animate(target: isAligned ? 1 : 0).scale(duration: 300.ms);
          }),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms);
  }

  Widget _buildCompassRing(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primaryPurple.withOpacity(0.3), width: 3),
        gradient: RadialGradient(colors: [Colors.transparent, primaryPurple.withOpacity(0.05)]),
      ),
      child: Obx(() {
        final rotation = -controller.heading.value * (pi / 180);
        return Transform.rotate(
          angle: rotation,
          child: CustomPaint(size: Size(size, size), painter: CompassRingPainter()),
        );
      }),
    );
  }

  Widget _buildCompassFace(double size) {
    return Obx(() {
      final rotation = -controller.heading.value * (pi / 180);
      return Transform.rotate(
        angle: rotation,
        child: Container(
          width: size * 0.7,
          height: size * 0.7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                primaryPurple.withOpacity(0.8),
                primaryPurple.withOpacity(0.4),
                Colors.white,
              ],
            ),
            boxShadow: [BoxShadow(color: primaryPurple.withOpacity(0.3), blurRadius: 20)],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // North indicator
              Positioned(
                top: 10,
                child: Text(
                  'N',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildQiblaIndicator(double size) {
    return Obx(() {
      final qiblaRad = controller.qiblaAngle.value * (pi / 180);
      final headingRad = controller.heading.value * (pi / 180);
      final angle = qiblaRad - headingRad;

      return Transform.rotate(
        angle: angle,
        child: Transform.translate(
          offset: Offset(0, -(size * 0.35)),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentTeal,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: accentTeal.withOpacity(0.5), blurRadius: 15, spreadRadius: 2),
              ],
            ),
            child: const Icon(Icons.mosque, color: Colors.white, size: 28),
          ),
        ),
      );
    });
  }

  Widget _buildCenterDisplay() {
    return Obx(() {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: primaryPurple, width: 3),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: Center(
          child: Text(
            '${controller.qiblaAngle.value.round()}°',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: darkPurple,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCalibrationWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warningOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: warningOrange, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: warningOrange, size: 32),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compass Needs Calibration',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Move your phone in a figure-8 motion to calibrate',
                  style: GoogleFonts.poppins(fontSize: 12, color: darkPurple.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().shake(duration: 600.ms);
  }

  Widget _buildLocationStatus() {
    return Obx(() {
      final isReady = controller.locationReady.value;
      final error = controller.locationError.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isReady ? Icons.location_on : Icons.location_off,
              color: isReady ? successGreen : warningOrange,
              size: 28,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                isReady
                    ? '📍 Location acquired - Accurate Qibla direction'
                    : error.isEmpty
                    ? '⚠️ Using manual Qibla mode'
                    : error,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: darkPurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildManualAdjustment() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryPurple.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: primaryPurple, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Manual Qibla Adjustment',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: darkPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _adjustButton(
                icon: Icons.rotate_left,
                label: '-10°',
                onPressed: () => controller.adjustManualQiblaAngle(-10),
              ),
              _adjustButton(
                icon: Icons.remove,
                label: '-1°',
                onPressed: () => controller.adjustManualQiblaAngle(-1),
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryPurple, primaryPurple.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${controller.manualQiblaAngle.value.round()}°',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              _adjustButton(
                icon: Icons.add,
                label: '+1°',
                onPressed: () => controller.adjustManualQiblaAngle(1),
              ),
              _adjustButton(
                icon: Icons.rotate_right,
                label: '+10°',
                onPressed: () => controller.adjustManualQiblaAngle(10),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Tap Recalibrate button to enable location-based Qibla',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: darkPurple.withOpacity(0.6),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _adjustButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primaryPurple.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryPurple, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: darkPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for compass ring with degree markers
class CompassRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = const Color(0xFF2D1B69)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw major direction markers (N, E, S, W)
    final directions = ['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90) * (pi / 180);
      final x = center.dx + radius * 0.85 * sin(angle);
      final y = center.dy - radius * 0.85 * cos(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF8F66FF),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }

    // Draw degree markers
    for (int i = 0; i < 360; i += 10) {
      final angle = i * (pi / 180);
      final isMajor = i % 30 == 0;

      final start = Offset(
        center.dx + radius * 0.92 * sin(angle),
        center.dy - radius * 0.92 * cos(angle),
      );

      final end = Offset(
        center.dx + radius * (isMajor ? 0.85 : 0.88) * sin(angle),
        center.dy - radius * (isMajor ? 0.85 : 0.88) * cos(angle),
      );

      paint.strokeWidth = isMajor ? 3 : 1;
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
