import 'dart:math';
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

  // App theme colors
  static const Color primaryPurple = Color(0xFF8F66FF);
  static const Color darkPurple = Color(0xFF2D1B69);
  static const Color goldAccent = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final compassSize = min(size.width * 0.65, 280.0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            elevation: 0,
            backgroundColor: primaryPurple,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryPurple, darkPurple],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative moon
                    Positioned(
                      right: 20,
                      top: 40,
                      child: Icon(
                        Icons.nightlight_round,
                        color: goldAccent.withOpacity(0.3),
                        size: 60,
                      ),
                    ),
                  ],
                ),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore, color: goldAccent, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Qibla Finder',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Status Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatusChip(
                          icon: Icons.wifi,
                          label: 'Online',
                          isActiveBuilder: () => controller.isOnline.value,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusChip(
                          icon: Icons.gps_fixed,
                          label: 'GPS',
                          isActiveBuilder: () => controller.locationReady.value,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Bismillah Card
                // _buildBismillahCard(),
                // const SizedBox(height: 16),

                // Banner Ad
                const OptimizedBannerAdWidget(padding: EdgeInsets.symmetric(horizontal: 20)),

                const SizedBox(height: 16),

                // Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.explore,
                          label: 'Qibla',
                          valueBuilder: () => '${controller.qiblaAngle.value.round()}°',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.mosque,
                          label: 'Distance',
                          valueBuilder: () => controller.formattedDistance,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Compass
                _buildCompassSection(compassSize),

                // const SizedBox(height: 20),

                // Accuracy Indicator
                _buildAccuracyIndicator(),

                const SizedBox(height: 20),

                // City Selector
                _buildCitySelector(),

                const SizedBox(height: 16),

                // Calibration Warning
                Obx(
                  () => controller.calibrationNeeded.value
                      ? _buildCalibrationCard()
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required bool Function() isActiveBuilder,
  }) {
    return Obx(() {
      final isActive = isActiveBuilder();
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? primaryPurple.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: (isActive ? primaryPurple : Colors.grey).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 18, color: isActive ? primaryPurple : Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.grey[800] : Colors.grey,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBismillahCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryPurple.withOpacity(0.1), darkPurple.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldAccent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
            style: GoogleFonts.amiri(fontSize: 24, color: darkPurple, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'In the name of Allah, the Most Gracious, the Most Merciful',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String Function() valueBuilder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryPurple, size: 22),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Text(
              valueBuilder(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: darkPurple,
              ),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassSection(double compassSize) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [primaryPurple, darkPurple],
        // ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [],
      ),
      child: Column(
        children: [
          // Compass
          Container(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryPurple,
              border: Border.all(color: goldAccent.withOpacity(0.5), width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Compass Widget
                IslamicCompassWidget(controller: controller, compassSize: compassSize),

                // Center Kaaba indicator
                Obx(() {
                  final headingRad = controller.heading.value * (pi / 180);
                  final qiblaRad = controller.qiblaAngle.value * (pi / 180);
                  final angle = qiblaRad - headingRad;

                  return Transform.rotate(
                    angle: angle,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: goldAccent.withOpacity(0.2),
                      ),
                      child: Icon(Icons.mosque, color: goldAccent, size: 22),
                    ),
                  );
                }),
              ],
            ),
          ),

          // const SizedBox(height: 16),

          // Direction text
          Obx(
            () => Text(
              '${controller.heading.value.round()}° ${_getDirection(controller.heading.value)}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ).animate().scale(
      duration: 600.ms,
      curve: Curves.easeOutBack,
      begin: const Offset(0.9, 0.9),
      end: const Offset(1, 1),
    );
  }

  String _getDirection(double heading) {
    if (heading >= 337.5 || heading < 22.5) return 'N';
    if (heading >= 22.5 && heading < 67.5) return 'NE';
    if (heading >= 67.5 && heading < 112.5) return 'E';
    if (heading >= 112.5 && heading < 157.5) return 'SE';
    if (heading >= 157.5 && heading < 202.5) return 'S';
    if (heading >= 202.5 && heading < 247.5) return 'SW';
    if (heading >= 247.5 && heading < 292.5) return 'W';
    return 'NW';
  }

  Widget _buildAccuracyIndicator() {
    return Obx(() {
      final isAccurate = controller.locationReady.value && !controller.calibrationNeeded.value;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isAccurate ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAccurate ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAccurate ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isAccurate ? 'Accurate Qibla Direction' : 'Manual Mode Active',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isAccurate ? Colors.green[700] : Colors.orange[700],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCitySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.location_city, color: primaryPurple, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Offline Qibla',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Select city when GPS is unavailable',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 12),

          // Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Obx(
              () => DropdownButton<int>(
                value: controller.selectedCityIndex.value >= 0
                    ? controller.selectedCityIndex.value
                    : null,
                hint: Text(
                  'Choose your city...',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
                ),
                isExpanded: true,
                underline: const SizedBox(),
                icon: Icon(Icons.keyboard_arrow_down, color: primaryPurple),
                items: List.generate(
                  QiblaController.popularCities.length,
                  (index) => DropdownMenuItem<int>(
                    value: index,
                    child: Text(
                      QiblaController.popularCities[index]['name'] as String,
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                    ),
                  ),
                ),
                onChanged: (index) {
                  if (index != null) controller.selectCity(index);
                },
              ),
            ),
          ),

          // Action buttons
          Obx(
            () => controller.selectedCityIndex.value >= 0
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => controller.useCurrentLocation(),
                            icon: const Icon(Icons.my_location, size: 18),
                            label: Text('Use GPS', style: GoogleFonts.poppins(fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryPurple,
                              side: BorderSide(color: primaryPurple.withOpacity(0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: primaryPurple,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            onPressed: () => controller.refreshQibla(),
                            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.screen_rotation,
              color: Colors.orange,
              size: 24,
            ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2000.ms),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calibration Needed',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[800],
                  ),
                ),
                Text(
                  'Move phone in figure-8 pattern',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().shake(duration: 300.ms);
  }
}
