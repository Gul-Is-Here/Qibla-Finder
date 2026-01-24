import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/prayer_controller/prayer_times_controller.dart';
import '../../routes/app_pages.dart';
import '../../services/notifications/notification_service.dart';
import '../../widgets/shimmer_widget/shimmer_loading_widgets.dart';
import '../notification_views/notification_settings_screen.dart';
import '../home_view/common_view/islamic_calendar_screen.dart';
import '../home_view/Diker/dhikr_counter_screen.dart';
import '../home_view/dua_view/dua_collection_screen.dart';
import '../hadith_views/daily_hadith_screen.dart';
import 'prayer_times_detail_screen.dart';

class BeautifulPrayerTimesScreen extends StatefulWidget {
  const BeautifulPrayerTimesScreen({super.key});

  @override
  State<BeautifulPrayerTimesScreen> createState() => _BeautifulPrayerTimesScreenState();
}

class _BeautifulPrayerTimesScreenState extends State<BeautifulPrayerTimesScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _shimmerController;

  // App Theme Colors
  static const Color primaryPurple = Color(0xFF8F66FF); // Main app purple
  static const Color lightPurple = Color(0xFFAB80FF); // Light purple
  static const Color darkPurple = Color(0xFF2D1B69); // Dark purple
  static const Color accentPurple = Color(0xFF9F70FF); // Accent purple

  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color moonGlow = Color(0xFFF5E6B8);
  static const Color starWhite = Color(0xFFF8F4E9);

  // Prayer completion tracking
  final RxMap<String, bool> prayerCompleted = <String, bool>{}.obs;
  final RxInt prayerStreak = 0.obs;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this)
      ..repeat(reverse: true);

    _rotateController = AnimationController(duration: const Duration(seconds: 30), vsync: this)
      ..repeat();

    _shimmerController = AnimationController(duration: const Duration(seconds: 3), vsync: this)
      ..repeat();

    // _loadPrayerCompletionStatus();
    _requestNotificationPermissionIfNeeded();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  // void _loadPrayerCompletionStatus() {
  //   final storage = GetStorage();
  //   final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  //   final savedData = storage.read('prayer_completed_$today');
  //   if (savedData != null) {
  //     prayerCompleted.value = Map<String, bool>.from(savedData);
  //   }
  //   prayerStreak.value = storage.read('prayer_streak') ?? 0;
  // }

  // void _togglePrayerCompletion(String prayerName) {
  //   final storage = GetStorage();
  //   final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  //   prayerCompleted[prayerName] = !(prayerCompleted[prayerName] ?? false);
  //   storage.write('prayer_completed_$today', prayerCompleted);

  //   // Update streak
  //   final allCompleted = [
  //     'Fajr',
  //     'Dhuhr',
  //     'Asr',
  //     'Maghrib',
  //     'Isha',
  //   ].every((p) => prayerCompleted[p] == true);
  //   if (allCompleted) {
  //     prayerStreak.value++;
  //     storage.write('prayer_streak', prayerStreak.value);
  //     _showStreakCelebration();
  //   }
  // }

  // void _showStreakCelebration() {
  //   Get.snackbar(
  //     '🎉 MashaAllah!',
  //     'You completed all prayers today! Streak: ${prayerStreak.value} days',
  //     backgroundColor: islamicGreen,
  //     colorText: Colors.white,
  //     snackPosition: SnackPosition.TOP,
  //     duration: const Duration(seconds: 3),
  //     margin: const EdgeInsets.all(16),
  //     borderRadius: 16,
  //   );
  // }

  Future<void> _requestNotificationPermissionIfNeeded() async {
    try {
      final storage = GetStorage();
      final hasAskedPermission = storage.read('notification_permission_asked') ?? false;
      final notificationService = NotificationService.instance;
      final isAllowed = await notificationService.areNotificationsEnabled();

      if (isAllowed && !hasAskedPermission) {
        final controller = Get.find<PrayerTimesController>();
        for (int i = 0; i < 10; i++) {
          if (controller.monthlyPrayerTimes.isNotEmpty) break;
          await Future.delayed(const Duration(milliseconds: 500));
        }
        await controller.enableAllPrayerNotifications();
        await storage.write('notification_permission_asked', true);
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
  }

  String _formatTimeTo12Hour(String time) {
    try {
      final parts = time.trim().split(':');
      if (parts.length < 2) return time;

      int hour = int.parse(parts[0]);
      final minute = parts[1].split(' ')[0];
      String period = hour >= 12 ? 'PM' : 'AM';

      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;

      return '$hour:$minute $period';
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrayerTimesController());

    // Set status bar color to match header
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: primaryPurple,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: lightPurple.withOpacity(0.05),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (controller.isLoading.value && controller.prayerTimes.value == null) {
            return _buildLoadingState();
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return _buildErrorState(controller);
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Beautiful Header
              SliverToBoxAdapter(child: _buildIslamicHeader(controller)),

              // Main Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Offline Banner
                    // if (!controller.isOnline.value) _buildOfflineBanner(),

                    // Location Permission Banner
                    _buildLocationPermissionBanner(),

                    // Banner Ad
                    // const OptimizedBannerAdWidget(
                    //   padding: EdgeInsets.symmetric(horizontal: 20),
                    // ),

                    // Daily Verse Card
                    const SizedBox(height: 20),

                    // Next Prayer Top Card with Share and View Times
                    if (controller.prayerTimes.value != null) _buildNextPrayerTopCard(controller),

                    // Prayer Times List
                    if (controller.prayerTimes.value != null) _buildPrayerTimesList(controller),

                    const SizedBox(height: 20),
                    // _buildDailyVerseCard(),
                    // Quick Actions
                    _buildQuickActions(),

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

  Widget _buildIslamicHeader(PrayerTimesController controller) {
    return Obx(() {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryPurple, // Match status bar
              primaryPurple,
              darkPurple,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -50,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: goldAccent.withOpacity(0.05),
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
                  color: lightPurple.withOpacity(0.05),
                ),
              ),
            ),
            // Glowing moon
            Positioned(
              top: 20,
              right: 20,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: moonGlow.withOpacity(0.2 + _pulseController.value * 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(Icons.nightlight_round, color: moonGlow, size: 30),
                  );
                },
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 20,
                right: 20,
                bottom: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar - Location and Icons
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: goldAccent.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.mosque, color: goldAccent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.locationName.value.isEmpty
                                  ? 'Loading Location...'
                                  : controller.locationName.value.split(',').first,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: starWhite,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              controller.isOnline.value ? '● Online' : '○ Offline',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: controller.isOnline.value ? primaryPurple : Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification Icon
                      GestureDetector(
                        onTap: () => Get.to(() => NotificationSettingsScreen()),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.notifications, color: goldAccent, size: 20),
                        ),
                      ),
                    ],
                  ),

                  // const SizedBox(height: 16),

                  // // Next Prayer Card (Original Style)
                  // const SizedBox(height: 10),

                  // Next Prayer Name
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.baseline,
                  //   textBaseline: TextBaseline.alphabetic,
                  //   children: [
                  //     Text(
                  //       'Next: ',
                  //       style: GoogleFonts.poppins(
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.w600,
                  //         color: starWhite.withOpacity(0.9),
                  //       ),
                  //     ),
                  //     Text(
                  //       nextPrayer.isEmpty ? 'Loading...' : nextPrayer.toUpperCase(),
                  //       style: GoogleFonts.cinzel(
                  //         fontSize: 20,
                  //         fontWeight: FontWeight.bold,
                  //         color: goldAccent,
                  //         letterSpacing: 1,
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  // Prayer Time Row
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Row(
                  //       crossAxisAlignment: CrossAxisAlignment.baseline,
                  //       textBaseline: TextBaseline.alphabetic,
                  //       children: [
                  //         if (nextPrayerTime.isNotEmpty)
                  //           Text(
                  //             _formatTimeTo12Hour(nextPrayerTime),
                  //             style: GoogleFonts.robotoMono(
                  //               fontSize: 28,
                  //               fontWeight: FontWeight.w700,
                  //               color: starWhite,
                  //             ),
                  //           ),
                  //         const SizedBox(width: 8),
                  //         Text(
                  //           '(Adhan)',
                  //           style: GoogleFonts.poppins(
                  //             fontSize: 11,
                  //             color: starWhite.withOpacity(0.7),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     // Prayer icon
                  //     Container(
                  //       padding: const EdgeInsets.all(10),
                  //       decoration: BoxDecoration(
                  //         color: goldAccent.withOpacity(0.2),
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       child: Icon(
                  //         _getPrayerIcon(nextPrayer),
                  //         color: goldAccent,
                  //         size: 22,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // Commented out - may be used later for calendar navigation
  /*
  Widget _buildDateNavigator(PrayerTimesController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _buildNavButton(Icons.chevron_left, onTap: controller.goToPreviousDay),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Get.to(() => IslamicCalendarScreen()),
              child: Column(
                children: [
                  Obx(() {
                    if (controller.prayerTimes.value != null) {
                      return Text(
                        controller.prayerTimes.value!.hijriDate,
                        style: GoogleFonts.amiri(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: goldAccent,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      DateFormat('EEEE, d MMMM yyyy').format(controller.selectedDate.value),
                      style: GoogleFonts.poppins(fontSize: 12, color: starWhite.withOpacity(0.7)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildNavButton(Icons.chevron_right, onTap: controller.goToNextDay),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildNavButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: goldAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: goldAccent.withOpacity(0.3)),
        ),
        child: Icon(icon, color: goldAccent, size: 22),
      ),
    );
  }
  */

  Widget _buildDailyVerseCard() {
    // Random daily verse
    final verses = [
      {
        'arabic': 'إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا',
        'translation':
            'Indeed, prayer has been decreed upon the believers a decree of specified times.',
        'reference': 'Surah An-Nisa 4:103',
      },
      {
        'arabic': 'وَأَقِيمُوا الصَّلَاةَ وَآتُوا الزَّكَاةَ',
        'translation': 'And establish prayer and give zakah.',
        'reference': 'Surah Al-Baqarah 2:43',
      },
      {
        'arabic': 'حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ',
        'translation': 'Maintain with care the prayers and the middle prayer.',
        'reference': 'Surah Al-Baqarah 2:238',
      },
    ];

    final todayIndex = DateTime.now().day % verses.length;
    final verse = verses[todayIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lightPurple.withOpacity(0.1), primaryPurple.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryPurple.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories, color: primaryPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Daily Verse',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            verse['arabic']!,
            style: GoogleFonts.amiri(fontSize: 20, color: Colors.grey[900], height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            verse['translation']!,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            verse['reference']!,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: primaryPurple.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  // Top compact card showing next prayer with share and view buttons
  Widget _buildNextPrayerTopCard(PrayerTimesController controller) {
    final prayers = controller.prayerTimes.value!.getAllPrayerTimes();
    final nextPrayer = controller.nextPrayer.value;
    final nextPrayerTime = prayers[nextPrayer] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryPurple.withOpacity(0.9), darkPurple.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: goldAccent.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.4),
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
              Expanded(
                child: _buildSunTimeItem(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Sunrise',
                  time: prayers['Sunrise'] ?? '',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSunTimeItem(
                  icon: Icons.nightlight_outlined,
                  label: 'Sunset',
                  time: prayers['Maghrib'] ?? '',
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next: ${nextPrayer.toUpperCase()}',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: starWhite,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatTimeTo12Hour(nextPrayerTime),
                          style: GoogleFonts.robotoMono(
                            fontSize: 24,
                            color: goldAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text('(Adhan)', style: GoogleFonts.poppins(fontSize: 11, color: starWhite)),
                      ],
                    ),
                  ],
                ),
              ),

              // Remaining time with live countdown
              StreamBuilder<int>(
                stream: Stream.periodic(const Duration(seconds: 1), (count) => count),
                builder: (context, snapshot) {
                  String remainingTimeStr = '--:--:--';

                  try {
                    final now = DateTime.now();
                    final timeParts = nextPrayerTime.trim().split(':');
                    if (timeParts.length >= 2) {
                      int hour = int.parse(timeParts[0]);
                      final minutePart = timeParts[1].split(' ')[0];
                      final minute = int.parse(minutePart);

                      var nextPrayerDateTime = DateTime(now.year, now.month, now.day, hour, minute);
                      if (nextPrayerDateTime.isBefore(now)) {
                        nextPrayerDateTime = nextPrayerDateTime.add(const Duration(days: 1));
                      }

                      final remainingTime = nextPrayerDateTime.difference(now);
                      final hours = remainingTime.inHours;
                      final minutes = remainingTime.inMinutes % 60;
                      final seconds = remainingTime.inSeconds % 60;
                      remainingTimeStr =
                          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                    }
                  } catch (e) {
                    remainingTimeStr = '--:--:--';
                  }

                  return Column(
                    children: [
                      Text(
                        'Remaining',
                        style: GoogleFonts.poppins(fontSize: 10, color: starWhite.withOpacity(0.7)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        remainingTimeStr,
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: goldAccent,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

          // const SizedBox(height: 16),

          // // Sunrise and Sunset times
          const SizedBox(height: 16),

          // Share and View Times links
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _shareAllPrayerTimes(prayers),
                child: Row(
                  children: [
                    Icon(Icons.share, color: goldAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Share',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: goldAccent,
                        decoration: TextDecoration.underline,
                        decorationColor: goldAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Get.to(() => const PrayerTimesDetailScreen());
                },
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: goldAccent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'View Times',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: goldAccent,
                        decoration: TextDecoration.underline,
                        decorationColor: goldAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildSunTimeItem({required IconData icon, required String label, required String time}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: goldAccent, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 10, color: starWhite.withOpacity(0.7)),
              ),
              Text(
                _formatTimeTo12Hour(time),
                style: GoogleFonts.robotoMono(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: starWhite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _shareAllPrayerTimes(Map<String, String> prayers) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM dd, yyyy').format(now);

    final text =
        '''
🕌 Prayer Times for $dateStr

🌅 Fajr: ${prayers['Fajr']}
🌄 Sunrise: ${prayers['Sunrise']}
☀️ Dhuhr: ${prayers['Dhuhr']}
🌤️ Asr: ${prayers['Asr']}
🌆 Maghrib: ${prayers['Maghrib']}
🌙 Isha: ${prayers['Isha']}

Shared from Qibla Compass App
    ''';

    Share.share(text, subject: 'Prayer Times - $dateStr');
  }

  Widget _buildPrayerTimesList(PrayerTimesController controller) {
    final prayers = controller.prayerTimes.value!.getAllPrayerTimes();
    // Only get the 5 main prayers (exclude Sunrise)
    final mainPrayers = {
      'Fajr': prayers['Fajr']!,
      'Dhuhr': prayers['Dhuhr']!,
      'Asr': prayers['Asr']!,
      'Maghrib': prayers['Maghrib']!,
      'Isha': prayers['Isha']!,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Beautiful horizontal prayer times card
          _buildHorizontalPrayerTimesCard(mainPrayers, controller),
        ],
      ),
    );
  }

  // Beautiful horizontal prayer times card - matching screenshot style
  Widget _buildHorizontalPrayerTimesCard(
    Map<String, String> prayers,
    PrayerTimesController controller,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header       SizedBox(height: 12),
        Text(
          'PRAYER TIME',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 12),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryPurple.withOpacity(0.9),
                darkPurple.withOpacity(0.85),
                accentPurple.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: lightPurple.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: primaryPurple.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              BoxShadow(
                color: lightPurple.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative pattern overlay

              // Subtle shine effect

              // Main content
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: prayers.entries.map((entry) {
                  final isNext = controller.nextPrayer.value == entry.key;
                  return _buildCompactPrayerItem(
                    prayerName: entry.key,
                    prayerTime: entry.value,
                    isNext: isNext,
                  );
                }).toList(),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
      ],
    );
  }

  // Compact prayer item for horizontal row - matching screenshot
  Widget _buildCompactPrayerItem({
    required String prayerName,
    required String prayerTime,
    required bool isNext,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final opacity = isNext ? (0.7 + (_pulseController.value * 0.3)) : 1.0;

        return Column(
          children: [
            // Dot indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isNext
                    ? const Color.fromARGB(255, 235, 207, 114).withOpacity(opacity)
                    : Colors.white.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 8),
            // Prayer name
            Text(
              prayerName.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                color: isNext ? goldAccent.withOpacity(opacity) : starWhite,
              ),
            ),
            const SizedBox(height: 4),
            // Prayer time (first time only - Adhan time)
            Text(
              _formatTimeTo12Hour(prayerTime.split('\n').first),
              style: GoogleFonts.robotoMono(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isNext ? goldAccent.withOpacity(opacity) : starWhite,
              ),
            ),
            // Iqamah time if available (second line)
            if (prayerTime.contains('\n')) ...[
              const SizedBox(height: 2),
              Text(
                _formatTimeTo12Hour(prayerTime.split('\n').last),
                style: GoogleFonts.robotoMono(
                  fontSize: 11,
                  color: isNext
                      ? goldAccent.withOpacity(opacity * 0.8)
                      : starWhite.withOpacity(0.7),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // Old compact prayer card - commented out, using new design above
  /*
  Widget _buildCompactPrayerCard({
    required String prayerName,
    required String prayerTime,
    required bool isNext,
  }) {
    final config = _getPrayerConfig(prayerName);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final blinkOpacity = isNext ? (0.7 + (_pulseController.value * 0.3)) : 1.0;
        final glowIntensity = isNext ? (0.3 + (_pulseController.value * 0.4)) : 0.2;

        return Container(
          margin: const EdgeInsets.only(right: 12),
          width: 110,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isNext
                  ? [emeraldGreen.withOpacity(blinkOpacity), islamicGreen.withOpacity(blinkOpacity)]
                  : [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.04)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isNext ? goldAccent.withOpacity(blinkOpacity) : Colors.white.withOpacity(0.1),
              width: isNext ? 2.5 : 1.5,
            ),
            boxShadow: isNext
                ? [
                    BoxShadow(
                      color: emeraldGlow.withOpacity(glowIntensity),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: goldAccent.withOpacity(glowIntensity),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Prayer icon with glow
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isNext ? goldAccent.withOpacity(0.3) : config.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: isNext
                      ? [
                          BoxShadow(
                            color: goldAccent.withOpacity(glowIntensity),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ]
                      : [],
                ),
                child: Icon(config.icon, color: isNext ? goldAccent : config.color, size: 28),
              ),

              const SizedBox(height: 12),

              // Prayer name
              Text(
                prayerName.toUpperCase(),
                style: GoogleFonts.cinzel(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isNext ? goldAccent : starWhite,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 6),

              // Prayer time with blinking effect
              Opacity(
                opacity: blinkOpacity,
                child: Text(
                  _formatTimeTo12Hour(prayerTime),
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isNext ? moonGlow : starWhite.withOpacity(0.9),
                  ),
                ),
              ),

              // Next prayer indicator
              if (isNext) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: goldAccent.withOpacity(blinkOpacity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'NEXT',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: deepNight,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
  */

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact Header
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [primaryPurple, goldAccent],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Quick Actions',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[850],
                  ),
                ),
              ],
            ),
          ),

          // Featured Card - Ramadan (Keep unchanged)
          _buildFeaturedQuickActionCard(
            icon: Icons.nights_stay_rounded,
            title: 'Ramadan',
            subtitle: 'Suhoor, Iftar & Fasting Tracker',
            gradient: [const Color(0xFF8F66FF), const Color(0xFF6B4EE6)],
            onTap: () => Get.toNamed(Routes.RAMADAN),
          ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),

          const SizedBox(height: 12),

          // Compact 3x2 Grid for other tools
          Row(
            children: [
              Expanded(
                child: _buildCompactActionChip(
                  icon: Icons.auto_stories_rounded,
                  label: 'Hadith',
                  color: const Color(0xFFD4AF37),
                  onTap: () => Get.to(() => const DailyHadithScreen()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactActionChip(
                  icon: Icons.calendar_month_rounded,
                  label: 'Calendar',
                  color: primaryPurple,
                  onTap: () => Get.to(() => IslamicCalendarScreen()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactActionChip(
                  icon: Icons.notifications_active_rounded,
                  label: 'Alerts',
                  color: accentPurple,
                  onTap: () => Get.to(() => NotificationSettingsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildCompactActionChip(
                  icon: Icons.touch_app_rounded,
                  label: 'Tasbih',
                  color: lightPurple,
                  onTap: () => Get.to(() => const DhikrCounterScreen()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactActionChip(
                  icon: Icons.menu_book_rounded,
                  label: 'Duas',
                  color: darkPurple,
                  onTap: () => Get.to(() => const DuaCollectionScreen()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactActionChip(
                  icon: Icons.calculate_rounded,
                  label: 'Zakat',
                  color: const Color(0xFF4CAF50),
                  onTap: () => Get.toNamed(Routes.ZAKAT_CALCULATOR),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Compact action chip for grid layout
  Widget _buildCompactActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.15), width: 1.5),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  // Enhanced Featured card for highlighted actions
  Widget _buildFeaturedQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required VoidCallback onTap,
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
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: gradient[0].withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Row(
          children: [
            // Enhanced Animated Icon Container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 18),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            // Enhanced Decorative Arrow
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPermissionBanner() {
    return FutureBuilder<LocationPermission>(
      future: Geolocator.checkPermission(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final permission = snapshot.data!;
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [lightPurple.withOpacity(0.2), primaryPurple.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primaryPurple.withOpacity(0.4), width: 1.5),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.location_off, color: primaryPurple, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enable location for accurate prayer times',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (permission == LocationPermission.deniedForever) {
                      await Geolocator.openAppSettings();
                    } else {
                      await Geolocator.requestPermission();
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    permission == LocationPermission.deniedForever
                        ? 'Open Settings'
                        : 'Enable Location',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return FutureBuilder<LocationPermission>(
      future: Geolocator.checkPermission(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final permission = snapshot.data!;
          if (permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 80, color: primaryPurple),
                    const SizedBox(height: 24),
                    Text(
                      'Location Required',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Enable location to get accurate prayer times',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        if (permission == LocationPermission.deniedForever) {
                          await Geolocator.openAppSettings();
                        } else {
                          await Geolocator.requestPermission();
                        }
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        permission == LocationPermission.deniedForever
                            ? 'Open Settings'
                            : 'Enable Location',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
        return ShimmerLoadingWidgets.prayerTimesShimmer();
      },
    );
  }

  Widget _buildErrorState(PrayerTimesController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              style: GoogleFonts.poppins(color: Colors.red[700], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                controller.errorMessage.value = '';
                controller.isLoading.value = true;
                controller.fetchPrayerTimes();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
              ),
              child: Text('Retry', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }
}
