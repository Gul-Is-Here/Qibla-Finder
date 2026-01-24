import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

/// Enhanced Notification Service with additional reminder features
///
/// New Features:
/// 1. Pre-Prayer Reminders (5-15 min before)
/// 2. Post-Prayer Check-in (Did you pray?)
/// 3. Jummah Special Reminder (Friday prayer)
/// 4. Daily Dhikr Reminder (Morning/Evening)
/// 5. Islamic Date Notifications
/// 6. Tahajjud/Night Prayer
/// 7. Duha Prayer
/// 8. Qada Prayer Tracker
/// 9. Monthly Prayer Report
/// 10. Streak Notifications
class EnhancedNotificationService {
  static final EnhancedNotificationService instance = EnhancedNotificationService._init();
  final GetStorage _storage = GetStorage();

  EnhancedNotificationService._init();

  // Storage Keys
  static const String _prePrayerEnabledKey = 'pre_prayer_enabled';
  static const String _prePrayerMinutesKey = 'pre_prayer_minutes';
  static const String _postPrayerEnabledKey = 'post_prayer_enabled';
  static const String _jummahEnabledKey = 'jummah_enabled';
  static const String _dhikrEnabledKey = 'dhikr_enabled';
  static const String _dhikrMorningTimeKey = 'dhikr_morning_time';
  static const String _dhikrEveningTimeKey = 'dhikr_evening_time';
  static const String _tahajjudEnabledKey = 'tahajjud_enabled';
  static const String _duhaEnabledKey = 'duha_enabled';
  static const String _qadaTrackingEnabledKey = 'qada_tracking_enabled';
  static const String _missedPrayersKey = 'missed_prayers';
  static const String _islamicDatesEnabledKey = 'islamic_dates_enabled';
  static const String _monthlyReportEnabledKey = 'monthly_report_enabled';
  static const String _streaksEnabledKey = 'streaks_enabled';
  static const String _prayerStreakKey = 'prayer_streak';
  static const String _lastPrayerDateKey = 'last_prayer_date';
  static const String _prayersCompletedKey =
      'prayers_completed'; // Format: "2026-01-09": ["Fajr", "Dhuhr"]

  /// Initialize enhanced notification channels
  /// NOTE: Channels are now initialized in NotificationService.initialize()
  /// This method is kept for backwards compatibility but does nothing
  Future<void> initializeEnhancedChannels() async {
    print('🔔 Enhanced Notification Channels already initialized in NotificationService');
    print('✅ Enhanced features ready to use');
  }

  // ==================== 1. PRE-PRAYER REMINDERS ====================

