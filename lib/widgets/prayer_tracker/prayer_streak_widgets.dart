import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/prayer_tracker_controller/prayer_tracker_controller.dart';

/// Beautiful Prayer Streak Card Widget
class PrayerStreakCard extends StatelessWidget {
  const PrayerStreakCard({super.key});

  // App Theme Colors
  static const Color primaryPurple = Color(0xFF8F66FF);
  static const Color lightPurple = Color(0xFFAB80FF);
  static const Color darkPurple = Color(0xFF2D1B69);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color starWhite = Color(0xFFF8F4E9);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrayerTrackerController());

    return Obx(() {
      final streak = controller.currentStreak.value;
      final emoji = controller.streakEmoji;
      final todayCount = controller.todayCompletedCount.value;
      final weeklyPercent = controller.weeklyPercentage.value;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryPurple.withOpacity(0.95), darkPurple.withOpacity(0.9)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: goldAccent.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row - Streak badge, progress bar, today count
            Row(
              children: [
                // Streak Badge (compact)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: goldAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: goldAccent.withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '$streak',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: goldAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Weekly Progress (compact)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Weekly',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            '${weeklyPercent.toStringAsFixed(0)}%',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: goldAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: weeklyPercent / 100,
                          minHeight: 6,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getProgressColor((weeklyPercent / 20).round()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Today's count (compact)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(color: _getProgressColor(todayCount), width: 2.5),
                  ),
                  child: Center(
                    child: Text(
                      '$todayCount/5',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Weekly dots (last 7 days) - compact
            _buildWeeklyDots(controller),
          ],
        ),
      );
    });
  }

  Widget _buildWeeklyDots(PrayerTrackerController controller) {
    final weeklyData = controller.weeklyData;
    final days = weeklyData.keys.toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days.map((dateKey) {
        final count = controller.getCompletionCountForDate(dateKey);
        final dayName = controller.getDayName(dateKey);
        final isToday = dayName == 'Today';

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getDotColor(count),
                border: isToday ? Border.all(color: goldAccent, width: 2) : null,
                boxShadow: count == 5
                    ? [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: count == 5
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : Text(
                        '$count',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              dayName.substring(0, dayName.length > 3 ? 3 : dayName.length),
              style: GoogleFonts.poppins(
                fontSize: 8,
                color: isToday ? goldAccent : Colors.white.withOpacity(0.6),
                fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Color _getDotColor(int count) {
    if (count == 5) return const Color(0xFF4CAF50);
    if (count >= 3) return const Color(0xFFFFB74D);
    if (count >= 1) return const Color(0xFF64B5F6);
    return Colors.white.withOpacity(0.2);
  }

  Color _getProgressColor(int count) {
    if (count >= 5) return const Color(0xFF4CAF50);
    if (count >= 3) return const Color(0xFFFFB74D);
    if (count >= 1) return const Color(0xFF64B5F6);
    return Colors.white.withOpacity(0.3);
  }
}

/// Prayer Completion Checkbox Widget for each prayer
class PrayerCompletionCheckbox extends StatelessWidget {
  final String prayerName;
  final bool isNext;
  final VoidCallback? onTap;

  const PrayerCompletionCheckbox({
    super.key,
    required this.prayerName,
    this.isNext = false,
    this.onTap,
  });

  static const Color primaryPurple = Color(0xFF8F66FF);
  static const Color goldAccent = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PrayerTrackerController>();

    return Obx(() {
      final isCompleted = controller.isPrayerCompleted(prayerName);

      return GestureDetector(
        onTap: () async {
          HapticFeedback.lightImpact();
          await controller.togglePrayer(prayerName);
          onTap?.call();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? goldAccent : Colors.white.withOpacity(0.1),
            border: Border.all(
              color: isCompleted
                  ? goldAccent
                  : isNext
                  ? goldAccent.withOpacity(0.6)
                  : Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: isCompleted
                ? [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
        ),
      );
    });
  }
}

/// Compact inline streak badge (for header)
class CompactStreakBadge extends StatelessWidget {
  const CompactStreakBadge({super.key});

  static const Color goldAccent = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PrayerTrackerController());

    return Obx(() {
      final streak = controller.currentStreak.value;
      final emoji = controller.streakEmoji;

      if (streak == 0) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: goldAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: goldAccent.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              '$streak',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: goldAccent,
              ),
            ),
          ],
        ),
      );
    });
  }
}
