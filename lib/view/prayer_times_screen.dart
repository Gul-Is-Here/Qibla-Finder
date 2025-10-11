import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import '../controller/prayer_times_controller.dart';
import '../services/ad_service.dart';
import 'notification_settings_screen.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Fade in animation for entire screen
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Pulse animation for next prayer card
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color get primary => const Color(0xFF00897B);
  Color get primaryDark => const Color(0xFF00695C);
  Color get accent => const Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrayerTimesController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.prayerTimes.value == null) {
            return _loading();
          }
          if (controller.errorMessage.value.isNotEmpty) {
            return _error(controller);
          }

          return RefreshIndicator(
            onRefresh: controller.refreshPrayerTimes,
            color: primary,
            child: NestedScrollView(
              headerSliverBuilder: (context, inner) => [
                _sliverHeader(controller),
              ],
              body: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    if (!controller.isOnline.value)
                      _animatedSlideIn(_offlineBanner(), delay: 100),
                    const SizedBox(height: 12),
                    _animatedSlideIn(
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: _nextPrayerCard(controller),
                      ),
                      delay: 200,
                    ),
                    _animatedSlideIn(_dateNavigator(controller), delay: 300),
                    if (controller.prayerTimes.value != null)
                      _animatedPrayerTiles(controller),
                    const SizedBox(height: 16),
                    Obx(() => _animatedSlideIn(_buildBannerAd(), delay: 800)),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ---------- Animation Helpers ----------
  Widget _animatedSlideIn(Widget child, {int delay = 0}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween(begin: 50.0, end: 0.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        // Clamp opacity to valid range [0.0, 1.0]
        final opacity = (1 - (value / 50)).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: child,
    );
  }

  Widget _animatedPrayerTiles(PrayerTimesController controller) {
    final prayers = controller.prayerTimes.value!.getAllPrayerTimes();

    return Column(
      children: List.generate(prayers.length, (index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            // Clamp opacity to valid range [0.0, 1.0] to prevent assertion errors
            final clampedOpacity = value.clamp(0.0, 1.0);
            return Transform.scale(
              scale: value,
              child: Opacity(opacity: clampedOpacity, child: child),
            );
          },
          child: _prayerTile(
            controller,
            prayerName: prayers.keys.elementAt(index),
            prayerTime: prayers.values.elementAt(index),
            isLast: index == prayers.length - 1,
          ),
        );
      }),
    );
  }

  // ---------- Sliver Header (collapsing) ----------
  Widget _sliverHeader(PrayerTimesController controller) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      expandedHeight: 150,
      backgroundColor: primary,
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      titleSpacing: 0,
      title: _topBar(controller),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Decorative blobs
            Positioned(
              top: -30,
              left: -20,
              child: _blob(120, Colors.white.withOpacity(.08)),
            ),
            Positioned(
              bottom: -40,
              right: -20,
              child: _blob(160, Colors.white.withOpacity(.06)),
            ),
            // Bottom rounded edge
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(PrayerTimesController controller) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 8, 0),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Obx(
                () => Text(
                  controller.locationName.value.isEmpty
                      ? 'Loading location...'
                      : controller.locationName.value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Notifications - Navigate to settings
            Obx(
              () => IconButton(
                tooltip: 'Notification Settings',
                icon: Icon(
                  controller.notificationsEnabled.value
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () =>
                    Get.to(() => const NotificationSettingsScreen()),
              ),
            ),
            // Date picker
            IconButton(
              tooltip: 'Pick date',
              icon: const Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () => _showDatePicker(controller),
            ),

            // PRO badge
          ],
        ),
      ),
    );
  }

  // ---------- Offline banner ----------
  Widget _offlineBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.orange, size: 16),
          const SizedBox(width: 8),
          Text(
            'Offline — showing cached prayer times',
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              color: Colors.orange[900],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Next Prayer Card (glassmorphism + micro-animations) ----------
  Widget _nextPrayerCard(PrayerTimesController controller) {
    final nextName = controller.nextPrayer.value.isEmpty
        ? 'Next Prayer'
        : controller.nextPrayer.value;
    final timeLeft = controller.timeUntilNextPrayer.value.isEmpty
        ? 'Calculating...'
        : controller.timeUntilNextPrayer.value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Background gradient
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Frosted glass overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
                child: Container(color: Colors.white.withOpacity(0.0)),
              ),
            ),
            // Shiny highlight
            Positioned(
              right: -30,
              top: -30,
              child: _blob(120, Colors.white.withOpacity(.10)),
            ),
            // Content
            Container(
              height: 170,
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'UPCOMING',
                            style: GoogleFonts.robotoMono(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            nextName,
                            key: ValueKey(nextName),
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Time left',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) =>
                              FadeTransition(opacity: anim, child: child),
                          child: Text(
                            timeLeft,
                            key: ValueKey(timeLeft),
                            style: GoogleFonts.robotoMono(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Animated badge
                  _pulsingMosqueBadge(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pulsingMosqueBadge() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.08),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      onEnd: () {},
      builder: (context, value, _) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(.25),
                  Colors.white.withOpacity(.10),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(.30),
                width: 1,
              ),
            ),
            child: const Center(
              child: Icon(Icons.mosque, color: Colors.white, size: 40),
            ),
          ),
        );
      },
    );
  }

  // ---------- Date Navigator (pill) ----------
  Widget _dateNavigator(PrayerTimesController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          _roundIcon(Icons.chevron_left, onTap: controller.goToPreviousDay),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => _showDatePicker(controller),
              child: Column(
                children: [
                  if (controller.prayerTimes.value != null)
                    Text(
                      controller.prayerTimes.value!.hijriDate,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat(
                      'EEEE, d MMM yyyy',
                    ).format(controller.selectedDate.value),
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _roundIcon(Icons.chevron_right, onTap: controller.goToNextDay),
        ],
      ),
    );
  }

  Widget _roundIcon(IconData icon, {VoidCallback? onTap}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 150),
      tween: Tween(begin: 1.0, end: 1.0),
      builder: (context, scale, child) {
        return GestureDetector(
          onTapDown: (_) => setState(() {}),
          onTapUp: (_) {
            onTap?.call();
            setState(() {});
          },
          onTapCancel: () => setState(() {}),
          child: Transform.scale(
            scale: scale,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: primary, size: 20),
            ),
          ),
        );
      },
    );
  }

  // ---------- Individual Prayer Tile ----------
  Widget _prayerTile(
    PrayerTimesController controller, {
    required String prayerName,
    required String prayerTime,
    required bool isLast,
  }) {
    final config = {
      'Fajr': {'icon': Icons.nightlight_round, 'subtitle': 'Before sunrise'},
      'Sunrise': {'icon': Icons.wb_sunny, 'subtitle': ''},
      'Dhuhr': {'icon': Icons.wb_sunny_outlined, 'subtitle': 'After midday'},
      'Asr': {'icon': Icons.light_mode, 'subtitle': 'Late afternoon'},
      'Maghrib': {'icon': Icons.wb_twilight, 'subtitle': 'Just after sunset'},
      'Isha': {'icon': Icons.dark_mode, 'subtitle': 'Night prayer'},
    };

    final isNext = controller.nextPrayer.value == prayerName;
    final icon = (config[prayerName]?['icon'] as IconData?) ?? Icons.schedule;
    final subtitle = (config[prayerName]?['subtitle'] as String?) ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isNext ? primary.withOpacity(.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isNext ? primary.withOpacity(.3) : Colors.grey[300]!,
            width: isNext ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isNext
                  ? primary.withOpacity(.15)
                  : Colors.black.withOpacity(.04),
              blurRadius: isNext ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Animated icon container
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 1.0, end: isNext ? 1.1 : 1.0),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isNext
                            ? [primary, primary.withOpacity(.7)]
                            : [
                                primary.withOpacity(.10),
                                primary.withOpacity(.05),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isNext
                          ? [
                              BoxShadow(
                                color: primary.withOpacity(.3),
                                blurRadius: 8,
                                spreadRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: isNext ? Colors.white : primary,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            // Prayer info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayerName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isNext ? primary : Colors.black87,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            // Time with badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  prayerTime,
                  style: GoogleFonts.robotoMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isNext ? primary : Colors.black87,
                  ),
                ),
                if (isNext)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      'NEXT',
                      style: GoogleFonts.robotoMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Prayer Tiles (Unused - kept for reference) ----------
  Widget _prayerTiles(PrayerTimesController controller) {
    final prayerTimes = controller.prayerTimes.value!;
    final prayers = prayerTimes.getAllPrayerTimes();

    final config = {
      'Fajr': {'icon': Icons.nightlight_round, 'subtitle': 'Before sunrise'},
      'Sunrise': {'icon': Icons.wb_sunny, 'subtitle': ''},
      'Dhuhr': {'icon': Icons.wb_sunny_outlined, 'subtitle': 'After midday'},
      'Asr': {'icon': Icons.light_mode, 'subtitle': 'Late afternoon'},
      'Maghrib': {'icon': Icons.wb_twilight, 'subtitle': 'Just after sunset'},
      'Isha': {'icon': Icons.dark_mode, 'subtitle': 'Night prayer'},
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ListView.separated(
          itemCount: prayers.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => Divider(
            color: Colors.grey[200],
            height: 1,
            thickness: 1,
            indent: 68,
          ),
          itemBuilder: (context, index) {
            final entry = prayers.entries.elementAt(index);
            final isNext = controller.nextPrayer.value == entry.key;
            final icon =
                (config[entry.key]?['icon'] as IconData?) ?? Icons.schedule;
            final sub = (config[entry.key]?['subtitle'] as String?) ?? '';

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: isNext ? primary.withOpacity(.06) : Colors.transparent,
                borderRadius: index == 0
                    ? const BorderRadius.vertical(top: Radius.circular(18))
                    : index == prayers.length - 1
                    ? const BorderRadius.vertical(bottom: Radius.circular(18))
                    : null,
              ),
              child: Row(
                children: [
                  // Icon tile
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  // Title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: GoogleFonts.poppins(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        if (sub.isNotEmpty)
                          Text(
                            sub,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Time
                  Text(
                    entry.value,
                    style: GoogleFonts.robotoMono(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isNext ? primary : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (isNext)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primary.withOpacity(.25)),
                      ),
                      child: Text(
                        'NEXT',
                        style: GoogleFonts.robotoMono(
                          fontSize: 10.5,
                          color: primaryDark,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------- Loading / Error ----------
  Widget _loading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF00897B)),
          const SizedBox(height: 16),
          Text(
            'Loading Prayer Times…',
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _error(PrayerTimesController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 10),
            Text(
              controller.errorMessage.value,
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: controller.refreshPrayerTimes,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(
                'Retry',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Utilities ----------
  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 30, spreadRadius: 10)],
      ),
    );
  }

  // ---------- Dialogs (unchanged behavior) ----------
  Future<void> _showDatePicker(PrayerTimesController controller) async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00897B),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00897B),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) controller.changeDate(date);
  }

  // Banner Ad Widget
  Widget _buildBannerAd() {
    final adService = Get.find<AdService>();

    // Check if ads are disabled for store or if banner is not loaded
    if (AdService.areAdsDisabled || !adService.isBannerAdLoaded.value) {
      return const SizedBox.shrink();
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
        child: SizedBox(height: 60, child: AdWidget(ad: adService.bannerAd!)),
      ),
    );
  }
}
