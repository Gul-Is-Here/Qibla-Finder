import 'dart:io' show Platform;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/prayer_model/prayer_times_model.dart';
import '../../routes/app_pages.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isPlayingAzan = false;
  bool _isInitialized = false;

  NotificationService._init();

  // Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) {
      print('🔔 NotificationService already initialized');
      return;
    }

    print('🔔 Initializing NotificationService...');

    try {
      await AwesomeNotifications().initialize(
        null, // Default app icon
        [
          NotificationChannel(
            channelKey: 'prayer_channel',
            channelName: 'Prayer Times',
            channelDescription: 'Notifications for prayer times',
            defaultColor: const Color(0xFFAB80FF),
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
            soundSource: 'resource://raw/azan', // Custom azan sound from Android raw resources
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
        debug: false, // Changed to false for consistent behavior in release mode
      );

      _isInitialized = true;
      print('✅ NotificationService initialized successfully with custom azan sound');
    } catch (e, stackTrace) {
      print('❌ Error initializing NotificationService: $e');
      print('Stack trace: $stackTrace');

      // Try again without custom sound if initialization fails
      try {
        print('⚠️ Retrying initialization without custom sound...');
        await AwesomeNotifications().initialize(null, [
          NotificationChannel(
            channelKey: 'prayer_channel',
            channelName: 'Prayer Times',
            channelDescription: 'Notifications for prayer times',
            defaultColor: const Color(0xFFAB80FF),
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
          ),
          NotificationChannel(
            channelKey: 'silent_channel',
            channelName: 'Silent Notifications',
            channelDescription: 'Silent notifications for reminders',
            defaultColor: const Color(0xFFAB80FF),
            importance: NotificationImportance.High,
            playSound: false,
            enableVibration: false,
          ),
          NotificationChannel(
            channelKey: 'qibla_reminder',
            channelName: 'Qibla Reminders',
            channelDescription: 'Reminders for prayer direction',
            defaultColor: const Color(0xFFAB80FF),
            importance: NotificationImportance.Default,
            playSound: true,
            enableVibration: true,
          ),
        ], debug: false);
        _isInitialized = true;
        print('✅ NotificationService initialized successfully (default sound)');
      } catch (e2) {
        print('❌ Failed to initialize NotificationService even without custom sound: $e2');
        _isInitialized = false;
        rethrow;
      }
    }

    // NOTE: Notification permissions are now requested when user visits Prayer Times screen
    // This provides better UX and higher opt-in rates

    // Set up notification listeners
    _setupListeners();
  }

  Future<bool> requestPermissions() async {
    try {
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      print('DEBUG NotificationService: Current permission status = $isAllowed');

      if (!isAllowed) {
        print('DEBUG NotificationService: Requesting permission...');
        isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
        print('DEBUG NotificationService: Permission request result = $isAllowed');
      }
      return isAllowed;
    } catch (e) {
      print('ERROR NotificationService: Failed to request permissions: $e');
      return false;
    }
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
    // Prevent multiple simultaneous playback attempts
    if (_isPlayingAzan) {
      print('⚠️ Azan already playing, skipping duplicate request');
      return;
    }

    try {
      _isPlayingAzan = true;

      // Stop any currently playing audio first
      await _audioPlayer.stop();

      // Set the audio source
      await _audioPlayer.setAsset('assets/audio/azan.mp3');

      // Play the audio
      await _audioPlayer.play();

      print('✅ Azan playback started');

      // Listen for completion
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlayingAzan = false;
          print('✅ Azan playback completed');
        }
      });
    } catch (e) {
      print('❌ Error playing Azan: $e');
      _isPlayingAzan = false;
    }
  }

  static Future<void> _stopAzan() async {
    try {
      await _audioPlayer.stop();
      _isPlayingAzan = false;
      print('🔇 Azan playback stopped');
    } catch (e) {
      print('❌ Error stopping Azan: $e');
      _isPlayingAzan = false;
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
    // Convert to 12-hour format with AM/PM
    int hour = prayerTime.hour;
    String period = hour >= 12 ? 'PM' : 'AM';

    // Convert 24-hour to 12-hour format
    if (hour > 12) {
      hour = hour - 12;
    } else if (hour == 0) {
      hour = 12;
    }

    final timeStr = '$hour:${prayerTime.minute.toString().padLeft(2, '0')} $period';

    final messages = {
      'Fajr': 'Time for Fajr prayer at $timeStr',
      'Dhuhr': 'Dhuhr time at $timeStr',
      'Asr': 'Asr at $timeStr',
      'Maghrib': 'Maghrib at $timeStr',
      'Isha': 'Isha at $timeStr',
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
    print('🔔 scheduleAzanNotification: Called for $prayerName');
    print('🔔 scheduleAzanNotification: ID=$id, Time=$prayerTime, Location=$locationName');
    print('🔔 scheduleAzanNotification: Current time = ${DateTime.now()}');
    print(
      '🔔 scheduleAzanNotification: Time difference = ${prayerTime.difference(DateTime.now())}',
    );

    // Cancel existing notification with this ID
    await AwesomeNotifications().cancel(id);
    print('🔔 scheduleAzanNotification: Cancelled existing notification with ID=$id');

    // Only schedule if prayer time is in the future
    if (prayerTime.isBefore(DateTime.now())) {
      print('⏭️ scheduleAzanNotification: Skipping $prayerName - time has passed ($prayerTime)');
      return;
    }

    final emoji = _getPrayerEmoji(prayerName);
    final body = _getNotificationBody(prayerName, prayerTime, locationName);

    print('🔔 scheduleAzanNotification: Creating notification...');
    print('🔔 scheduleAzanNotification: Title = "$emoji $prayerName Prayer Time"');
    print('🔔 scheduleAzanNotification: Body = "$body"');

    try {
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
            isDangerousOption: true,
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

      print(
        '✅ scheduleAzanNotification: Successfully scheduled $prayerName notification for $prayerTime (ID: $id)',
      );

      // Verify it was scheduled
      final scheduledList = await AwesomeNotifications().listScheduledNotifications();
      final wasScheduled = scheduledList.any((n) => n.content?.id == id);
      print(
        '🔔 scheduleAzanNotification: Verification - Notification $id found in schedule: $wasScheduled',
      );
    } catch (e, stackTrace) {
      print('❌ scheduleAzanNotification: Error scheduling $prayerName notification: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // Schedule silent sunrise notification (no Azan sound)
  Future<void> scheduleSilentSunriseNotification({
    required int id,
    required DateTime sunriseTime,
    String? locationName,
  }) async {
    try {
      print('🌅 scheduleSilentSunriseNotification: Scheduling for $sunriseTime (ID: $id)');

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'silent_channel', // Use silent channel
          title: '🌅 Sunrise Time',
          body: locationName != null
              ? 'Sunrise in $locationName at ${DateFormat('h:mm a').format(sunriseTime)}'
              : 'Sunrise at ${DateFormat('h:mm a').format(sunriseTime)}',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Reminder,
          backgroundColor: Colors.amber,
          color: Colors.orange,
          payload: {
            'type': 'sunrise',
            'time': sunriseTime.toIso8601String(),
            'location': locationName ?? '',
          },
        ),
        schedule: NotificationCalendar.fromDate(date: sunriseTime),
      );

      print('✅ scheduleSilentSunriseNotification: Successfully scheduled sunrise notification');
    } catch (e, stackTrace) {
      print('❌ scheduleSilentSunriseNotification: Error: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // Schedule all prayers for a specific day
  Future<void> scheduleAllPrayersForDay({
    required PrayerTimesModel prayerTimes,
    required DateTime date,
    String? locationName,
    bool scheduleSunrise = false,
  }) async {
    print('🔔 scheduleAllPrayersForDay: Called for date: $date');

    final prayers = {
      'Fajr': prayerTimes.fajr,
      'Dhuhr': prayerTimes.dhuhr,
      'Asr': prayerTimes.asr,
      'Maghrib': prayerTimes.maghrib,
      'Isha': prayerTimes.isha,
    };

    print('🔔 scheduleAllPrayersForDay: Prayer times: $prayers');

    int baseId = date.day * 1000 + date.month * 100;
    int scheduledCount = 0;
    int skippedCount = 0;

    for (var entry in prayers.entries.indexed) {
      final prayerName = entry.$2.key;
      final prayerTimeStr = entry.$2.value;

      try {
        final prayerTime = _parsePrayerTime(prayerTimeStr, date);
        print(
          '🔔 scheduleAllPrayersForDay: $prayerName at $prayerTime (${prayerTime.isAfter(DateTime.now()) ? "FUTURE" : "PAST"})',
        );

        if (prayerTime.isAfter(DateTime.now())) {
          await scheduleAzanNotification(
            id: baseId + entry.$1,
            prayerName: prayerName,
            prayerTime: prayerTime,
            locationName: locationName,
          );
          scheduledCount++;
          print('✅ scheduleAllPrayersForDay: Scheduled $prayerName notification');
        } else {
          skippedCount++;
          print('⏭️ scheduleAllPrayersForDay: Skipped $prayerName (time has passed)');
        }
      } catch (e) {
        print('❌ scheduleAllPrayersForDay: Error scheduling $prayerName: $e');
      }
    }

    // Schedule sunrise notification if enabled (always silent)
    if (scheduleSunrise && prayerTimes.sunrise.isNotEmpty) {
      try {
        final sunriseTime = _parsePrayerTime(prayerTimes.sunrise, date);
        print(
          '🌅 scheduleAllPrayersForDay: Sunrise at $sunriseTime (${sunriseTime.isAfter(DateTime.now()) ? "FUTURE" : "PAST"})',
        );

        if (sunriseTime.isAfter(DateTime.now())) {
          await scheduleSilentSunriseNotification(
            id: baseId + 100, // Different ID range for sunrise
            sunriseTime: sunriseTime,
            locationName: locationName,
          );
          scheduledCount++;
          print('✅ scheduleAllPrayersForDay: Scheduled silent Sunrise notification');
        } else {
          skippedCount++;
          print('⏭️ scheduleAllPrayersForDay: Skipped Sunrise (time has passed)');
        }
      } catch (e) {
        print('❌ scheduleAllPrayersForDay: Error scheduling Sunrise: $e');
      }
    }

    print(
      '🔔 scheduleAllPrayersForDay: Completed - Scheduled: $scheduledCount, Skipped: $skippedCount',
    );
  }

  // Schedule prayers for multiple days (monthly)
  Future<void> scheduleMonthlyPrayers({
    required List<PrayerTimesModel> monthlyPrayerTimes,
    String? locationName,
    bool scheduleSunrise = false,
  }) async {
    print('🔔 NotificationService: scheduleMonthlyPrayers called');
    print(
      '🔔 NotificationService: Total prayer times available: ${monthlyPrayerTimes.length} days',
    );
    print('🔔 NotificationService: Location name: $locationName');

    // iOS has strict notification limits - only schedule 3 days to avoid crashes
    // This equals 15 notifications (3 days × 5 prayers) which is well within iOS limits
    // Android can handle more notifications
    final isIOS = Platform.isIOS;
    final maxDaysToSchedule = isIOS ? 3 : monthlyPrayerTimes.length;

    // Take only the first N days
    final prayerTimesToSchedule = monthlyPrayerTimes.take(maxDaysToSchedule).toList();

    print('🔔 NotificationService: Platform: ${isIOS ? "iOS" : "Android"}');
    print('🔔 NotificationService: Scheduling prayers for ${prayerTimesToSchedule.length} days');

    // Ensure notification service is initialized
    if (!_isInitialized) {
      print('⚠️ NotificationService not initialized, initializing now...');
      await initialize();
    }

    // CRITICAL: Always cancel ALL existing notifications first to prevent memory issues
    // This is especially important on iOS to avoid crash from accumulated notifications
    try {
      print('🔔 NotificationService: Cancelling ALL existing notifications first...');
      await AwesomeNotifications().cancelAll();
      print('✅ NotificationService: Successfully cleared all existing notifications');

      // Add a small delay to ensure cleanup is complete
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('⚠️ NotificationService: Error cancelling notifications: $e');
      // Continue anyway as this is not critical
    }

    int successCount = 0;
    int errorCount = 0;

    for (var prayerTimes in prayerTimesToSchedule) {
      try {
        // Parse the date from prayer times
        final date = _parseDateFromString(prayerTimes.date);
        print('🔔 NotificationService: Scheduling for date: ${prayerTimes.date}');

        await scheduleAllPrayersForDay(
          prayerTimes: prayerTimes,
          date: date,
          locationName: locationName,
          scheduleSunrise: scheduleSunrise,
        );
        successCount++;
      } catch (e, stackTrace) {
        errorCount++;
        print('❌ NotificationService: Error scheduling prayer for ${prayerTimes.date}: $e');
        print('Stack trace: $stackTrace');
      }
    }

    print(
      '✅ NotificationService: Completed scheduling ${isIOS ? "iOS (5 days)" : "monthly"} prayers',
    );
    print('🔔 NotificationService: Success: $successCount, Errors: $errorCount');
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
    try {
      // Check if it's already in "YYYY-MM-DD" format (new normalized format)
      if (dateStr.contains('-') && dateStr.length == 10) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final day = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      }

      // Otherwise, parse old format: "12 October 2025"
      final parts = dateStr.split(' ');
      if (parts.length != 3) {
        throw FormatException('Invalid date format: $dateStr');
      }

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
    } catch (e) {
      print('⚠️ Error parsing date "$dateStr": $e');
      // Return a default date if parsing fails
      return DateTime.now();
    }
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
    final notifications = await AwesomeNotifications().listScheduledNotifications();
    print('🔔 getScheduledNotifications: Found ${notifications.length} scheduled notifications');
    return notifications;
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final isEnabled = await AwesomeNotifications().isNotificationAllowed();
    print('🔔 areNotificationsEnabled: $isEnabled');
    return isEnabled;
  }

  // Print all scheduled notifications for debugging
  Future<void> printScheduledNotifications() async {
    final notifications = await getScheduledNotifications();
    print('📋 ========== SCHEDULED NOTIFICATIONS (${notifications.length}) ==========');
    for (var notification in notifications) {
      print('📋 ID: ${notification.content?.id}, Title: ${notification.content?.title}');
      print('📋 Body: ${notification.content?.body}');
      print('📋 Scheduled for: ${notification.schedule}');
      print('📋 ---');
    }
    print('📋 ========== END OF LIST ==========');
  }

  // Dispose audio player
  void dispose() {
    _audioPlayer.dispose();
  }
}
