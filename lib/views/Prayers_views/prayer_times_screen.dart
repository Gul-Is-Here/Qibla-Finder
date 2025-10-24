import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:qibla_compass_offline/controllers/prayer_controller/prayer_times_controller.dart';
import 'package:qibla_compass_offline/views/home_view/common_view/islamic_calendar_screen.dart';
import 'package:qibla_compass_offline/views/notification_views/notification_settings_screen.dart';

import '../../../services/ads/ad_service.dart';
import '../../../services/notifications/notification_service.dart';

import '../../widgets/shimmer_widget/shimmer_loading_widgets.dart';


class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  // Banner ad instance
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    // Fade in animation for entire screen
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    // Pulse animation for next prayer card
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _fadeController.forward();

    // Request notification permission when screen loads
    _requestNotificationPermissionIfNeeded();

    // Initialize banner ad
    _createBannerAd();
  }

  Future<void> _requestNotificationPermissionIfNeeded() async {
    final storage = GetStorage();
    final hasAskedPermission = storage.read('notification_permission_asked') ?? false;

    // Only ask once
    if (!hasAskedPermission) {
      // Wait a bit for UI to settle
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if already granted
      final notificationService = NotificationService.instance;
      final isAllowed = await notificationService.areNotificationsEnabled();

      if (!isAllowed) {
        // Show a friendly dialog first
        _showNotificationPermissionDialog();
      }

      // Mark as asked
      await storage.write('notification_permission_asked', true);
    }
  }

  void _showNotificationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: primary, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Enable Prayer Notifications',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Never miss a prayer time!',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Get notified with beautiful Azan at each prayer time:',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('🌅 Fajr - Dawn prayer'),
            _buildFeatureItem('☀️ Dhuhr - Noon prayer'),
            _buildFeatureItem('🌤️ Asr - Afternoon prayer'),
            _buildFeatureItem('🌅 Maghrib - Sunset prayer'),
            _buildFeatureItem('🌙 Isha - Night prayer'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Works offline with 60+ days of prayer times',
                      style: GoogleFonts.poppins(fontSize: 12, color: primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // User declined, they can enable later from settings
            },
            child: Text(
              'Not Now',
              style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _requestNotificationPermission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Enable Notifications',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
        ],
      ),
    );
  }

  Future<void> _requestNotificationPermission() async {
    final notificationService = NotificationService.instance;
    final controller = Get.find<PrayerTimesController>();

    final allowed = await notificationService.requestPermissions();

    if (allowed) {
      controller.notificationsEnabled.value = true;
      // Enable notifications in controller
      await controller.enableNotifications();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _fadeController.dispose();
    _pulseController.dispose();
    // Safely dispose banner ad
    if (_bannerAd != null) {
      _bannerAd!.dispose();
      _bannerAd = null;
    }
    super.dispose();
  }

  void _createBannerAd() {
    if (AdService.areAdsDisabled || _isDisposed) {
      return;
    }

    // Dispose existing ad first to prevent conflicts
    if (_bannerAd != null) {
      _bannerAd!.dispose();
      _bannerAd = null;
      _isBannerAdLoaded = false;
    }

    final adService = Get.find<AdService>();
    _bannerAd = adService.createUniqueBannerAd(
      customKey: 'prayer_times_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (_bannerAd != null && !_isDisposed) {
      _bannerAd!
          .load()
          .then((_) {
            if (mounted && _bannerAd != null && !_isDisposed) {
              setState(() {
                _isBannerAdLoaded = true;
              });
            }
          })
          .catchError((error) {
            print('Banner ad failed to load: $error');
            if (_bannerAd != null && !_isDisposed) {
              _bannerAd!.dispose();
              _bannerAd = null;
            }
            if (mounted && !_isDisposed) {
              setState(() {
                _isBannerAdLoaded = false;
              });
            }
          });
    }
  }

  Color get primary => const Color(0xFF1B5E20); // Deep Islamic Green
  Color get primaryDark => const Color(0xFF0D4F17);
  Color get accent => const Color(0xFFFFD700); // Gold accent
  Color get softGreen => const Color(0xFFE8F5E8);
  Color get cardBackground => const Color(0xFFF8F9FA);

  // Helper function to format time to 12-hour format with AM/PM
  String _formatTimeTo12Hour(String time) {
    try {
      final cleanTime = time.trim();
      final parts = cleanTime.split(':');

      if (parts.length < 2) {
        return time; // Return original if invalid format
      }

      int hour = int.parse(parts[0]);
      final minute = parts[1].split(' ')[0]; // Get minute part without any AM/PM

      String period = 'AM';

      if (hour >= 12) {
        period = 'PM';
        if (hour > 12) {
          hour -= 12;
        }
      }

      if (hour == 0) {
        hour = 12;
      }

      return '$hour:$minute $period';
    } catch (e) {
      return time; // Return original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrayerTimesController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light gray background
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Obx(() {
          if (controller.isLoading.value && controller.prayerTimes.value == null) {
            return ShimmerLoadingWidgets.prayerTimesShimmer();
          }
          if (controller.errorMessage.value.isNotEmpty) {
            // Show a simple error screen when controller reports an error.
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.errorMessage.value,
                      style: GoogleFonts.poppins(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        // Clear the error so UI can try to recover; actual retry logic
                        // should be implemented inside the controller where appropriate.
                        controller.errorMessage.value = '';
                        controller.isLoading.value = true;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Dismiss',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Modern Islamic App Bar
              SliverAppBar(
                expandedHeight: 230,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: primary,
                flexibleSpace: FlexibleSpaceBar(background: _buildModernHeader(controller)),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(0),
                  child: Container(
                    height: 15,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                  ),
                ),
              ),
              // Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (!controller.isOnline.value) _modernOfflineBanner(),
                    const SizedBox(height: 20),
                    _modernDateNavigator(controller),
                    const SizedBox(height: 20),
                    if (controller.prayerTimes.value != null) _modernPrayerCards(controller),
                    // const SizedBox(height: 30),
                    // // _modernIslamicFeaturesSection(),
                    // const SizedBox(height: 20),
                    _buildBannerAd(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ---------- Offline banner ----------

  // ---------- Next Prayer Card (glassmorphism + micro-animations) ----------

  // ---------- Date Navigator (pill) ----------

  // ---------- Individual Prayer Tile ----------

  // Banner Ad Widget
  Widget _buildBannerAd() {
    // Check if ads are disabled for store
    if (AdService.areAdsDisabled) {
      return const SizedBox.shrink();
    }

    // Show ad only if loaded
    if (!_isBannerAdLoaded || _bannerAd == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 100,
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Text(
            'Loading Ad...',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 100,
          child: AdWidget(key: ValueKey('prayer_banner_${_bannerAd.hashCode}'), ad: _bannerAd!),
        ),
      ),
    );
  }

  // Islamic Features Section

  // Modern Islamic Header with Beautiful Design - Updated to match screenshot
  Widget _buildModernHeader(PrayerTimesController controller) {
    return Obx(() {
      final nextName = controller.nextPrayer.value.isEmpty
          ? 'Next Prayer'
          : controller.nextPrayer.value;
      final timeLeft = controller.timeUntilNextPrayer.value.isEmpty
          ? 'Calculating...'
          : controller.timeUntilNextPrayer.value;

      // Get the next prayer time
      String nextPrayerTime = '';
      if (controller.prayerTimes.value != null && controller.nextPrayer.value.isNotEmpty) {
        final prayers = controller.prayerTimes.value!.getAllPrayerTimes();
        nextPrayerTime = prayers[controller.nextPrayer.value] ?? '';
      }

      // Get sunrise and sunset times for display
      String sunriseTime = '';
      String sunsetTime = '';
      if (controller.prayerTimes.value != null) {
        final prayers = controller.prayerTimes.value!.getAllPrayerTimes();
        sunriseTime = prayers['Sunrise'] ?? '';
        sunsetTime = prayers['Maghrib'] ?? '';
      }

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF003D33), const Color(0xFF00574A), const Color(0xFF006B56)],
          ),
        ),
        child: Stack(
          children: [
            // Geometric shapes
            Positioned(
              right: -50,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar - Organization Name and Menu
                    Row(
                      children: [
                        // Organization Icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.mosque, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.locationName.value.isEmpty
                                    ? 'Community Center'
                                    : controller.locationName.value.split(',').first,
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Faith. Family. Fellowship',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Menu Icon
                      ],
                    ),
                    // const SizedBox(height: 16),

                    // // Remaining Time Card
                    const SizedBox(height: 12),

                    // Next Prayer Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Remaining Time',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '($timeLeft)',
                                style: GoogleFonts.robotoMono(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Spacer(),
                              Column(
                                children: [
                                  Text(
                                    sunriseTime.isNotEmpty
                                        ? "Sunrise: ${_formatTimeTo12Hour(sunriseTime)}"
                                        : '',
                                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
                                  ),
                                  Text(
                                    sunsetTime.isNotEmpty
                                        ? "Sunset: ${_formatTimeTo12Hour(sunsetTime)}"
                                        : '',
                                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
                                  ),
                                ],
                              ), // Placeholder for alignment
                            ],
                          ),

                          // Next Prayer Label and Name
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'Next: ',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.1,
                                ),
                              ),
                              Text(
                                nextName.toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.1,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),

                          // Prayer Time and Label
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  if (nextPrayerTime.isNotEmpty)
                                    Text(
                                      _formatTimeTo12Hour(nextPrayerTime),
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                    ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '(Adhan Time)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.85),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  Get.to(() => NotificationSettingsScreen());
                                },
                                icon: Icon(
                                  Icons.notifications,
                                  size: 20,
                                  color: Colors.yellow[700],
                                ),
                              ),
                            ],
                          ),

                          // Action Buttons
                          GestureDetector(
                            onTap: () {
                              Get.to(() => IslamicCalendarScreen());
                            },
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month, size: 12, color: Colors.yellow[700]),
                                SizedBox(width: 5),
                                Text(
                                  'Calendar',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                // View Times Button
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Sunrise and Sunset Times - Moved below prayer times list

                    // Location and Quick Actions
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // Helper method for quick prayer time display

  // Show options menu

  // Modern Offline Banner
  Widget _modernOfflineBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange[50]!, Colors.orange[100]!]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.wifi_off, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Offline Mode',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[900],
                  ),
                ),
                Text(
                  'Showing cached prayer times',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modern Date Navigator
  Widget _modernDateNavigator(PrayerTimesController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _modernNavButton(Icons.chevron_left, onTap: controller.goToPreviousDay),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => () {},
              child: Column(
                children: [
                  if (controller.prayerTimes.value != null)
                    Text(
                      controller.prayerTimes.value!.hijriDate,
                      style: GoogleFonts.amiri(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy').format(controller.selectedDate.value),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          _modernNavButton(Icons.chevron_right, onTap: controller.goToNextDay),
        ],
      ),
    );
  }

  Widget _modernNavButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: softGreen,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withOpacity(0.2)),
        ),
        child: Icon(icon, color: primary, size: 20),
      ),
    );
  }

  // Modern Prayer Cards
  Widget _modernPrayerCards(PrayerTimesController controller) {
    final prayers = controller.prayerTimes.value!.getAllPrayerTimes();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: prayers.entries.map((entry) {
          final isNext = controller.nextPrayer.value == entry.key;
          return _modernPrayerCard(
            controller,
            prayerName: entry.key,
            prayerTime: entry.value,
            isNext: isNext,
          );
        }).toList(),
      ),
    );
  }

  Widget _modernPrayerCard(
    PrayerTimesController controller, {
    required String prayerName,
    required String prayerTime,
    required bool isNext,
  }) {
    final config = {
      'Fajr': {
        'icon': Icons.nightlight_round,
        'subtitle': 'Before sunrise',
        'color': const Color(0xFF1A237E),
      },
      'Sunrise': {'icon': Icons.wb_sunny, 'subtitle': 'Sunrise', 'color': const Color(0xFFF57C00)},
      'Dhuhr': {
        'icon': Icons.wb_sunny_outlined,
        'subtitle': 'After midday',
        'color': const Color(0xFF1976D2),
      },
      'Asr': {
        'icon': Icons.light_mode,
        'subtitle': 'Late afternoon',
        'color': const Color(0xFF689F38),
      },
      'Maghrib': {
        'icon': Icons.wb_twilight,
        'subtitle': 'Just after sunset',
        'color': const Color(0xFFE64A19),
      },
      'Isha': {
        'icon': Icons.dark_mode,
        'subtitle': 'Night prayer',
        'color': const Color(0xFF5E35B1),
      },
    };

    final icon = (config[prayerName]?['icon'] as IconData?) ?? Icons.schedule;
    final subtitle = (config[prayerName]?['subtitle'] as String?) ?? '';
    final prayerColor = (config[prayerName]?['color'] as Color?) ?? primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isNext ? primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isNext ? primary : Colors.grey[200]!, width: isNext ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: isNext ? primary.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: isNext ? 15 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Prayer Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isNext
                    ? [primary, primary.withOpacity(0.8)]
                    : [prayerColor.withOpacity(0.1), prayerColor.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isNext
                  ? [
                      BoxShadow(
                        color: primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: isNext ? Colors.white : prayerColor, size: 20),
          ),
          const SizedBox(width: 16),

          // Prayer Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      prayerName,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isNext ? primary : Colors.black87,
                      ),
                    ),
                    if (isNext) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'NEXT',
                          style: GoogleFonts.robotoMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          // Prayer Time
          Text(
            _formatTimeTo12Hour(prayerTime),
            style: GoogleFonts.robotoMono(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isNext ? primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Modern Islamic Features Section
  Widget _modernIslamicFeaturesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 12),
              Text(
                'Islamic Features',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Access Features
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _modernFeatureCard(
                icon: Icons.calendar_month,
                title: 'Islamic Calendar',
                subtitle: 'Hijri dates & events',
                gradient: [const Color(0xFF1B5E20), const Color(0xFF2E7D32)],
                onTap: () => Get.toNamed('/islamic-calendar'),
              ),
              _modernFeatureCard(
                icon: Icons.menu_book,
                title: 'Dua Collection',
                subtitle: 'Daily prayers',
                gradient: [const Color(0xFF1565C0), const Color(0xFF1976D2)],
                onTap: () => Get.toNamed('/dua-collection'),
              ),
              _modernFeatureCard(
                icon: Icons.star,
                title: '99 Names',
                subtitle: 'Names of Allah',
                gradient: [const Color(0xFF7B1FA2), const Color(0xFF8E24AA)],
                onTap: () => Get.toNamed('/names-of-allah'),
              ),
              _modernFeatureCard(
                icon: Icons.location_on,
                title: 'Mosque Finder',
                subtitle: 'Nearby mosques',
                gradient: [const Color(0xFFE65100), const Color(0xFFFF9800)],
                onTap: () => Get.toNamed('/mosque-finder'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Dhikr Counter - Wide Card
          _modernFeatureCard(
            icon: Icons.fingerprint,
            title: 'Dhikr Counter',
            subtitle: 'Count your dhikr and tasbeeh',
            gradient: [const Color(0xFF4527A0), const Color(0xFF5E35B1)],
            onTap: () => Get.toNamed('/dhikr-counter'),
            isWide: true,
          ),
        ],
      ),
    );
  }

  Widget _modernFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
    bool isWide = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isWide
            ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
      ),
    );
  }
}