  /// Schedule pre-prayer reminder (5-15 minutes before prayer)
  Future<void> schedulePrePrayerReminder({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
    int minutesBefore = 15,
  }) async {
    if (!(_storage.read(_prePrayerEnabledKey) ?? false)) {
      print('⏭️ Pre-prayer reminders disabled');
      return;
    }

    final reminderTime = prayerTime.subtract(Duration(minutes: minutesBefore));

    if (reminderTime.isBefore(DateTime.now())) {
      print('⏭️ Pre-prayer reminder time has passed for $prayerName');
      return;
    }

    final emoji = _getPrayerEmoji(prayerName);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'pre_prayer_reminder',
        title: '$emoji $prayerName Starting Soon',
        body:
            '$prayerName prayer begins in $minutesBefore minutes at ${DateFormat('h:mm a').format(prayerTime)}\nPrepare for prayer 🤲',
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Reminder,
        wakeUpScreen: false,
        backgroundColor: const Color(0xFF8F66FF),
        color: const Color(0xFFD4AF37),
        payload: {
          'type': 'pre_prayer',
          'prayer': prayerName,
          'prayer_time': prayerTime.toIso8601String(),
        },
      ),
      actionButtons: [NotificationActionButton(key: 'DISMISS', label: 'OK', autoDismissible: true)],
      schedule: NotificationCalendar.fromDate(date: reminderTime),
    );

    print(
      '✅ Pre-prayer reminder scheduled for $prayerName at $reminderTime (${minutesBefore}min before)',
    );
  }

  // ==================== 2. POST-PRAYER CHECK-IN ====================

  /// Schedule post-prayer check-in (30 min after prayer)
  Future<void> schedulePostPrayerCheckIn({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
  }) async {
    if (!(_storage.read(_postPrayerEnabledKey) ?? false)) {
      print('⏭️ Post-prayer check-in disabled');
      return;
    }

    final checkInTime = prayerTime.add(const Duration(minutes: 30));

    if (checkInTime.isBefore(DateTime.now())) {
      print('⏭️ Post-prayer check-in time has passed for $prayerName');
      return;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'post_prayer_checkin',
        title: '🤲 Did You Pray $prayerName?',
        body:
            'It\'s been 30 minutes since $prayerName time.\nTap to mark as prayed or get reminded later.',
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Reminder,
        backgroundColor: const Color(0xFFD4AF37),
        payload: {
          'type': 'post_prayer',
          'prayer': prayerName,
          'prayer_time': prayerTime.toIso8601String(),
        },
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'MARK_PRAYED',
          label: 'Mark Prayed ✅',
          color: const Color(0xFF4CAF50),
          autoDismissible: true,
        ),
        NotificationActionButton(key: 'REMIND_LATER', label: 'Remind Later', autoDismissible: true),
      ],
      schedule: NotificationCalendar.fromDate(date: checkInTime),
    );

    print('✅ Post-prayer check-in scheduled for $prayerName at $checkInTime');
  }

  // ==================== 3. JUMMAH SPECIAL REMINDER ====================

  /// Schedule Jummah (Friday) prayer reminder
  Future<void> scheduleJummahReminder({required DateTime jummahTime, String? locationName}) async {
    if (!(_storage.read(_jummahEnabledKey) ?? true)) {
      print('⏭️ Jummah reminders disabled');
      return;
    }

    // Only schedule if it's Friday
    if (jummahTime.weekday != DateTime.friday) {
      print('⏭️ Not Friday, skipping Jummah reminder');
      return;
    }

    // Schedule 1 hour before Jummah
    final reminderTime = jummahTime.subtract(const Duration(hours: 1));

    if (reminderTime.isBefore(DateTime.now())) {
      print('⏭️ Jummah reminder time has passed');
      return;
    }

    final id = 9000 + jummahTime.day; // Special ID range for Jummah

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'jummah_channel',
        title: '🕌 Jummah Prayer Today',
        body:
            'Friday prayer starts at ${DateFormat('h:mm a').format(jummahTime)}\n📖 Don\'t forget to read Surah Al-Kahf',
        summary: locationName ?? 'Jummah Reminder',
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Event,
        wakeUpScreen: true,
        backgroundColor: const Color(0xFF2D1B69),
        color: const Color(0xFFD4AF37),
        payload: {'type': 'jummah', 'time': jummahTime.toIso8601String()},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'READ_SURAH',
          label: '📖 Read Surah Al-Kahf',
          autoDismissible: false,
        ),
        NotificationActionButton(
          key: 'SET_REMINDER',
          label: '⏰ Set Reminder',
          autoDismissible: true,
        ),
      ],
      schedule: NotificationCalendar.fromDate(date: reminderTime),
    );

    print(
      '✅ Jummah reminder scheduled for ${DateFormat('EEEE, MMM d').format(jummahTime)} at $reminderTime',
    );
  }

  // ==================== 4. DAILY DHIKR REMINDER ====================

  /// Schedule daily dhikr reminders (morning and evening)
  Future<void> scheduleDailyDhikrReminders() async {
    if (!(_storage.read(_dhikrEnabledKey) ?? false)) {
      print('⏭️ Dhikr reminders disabled');
      return;
    }

    final now = DateTime.now();

    // Morning Dhikr (default: 6:30 AM)
    final morningTimeStr = _storage.read(_dhikrMorningTimeKey) ?? '06:30';
    final morningParts = morningTimeStr.split(':');
    var morningTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(morningParts[0]),
      int.parse(morningParts[1]),
    );

    if (morningTime.isBefore(now)) {
      morningTime = morningTime.add(const Duration(days: 1));
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 8001,
        channelKey: 'dhikr_reminder',
        title: '📿 Morning Dhikr Time',
        body: 'Have you done your morning adhkar?\nTap to open Dhikr Counter',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        backgroundColor: const Color(0xFF00897B),
        payload: {'type': 'dhikr', 'period': 'morning'},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'OPEN_COUNTER',
          label: 'Open Counter',
          autoDismissible: false,
        ),
        NotificationActionButton(key: 'MARK_DONE', label: 'Mark Done ✅', autoDismissible: true),
      ],
      schedule: NotificationCalendar.fromDate(date: morningTime),
    );

    // Evening Dhikr (default: 5:30 PM)
    final eveningTimeStr = _storage.read(_dhikrEveningTimeKey) ?? '17:30';
    final eveningParts = eveningTimeStr.split(':');
    var eveningTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(eveningParts[0]),
      int.parse(eveningParts[1]),
    );

    if (eveningTime.isBefore(now)) {
      eveningTime = eveningTime.add(const Duration(days: 1));
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 8002,
        channelKey: 'dhikr_reminder',
        title: '📿 Evening Dhikr Time',
        body: 'Time for evening adhkar\nRemember Allah before sunset 🌅',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        backgroundColor: const Color(0xFFFF9800),
        payload: {'type': 'dhikr', 'period': 'evening'},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'OPEN_COUNTER',
          label: 'Open Counter',
          autoDismissible: false,
        ),
        NotificationActionButton(key: 'MARK_DONE', label: 'Mark Done ✅', autoDismissible: true),
      ],
      schedule: NotificationCalendar.fromDate(date: eveningTime),
    );

    print('✅ Daily Dhikr reminders scheduled (Morning: $morningTime, Evening: $eveningTime)');
  }

  // ==================== 5. ISLAMIC DATE NOTIFICATIONS ====================

  /// Schedule notification for special Islamic dates
  Future<void> scheduleIslamicDateNotification({
    required DateTime date,
    required String eventName,
    required String description,
    String? actionInfo,
  }) async {
    if (!(_storage.read(_islamicDatesEnabledKey) ?? true)) {
      print('⏭️ Islamic date notifications disabled');
      return;
    }

    // Schedule for 8 AM on the special date
    final notificationTime = DateTime(date.year, date.month, date.day, 8, 0);

    if (notificationTime.isBefore(DateTime.now())) {
      print('⏭️ Islamic date notification time has passed');
      return;
    }

    final id = 7000 + date.day + (date.month * 100);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'islamic_events',
        title: '🌙 Special Islamic Date',
        body: 'Today is $eventName\n$description',
        summary: actionInfo ?? '',
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Event,
        wakeUpScreen: true,
        backgroundColor: const Color(0xFFFF9800),
        color: const Color(0xFFD4AF37),
        payload: {'type': 'islamic_date', 'event': eventName, 'date': date.toIso8601String()},
      ),
      actionButtons: [
        NotificationActionButton(key: 'LEARN_MORE', label: 'Learn More', autoDismissible: false),
        NotificationActionButton(key: 'DISMISS', label: 'OK', autoDismissible: true),
      ],
      schedule: NotificationCalendar.fromDate(date: notificationTime),
    );

    print('✅ Islamic date notification scheduled: $eventName on $date');
  }

  // ==================== 6. TAHAJJUD/NIGHT PRAYER REMINDER ====================

  /// Schedule Tahajjud reminder (last third of night)
  Future<void> scheduleTahajjudReminder({
    required DateTime ishaTime,
    required DateTime fajrTime,
  }) async {
    if (!(_storage.read(_tahajjudEnabledKey) ?? false)) {
      print('⏭️ Tahajjud reminders disabled');
      return;
    }

    // Calculate last third of night
    final nightDuration = fajrTime.difference(ishaTime);
    final lastThirdStart = ishaTime.add(
      Duration(milliseconds: (nightDuration.inMilliseconds * 2 / 3).round()),
    );

    if (lastThirdStart.isBefore(DateTime.now())) {
      print('⏭️ Tahajjud time has passed');
      return;
    }

    final id = 6000 + fajrTime.day;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'optional_prayers',
        title: '🌙 Last Third of Night',
        body:
            'Perfect time for Tahajjud prayer\n"The Lord descends to the lowest heaven during this time"\n\nFajr begins at ${DateFormat('h:mm a').format(fajrTime)}',
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Alarm,
        wakeUpScreen: true,
        backgroundColor: const Color(0xFF2D1B69),
        color: const Color(0xFFD4AF37),
        payload: {'type': 'tahajjud', 'fajr_time': fajrTime.toIso8601String()},
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'SNOOZE_30',
          label: 'Snooze 30min',
          actionType: ActionType.SilentAction,
        ),
        NotificationActionButton(key: 'IM_AWAKE', label: 'I\'m Awake ✅', autoDismissible: true),
      ],
      schedule: NotificationCalendar.fromDate(date: lastThirdStart),
    );

    print('✅ Tahajjud reminder scheduled for $lastThirdStart');
  }

  // ==================== 7. DUHA PRAYER REMINDER ====================

  /// Schedule Duha prayer reminder (15-20 min after sunrise)
  Future<void> scheduleDuhaReminder({
    required DateTime sunriseTime,
    required DateTime dhuhrTime,
  }) async {
    if (!(_storage.read(_duhaEnabledKey) ?? false)) {
      print('⏭️ Duha reminders disabled');
      return;
    }

    // Schedule 20 minutes after sunrise
    final duhaTime = sunriseTime.add(const Duration(minutes: 20));

    if (duhaTime.isBefore(DateTime.now())) {
      print('⏭️ Duha time has passed');
      return;
    }

    final id = 5000 + sunriseTime.day;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'optional_prayers',
        title: '☀️ Duha Prayer Time',
        body:
            'Morning prayer available until ${DateFormat('h:mm a').format(dhuhrTime)}\n"Two Rak\'ahs in the morning are better than the world and all it contains"',
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Reminder,
        backgroundColor: const Color(0xFFFF9800),
        color: const Color(0xFFFFEB3B),
        payload: {'type': 'duha', 'sunrise_time': sunriseTime.toIso8601String()},
      ),
      actionButtons: [
        NotificationActionButton(key: 'DISMISS', label: 'Dismiss', autoDismissible: true),
        NotificationActionButton(key: 'LEARN_MORE', label: 'Learn More', autoDismissible: false),
      ],
      schedule: NotificationCalendar.fromDate(date: duhaTime),
    );

    print('✅ Duha reminder scheduled for $duhaTime');
  }

  // ==================== 8. QADA PRAYER TRACKER ====================

  /// Add missed prayer to tracker
  Future<void> addMissedPrayer(String prayerName, DateTime date) async {
    if (!(_storage.read(_qadaTrackingEnabledKey) ?? false)) {
      return;
    }

    List<String> missedPrayers = _getMissedPrayers();
    final entry = '${DateFormat('yyyy-MM-dd').format(date)}:$prayerName';

    if (!missedPrayers.contains(entry)) {
      missedPrayers.add(entry);
      await _storage.write(_missedPrayersKey, missedPrayers);
      print('✅ Added missed prayer: $prayerName on ${DateFormat('MMM d').format(date)}');
    }
  }

  /// Remove completed Qada prayer
  Future<void> markQadaCompleted(String prayerName, DateTime date) async {
    List<String> missedPrayers = _getMissedPrayers();
    final entry = '${DateFormat('yyyy-MM-dd').format(date)}:$prayerName';

    missedPrayers.remove(entry);
    await _storage.write(_missedPrayersKey, missedPrayers);
    print('✅ Marked Qada completed: $prayerName from ${DateFormat('MMM d').format(date)}');
  }

  /// Get list of missed prayers
  List<String> _getMissedPrayers() {
    return List<String>.from(_storage.read(_missedPrayersKey) ?? []);
  }

  /// Schedule weekly Qada reminder
  Future<void> scheduleWeeklyQadaReminder() async {
    if (!(_storage.read(_qadaTrackingEnabledKey) ?? false)) {
      print('⏭️ Qada tracking disabled');
      return;
    }

    final missedPrayers = _getMissedPrayers();

    if (missedPrayers.isEmpty) {
      print('✅ No missed prayers to remind about');
      return;
    }

    // Schedule for Friday evening (after Isha)
    final now = DateTime.now();
    var reminderDate = now;

    // Find next Friday
    while (reminderDate.weekday != DateTime.friday) {
      reminderDate = reminderDate.add(const Duration(days: 1));
    }

    // Set time to 9 PM
    reminderDate = DateTime(reminderDate.year, reminderDate.month, reminderDate.day, 21, 0);

    if (reminderDate.isBefore(now)) {
      reminderDate = reminderDate.add(const Duration(days: 7));
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 4000,
        channelKey: 'post_prayer_checkin',
        title: '📿 Missed Prayer Reminder',
        body:
            'You have ${missedPrayers.length} Qada prayer${missedPrayers.length > 1 ? 's' : ''} to make up\nPerform them when convenient 🤲',
        notificationLayout: NotificationLayout.BigText,
        summary: 'Qada Prayers: ${missedPrayers.length}',
        category: NotificationCategory.Reminder,
        backgroundColor: const Color(0xFFD4AF37),
        payload: {'type': 'qada_reminder', 'count': missedPrayers.length.toString()},
      ),
      actionButtons: [
        NotificationActionButton(key: 'VIEW_LIST', label: 'View List', autoDismissible: false),
        NotificationActionButton(key: 'DISMISS', label: 'Later', autoDismissible: true),
      ],
      schedule: NotificationCalendar.fromDate(date: reminderDate),
    );

    print('✅ Weekly Qada reminder scheduled for $reminderDate (${missedPrayers.length} prayers)');
  }

  // ==================== 9. MONTHLY PRAYER REPORT ====================

  /// Schedule monthly prayer report
  Future<void> scheduleMonthlyReport() async {
    if (!(_storage.read(_monthlyReportEnabledKey) ?? true)) {
      print('⏭️ Monthly reports disabled');
      return;
    }

    // Schedule for 1st of next month at 9 AM
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1, 9, 0);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 3000,
        channelKey: 'achievements',
        title: '📊 Your Monthly Prayer Report',
        body:
            'View your prayer statistics for ${DateFormat('MMMM yyyy').format(DateTime(now.year, now.month))}',
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Status,
        backgroundColor: const Color(0xFF4CAF50),
        payload: {
          'type': 'monthly_report',
          'month': now.month.toString(),
          'year': now.year.toString(),
        },
      ),
      actionButtons: [
        NotificationActionButton(key: 'VIEW_REPORT', label: 'View Details', autoDismissible: false),
        NotificationActionButton(key: 'DISMISS', label: 'Later', autoDismissible: true),
      ],
      schedule: NotificationCalendar.fromDate(date: nextMonth),
    );

    print('✅ Monthly report scheduled for $nextMonth');
  }

  // ==================== 10. STREAK NOTIFICATIONS ====================

  /// Check and update prayer streak
  Future<void> updatePrayerStreak(String prayerName) async {
    if (!(_storage.read(_streaksEnabledKey) ?? true)) {
      return;
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Map<String, dynamic> prayersCompleted = _getPrayersCompleted();

    // Add prayer to today's list
    List<String> todayPrayers = List<String>.from(prayersCompleted[today] ?? []);
    if (!todayPrayers.contains(prayerName)) {
      todayPrayers.add(prayerName);
      prayersCompleted[today] = todayPrayers;
      await _storage.write(_prayersCompletedKey, prayersCompleted);
    }

    // Check if all 5 prayers completed today
    if (todayPrayers.length == 5) {
      await _incrementStreak();
    }
  }

  Future<void> _incrementStreak() async {
    int currentStreak = _storage.read(_prayerStreakKey) ?? 0;
    currentStreak++;
    await _storage.write(_prayerStreakKey, currentStreak);
    await _storage.write(_lastPrayerDateKey, DateFormat('yyyy-MM-dd').format(DateTime.now()));

    // Send streak milestone notification
    if (currentStreak == 7 ||
        currentStreak == 30 ||
        currentStreak == 100 ||
        currentStreak % 100 == 0) {
      await _sendStreakNotification(currentStreak);
    }
  }

  Future<void> _sendStreakNotification(int streak) async {
    String message;
    String emoji;

    if (streak == 7) {
      message = 'You\'ve prayed on time for 7 days straight!\nKeep up the excellent work! 🎉';
      emoji = '🔥';
    } else if (streak == 30) {
      message = 'Amazing! 30 days of consistent prayers!\nMay Allah reward you abundantly! 🌟';
      emoji = '⭐';
    } else if (streak == 100) {
      message = 'Mashallah! 100 days of dedication!\nYou\'re an inspiration! 🏆';
      emoji = '🏆';
    } else {
      message = '$streak days of consistent prayers!\nSubhanAllah! Keep going! 💪';
      emoji = '🎯';
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2000 + streak,
        channelKey: 'achievements',
        title: '$emoji $streak-Day Prayer Streak!',
        body: message,
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Status,
        backgroundColor: const Color(0xFF4CAF50),
        color: const Color(0xFFFFD700),
        payload: {'type': 'streak', 'days': streak.toString()},
      ),
      actionButtons: [
        NotificationActionButton(key: 'VIEW_STATS', label: 'View Stats', autoDismissible: false),
        NotificationActionButton(key: 'SHARE', label: 'Share 🎉', autoDismissible: true),
      ],
    );

    print('🎉 Streak notification sent: $streak days');
  }

  /// Get current prayer streak
  int getCurrentStreak() {
    return _storage.read(_prayerStreakKey) ?? 0;
  }

  Map<String, dynamic> _getPrayersCompleted() {
    return Map<String, dynamic>.from(_storage.read(_prayersCompletedKey) ?? {});
  }

  // ==================== UTILITY METHODS ====================

  String _getPrayerEmoji(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return '🌅';
      case 'dhuhr':
        return '☀️';
      case 'asr':
        return '🌤️';
      case 'maghrib':
        return '🌇';
      case 'isha':
        return '🌙';
      default:
        return '🕌';
    }
  }

  // ==================== SETTINGS GETTERS/SETTERS ====================

  bool get prePrayerEnabled => _storage.read(_prePrayerEnabledKey) ?? false;
  Future<void> setPrePrayerEnabled(bool value) async =>
      await _storage.write(_prePrayerEnabledKey, value);

  int get prePrayerMinutes => _storage.read(_prePrayerMinutesKey) ?? 15;
  Future<void> setPrePrayerMinutes(int value) async =>
      await _storage.write(_prePrayerMinutesKey, value);

  bool get postPrayerEnabled => _storage.read(_postPrayerEnabledKey) ?? false;
  Future<void> setPostPrayerEnabled(bool value) async =>
      await _storage.write(_postPrayerEnabledKey, value);

  bool get jummahEnabled => _storage.read(_jummahEnabledKey) ?? true;
  Future<void> setJummahEnabled(bool value) async => await _storage.write(_jummahEnabledKey, value);

  bool get dhikrEnabled => _storage.read(_dhikrEnabledKey) ?? false;
  Future<void> setDhikrEnabled(bool value) async => await _storage.write(_dhikrEnabledKey, value);

  bool get tahajjudEnabled => _storage.read(_tahajjudEnabledKey) ?? false;
  Future<void> setTahajjudEnabled(bool value) async =>
      await _storage.write(_tahajjudEnabledKey, value);

  bool get duhaEnabled => _storage.read(_duhaEnabledKey) ?? false;
  Future<void> setDuhaEnabled(bool value) async => await _storage.write(_duhaEnabledKey, value);

  bool get qadaTrackingEnabled => _storage.read(_qadaTrackingEnabledKey) ?? false;
  Future<void> setQadaTrackingEnabled(bool value) async =>
      await _storage.write(_qadaTrackingEnabledKey, value);

  bool get islamicDatesEnabled => _storage.read(_islamicDatesEnabledKey) ?? true;
  Future<void> setIslamicDatesEnabled(bool value) async =>
      await _storage.write(_islamicDatesEnabledKey, value);

  bool get monthlyReportEnabled => _storage.read(_monthlyReportEnabledKey) ?? true;
  Future<void> setMonthlyReportEnabled(bool value) async =>
      await _storage.write(_monthlyReportEnabledKey, value);

  bool get streaksEnabled => _storage.read(_streaksEnabledKey) ?? true;
  Future<void> setStreaksEnabled(bool value) async =>
      await _storage.write(_streaksEnabledKey, value);
}
