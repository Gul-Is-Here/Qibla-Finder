import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/ads/inmobi_ad_service.dart';
import '../../services/ads/ad_service.dart';

/// Test screen for InMobi and AdMob ads integration
///
/// Add this to your app routes and access it from settings/debug menu:
/// ```dart
/// GetPage(
///   name: '/ad-test',
///   page: () => AdTestScreen(),
/// ),
/// ```
class AdTestScreen extends StatefulWidget {
  const AdTestScreen({super.key});

  @override
  State<AdTestScreen> createState() => _AdTestScreenState();
}

class _AdTestScreenState extends State<AdTestScreen> {
  late final InMobiAdService inMobiService;
  late final AdService adMobService;
  bool _servicesInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    try {
      inMobiService = Get.find<InMobiAdService>();
      adMobService = Get.find<AdService>();
      _servicesInitialized = true;
    } catch (e) {
      print('❌ Services not ready: $e');
      // Retry after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _initializeServices();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_servicesInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ad Integration Test'),
          backgroundColor: const Color(0xFF8F66FF),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing ad services...'),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Integration Test'),
        backgroundColor: const Color(0xFF8F66FF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // === INMOBI SECTION ===
            _buildSectionHeader('InMobi Ads', Icons.ads_click, Colors.blue),
            const SizedBox(height: 12),

            Obx(
              () => _buildStatusCard(
                'InMobi Status',
                inMobiService.isInitialized.value ? '✅ Initialized' : '❌ Not Initialized',
                inMobiService.isInitialized.value ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 8),

            Obx(
              () => _buildStatusCard(
                'Interstitial Status',
                inMobiService.isInterstitialLoaded.value ? '✅ Loaded & Ready' : '⏳ Not Loaded',
                inMobiService.isInterstitialLoaded.value ? Colors.green : Colors.orange,
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () async {
                Get.snackbar(
                  'ℹ️ Info',
                  'InMobi interstitial loads automatically. Check status above.',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 3),
                );
              },
              icon: const Icon(Icons.info),
              label: const Text('InMobi Loads Automatically'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 8),

            Obx(
              () => ElevatedButton.icon(
                onPressed: inMobiService.isInterstitialLoaded.value
                    ? () async {
                        final success = await inMobiService.showInterstitialAd(
                          onAdClosed: () {
                            Get.snackbar(
                              '✅ Ad Closed',
                              'InMobi ad was dismissed. Next ad will auto-load.',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        );

                        if (!success) {
                          Get.snackbar(
                            '❌ Failed',
                            'Ad not ready or daily limit reached',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Show InMobi Interstitial'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 24),

            // === ADMOB SECTION ===
            _buildSectionHeader('AdMob Ads', Icons.monetization_on, Colors.purple),
            const SizedBox(height: 12),

            Obx(
              () => _buildStatusCard(
                'Interstitial Status',
                adMobService.isInterstitialAdLoaded.value ? '✅ Loaded & Ready' : '⏳ Not Loaded',
                adMobService.isInterstitialAdLoaded.value ? Colors.green : Colors.orange,
              ),
            ),

            const SizedBox(height: 12),

            Obx(
              () => ElevatedButton.icon(
                onPressed: adMobService.isInterstitialAdLoaded.value
                    ? () {
                        adMobService.showInterstitialAd(
                          onAdClosed: () {
                            Get.snackbar(
                              '✅ Ad Closed',
                              'AdMob ad was dismissed',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        );
                      }
                    : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Show AdMob Interstitial'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 24),

            // === SMART WATERFALL ===
            _buildSectionHeader('Smart Waterfall', Icons.water_drop, Colors.teal),
            const SizedBox(height: 12),

            Text(
              'Try AdMob first, fallback to InMobi',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () => _showSmartAd(),
              icon: const Icon(Icons.smart_toy),
              label: const Text('Show Smart Ad (Waterfall)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 24),

            // === INFO SECTION ===
            _buildSectionHeader('Information', Icons.info, Colors.orange),
            const SizedBox(height: 12),

            _buildInfoCard(
              'Daily Limit',
              '3 interstitial ads per day (shared)',
              Icons.block,
              Colors.orange,
            ),

            const SizedBox(height: 8),

            _buildInfoCard(
              'Reset Time',
              'Daily limit resets at 5:00 AM',
              Icons.refresh,
              Colors.blue,
            ),

            const SizedBox(height: 8),

            _buildInfoCard(
              'Testing',
              'Ads may not show immediately. Check logs.',
              Icons.bug_report,
              Colors.red,
            ),

            const SizedBox(height: 24),

            // === DEBUG INFO ===
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Debug Information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('InMobi Account: 9f55f3fd055c4688acd6d882a07523d9'),
                  Text('InMobi Interstitial: 10000592527'),
                  Text('InMobi Banner: 10000592528'),
                  const SizedBox(height: 8),
                  Text('Check logcat for:'),
                  Text('  D/InMobiAds: ...'),
                  Text('  I/flutter: ...'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          Text(
            status,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSmartAd() async {
    // Try AdMob first (usually higher eCPM)
    if (adMobService.isInterstitialAdLoaded.value) {
      Get.snackbar(
        '📱 AdMob',
        'Showing AdMob ad...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.purple,
        colorText: Colors.white,
      );

      adMobService.showInterstitialAd(
        onAdClosed: () {
          print('✅ AdMob ad closed');
        },
      );
      return;
    }

    // Fallback to InMobi
    if (inMobiService.isInterstitialLoaded.value) {
      Get.snackbar(
        '📱 InMobi',
        'AdMob not available, showing InMobi ad...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      await inMobiService.showInterstitialAd(
        onAdClosed: () {
          print('✅ InMobi ad closed. Next ad will auto-load.');
        },
      );
      return;
    }

    // No ads available
    Get.snackbar(
      '❌ No Ads',
      'No ads available from any network. Try loading first.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
