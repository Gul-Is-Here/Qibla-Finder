import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../model/prayer_times_model.dart';
import '../services/prayer_times_service.dart';
import '../services/location_service.dart';
import '../services/prayer_times_database.dart';
import '../services/notification_service.dart';

class PrayerTimesController extends GetxController {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  final LocationService _locationService = Get.find<LocationService>();
  final PrayerTimesDatabase _database = PrayerTimesDatabase.instance;
  final NotificationService _notificationService = NotificationService.instance;

  var prayerTimes = Rxn<PrayerTimesModel>();
  var monthlyPrayerTimes = <PrayerTimesModel>[].obs;
  var isLoading = false.obs;
  var selectedDate = DateTime.now().obs;
  var currentLocation = Rxn<Position>();
  var locationName = ''.obs;
  var nextPrayer = ''.obs;
  var timeUntilNextPrayer = ''.obs;
  var errorMessage = ''.obs;
  var isOnline = true.obs;
  var notificationsEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializePrayerTimes();
    _checkNotificationStatus();
  }

  Future<void> _initializePrayerTimes() async {
    await fetchPrayerTimes();
    await fetchAndCacheMonthlyPrayerTimes();
    _startNextPrayerTimer();
  }

  Future<void> _checkNotificationStatus() async {
    notificationsEnabled.value = await _notificationService
        .areNotificationsEnabled();
  }

  Future<void> enableNotifications() async {
    final allowed = await _notificationService.requestPermissions();
    notificationsEnabled.value = allowed;

    if (allowed && monthlyPrayerTimes.isNotEmpty) {
      await _scheduleAllNotifications();
    }
  }

  Future<void> _scheduleAllNotifications() async {
    await _notificationService.scheduleMonthlyPrayers(
      monthlyPrayerTimes: monthlyPrayerTimes,
      locationName: locationName.value,
    );
  }

  Future<void> fetchPrayerTimes({DateTime? date}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get current location
      final position = await _locationService.getCurrentPosition();
      currentLocation.value = position;
      selectedDate.value = date ?? DateTime.now();

      // Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      isOnline.value = connectivityResult.first != ConnectivityResult.none;

      PrayerTimesModel? times;

      if (isOnline.value) {
        // Fetch from internet
        times = await _prayerTimesService.getPrayerTimesByCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
          date: selectedDate.value,
        );

        // Save to database
        if (times != null) {
          await _updateLocationName(position);
          await _database.insertPrayerTimes(
            times,
            position.latitude,
            position.longitude,
            locationName.value,
          );
        }
      } else {
        // Load from database (offline mode)
        final dateStr = _formatDate(selectedDate.value);
        times = await _database.getPrayerTimes(
          dateStr,
          position.latitude,
          position.longitude,
        );

        if (times == null) {
          errorMessage.value =
              'No offline data available. Please connect to internet.';
        } else {
          locationName.value = times.location ?? 'Unknown Location';
        }
      }

      if (times != null) {
        prayerTimes.value = times;
        nextPrayer.value = times.getNextPrayer();
        if (isOnline.value) {
          _updateLocationName(position);
        }
      } else if (isOnline.value) {
        errorMessage.value = 'Failed to fetch prayer times';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      print('Error fetching prayer times: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAndCacheMonthlyPrayerTimes() async {
    if (currentLocation.value == null) return;

    try {
      // Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      isOnline.value = connectivityResult.first != ConnectivityResult.none;

      if (!isOnline.value) {
        // Load from database
        final times = await _database.getUpcomingPrayerTimes(
          DateTime.now(),
          currentLocation.value!.latitude,
          currentLocation.value!.longitude,
        );
        monthlyPrayerTimes.value = times;
        return;
      }

      // Fetch from internet for current month
      final times = await _prayerTimesService.getMonthlyPrayerTimes(
        latitude: currentLocation.value!.latitude,
        longitude: currentLocation.value!.longitude,
        date: selectedDate.value,
      );

      if (times.isNotEmpty) {
        monthlyPrayerTimes.value = times;

        // Save to database
        await _database.insertMultiplePrayerTimes(
          times,
          currentLocation.value!.latitude,
          currentLocation.value!.longitude,
          locationName.value,
        );

        // Fetch next month as well
        final nextMonth = DateTime(
          selectedDate.value.year,
          selectedDate.value.month + 1,
        );

        final nextMonthTimes = await _prayerTimesService.getMonthlyPrayerTimes(
          latitude: currentLocation.value!.latitude,
          longitude: currentLocation.value!.longitude,
          date: nextMonth,
        );

        if (nextMonthTimes.isNotEmpty) {
          await _database.insertMultiplePrayerTimes(
            nextMonthTimes,
            currentLocation.value!.latitude,
            currentLocation.value!.longitude,
            locationName.value,
          );

          // Add to monthly prayer times
          monthlyPrayerTimes.addAll(nextMonthTimes);
        }

        // Schedule notifications for all prayers
        if (notificationsEnabled.value) {
          await _scheduleAllNotifications();
        }

        // Clean up old data
        await _database.deleteOldPrayerTimes();
      }
    } catch (e) {
      print('Error fetching monthly prayer times: $e');

      // Try loading from database on error
      final times = await _database.getUpcomingPrayerTimes(
        DateTime.now(),
        currentLocation.value!.latitude,
        currentLocation.value!.longitude,
      );
      monthlyPrayerTimes.value = times;
    }
  }

  Future<void> fetchMonthlyPrayerTimes() async {
    await fetchAndCacheMonthlyPrayerTimes();
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  void changeDate(DateTime newDate) {
    selectedDate.value = newDate;
    fetchPrayerTimes(date: newDate);
  }

  void goToNextDay() {
    final nextDay = selectedDate.value.add(const Duration(days: 1));
    changeDate(nextDay);
  }

  void goToPreviousDay() {
    final previousDay = selectedDate.value.subtract(const Duration(days: 1));
    changeDate(previousDay);
  }

  void goToToday() {
    changeDate(DateTime.now());
  }

  Future<void> refreshPrayerTimes() async {
    await fetchPrayerTimes();
    await fetchAndCacheMonthlyPrayerTimes();
  }

  void _startNextPrayerTimer() {
    // Calculate immediately on start
    if (prayerTimes.value != null) {
      nextPrayer.value = prayerTimes.value!.getNextPrayer();
      _calculateTimeUntilNextPrayer();
    }

    // Update time until next prayer every second for countdown
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (prayerTimes.value != null) {
        // Recalculate next prayer (in case current one has passed)
        final newNextPrayer = prayerTimes.value!.getNextPrayer();
        if (newNextPrayer != nextPrayer.value) {
          // Prayer has changed, update it
          nextPrayer.value = newNextPrayer;
        }
        _calculateTimeUntilNextPrayer();
      }
    });
  }

  void _calculateTimeUntilNextPrayer() {
    if (prayerTimes.value == null) {
      timeUntilNextPrayer.value = 'Calculating...';
      return;
    }

    final now = DateTime.now();
    final prayers = prayerTimes.value!.getAllPrayerTimes();
    final nextPrayerName = nextPrayer.value;

    if (nextPrayerName.isEmpty || !prayers.containsKey(nextPrayerName)) {
      timeUntilNextPrayer.value = 'Loading...';
      return;
    }

    try {
      final nextPrayerTimeStr = prayers[nextPrayerName]!;
      DateTime nextPrayerTime = _parseTime(nextPrayerTimeStr);

      // If the next prayer is "Fajr" and its time has passed today,
      // it means it's for tomorrow, so add 1 day
      if (nextPrayerName == 'Fajr' && nextPrayerTime.isBefore(now)) {
        nextPrayerTime = nextPrayerTime.add(const Duration(days: 1));
      }

      if (nextPrayerTime.isAfter(now)) {
        final duration = nextPrayerTime.difference(now);
        final hours = duration.inHours;
        final minutes = duration.inMinutes.remainder(60);
        final seconds = duration.inSeconds.remainder(60);

        if (hours > 0) {
          timeUntilNextPrayer.value = '${hours}h ${minutes}m ${seconds}s';
        } else if (minutes > 0) {
          timeUntilNextPrayer.value = '${minutes}m ${seconds}s';
        } else if (seconds > 0) {
          timeUntilNextPrayer.value = '${seconds}s';
        } else {
          timeUntilNextPrayer.value = 'Now';
        }
      } else {
        // This shouldn't happen, but just in case
        timeUntilNextPrayer.value = 'Calculating...';
      }
    } catch (e) {
      print('Error calculating time until next prayer: $e');
      timeUntilNextPrayer.value = 'Error';
    }
  }

  DateTime _parseTime(String time) {
    try {
      // Remove extra spaces and trim
      final cleanTime = time.trim();
      final parts = cleanTime.split(':');

      if (parts.length < 2) {
        throw FormatException('Invalid time format: $time');
      }

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

      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      print('Error parsing time "$time": $e');
      return DateTime.now();
    }
  }

  Future<void> _updateLocationName(Position position) async {
    try {
      // Use geocoding to get the location name
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // Build location name from available data
        String name = '';

        if (place.locality != null && place.locality!.isNotEmpty) {
          name = place.locality!;
        } else if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          name = place.subAdministrativeArea!;
        } else if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          name = place.administrativeArea!;
        }

        // Add country if we have a city/locality
        if (name.isNotEmpty && place.country != null) {
          locationName.value = '$name, ${place.country}';
        } else if (name.isNotEmpty) {
          locationName.value = name;
        } else {
          // Fallback to coordinates if no name found
          locationName.value =
              'Lat: ${position.latitude.toStringAsFixed(2)}, Lon: ${position.longitude.toStringAsFixed(2)}';
        }
      } else {
        locationName.value =
            'Lat: ${position.latitude.toStringAsFixed(2)}, Lon: ${position.longitude.toStringAsFixed(2)}';
      }
    } catch (e) {
      print('Error getting location name: $e');
      // Fallback to coordinates on error
      locationName.value =
          'Lat: ${position.latitude.toStringAsFixed(2)}, Lon: ${position.longitude.toStringAsFixed(2)}';
    }
  }

  bool isToday() {
    final now = DateTime.now();
    return selectedDate.value.year == now.year &&
        selectedDate.value.month == now.month &&
        selectedDate.value.day == now.day;
  }
}
