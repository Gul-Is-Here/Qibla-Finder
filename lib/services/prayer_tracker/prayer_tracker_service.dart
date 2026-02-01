import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

/// Service to track prayer completion and streaks
class PrayerTrackerService {
  static final PrayerTrackerService _instance = PrayerTrackerService._internal();
  factory PrayerTrackerService() => _instance;
  PrayerTrackerService._internal();

  static PrayerTrackerService get instance => _instance;

  final _storage = GetStorage();

  // Storage keys
  static const String _prayerCompletionKey = 'prayer_completion';
  static const String _streakKey = 'prayer_streak';
  static const String _lastPrayerDateKey = 'last_prayer_date';
  static const String _longestStreakKey = 'longest_streak';
  static const String _totalPrayersKey = 'total_prayers_completed';

  // Prayer names
  static const List<String> prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  /// Get today's date string
  String get _todayKey => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// Get yesterday's date string
  String get _yesterdayKey =>
      DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1)));

  /// Initialize the service
  Future<void> init() async {
    await _checkAndUpdateStreak();
  }

  /// Get prayer completion status for a specific date
  Map<String, bool> getPrayerCompletionForDate(String dateKey) {
    final data = _storage.read<Map<String, dynamic>>(_prayerCompletionKey) ?? {};
    final dayData = data[dateKey] as Map<String, dynamic>? ?? {};

    return {for (var prayer in prayerNames) prayer: dayData[prayer] as bool? ?? false};
  }

  /// Get today's prayer completion status
  Map<String, bool> getTodayPrayerCompletion() {
    return getPrayerCompletionForDate(_todayKey);
  }

  /// Mark a prayer as completed/uncompleted for today
  Future<void> markPrayer(String prayerName, bool completed) async {
    final data = _storage.read<Map<String, dynamic>>(_prayerCompletionKey) ?? {};
    final dayData = Map<String, dynamic>.from(data[_todayKey] as Map<String, dynamic>? ?? {});

    dayData[prayerName] = completed;
    data[_todayKey] = dayData;

    await _storage.write(_prayerCompletionKey, data);

    // Update total prayers count
    if (completed) {
      final total = _storage.read<int>(_totalPrayersKey) ?? 0;
      await _storage.write(_totalPrayersKey, total + 1);
    } else {
      final total = _storage.read<int>(_totalPrayersKey) ?? 0;
      if (total > 0) {
        await _storage.write(_totalPrayersKey, total - 1);
      }
    }

    await _checkAndUpdateStreak();
  }

  /// Toggle prayer completion status
  Future<bool> togglePrayer(String prayerName) async {
    final current = getTodayPrayerCompletion();
    final newStatus = !(current[prayerName] ?? false);
    await markPrayer(prayerName, newStatus);
    return newStatus;
  }

  /// Get count of completed prayers for today
  int getTodayCompletedCount() {
    final today = getTodayPrayerCompletion();
    return today.values.where((v) => v).length;
  }

  /// Get completion percentage for today
  double getTodayCompletionPercentage() {
    return (getTodayCompletedCount() / 5) * 100;
  }

  /// Check if all prayers are completed for a date
  bool isAllPrayersCompleted(String dateKey) {
    final dayData = getPrayerCompletionForDate(dateKey);
    return dayData.values.every((v) => v);
  }

  /// Check if at least one prayer is completed for a date
  bool hasAnyPrayerCompleted(String dateKey) {
    final dayData = getPrayerCompletionForDate(dateKey);
    return dayData.values.any((v) => v);
  }

  /// Get current streak
  int getCurrentStreak() {
    return _storage.read<int>(_streakKey) ?? 0;
  }

  /// Get longest streak ever
  int getLongestStreak() {
    return _storage.read<int>(_longestStreakKey) ?? 0;
  }

  /// Get total prayers completed all time
  int getTotalPrayersCompleted() {
    return _storage.read<int>(_totalPrayersKey) ?? 0;
  }

  /// Check and update streak based on prayer completion
  Future<void> _checkAndUpdateStreak() async {
    final lastPrayerDate = _storage.read<String>(_lastPrayerDateKey);
    final currentStreak = _storage.read<int>(_streakKey) ?? 0;

    // Check if user completed at least one prayer today
    final todayHasPrayer = hasAnyPrayerCompleted(_todayKey);

    if (todayHasPrayer) {
      // Update last prayer date to today
      await _storage.write(_lastPrayerDateKey, _todayKey);

      if (lastPrayerDate == null) {
        // First time tracking
        await _storage.write(_streakKey, 1);
      } else if (lastPrayerDate == _todayKey) {
        // Already tracked today, do nothing
      } else if (lastPrayerDate == _yesterdayKey) {
        // Continuing streak from yesterday
        final newStreak = currentStreak + 1;
        await _storage.write(_streakKey, newStreak);

        // Update longest streak if needed
        final longestStreak = getLongestStreak();
        if (newStreak > longestStreak) {
          await _storage.write(_longestStreakKey, newStreak);
        }
      } else {
        // Streak broken, start new streak
        await _storage.write(_streakKey, 1);
      }
    }
  }

  /// Get weekly prayer data (last 7 days)
  Map<String, Map<String, bool>> getWeeklyData() {
    final result = <String, Map<String, bool>>{};

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      result[dateKey] = getPrayerCompletionForDate(dateKey);
    }

    return result;
  }

  /// Get weekly completion percentage
  double getWeeklyCompletionPercentage() {
    final weeklyData = getWeeklyData();
    int totalPrayers = 0;
    int completedPrayers = 0;

    for (var dayData in weeklyData.values) {
      totalPrayers += 5;
      completedPrayers += dayData.values.where((v) => v).length;
    }

    if (totalPrayers == 0) return 0;
    return (completedPrayers / totalPrayers) * 100;
  }

  /// Get streak emoji based on streak count
  String getStreakEmoji(int streak) {
    if (streak >= 100) return '⭐';
    if (streak >= 30) return '🏆';
    if (streak >= 7) return '🔥';
    if (streak >= 3) return '✨';
    return '🌱';
  }

  /// Get streak message based on streak count
  String getStreakMessage(int streak) {
    if (streak >= 100) return 'Legendary! 100+ days!';
    if (streak >= 30) return 'Amazing! 1 month streak!';
    if (streak >= 7) return 'On fire! 1 week streak!';
    if (streak >= 3) return 'Great start!';
    if (streak >= 1) return 'Keep going!';
    return 'Start your streak!';
  }

  /// Reset all data (for testing)
  Future<void> resetAllData() async {
    await _storage.remove(_prayerCompletionKey);
    await _storage.remove(_streakKey);
    await _storage.remove(_lastPrayerDateKey);
    await _storage.remove(_longestStreakKey);
    await _storage.remove(_totalPrayersKey);
  }
}
