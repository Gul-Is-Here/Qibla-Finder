import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../models/prayer_times_model.dart';
import '../routes/app_pages.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  static final AudioPlayer _audioPlayer = AudioPlayer();

  NotificationService._init();

  // Initialize notification service
  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // Default app icon
      [
        NotificationChannel(
          channelKey: 'prayer_channel',
          channelName: 'Prayer Times',
          channelDescription: 'Notifications for prayer times',
          defaultColor: const Color(0xFF00897B),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
          soundSource: 'resource://raw/azan',
        ),
        NotificationChannel(
          channelKey: 'silent_channel',
          channelName: 'Silent Notifications',
          channelDescription: 'Silent notifications for reminders',
          defaultColor: const Color(0xFF00897B),
          importance: NotificationImportance.High,
          playSound: false,
          enableVibration: false,
        ),
        NotificationChannel(
          channelKey: 'qibla_reminder',
          channelName: 'Qibla Reminders',
          channelDescription: 'Reminders for prayer direction',
          defaultColor: const Color(0xFF004D40),
          importance: NotificationImportance.Default,
          playSound: true,
          enableVibration: true,
        ),
      ],
      debug: true,
    );

    // NOTE: Notification permissions are now requested when user visits Prayer Times screen
    // This provides better UX and higher opt-in rates

    // Set up notification listeners
    _setupListeners();
  }

  Future<bool> requestPermissions() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return isAllowed;
  }

  void _setupListeners() {
    // Listen to notification events
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    print('Notification created: ${receivedNotification.id}');
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    print('Notification displayed: ${receivedNotification.id}');

    // Play Azan when notification is displayed
    if (receivedNotification.channelKey == 'prayer_channel') {
      await _playAzan();
    }
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    print('Notification dismissed: ${receivedAction.id}');
    await _stopAzan();
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    print('Notification action: ${receivedAction.buttonKeyPressed}');

    // Handle navigation when notification is tapped
    if (receivedAction.buttonKeyPressed.isEmpty) {
      // User tapped the notification itself (not a button)
      // Navigate to Prayer Times screen
      Get.toNamed(Routes.PRAYER_TIMES);
    } else if (receivedAction.buttonKeyPressed == 'STOP_AZAN') {
      await _stopAzan();
    } else if (receivedAction.buttonKeyPressed == 'MARK_PRAYED') {
      await _stopAzan();
      // You can add logic to mark prayer as completed
    }
  }

  static Future<void> _playAzan() async {
    try {
      await _audioPlayer.setAsset('assets/audio/azan.mp3');
      await _audioPlayer.play();
    } catch (e) {
      print('Error playing Azan: $e');
    }
  }

  static Future<void> _stopAzan() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping Azan: $e');
    }
  }

  // Get prayer emoji based on prayer name
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

  // Get beautiful notification body with time formatting
  String _getNotificationBody(String prayerName, DateTime prayerTime, String? locationName) {
    final timeStr =
        '${prayerTime.hour.toString().padLeft(2, '0')}:${prayerTime.minute.toString().padLeft(2, '0')}';

    final messages = {
      'Fajr': ' Time for Fajr prayer at $timeStr',
      'Dhuhr': ' Dhuhr time at $timeStr',
      'Asr': ' Asr at $timeStr',
      'Maghrib': ' Maghrib at $timeStr',
      'Isha': ' Isha at $timeStr',
    };

    return messages[prayerName] ?? 'It\'s time for $prayerName prayer at $timeStr';
  }

  // Schedule notification for a specific prayer
  Future<void> scheduleAzanNotification({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
    String? locationName,
  }) async {
    // Cancel existing notification with this ID
    await AwesomeNotifications().cancel(id);

    // Only schedule if prayer time is in the future
    if (prayerTime.isBefore(DateTime.now())) {
      print('Skipping $prayerName - time has passed ($prayerTime)');
      return;
    }

    final emoji = _getPrayerEmoji(prayerName);
    final body = _getNotificationBody(prayerName, prayerTime, locationName);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,

        channelKey: 'prayer_channel',
        title: '$emoji $prayerName Prayer Time',
        body: body,
        summary: locationName ?? '',
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Alarm,
        wakeUpScreen: true,
        fullScreenIntent: true,
        autoDismissible: false,
        backgroundColor: const Color(0xFF00332F),
        color: const Color(0xFF00897B),
        payload: {
          'prayer': prayerName,
          'time': prayerTime.toIso8601String(),
          'location': locationName ?? '',
        },
        criticalAlert: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'STOP_AZAN',
          label: 'Mute',
          color: Colors.red,
          autoDismissible: true,
          actionType: ActionType.Default,
        ),
        NotificationActionButton(
          key: 'MARK_PRAYED',
          label: 'Prayed',
          color: const Color(0xFF00897B),
          autoDismissible: true,
          actionType: ActionType.Default,
        ),
      ],
      schedule: NotificationCalendar.fromDate(date: prayerTime),
    );

    print('Scheduled $prayerName notification for $prayerTime (ID: $id)');
  }

  // Schedule all prayers for a specific day
  Future<void> scheduleAllPrayersForDay({
    required PrayerTimesModel prayerTimes,
    required DateTime date,
    String? locationName,
  }) async {
    final prayers = {
      'Fajr': prayerTimes.fajr,
      'Dhuhr': prayerTimes.dhuhr,
      'Asr': prayerTimes.asr,
      'Maghrib': prayerTimes.maghrib,
      'Isha': prayerTimes.isha,
    };

    int baseId = date.day * 1000 + date.month * 100;

    for (var entry in prayers.entries.indexed) {
      final prayerName = entry.$2.key;
      final prayerTimeStr = entry.$2.value;
      final prayerTime = _parsePrayerTime(prayerTimeStr, date);

      if (prayerTime.isAfter(DateTime.now())) {
        await scheduleAzanNotification(
          id: baseId + entry.$1,
          prayerName: prayerName,
          prayerTime: prayerTime,
          locationName: locationName,
        );
      }
    }
  }

  // Schedule prayers for multiple days (monthly)
  Future<void> scheduleMonthlyPrayers({
    required List<PrayerTimesModel> monthlyPrayerTimes,
    String? locationName,
  }) async {
    print('Scheduling prayers for ${monthlyPrayerTimes.length} days');

    for (var prayerTimes in monthlyPrayerTimes) {
      try {
        // Parse the date from prayer times
        final date = _parseDateFromString(prayerTimes.date);

        await scheduleAllPrayersForDay(
          prayerTimes: prayerTimes,
          date: date,
          locationName: locationName,
        );
      } catch (e) {
        print('Error scheduling prayer for ${prayerTimes.date}: $e');
      }
    }

    print('Completed scheduling monthly prayers');
  }

  DateTime _parsePrayerTime(String timeStr, DateTime date) {
    // Remove any extra spaces and split by colon
    final cleanTime = timeStr.trim();
    final parts = cleanTime.split(':');

    int hour = int.parse(parts[0]);
    final minutePart = parts[1].split(' ');
    int minute = int.parse(minutePart[0]);

    // Handle AM/PM if present
    if (minutePart.length > 1) {
      final period = minutePart[1].toLowerCase();
      if (period == 'pm' && hour != 12) {
        hour += 12;
      } else if (period == 'am' && hour == 12) {
        hour = 0;
      }
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  DateTime _parseDateFromString(String dateStr) {
    // Format: "12 October 2025" or similar
    final parts = dateStr.split(' ');
    final day = int.parse(parts[0]);
    final year = int.parse(parts[2]);

    final monthMap = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };

    final month = monthMap[parts[1]] ?? 1;

    return DateTime(year, month, day);
  }

  // Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
    print('Cancelled all notifications');
  }

  // Cancel notifications for a specific day
  Future<void> cancelDayNotifications(DateTime date) async {
    int baseId = date.day * 1000 + date.month * 100;
    for (int i = 0; i < 5; i++) {
      await AwesomeNotifications().cancel(baseId + i);
    }
  }

  // Get list of scheduled notifications
  Future<List<NotificationModel>> getScheduledNotifications() async {
    return await AwesomeNotifications().listScheduledNotifications();
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  // Dispose audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}
