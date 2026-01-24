import 'dart:io' show Platform;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/prayer_model/prayer_times_model.dart';
import '../../routes/app_pages.dart';
import 'enhanced_notification_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
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
      // Initialize ALL notification channels in one place (main + enhanced)
      await AwesomeNotifications().initialize(
        null, // Default app icon
        [
          // Main Prayer Channel with Azan sound (v3 - FIXED: removed defaultRingtoneType to use custom sound)
          NotificationChannel(
            channelKey: 'prayer_channel_v3',
            channelName: 'Prayer Times with Azan',
            channelDescription: 'Notifications for prayer times with Azan sound',
            defaultColor: const Color(0xFFAB80FF),
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
            soundSource: 'resource://raw/azan',
            enableLights: true,
            locked: false,
            onlyAlertOnce: false,
            // NOTE: DO NOT set defaultRingtoneType - it overrides soundSource!
            criticalAlerts: true,
          ),
          // Silent Notifications Channel
          NotificationChannel(
            channelKey: 'silent_channel',
            channelName: 'Silent Notifications',
            channelDescription: 'Silent notifications for reminders',
            defaultColor: const Color(0xFF00897B),
            importance: NotificationImportance.High,
            playSound: false,
            enableVibration: false,
          ),
          // Qibla Reminders Channel
          NotificationChannel(
            channelKey: 'qibla_reminder',
            channelName: 'Qibla Reminders',
            channelDescription: 'Reminders for prayer direction',
            defaultColor: const Color(0xFF004D40),
            importance: NotificationImportance.Default,
            playSound: true,
            enableVibration: true,
          ),
          // Enhanced: Pre-Prayer Reminder Channel
          NotificationChannel(
            channelKey: 'pre_prayer_reminder',
            channelName: 'Pre-Prayer Reminders',
            channelDescription: 'Reminders before prayer time',
            defaultColor: const Color(0xFF8F66FF),
            ledColor: Colors.white,
            importance: NotificationImportance.High,
            playSound: true,
            enableVibration: true,
          ),
          // Enhanced: Post-Prayer Check-in Channel
          NotificationChannel(
            channelKey: 'post_prayer_checkin',
            channelName: 'Prayer Check-in',
            channelDescription: 'Reminders to mark prayer completion',
            defaultColor: const Color(0xFFD4AF37),
            importance: NotificationImportance.Default,
            playSound: false,
            enableVibration: true,
            criticalAlerts: true,
          ),
          // Enhanced: Jummah Special Channel
          NotificationChannel(
            channelKey: 'jummah_channel',
            channelName: 'Jummah Reminders',
            channelDescription: 'Friday prayer reminders',
            defaultColor: const Color(0xFF2D1B69),
            ledColor: const Color(0xFFD4AF37),
            importance: NotificationImportance.Max,
            playSound: true,
            enableVibration: true,
          ),
          // Enhanced: Dhikr Reminder Channel
          NotificationChannel(
            channelKey: 'dhikr_reminder',
            channelName: 'Dhikr Reminders',
            channelDescription: 'Daily dhikr and remembrance reminders',
            defaultColor: const Color(0xFF00897B),
            importance: NotificationImportance.Default,
            playSound: true,
            enableVibration: false,
          ),
          // Enhanced: Optional Prayers Channel
          NotificationChannel(
            channelKey: 'optional_prayers',
            channelName: 'Optional Prayers',
            channelDescription: 'Reminders for Tahajjud, Duha, etc.',
            defaultColor: const Color(0xFF4CAF50),
            importance: NotificationImportance.Default,
            playSound: true,
            enableVibration: true,
          ),
          // Enhanced: Islamic Events Channel
          NotificationChannel(
            channelKey: 'islamic_events',
            channelName: 'Islamic Events',
            channelDescription: 'Special Islamic dates and events',
            defaultColor: const Color(0xFFFF9800),
            importance: NotificationImportance.High,
            playSound: true,
            enableVibration: true,
          ),
          // Enhanced: Achievement/Streak Channel
          NotificationChannel(
            channelKey: 'achievements',
            channelName: 'Achievements',
            channelDescription: 'Prayer streaks and milestones',
            defaultColor: const Color(0xFF4CAF50),
            importance: NotificationImportance.Default,
            playSound: true,
            enableVibration: false,
          ),
        ],
        debug: true, // Enable debug for troubleshooting
      );

      _isInitialized = true;
      print('✅ NotificationService initialized successfully with all channels (main + enhanced)');
    } catch (e, stackTrace) {
      print('❌ Error initializing NotificationService: $e');
      print('Stack trace: $stackTrace');

      // Try again without custom sound if initialization fails
      try {
        print('⚠️ Retrying initialization without custom sound...');
        await AwesomeNotifications().initialize(null, [
          NotificationChannel(
            channelKey: 'prayer_channel_v3',
            channelName: 'Prayer Times',
            channelDescription: 'Notifications for prayer times',
            defaultColor: const Color(0xFFAB80FF),
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
            criticalAlerts: true,
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
          // Enhanced channels (without custom sound)
          NotificationChannel(
            channelKey: 'pre_prayer_reminder',
            channelName: 'Pre-Prayer Reminders',
            channelDescription: 'Reminders before prayer time',
            defaultColor: const Color(0xFF8F66FF),
            ledColor: Colors.white,
            importance: NotificationImportance.High,
            playSound: true,
            enableVibration: true,
          ),
          NotificationChannel(
            channelKey: 'post_prayer_checkin',
            channelName: 'Prayer Check-in',
            channelDescription: 'Reminders to mark prayer completion',
            defaultColor: const Color(0xFFD4AF37),
            importance: NotificationImportance.Default,
            playSound: false,
            enableVibration: true,
            criticalAlerts: true,
          ),
          NotificationChannel(
            channelKey: 'jummah_channel',
            channelName: 'Jummah Reminders',
            channelDescription: 'Friday prayer reminders',
            defaultColor: const Color(0xFF2D1B69),
            ledColor: const Color(0xFFD4AF37),
            importance: NotificationImportance.Max,
            playSound: true,
            enableVibration: true,
          ),
          NotificationChannel(
            channelKey: 'dhikr_reminder',
            channelName: 'Dhikr Reminders',
            channelDescription: 'Daily dhikr and remembrance reminders',
            defaultColor: const Color(0xFF00897B),
            importance: NotificationImportance.Default,
            playSound: true,
            enableVibration: false,
          ),
          NotificationChannel(
            channelKey: 'optional_prayers',
            channelName: 'Optional Prayers',
            channelDescription: 'Reminders for Tahajjud, Duha, etc.',
            defaultColor: const Color(0xFF4CAF50),
            importance: NotificationImportance.Default,
            playSound: true,
            enableVibration: true,
          ),
          NotificationChannel(
            channelKey: 'islamic_events',
            channelName: 'Islamic Events',
            channelDescription: 'Special Islamic dates and events',
            defaultColor: const Color(0xFFFF9800),
            importance: NotificationImportance.High,
            playSound: true,
            enableVibration: true,
          ),
          NotificationChannel(
            channelKey: 'achievements',
            channelName: 'Achievements',
            channelDescription: 'Prayer streaks and milestones',
            defaultColor: const Color(0xFF4CAF50),
            importance: NotificationImportance.Default,
            playSound: true,
            enableVibration: false,
          ),
        ], debug: false);
        _isInitialized = true;
        print('✅ NotificationService initialized successfully with all channels (default sound)');
      } catch (e2) {
        print('❌ Failed to initialize NotificationService: $e2');
        _isInitialized = false;
        rethrow;
      }
    }

    // NOTE: Notification permissions are now requested when user visits Prayer Times screen
    // This provides better UX and higher opt-in rates

    // Set up notification listeners
    _setupListeners();

    // Mark enhanced channels as already initialized (no separate initialization needed)
    print('✅ All notification channels (main + enhanced) are ready');
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
    // Azan sound is now played by the notification system automatically
    // No need to manually play it from the app
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    print('Notification dismissed: ${receivedAction.id}');
    // Notification sound is controlled by system, dismissing notification stops sound
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    print('Notification action: ${receivedAction.buttonKeyPressed}');

    final payload = receivedAction.payload ?? {};
    final enhancedService = EnhancedNotificationService.instance;

    // Handle navigation when notification is tapped
    if (receivedAction.buttonKeyPressed.isEmpty) {
      // User tapped the notification itself (not a button)
      // Navigate to Prayer Times screen
      Get.toNamed(Routes.PRAYER_TIMES);
      return;
    }

    // Handle action buttons
    switch (receivedAction.buttonKeyPressed) {
      case 'STOP_AZAN':
        // Dismiss the notification to stop the azan sound
        await AwesomeNotifications().dismiss(receivedAction.id ?? 0);
        Get.snackbar(
          '🔇 Azan Stopped',
          'Notification dismissed',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        break;

      case 'MARK_PRAYED':
        // Dismiss the notification to stop the azan sound
        await AwesomeNotifications().dismiss(receivedAction.id ?? 0);
        final prayerName = payload['prayer'] ?? '';
        if (prayerName.isNotEmpty) {
          await enhancedService.updatePrayerStreak(prayerName);
          Get.snackbar(
            '✅ Prayer Marked',
            'Great! $prayerName marked as completed',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF4CAF50),
            colorText: Colors.white,
          );
        }
        break;

      case 'REMIND_LATER':
        Get.snackbar(
          'ℹ️ Reminder Set',
          'We\'ll remind you in 15 minutes',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        break;

      case 'OPEN_COUNTER':
        // Navigate to Dhikr Counter - update route as needed
        Get.toNamed(Routes.HOME); // Replace with actual dhikr counter route
        break;

      case 'MARK_DONE':
        Get.snackbar(
          '✅ Completed',
          'May Allah accept your remembrance',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );
        break;

      case 'READ_SURAH':
        // Navigate to Quran reader - update route as needed
        Get.snackbar(
          '📖 Surah Al-Kahf',
          'Opening Quran reader...',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        break;

      case 'SET_REMINDER':
        Get.snackbar(
          '⏰ Reminder Set',
          'We\'ll remind you before Jummah',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        break;

      case 'VIEW_LIST':
        // Navigate to Qada tracker - implement screen as needed
        Get.snackbar(
          '📝 Qada Prayers',
          'Feature coming soon',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        break;

      case 'VIEW_STATS':
      case 'VIEW_REPORT':
        // Navigate to prayer stats - implement screen as needed
        Get.snackbar(
          '📊 Prayer Statistics',
          'Feature coming soon',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        break;

      case 'SHARE':
        final streak = enhancedService.getCurrentStreak();
        Get.snackbar(
          '🎉 Share Achievement',
          '$streak days prayer streak!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        break;

      case 'SNOOZE_30':
        Get.snackbar(
          '😴 Snoozed',
          'We\'ll wake you in 30 minutes',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        break;

      case 'IM_AWAKE':
        Get.snackbar(
          '🌙 Great!',
          'May your Tahajjud be accepted',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF2D1B69),
          colorText: Colors.white,
        );
        break;

      case 'LEARN_MORE':
        Get.snackbar(
          '📖 Learn More',
          'Tap to learn about this blessed day',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        break;

      case 'DISMISS':
        // Just dismiss
        break;

      default:
        print('⚠️ Unknown action: ${receivedAction.buttonKeyPressed}');
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

  // Get Islamic greeting based on prayer time
  String _getIslamicGreeting(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 'صَلَاةُ الْفَجْر'; // Salat al-Fajr
      case 'dhuhr':
        return 'صَلَاةُ الظُّهْر'; // Salat al-Dhuhr
      case 'asr':
        return 'صَلَاةُ الْعَصْر'; // Salat al-Asr
      case 'maghrib':
        return 'صَلَاةُ الْمَغْرِب'; // Salat al-Maghrib
      case 'isha':
        return 'صَلَاةُ الْعِشَاء'; // Salat al-Isha
      default:
        return 'حَانَ وَقْتُ الصَّلَاة'; // Time for prayer
    }
  }

  // Get inspirational message for each prayer
  String _getInspirationMessage(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return '🤲 "Prayer is better than sleep" - Start your day blessed';
      case 'dhuhr':
        return '🤲 Take a moment to connect with Allah in your busy day';
      case 'asr':
        return '🤲 "Guard strictly the prayers, especially the middle prayer"';
      case 'maghrib':
        return '🤲 As the sun sets, let gratitude fill your heart';
      case 'isha':
        return '🤲 End your day in peace with remembrance of Allah';
      default:
        return '🤲 "Indeed, prayer prohibits immorality and wrongdoing"';
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
    final inspiration = _getInspirationMessage(prayerName);

    String locationStr = locationName != null && locationName.isNotEmpty ? '📍 $locationName' : '';

    return '⏰ $timeStr\n$inspiration${locationStr.isNotEmpty ? '\n$locationStr' : ''}';
  }

  // Get beautiful notification title
  String _getNotificationTitle(String prayerName) {
    final emoji = _getPrayerEmoji(prayerName);
    final arabicName = _getIslamicGreeting(prayerName);
    return '$emoji $prayerName Time • $arabicName';
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

    final title = _getNotificationTitle(prayerName);
    final body = _getNotificationBody(prayerName, prayerTime, locationName);

    print('🔔 scheduleAzanNotification: Creating notification...');
    print('🔔 scheduleAzanNotification: Title = "$title"');
    print('🔔 scheduleAzanNotification: Body = "$body"');

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: id,
          channelKey: 'prayer_channel_v3',
          title: title,
          body: body,
          summary: locationName ?? '',
          notificationLayout: NotificationLayout.BigText,
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
          autoDismissible: false,
          backgroundColor: const Color(0xFF2D1B69),
          color: const Color(0xFFD4AF37),
          payload: {
            'prayer': prayerName,
            'time': prayerTime.toIso8601String(),
            'location': locationName ?? '',
          },
          criticalAlert: true,
          customSound: 'resource://raw/azan',
          largeIcon: 'resource://drawable/ic_mosque',
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'STOP_AZAN',
            label: '🔇 Stop Azan',
            autoDismissible: true,
            actionType: ActionType.SilentAction,
          ),
          NotificationActionButton(
            key: 'MARK_PRAYED',
            label: '✅ Mark as Prayed',
            autoDismissible: true,
            actionType: ActionType.SilentAction,
          ),
        ],
        schedule: NotificationCalendar(
          year: prayerTime.year,
          month: prayerTime.month,
          day: prayerTime.day,
          hour: prayerTime.hour,
          minute: prayerTime.minute,
          second: 0,
          millisecond: 0,
          preciseAlarm: true,
          allowWhileIdle: true,
        ),
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

    // === ENHANCED NOTIFICATIONS ===
    await _scheduleEnhancedNotifications(
      prayerTimes: prayerTimes,
      date: date,
      locationName: locationName,
      baseId: baseId,
    );
  }

  // Schedule enhanced notifications for a day
  Future<void> _scheduleEnhancedNotifications({
    required PrayerTimesModel prayerTimes,
    required DateTime date,
    String? locationName,
    required int baseId,
  }) async {
    try {
      final enhancedService = EnhancedNotificationService.instance;

      // Parse all prayer times
      final fajrTime = _parsePrayerTime(prayerTimes.fajr, date);
      final sunriseTime = _parsePrayerTime(prayerTimes.sunrise, date);
      final dhuhrTime = _parsePrayerTime(prayerTimes.dhuhr, date);
      final asrTime = _parsePrayerTime(prayerTimes.asr, date);
      final maghribTime = _parsePrayerTime(prayerTimes.maghrib, date);
      final ishaTime = _parsePrayerTime(prayerTimes.isha, date);

      final prayers = [
        {'name': 'Fajr', 'time': fajrTime},
        {'name': 'Dhuhr', 'time': dhuhrTime},
        {'name': 'Asr', 'time': asrTime},
        {'name': 'Maghrib', 'time': maghribTime},
        {'name': 'Isha', 'time': ishaTime},
      ];

      // 1. Pre-Prayer Reminders
      if (enhancedService.prePrayerEnabled) {
        for (int i = 0; i < prayers.length; i++) {
          await enhancedService.schedulePrePrayerReminder(
            id: 10000 + baseId + i,
            prayerName: prayers[i]['name'] as String,
            prayerTime: prayers[i]['time'] as DateTime,
            minutesBefore: enhancedService.prePrayerMinutes,
          );
        }
      }

      // 2. Post-Prayer Check-ins
      if (enhancedService.postPrayerEnabled) {
        for (int i = 0; i < prayers.length; i++) {
          await enhancedService.schedulePostPrayerCheckIn(
            id: 20000 + baseId + i,
            prayerName: prayers[i]['name'] as String,
            prayerTime: prayers[i]['time'] as DateTime,
          );
        }
      }

      // 3. Jummah Reminder (if Friday)
      if (date.weekday == DateTime.friday && enhancedService.jummahEnabled) {
        await enhancedService.scheduleJummahReminder(
          jummahTime: dhuhrTime,
          locationName: locationName,
        );
      }

      // 4. Tahajjud Reminder
      if (enhancedService.tahajjudEnabled) {
        await enhancedService.scheduleTahajjudReminder(ishaTime: ishaTime, fajrTime: fajrTime);
      }

      // 5. Duha Prayer Reminder
      if (enhancedService.duhaEnabled) {
        await enhancedService.scheduleDuhaReminder(sunriseTime: sunriseTime, dhuhrTime: dhuhrTime);
      }

      print('✅ Enhanced notifications scheduled for $date');
    } catch (e) {
      print('⚠️ Error scheduling enhanced notifications: $e');
      // Continue without enhanced features
    }
  }

  // Schedule prayers for multiple days (monthly) - OPTIMIZED
  // Only schedules FUTURE prayers, not past ones
  Future<void> scheduleMonthlyPrayers({
    required List<PrayerTimesModel> monthlyPrayerTimes,
    String? locationName,
    bool scheduleSunrise = false,
  }) async {
    print('🔔 NotificationService: scheduleMonthlyPrayers called');
    print(
      '🔔 NotificationService: Total prayer times available: ${monthlyPrayerTimes.length} days',
    );

    // iOS has strict notification limits (64 max) - only schedule 7 days
    // Android can handle full month - schedule up to 30 days
    final isIOS = Platform.isIOS;
    final maxDaysToSchedule = isIOS ? 7 : 30; // Full month for Android

    print('🔔 Platform: ${isIOS ? "iOS" : "Android"}, Max days: $maxDaysToSchedule');

    // Filter to only include today and future dates
    final now = DateTime.now();

    final futurePrayerTimes = monthlyPrayerTimes
        .where((pt) {
          try {
            final ptDate = _parseDateFromString(pt.date);
            return !ptDate.isBefore(DateTime(now.year, now.month, now.day));
          } catch (e) {
            return false;
          }
        })
        .take(maxDaysToSchedule)
        .toList();

    print('🔔 NotificationService: Scheduling ${futurePrayerTimes.length} future days');

    // Ensure notification service is initialized
    if (!_isInitialized) {
      print('⚠️ NotificationService not initialized, initializing now...');
      await initialize();
    }

    // Get existing scheduled notification IDs to avoid duplicate work
    final existingNotifications = await AwesomeNotifications().listScheduledNotifications();
    final existingIds = existingNotifications.map((n) => n.content?.id).toSet();
    print('🔔 Found ${existingIds.length} existing scheduled notifications');

    // Only cancel notifications for dates we're about to reschedule
    // This avoids the expensive cancelAll() call
    int cancelledCount = 0;
    for (var notification in existingNotifications) {
      final id = notification.content?.id;
      if (id != null) {
        // Cancel only if it's a prayer notification (IDs typically start with date-based pattern)
        // Or if the scheduled time has passed
        final scheduledDate = notification.schedule;
        if (scheduledDate != null) {
          // Cancel past notifications
          await AwesomeNotifications().cancel(id);
          cancelledCount++;
        }
      }
    }
    print('🔔 Cancelled $cancelledCount past/outdated notifications');

    int successCount = 0;
    int skippedCount = 0;
    int errorCount = 0;

    for (var prayerTimes in futurePrayerTimes) {
      try {
        final date = _parseDateFromString(prayerTimes.date);

        // Schedule only FUTURE prayers for today, all prayers for future days
        await _scheduleUpcomingPrayersForDay(
          prayerTimes: prayerTimes,
          date: date,
          locationName: locationName,
          scheduleSunrise: scheduleSunrise,
          existingIds: existingIds,
        );
        successCount++;
      } catch (e) {
        errorCount++;
        print('❌ Error scheduling for ${prayerTimes.date}: $e');
      }
    }

    print(
      '✅ Scheduling complete: Success=$successCount, Skipped=$skippedCount, Errors=$errorCount',
    );

    // Schedule daily recurring reminders (once, not per day)
    await _scheduleDailyReminders();
  }

  // Schedule only upcoming prayers for a day (skip past prayers)
  Future<void> _scheduleUpcomingPrayersForDay({
    required PrayerTimesModel prayerTimes,
    required DateTime date,
    String? locationName,
    bool scheduleSunrise = false,
    Set<int?>? existingIds,
  }) async {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    final prayers = <String, String>{
      'Fajr': prayerTimes.fajr,
      'Dhuhr': prayerTimes.dhuhr,
      'Asr': prayerTimes.asr,
      'Maghrib': prayerTimes.maghrib,
      'Isha': prayerTimes.isha,
    };

    if (scheduleSunrise) {
      prayers['Sunrise'] = prayerTimes.sunrise;
    }

    for (var entry in prayers.entries) {
      try {
        final prayerTime = _parsePrayerTime(entry.value, date);

        // Skip if prayer time has already passed (for today)
        if (isToday && prayerTime.isBefore(now)) {
          continue; // Skip past prayers
        }

        // Generate unique ID for this prayer
        final notificationId = _generateNotificationId(date, entry.key);

        // Skip if already scheduled
        if (existingIds != null && existingIds.contains(notificationId)) {
          continue;
        }

        await _scheduleSinglePrayer(
          prayerName: entry.key,
          prayerTime: prayerTime,
          locationName: locationName,
          notificationId: notificationId,
        );
      } catch (e) {
        print('⚠️ Error scheduling ${entry.key}: $e');
      }
    }
  }

  // Generate consistent notification ID for a prayer
  int _generateNotificationId(DateTime date, String prayerName) {
    final prayerIndex = {'Fajr': 1, 'Sunrise': 2, 'Dhuhr': 3, 'Asr': 4, 'Maghrib': 5, 'Isha': 6};
    final index = prayerIndex[prayerName] ?? 0;
    // Format: YYYYMMDDP where P is prayer index (1-6)
    return int.parse(
      '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}$index',
    );
  }

  // Schedule a single prayer notification
  Future<void> _scheduleSinglePrayer({
    required String prayerName,
    required DateTime prayerTime,
    String? locationName,
    required int notificationId,
  }) async {
    final title = _getNotificationTitle(prayerName);
    final body = _getNotificationBody(prayerName, prayerTime, locationName);

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: 'prayer_channel_v3',
        title: title,
        body: body,
        summary: locationName ?? '',
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Alarm,
        wakeUpScreen: true,
        fullScreenIntent: true,
        autoDismissible: false,
        backgroundColor: const Color(0xFF2D1B69),
        color: const Color(0xFFD4AF37),
        customSound: 'resource://raw/azan',
        criticalAlert: true,
        largeIcon: 'resource://drawable/ic_mosque',
        payload: {
          'prayer': prayerName,
          'time': prayerTime.toIso8601String(),
          'location': locationName ?? '',
        },
      ),
      schedule: NotificationCalendar(
        year: prayerTime.year,
        month: prayerTime.month,
        day: prayerTime.day,
        hour: prayerTime.hour,
        minute: prayerTime.minute,
        second: 0,
        millisecond: 0,
        preciseAlarm: true,
        allowWhileIdle: true,
      ),
    );
  }

  // Schedule daily recurring reminders (Dhikr, Qada, Monthly Report)
  Future<void> _scheduleDailyReminders() async {
    try {
      final enhancedService = EnhancedNotificationService.instance;

      // Dhikr reminders (morning & evening)
      if (enhancedService.dhikrEnabled) {
        await enhancedService.scheduleDailyDhikrReminders();
        print('✅ Daily Dhikr reminders scheduled');
      }

      // Weekly Qada reminder
      if (enhancedService.qadaTrackingEnabled) {
        await enhancedService.scheduleWeeklyQadaReminder();
        print('✅ Weekly Qada reminder scheduled');
      }

      // Monthly report
      if (enhancedService.monthlyReportEnabled) {
        await enhancedService.scheduleMonthlyReport();
        print('✅ Monthly report scheduled');
      }
    } catch (e) {
      print('⚠️ Error scheduling daily reminders: $e');
    }
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

  // Test notification with azan sound - triggers immediately
  Future<void> testAzanNotification() async {
    print('🔔 testAzanNotification: Creating test notification with azan sound...');

    final testTitle = _getNotificationTitle('Test');
    final testBody = _getNotificationBody('Test', DateTime.now(), 'Test Location');

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 99999, // Special ID for test notifications
          channelKey: 'prayer_channel_v3',
          title: testTitle,
          body: testBody,
          summary: 'Test Location',
          notificationLayout: NotificationLayout.BigText,
          category: NotificationCategory.Alarm,
          wakeUpScreen: true,
          fullScreenIntent: true,
          autoDismissible: false,
          backgroundColor: const Color(0xFF2D1B69),
          color: const Color(0xFFD4AF37),
          customSound: 'resource://raw/azan',
          criticalAlert: true,
          largeIcon: 'resource://drawable/ic_mosque',
          payload: {'test': 'true', 'prayer': 'Test'},
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'STOP_AZAN',
            label: '🔇 Stop Azan',
            autoDismissible: true,
            actionType: ActionType.SilentAction,
          ),
          NotificationActionButton(
            key: 'MARK_PRAYED',
            label: '✅ Mark as Prayed',
            autoDismissible: true,
            actionType: ActionType.SilentAction,
          ),
        ],
      );

      print('✅ testAzanNotification: Test notification created successfully!');
      print('🔊 If you hear the azan sound, the configuration is correct.');
      print('🔇 If you don\'t hear sound, check:');
      print('   1. Phone is not on silent/vibrate mode');
      print('   2. Notification volume is turned up');
      print('   3. App has notification permissions');
      print('   4. Notification channel settings allow sound');
    } catch (e, stackTrace) {
      print('❌ testAzanNotification: Error creating test notification: $e');
      print('Stack trace: $stackTrace');
    }
  }

  // Print all scheduled notifications for debugging
  Future<void> printScheduledNotifications() async {
    final notifications = await getScheduledNotifications();
    print('📋 ========== SCHEDULED NOTIFICATIONS (${notifications.length}) ==========');
    for (var notification in notifications) {
      print('📋 ID: ${notification.content?.id}, Title: ${notification.content?.title}');
      print('📋 Body: ${notification.content?.body}');
      print('📋 Scheduled for: ${notification.schedule}');
      print('📋 Channel: ${notification.content?.channelKey}');
      print('📋 ---');
    }
    print('📋 ========== END OF LIST ==========');
  }
}
