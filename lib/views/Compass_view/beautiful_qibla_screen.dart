import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/compass_controller/qibla_controller.dart';
import '../../services/ads/ad_service.dart';
import '../../widgets/compass_widget/islamic_compass_widget.dart';
import '../../widgets/ads_widget/optimized_banner_ad.dart';

class BeautifulQiblaScreen extends StatefulWidget {
  const BeautifulQiblaScreen({super.key});

  @override
  State<BeautifulQiblaScreen> createState() => _BeautifulQiblaScreenState();
}

class _BeautifulQiblaScreenState extends State<BeautifulQiblaScreen> with TickerProviderStateMixin {
  final QiblaController controller = Get.find<QiblaController>();
  final AdService adService = Get.find<AdService>();

  late AnimationController _pulseController;
  late AnimationController _rotateController;

  // App theme colors - Purple palette
  static const Color primary = Color(0xFF8F66FF);
  static const Color darkPurple = Color(0xFF2D1B69);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color moonWhite = Color(0xFFF8F4E9);
  static const Color darkBg = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this)
      ..repeat(reverse: true);

    _rotateController = AnimationController(duration: const Duration(seconds: 20), vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: darkBg,
      body: Stack(
        children: [
          // Animated starry background
          _buildStarryBackground(size),

          // Main content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Custom App Bar
                SliverToBoxAdapter(child: _buildIslamicHeader()),

                // Compass Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // Bismillah with decorative frame
                        _buildBismillahSection(),

                        const SizedBox(height: 20),

                        // Stats Cards
                        _buildStatsRow(),

                        const SizedBox(height: 24),

                        // Main Compass with Islamic Design
                        _buildIslamicCompass(size),

                        const SizedBox(height: 20),

                        // Qibla Accuracy Indicator
                        _buildQiblaAccuracyIndicator(),

                        const SizedBox(height: 16),

                        // Banner Ad
                        const OptimizedBannerAdWidget(padding: EdgeInsets.symmetric(horizontal: 0)),

                        const SizedBox(height: 16),

                        // City Selector with Islamic Design
                        _buildIslamicCitySelector(),

                        const SizedBox(height: 16),

                        // Calibration Guide
                        Obx(
                          () => controller.calibrationNeeded.value
                              ? _buildIslamicCalibrationGuide()
                              : const SizedBox.shrink(),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarryBackground(Size size) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1A2E), Color(0xFF2D1B69), Color(0xFF3D2B7A), Color(0xFF8F66FF)],
              stops: [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        ),

        // Animated stars
        ...List.generate(30, (index) {
          final random = Random(index);
          return Positioned(
            left: random.nextDouble() * size.width,
            top: random.nextDouble() * size.height * 0.6,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.3 + (_pulseController.value * 0.7 * (index % 3 == 0 ? 1 : 0.5)),
                  child: Icon(Icons.star, size: 2 + random.nextDouble() * 4, color: Colors.white),
                );
              },
            ),
          );
        }),

        // Crescent moon
        Positioned(
          top: 60,
          right: 30,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + (_pulseController.value * 0.05),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: goldAccent.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(Icons.nightlight_round, color: goldAccent, size: 36),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIslamicHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Status chips
          Row(
            children: [
              Obx(
                () => _buildStatusChip(
                  icon: controller.isOnline.value ? Icons.wifi : Icons.wifi_off,
                  label: controller.isOnline.value ? 'Online' : 'Offline',
                  isActive: controller.isOnline.value,
                ),
              ),
            ],
          ),

          // Title
          Column(
            children: [
              Text(
                'QIBLA',
                style: GoogleFonts.cinzel(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: goldAccent,
                  letterSpacing: 4,
                ),
              ),
              Text(
                'FINDER',
                style: GoogleFonts.cinzel(
                  fontSize: 12,
                  color: moonWhite.withOpacity(0.8),
                  letterSpacing: 6,
                ),
              ),
            ],
          ),

          // Location status
          Obx(
            () => _buildStatusChip(
              icon: controller.locationReady.value ? Icons.gps_fixed : Icons.gps_off,
              label: controller.locationReady.value ? 'GPS' : 'Manual',
              isActive: controller.locationReady.value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({required IconData icon, required String label, required bool isActive}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isActive ? primary : Colors.grey).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isActive ? goldAccent : Colors.grey).withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isActive ? goldAccent : Colors.grey),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: isActive ? moonWhite : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBismillahSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [goldAccent.withOpacity(0.1), Colors.transparent, goldAccent.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldAccent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Decorative Islamic pattern top
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDecorativeLine(),
              const SizedBox(width: 12),
              Icon(Icons.star, color: goldAccent, size: 12),
              const SizedBox(width: 12),
              _buildDecorativeLine(),
            ],
          ),
          const SizedBox(height: 12),

          // Bismillah text
          Text(
            'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
            style: GoogleFonts.amiri(fontSize: 26, color: goldAccent, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),
          Text(
            'In the name of Allah, the Most Gracious, the Most Merciful',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: moonWhite.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),
          // Decorative Islamic pattern bottom
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDecorativeLine(),
              const SizedBox(width: 12),
              Icon(Icons.star, color: goldAccent, size: 12),
              const SizedBox(width: 12),
              _buildDecorativeLine(),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildDecorativeLine() {
    return Container(
      width: 60,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.transparent, goldAccent, Colors.transparent]),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.explore,
            title: 'QIBLA',
            valueBuilder: () => '${controller.qiblaAngle.value.round()}°',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.mosque,
            title: 'DISTANCE',
            valueBuilder: () => controller.formattedDistance,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms);
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String Function() valueBuilder,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [darkPurple.withOpacity(0.8), primary.withOpacity(0.6)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldAccent.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: goldAccent.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: goldAccent, size: 20),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Text(
              valueBuilder(),
              style: GoogleFonts.cinzel(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: moonWhite,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: moonWhite.withOpacity(0.9),
              letterSpacing: 2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIslamicCompass(Size size) {
    final compassSize = min(size.width * 0.85, 340.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [darkPurple.withOpacity(0.3), darkBg.withOpacity(0.8)]),
        border: Border.all(color: goldAccent.withOpacity(0.4), width: 3),
        boxShadow: [
          BoxShadow(color: goldAccent.withOpacity(0.2), blurRadius: 30, spreadRadius: 5),
          BoxShadow(color: primary.withOpacity(0.3), blurRadius: 50, spreadRadius: 10),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer decorative ring
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateController.value * 2 * pi * 0.1,
                child: Container(
                  width: compassSize + 30,
                  height: compassSize + 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: goldAccent.withOpacity(0.15), width: 1),
                  ),
                  child: CustomPaint(painter: _IslamicPatternPainter(goldAccent.withOpacity(0.3))),
                ),
              );
            },
          ),

          // Compass Widget
          IslamicCompassWidget(controller: controller, compassSize: compassSize),

          // Center Kaaba icon - Rotates to align with Qibla direction
          Obx(() {
            final headingRad = controller.heading.value * (pi / 180);
            final qiblaRad = controller.qiblaAngle.value * (pi / 180);
            final qiblaIndicatorAngle = qiblaRad - headingRad;

            return Transform.rotate(
              angle: qiblaIndicatorAngle,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [goldAccent.withOpacity(0.3), Colors.transparent],
                  ),
                ),
                child: Center(child: Icon(Icons.mosque, color: goldAccent, size: 28)),
              ),
            );
          }),
        ],
      ),
    ).animate().scale(
      duration: 800.ms,
      curve: Curves.easeOutBack,
      begin: const Offset(0.8, 0.8),
      end: const Offset(1, 1),
    );
  }

  Widget _buildQiblaAccuracyIndicator() {
    return Obx(() {
      final isAccurate = controller.locationReady.value && !controller.calibrationNeeded.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isAccurate
                ? [primary.withOpacity(0.3), darkPurple.withOpacity(0.3)]
                : [Colors.orange.withOpacity(0.3), Colors.orange.withOpacity(0.1)],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isAccurate ? goldAccent.withOpacity(0.5) : Colors.orange.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAccurate ? Colors.green : Colors.orange,
                boxShadow: [
                  BoxShadow(
                    color: (isAccurate ? Colors.green : Colors.orange).withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isAccurate
                  ? 'Accurate Qibla Direction'
                  : controller.locationError.value.isEmpty
                  ? 'Manual Mode Active'
                  : controller.locationError.value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: moonWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }).animate().fadeIn(duration: 500.ms, delay: 400.ms);
  }

  Widget _buildIslamicCitySelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [darkPurple.withOpacity(0.6), primary.withOpacity(0.4)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: goldAccent.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: darkPurple.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: goldAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.location_city, color: goldAccent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offline Qibla',
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: goldAccent,
                      ),
                    ),
                    Text(
                      'Select your city when GPS is unavailable',
                      style: GoogleFonts.poppins(fontSize: 11, color: moonWhite.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: darkBg.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: goldAccent.withOpacity(0.2)),
            ),
            child: Obx(
              () => DropdownButton<int>(
                value: controller.selectedCityIndex.value >= 0
                    ? controller.selectedCityIndex.value
                    : null,
                hint: Text(
                  'Choose your city...',
                  style: GoogleFonts.poppins(fontSize: 14, color: moonWhite.withOpacity(0.6)),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                dropdownColor: darkPurple,
                icon: Icon(Icons.keyboard_arrow_down, color: goldAccent),
                items: List.generate(
                  QiblaController.popularCities.length,
                  (index) => DropdownMenuItem<int>(
                    value: index,
                    child: Text(
                      QiblaController.popularCities[index]['name'] as String,
                      style: GoogleFonts.poppins(fontSize: 14, color: moonWhite),
                    ),
                  ),
                ),
                onChanged: (index) {
                  if (index != null) {
                    controller.selectCity(index);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Action Buttons Row
          Obx(
            () => controller.selectedCityIndex.value >= 0
                ? Row(
                    children: [
                      // Use Current Location Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => controller.useCurrentLocation(),
                          icon: const Icon(Icons.my_location, size: 18),
                          label: Text(
                            'Use Current Location',
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: moonWhite,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Refresh Button
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [goldAccent.withOpacity(0.8), goldAccent],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: goldAccent.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => controller.refreshQibla(),
                          icon: const Icon(Icons.refresh, color: darkBg),
                          tooltip: 'Refresh Qibla',
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildIslamicCalibrationGuide() {
    return Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.screen_rotation,
                  color: Colors.orange,
                  size: 28,
                ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2000.ms),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calibration Needed',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Move your phone in a figure-8 pattern to improve compass accuracy',
                      style: GoogleFonts.poppins(fontSize: 12, color: moonWhite.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .shake(duration: 500.ms)
        .then()
        .shimmer(
          duration: 2000.ms,
          colors: [Colors.transparent, Colors.orange.withOpacity(0.3), Colors.transparent],
        );
  }
}

// Custom painter for Islamic geometric patterns
class _IslamicPatternPainter extends CustomPainter {
  final Color color;

  _IslamicPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw 8-pointed star pattern
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4);
      final startPoint = Offset(
        center.dx + (radius - 10) * cos(angle),
        center.dy + (radius - 10) * sin(angle),
      );
      final endPoint = Offset(
        center.dx + (radius - 30) * cos(angle + pi / 8),
        center.dy + (radius - 30) * sin(angle + pi / 8),
      );
      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
