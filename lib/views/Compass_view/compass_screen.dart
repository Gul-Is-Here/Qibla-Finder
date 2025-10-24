import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/compass_controller/qibla_controller.dart';
import '../../routes/app_pages.dart';
import '../../services/ads/ad_service.dart';
import '../../services/performance_service.dart';
import '../../widgets/compass_widget/compass_widget.dart';
import '../../widgets/ads_widget/optimized_banner_ad.dart';

class OptimizedHomeScreen extends StatelessWidget {
  OptimizedHomeScreen({super.key});

  final QiblaController controller = Get.find<QiblaController>();
  final AdService adService = Get.find<AdService>();
  final PerformanceService performanceService = Get.find<PerformanceService>();

  // Dark, modern Islamic palette to mirror the screenshot
  static const Color bg = Color(0xFF0E3A37); // deep teal background
  static const Color panel = Color(0xFF0F4B46); // slightly lighter panel
  static const Color pill = Color(0xFF1B5E20); // green pill/button
  static const Color stroke = Color(0xFF2A6C66); // lines / borders
  static const Color textOnDark = Colors.white; // primary text
  static const Color subText = Color(0xCCDAE7E6); // secondary text

  // ---- REFRESH HANDLER (loads ads like previously) ----
  Future<void> _handleRefresh(BuildContext context) async {
    // Refresh banners immediately
    adService.refreshBannerAds();

    // (optional) re-fetch sensors/location if you expose such methods
    // await controller.refresh(); // uncomment if you have this

    if (adService.shouldShowInterstitialAd()) {
      final c = Completer<void>();
      adService.showInterstitialAd(
        onAdClosed: () {
          // go back to MAIN like before, then complete the refresh
          Get.offAllNamed(Routes.MAIN);
          c.complete();
        },
      );
      await c.future;
    } else {
      // light refresh path
      Get.offAllNamed(Routes.HOME);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bg,
      // ---- FAB refresh (same logic as pull-to-refresh) ----
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleRefresh(context),
        backgroundColor: pill,
        elevation: 3,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      body: SafeArea(
        // ---- Pull to refresh wrapper ----
        child: RefreshIndicator(
          color: pill,
          backgroundColor: panel,
          onRefresh: () => _handleRefresh(context),
          child: Column(
            children: [
              // ---------------------
              // 1) Bismillah section (KEPT)
              // ---------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ',
                      style: GoogleFonts.amiri(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textOnDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _chip(
                          icon: performanceService.isOptimizationEnabled.value
                              ? Icons.flash_on
                              : Icons.flash_off,
                          label: performanceService.isOptimizationEnabled.value
                              ? 'Optimized'
                              : 'Standard',
                        ),
                        const SizedBox(width: 8),
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

              // ---------------------
              // 2) Banner Ad (KEPT)
              // ---------------------
              const OptimizedBannerAdWidget(
                key: ValueKey('main_banner'),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),

              // ---------------------
              // 3) Main content (screenshot style)
              // ---------------------
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      children: [
                        Text(
                          'Qibla Direction',
                          style: GoogleFonts.poppins(
                            color: textOnDark,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Divider(color: stroke, thickness: 1),
                        const SizedBox(height: 18),

                        // Compass pill (visual only, like screenshot)
                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                title: 'Your angle to Qibla',
                                valueBuilder: () => Obx(
                                  () => Text(
                                    // If you later expose deviceHeading, compute ((qibla - heading)+360)%360 here
                                    '${controller.qiblaAngle.value.round()}°',
                                    style: GoogleFonts.poppins(
                                      color: textOnDark,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _statCard(
                                title: 'Qibla angle from N',
                                valueBuilder: () => Obx(
                                  () => Text(
                                    '${controller.qiblaAngle.value.round()}°',
                                    style: GoogleFonts.poppins(
                                      color: textOnDark,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 26),

                        CompassWidget(
                              controller: controller,
                              compassSize: min(
                                size.width,
                                size.height * 0.3,
                              ).clamp(220, 300).toDouble(),
                            )
                            .animate(onPlay: (c) => c.repeat())
                            .shimmer(
                              duration: 3800.ms,
                              colors: [Colors.transparent, Colors.white12, Colors.transparent],
                            ),

                        const SizedBox(height: 20),

                        Obx(
                          () => Text(
                            'Qibla angle : ${controller.qiblaAngle.value.round()}°',
                            style: GoogleFonts.poppins(
                              color: textOnDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: panel,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: stroke),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  controller.locationReady.value
                                      ? Icons.location_on
                                      : Icons.location_off,
                                  color: controller.locationReady.value
                                      ? Colors.greenAccent
                                      : Colors.orangeAccent,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.locationReady.value
                                        ? 'Location Ready - Accurate Qibla'
                                        : controller.locationError.value.isEmpty
                                        ? 'Using Manual Qibla Mode'
                                        : controller.locationError.value,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: subText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Manual Qibla adjustment controls (shown when location not available)
                        Obx(
                          () => !controller.locationReady.value
                              ? Column(
                                  children: [
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: panel,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: stroke),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Colors.orangeAccent,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Adjust Qibla direction manually',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    color: subText,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              _angleButton(
                                                icon: Icons.rotate_left,
                                                label: '-10°',
                                                onPressed: () =>
                                                    controller.adjustManualQiblaAngle(-10),
                                              ),
                                              _angleButton(
                                                icon: Icons.rotate_left,
                                                label: '-1°',
                                                onPressed: () =>
                                                    controller.adjustManualQiblaAngle(-1),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: pill,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  '${controller.manualQiblaAngle.value.round()}°',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              _angleButton(
                                                icon: Icons.rotate_right,
                                                label: '+1°',
                                                onPressed: () =>
                                                    controller.adjustManualQiblaAngle(1),
                                              ),
                                              _angleButton(
                                                icon: Icons.rotate_right,
                                                label: '+10°',
                                                onPressed: () =>
                                                    controller.adjustManualQiblaAngle(10),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Rotate your device to face Qibla. Adjust angle if needed.',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: subText.withOpacity(0.7),
                                              fontStyle: FontStyle.italic,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----- UI helpers -----

  Widget _chip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({required String title, required Widget Function() valueBuilder}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stroke),
      ),
      child: Column(
        children: [
          valueBuilder(),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: subText, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _angleButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: stroke),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
