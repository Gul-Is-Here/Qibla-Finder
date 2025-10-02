import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qibla_compass_offline/widget/compass_widget.dart';

import '../controller/qibla_controller.dart';
import '../routes/app_pages.dart';
import '../services/ad_service.dart';
import '../services/performance_service.dart';
import '../widget/simple_compass_widget.dart';
import '../widget/customized_drawer.dart';
import '../widget/optimized_banner_ad.dart';

class OptimizedHomeScreen extends StatelessWidget {
  const OptimizedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QiblaController controller = Get.find();
    final AdService adService = Get.find();
    final PerformanceService performanceService = Get.find();

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF00332F),
      appBar: AppBar(
        title: Text(
          'Qibla Compass',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.3), Colors.transparent],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            height: 3.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00BCD4),
                  Color(0xFF4CAF50),
                  Color(0xFF8BC34A),
                ],
              ),
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Performance mode toggle with better design
          Obx(
            () => Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: performanceService.isOptimizationEnabled.value
                        ? Colors.yellow.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: performanceService.isOptimizationEnabled.value
                          ? Colors.yellow.withOpacity(0.5)
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    performanceService.isOptimizationEnabled.value
                        ? Icons.flash_on
                        : Icons.flash_off,
                    color: performanceService.isOptimizationEnabled.value
                        ? Colors.yellow
                        : Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  if (performanceService.isOptimizationEnabled.value) {
                    performanceService.disableBatteryOptimization();
                    Get.snackbar(
                      'Performance Mode',
                      'Optimization disabled',
                      backgroundColor: Colors.orange.withOpacity(0.9),
                      colorText: Colors.white,
                      borderRadius: 12,
                      margin: const EdgeInsets.all(16),
                    );
                  } else {
                    performanceService.enableBatteryOptimization();
                    Get.snackbar(
                      'Performance Mode',
                      'Optimization enabled for better battery life',
                      backgroundColor: Colors.green.withOpacity(0.9),
                      colorText: Colors.white,
                      borderRadius: 12,
                      margin: const EdgeInsets.all(16),
                    );
                  }
                },
              ),
            ),
          ),
          // Connectivity indicator with improved design
          Obx(
            () => Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: controller.isOnline.value
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: controller.isOnline.value
                          ? Colors.green.withOpacity(0.5)
                          : Colors.red.withOpacity(0.5),
                    ),
                  ),
                  child: Badge(
                    isLabelVisible: !controller.isOnline.value,
                    backgroundColor: Colors.red,
                    child: Icon(
                      controller.isOnline.value ? Icons.wifi : Icons.wifi_off,
                      color: controller.isOnline.value
                          ? Colors.green
                          : Colors.red,
                      size: 20,
                    ),
                  ),
                ),
                onPressed: () {
                  Get.snackbar(
                    'Connection Status',
                    controller.isOnline.value ? 'Online' : 'Offline',
                    backgroundColor: controller.isOnline.value
                        ? Colors.green.withOpacity(0.9)
                        : Colors.red.withOpacity(0.9),
                    colorText: Colors.white,
                    borderRadius: 12,
                    margin: const EdgeInsets.all(16),
                  );
                },
              ),
            ),
          ),
          // Vibration toggle button
          Obx(
            () => Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: controller.isVibrationEnabled.value
                        ? Colors.green.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: controller.isVibrationEnabled.value
                          ? Colors.green.withOpacity(0.5)
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    controller.isVibrationEnabled.value
                        ? Icons.vibration
                        : Icons.mobile_off,
                    color: controller.isVibrationEnabled.value
                        ? Colors.green
                        : Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  controller.toggleVibration(
                    !controller.isVibrationEnabled.value,
                  );
                  Get.snackbar(
                    'Vibration',
                    controller.isVibrationEnabled.value
                        ? 'Vibration enabled'
                        : 'Vibration disabled',
                    backgroundColor: controller.isVibrationEnabled.value
                        ? Colors.green.withOpacity(0.9)
                        : Colors.orange.withOpacity(0.9),
                    colorText: Colors.white,
                    borderRadius: 12,
                    margin: const EdgeInsets.all(16),
                  );
                },
              ),
            ),
          ),
          // Sound toggle button
          Obx(
            () => Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: controller.isSoundEnabled.value
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: controller.isSoundEnabled.value
                          ? Colors.blue.withOpacity(0.5)
                          : Colors.white.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    controller.isSoundEnabled.value
                        ? Icons.volume_up
                        : Icons.volume_off,
                    color: controller.isSoundEnabled.value
                        ? Colors.blue
                        : Colors.white,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  controller.toggleSound(!controller.isSoundEnabled.value);
                  Get.snackbar(
                    'Sound Effects',
                    controller.isSoundEnabled.value
                        ? 'Sound effects enabled'
                        : 'Sound effects disabled',
                    backgroundColor: controller.isSoundEnabled.value
                        ? Colors.blue.withOpacity(0.9)
                        : Colors.orange.withOpacity(0.9),
                    colorText: Colors.white,
                    borderRadius: 12,
                    margin: const EdgeInsets.all(16),
                  );
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () => Get.toNamed(Routes.SETTINGS),
            ),
          ),
        ],
      ),
      drawer: buildDrawer(context),

      // Fixed layout — no scroll
      body: SafeArea(
        child: Column(
          children: [
            // Top Banner Ad with enhanced styling
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const OptimizedBannerAdWidget(
                key: ValueKey('top_banner'),
                padding: EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),

            // Content area: make sure compass always fully fits
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Reserve some height for the buttons and padding
                  const double buttonsHeight = 120;
                  final double availableForCompass = max(
                    0,
                    constraints.maxHeight - buttonsHeight,
                  );

                  // Strict square side for compass (bounded)
                  final double compassSize =
                      (min(screenWidth, availableForCompass) * 0.85).clamp(
                        220.0,
                        360.0,
                      );

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Status indicator cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatusCard(
                                'Accuracy',
                                '±2°',
                                Icons.gps_fixed,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatusCard(
                                'Direction',
                                '${controller.qiblaAngle.value.toStringAsFixed(0)}°',
                                Icons.explore,
                                Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Enhanced Compass with glow effect
                      Container(
                        decoration: BoxDecoration(
                          // shape: BoxShape.circle,
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.tealAccent.withOpacity(0.3),
                          //     blurRadius: 30,
                          //     spreadRadius: 10,
                          //   ),
                          //   BoxShadow(
                          //     color: Colors.black.withOpacity(0.3),
                          //     blurRadius: 15,
                          //     spreadRadius: 5,
                          //   ),
                          // ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child:
                              SizedBox(
                                    width: compassSize,
                                    height: compassSize,
                                    child: CompassWidget(
                                      controller: controller,
                                      compassSize: compassSize,
                                    ),
                                  )
                                  .animate()
                                  .shimmer(
                                    duration: 3000.ms,
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.15),
                                      Colors.tealAccent.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                  )
                                  .then()
                                  .scale(
                                    duration: 2000.ms,
                                    curve: Curves.easeInOut,
                                    begin: const Offset(1.0, 1.0),
                                    end: const Offset(1.02, 1.02),
                                  )
                                  .then()
                                  .scale(
                                    duration: 2000.ms,
                                    curve: Curves.easeInOut,
                                    begin: const Offset(1.02, 1.02),
                                    end: const Offset(1.0, 1.0),
                                  ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: _buildActionButtons(controller, adService),
                      ),
                    ],
                  );
                },
              ),
            ),

            const OptimizedBannerAdWidget(
              key: ValueKey('bottom_banner'),
              padding: EdgeInsets.only(top: 8.0),
              showOnlyWhenLoaded: true,
              isBottomBanner: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(QiblaController controller, AdService adService) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.refresh,
            label: 'Refresh',
            onTap: () {
              // Refresh banner ads to prevent AdWidget reuse error
              adService.refreshBannerAds();

              if (adService.shouldShowInterstitialAd()) {
                adService.showInterstitialAd(
                  onAdClosed: () => Get.offAllNamed(Routes.HOME),
                );
              } else {
                Get.offAllNamed(Routes.HOME);
              }
            },
          ),
          _buildActionButton(
            icon: Icons.my_location,
            label: 'Recalibrate',
            onTap: () {
              Get.snackbar(
                'Calibration',
                'Move your device in a figure-8 motion to calibrate',
                backgroundColor: Colors.blue.withOpacity(0.9),
                colorText: Colors.white,
                borderRadius: 12,
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 4),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          // color: const Color(0xFF00332F),
          // borderRadius: BorderRadius.circular(20),
          // border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
