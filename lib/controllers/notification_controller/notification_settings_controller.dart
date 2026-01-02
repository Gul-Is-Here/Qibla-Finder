import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../services/notifications/notification_service.dart';
import '../prayer_controller/prayer_times_controller.dart';

class NotificationSettingsController extends GetxController {
  final NotificationService _notificationService = NotificationService.instance;
  final GetStorage _storage = GetStorage();

  // Observable settings
  var notificationsEnabled = false.obs;
  var playAzan = true.obs;
  var silentMode = false.obs;
  var volume = 0.8.obs;
  var vibration = true.obs;
  var fullScreenIntent = true.obs;

  // Individual prayer toggles
  var fajrEnabled = true.obs;
  var dhuhrEnabled = true.obs;
  var asrEnabled = true.obs;
  var maghribEnabled = true.obs;
  var ishaEnabled = true.obs;

  // Sunrise notification (always silent)
  var sunriseNotificationEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _checkNotificationPermission();
  }

  Future<void> _checkNotificationPermission() async {
    notificationsEnabled.value = await _notificationService.areNotificationsEnabled();
  }

  void _loadSettings() {
    // Load saved settings
    notificationsEnabled.value = _storage.read('notifications_enabled') ?? false;
    playAzan.value = _storage.read('play_azan') ?? true;
    silentMode.value = _storage.read('silent_mode') ?? false;
    volume.value = _storage.read('volume') ?? 0.8;
    vibration.value = _storage.read('vibration') ?? true;
    fullScreenIntent.value = _storage.read('full_screen_intent') ?? true;

    // Load individual prayer settings
    fajrEnabled.value = _storage.read('fajr_enabled') ?? true;
    dhuhrEnabled.value = _storage.read('dhuhr_enabled') ?? true;
    asrEnabled.value = _storage.read('asr_enabled') ?? true;
    maghribEnabled.value = _storage.read('maghrib_enabled') ?? true;
    ishaEnabled.value = _storage.read('isha_enabled') ?? true;

    // Load sunrise notification setting
    sunriseNotificationEnabled.value = _storage.read('sunrise_enabled') ?? false;
  }

  Future<void> toggleNotifications(bool value) async {
    if (value) {
      // Request permission
      final allowed = await _notificationService.requestPermissions();
      if (allowed) {
        notificationsEnabled.value = true;
        await _storage.write('notifications_enabled', true);

        // Reschedule notifications
        await _rescheduleNotifications();

        Get.snackbar(
          '✅ Notifications Enabled',
          'You will receive prayer time notifications',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          '❌ Permission Denied',
          'Please enable notifications from app settings',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } else {
      notificationsEnabled.value = false;
      await _storage.write('notifications_enabled', false);
      await _notificationService.cancelAllNotifications();

      Get.snackbar(
        'ℹ️ Notifications Disabled',
        'Prayer notifications have been turned off',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> toggleAzan(bool value) async {
    playAzan.value = value;
    await _storage.write('play_azan', value);

    if (value && silentMode.value) {
      silentMode.value = false;
      await _storage.write('silent_mode', false);
    }

    await _rescheduleNotifications();
  }

  Future<void> toggleSilentMode(bool value) async {
    silentMode.value = value;
    await _storage.write('silent_mode', value);

    if (value && playAzan.value) {
      playAzan.value = false;
      await _storage.write('play_azan', false);
    }

    await _rescheduleNotifications();
  }

  Future<void> setVolume(double value) async {
    volume.value = value;
    await _storage.write('volume', value);
  }

  Future<void> toggleVibration(bool value) async {
    vibration.value = value;
    await _storage.write('vibration', value);
    await _rescheduleNotifications();
  }

  Future<void> toggleFullScreenIntent(bool value) async {
    fullScreenIntent.value = value;
    await _storage.write('full_screen_intent', value);
    await _rescheduleNotifications();
  }

  Future<void> togglePrayer(String prayer, bool value) async {
    switch (prayer) {
      case 'Fajr':
        fajrEnabled.value = value;
        await _storage.write('fajr_enabled', value);
        break;
      case 'Dhuhr':
        dhuhrEnabled.value = value;
        await _storage.write('dhuhr_enabled', value);
        break;
      case 'Asr':
        asrEnabled.value = value;
        await _storage.write('asr_enabled', value);
        break;
      case 'Maghrib':
        maghribEnabled.value = value;
        await _storage.write('maghrib_enabled', value);
        break;
      case 'Isha':
        ishaEnabled.value = value;
        await _storage.write('isha_enabled', value);
        break;
    }

    await _rescheduleNotifications();
  }

  bool isPrayerEnabled(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return fajrEnabled.value;
      case 'Dhuhr':
        return dhuhrEnabled.value;
      case 'Asr':
        return asrEnabled.value;
      case 'Maghrib':
        return maghribEnabled.value;
      case 'Isha':
        return ishaEnabled.value;
      default:
        return true;
    }
  }

  Future<void> toggleSunriseNotification(bool value) async {
    sunriseNotificationEnabled.value = value;
    await _storage.write('sunrise_enabled', value);
    await _rescheduleNotifications();

    if (value) {
      Get.snackbar(
        'Sunrise Reminder Enabled',
        'You will receive silent notifications at sunrise',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber,
        colorText: Colors.white,
        icon: const Icon(Icons.wb_sunny, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _rescheduleNotifications() async {
    if (!notificationsEnabled.value) return;

    try {
      // Cancel all existing notifications
      await _notificationService.cancelAllNotifications();

      // Get prayer times controller
      if (Get.isRegistered<PrayerTimesController>()) {
        final prayerController = Get.find<PrayerTimesController>();

        if (prayerController.monthlyPrayerTimes.isNotEmpty) {
          // Filter prayer times based on enabled prayers
          final filteredPrayers = prayerController.monthlyPrayerTimes
              .where((prayerTime) => _shouldSchedulePrayer(prayerTime))
              .toList();

          // Schedule notifications with current settings
          await _notificationService.scheduleMonthlyPrayers(
            monthlyPrayerTimes: filteredPrayers,
            locationName: prayerController.locationName.value,
            scheduleSunrise: sunriseNotificationEnabled.value,
          );
        }
      }
    } catch (e) {
      print('Error rescheduling notifications: $e');
    }
  }

  bool _shouldSchedulePrayer(dynamic prayerTime) {
    // This is a simplified check - you can make it more sophisticated
    return true;
  }

  Future<void> sendTestNotification() async {
    await _notificationService.scheduleAzanNotification(
      id: 99999,
      prayerName: 'Test',
      prayerTime: DateTime.now().add(const Duration(seconds: 5)),
      locationName: 'Test Location',
    );
  }

  Future<void> clearAllNotifications() async {
    await _notificationService.cancelAllNotifications();
  }

  String getChannelKey() {
    if (silentMode.value) {
      return 'silent_channel';
    }
    return 'prayer_channel';
  }

  Map<String, dynamic> getNotificationSettings() {
    return {
      'playAzan': playAzan.value && !silentMode.value,
      'silent': silentMode.value,
      'volume': volume.value,
      'vibration': vibration.value,
      'fullScreenIntent': fullScreenIntent.value,
      'channelKey': getChannelKey(),
    };
  }
}
