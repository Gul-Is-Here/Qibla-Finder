import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/prayer_tracker/prayer_tracker_service.dart';

/// Controller for prayer tracking and streaks
class PrayerTrackerController extends GetxController {
  final _service = PrayerTrackerService.instance;

  // Observable state
  final RxMap<String, bool> todayCompletion = <String, bool>{}.obs;
  final RxInt currentStreak = 0.obs;
  final RxInt longestStreak = 0.obs;
  final RxInt totalPrayers = 0.obs;
  final RxInt todayCompletedCount = 0.obs;
  final RxDouble todayPercentage = 0.0.obs;
  final RxDouble weeklyPercentage = 0.0.obs;
  final RxMap<String, Map<String, bool>> weeklyData = <String, Map<String, bool>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  /// Load all data from service
  void _loadData() {
    todayCompletion.value = _service.getTodayPrayerCompletion();
    currentStreak.value = _service.getCurrentStreak();
    longestStreak.value = _service.getLongestStreak();
    totalPrayers.value = _service.getTotalPrayersCompleted();
    todayCompletedCount.value = _service.getTodayCompletedCount();
    todayPercentage.value = _service.getTodayCompletionPercentage();
    weeklyPercentage.value = _service.getWeeklyCompletionPercentage();
    weeklyData.value = _service.getWeeklyData();
  }

  /// Toggle prayer completion and refresh data
  Future<void> togglePrayer(String prayerName) async {
    await _service.togglePrayer(prayerName);
    _loadData();
  }

  /// Mark prayer as completed
  Future<void> markPrayerCompleted(String prayerName) async {
    await _service.markPrayer(prayerName, true);
    _loadData();
  }

  /// Mark prayer as not completed
  Future<void> markPrayerNotCompleted(String prayerName) async {
    await _service.markPrayer(prayerName, false);
    _loadData();
  }

  /// Check if a specific prayer is completed today
  bool isPrayerCompleted(String prayerName) {
    return todayCompletion[prayerName] ?? false;
  }

  /// Get streak emoji
  String get streakEmoji => _service.getStreakEmoji(currentStreak.value);

  /// Get streak message
  String get streakMessage => _service.getStreakMessage(currentStreak.value);

  /// Get day name from date key
  String getDayName(String dateKey) {
    final date = DateFormat('yyyy-MM-dd').parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return DateFormat('EEE').format(date);
  }

  /// Get completion count for a specific date
  int getCompletionCountForDate(String dateKey) {
    final dayData = weeklyData[dateKey] ?? {};
    return dayData.values.where((v) => v).length;
  }

  /// Refresh data
  @override
  void refresh() {
    _loadData();
  }
}
