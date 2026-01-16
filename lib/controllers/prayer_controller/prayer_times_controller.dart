import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/prayer_model/prayer_times_model.dart';
import '../../services/Prayer/prayer_times_service.dart';
import '../../services/location/location_service.dart';
import '../../services/Prayer/prayer_times_database.dart';
import '../../services/notifications/notification_service.dart';

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
  var isSyncingInBackground = false.obs;
  var lastSyncTime = Rxn<DateTime>();

  // Connectivity listener
  Stream<ConnectivityResult>? _connectivityStream;

  @override
  void onInit() {
    super.onInit();
    // DEFERRED: Run initialization after frame is rendered
    Future.microtask(() => _initializePrayerTimes());
    // These are lightweight, can run immediately
    _checkNotificationStatus();
    _setupConnectivityListener();
  }

  @override
  void onClose() {
    // Clean up connectivity listener
    super.onClose();
  }

  // Listen for connectivity changes and auto-sync when online
  void _setupConnectivityListener() {
    _connectivityStream = Connectivity().onConnectivityChanged.map((list) => list.first);
    _connectivityStream?.listen((ConnectivityResult result) {
      final wasOffline = !isOnline.value;
      isOnline.value = result != ConnectivityResult.none;

      print('📡 Connectivity changed: ${result.name} (Online: ${isOnline.value})');

      // If we just came online, sync data
      if (wasOffline && isOnline.value) {
        print('🔄 Connection restored - starting auto-sync...');
        _autoSyncWhenOnline();
      }
    });
  }

  // Auto-sync when connection is restored
  Future<void> _autoSyncWhenOnline() async {
    if (currentLocation.value == null) return;

    try {
      print('🔄 Auto-syncing prayer times...');

      // Sync current prayer times in background
      if (prayerTimes.value != null) {
        _syncPrayerTimesInBackground(currentLocation.value!, selectedDate.value);
      }

      // Sync monthly data in background
      _syncMonthlyPrayerTimesInBackground();

      print('✅ Auto-sync initiated');
    } catch (e) {
      print('⚠️ Auto-sync error: $e');
    }
  }

  Future<void> _initializePrayerTimes() async {
    // Run these in parallel instead of sequentially
    await fetchPrayerTimes();
    // Don't await monthly data - let it load in background
    fetchAndCacheMonthlyPrayerTimes();
    _startNextPrayerTimer();
  }

  Future<void> _checkNotificationStatus() async {
    notificationsEnabled.value = await _notificationService.areNotificationsEnabled();
  }

  Future<void> enableNotifications() async {
    final allowed = await _notificationService.requestPermissions();
    notificationsEnabled.value = allowed;

    if (allowed && monthlyPrayerTimes.isNotEmpty) {
      await _scheduleAllNotifications();
    }
  }

  // Enable all prayer notifications when permission is granted
  Future<void> enableAllPrayerNotifications() async {
    print('🔔 enableAllPrayerNotifications: Starting...');
    final storage = GetStorage();

    // Update the notification enabled flag FIRST
    notificationsEnabled.value = true;

    // Enable all prayer notifications
    await storage.write('fajr_enabled', true);
    await storage.write('dhuhr_enabled', true);
    await storage.write('asr_enabled', true);
    await storage.write('maghrib_enabled', true);
    await storage.write('isha_enabled', true);
    await storage.write('notifications_enabled', true);

    print('🔔 enableAllPrayerNotifications: Settings saved to storage');
    print('🔔 Monthly prayer times count: ${monthlyPrayerTimes.length}');

    // If monthly prayer times not yet loaded, trigger fetch and wait
    if (monthlyPrayerTimes.isEmpty) {
      print('⏳ Monthly prayer times not loaded, triggering fetch...');

      // Trigger the fetch in background if location is available
      if (currentLocation.value != null) {
        print('🔔 Fetching monthly prayer times...');
        await fetchAndCacheMonthlyPrayerTimes();
        print('✅ Monthly prayer times fetch completed: ${monthlyPrayerTimes.length} days');
      } else {
        print('⚠️ No location available, waiting for it...');
        // Wait up to 5 seconds for location and data
        for (int i = 0; i < 10; i++) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (monthlyPrayerTimes.isNotEmpty) {
            print('✅ Prayer times loaded after ${(i + 1) * 500}ms');
            break;
          }
        }
      }
    }

    // Schedule all notifications
    if (monthlyPrayerTimes.isNotEmpty) {
      print('🔔 Calling _scheduleAllNotifications with ${monthlyPrayerTimes.length} days...');
      await _scheduleAllNotifications();
      print('🔔 _scheduleAllNotifications completed');
    } else {
      print('⚠️ No monthly prayer times available to schedule after all attempts');
      print('⚠️ Notifications will be scheduled automatically when prayer times are fetched');
    }

    print('✅ All prayer notifications enabled');
  }

  Future<void> _scheduleAllNotifications() async {
    print('🔔 _scheduleAllNotifications: Calling NotificationService...');
    await _notificationService.scheduleMonthlyPrayers(
      monthlyPrayerTimes: monthlyPrayerTimes,
      locationName: locationName.value,
    );
    print('🔔 _scheduleAllNotifications: NotificationService call completed');

    // Debug: Print all scheduled notifications
    await _notificationService.printScheduledNotifications();
  }

  Future<void> fetchPrayerTimes({DateTime? date}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get current location with better error handling
      Position? position;
      try {
        position = await _locationService.getCurrentPosition();
        currentLocation.value = position;
      } catch (e) {
        print('⚠️ Error getting current location: $e');
        // Try to use last known location
        position = await _locationService.getLastKnownPosition();
        if (position != null) {
          currentLocation.value = position;
          print('📍 Using last known location');
        } else {
          // Use previous location if available
          if (currentLocation.value != null) {
            position = currentLocation.value;
            print('📍 Using previous session location');
          } else {
            errorMessage.value =
                'Unable to get location.\nPlease enable location services and try again.';
            isLoading.value = false;
            return;
          }
        }
      }

      selectedDate.value = date ?? DateTime.now();

      // Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      isOnline.value = connectivityResult.first != ConnectivityResult.none;

      // STEP 1: Always load from database first (instant display)
      final dateStr = _formatDate(selectedDate.value);
      print('📅 Formatted date for query: $dateStr');

      final cachedTimes = await _database.getPrayerTimes(
        dateStr,
        position!.latitude,
        position.longitude,
      );

      if (cachedTimes != null) {
        // Display cached data immediately
        prayerTimes.value = cachedTimes;
        nextPrayer.value = cachedTimes.getNextPrayer();
        locationName.value = cachedTimes.location ?? 'Unknown Location';
        print('✅ Loaded prayer times from local database');
        print('   Location: ${locationName.value}');
        print('   Fajr: ${cachedTimes.fajr}');

        // Stop loading immediately - no shimmer delay for returning users
        // Data is already available from cache
        isLoading.value = false;

        // STEP 2: If online, update in background (don't block UI)
        if (isOnline.value) {
          print('🌐 Online - will sync in background');
          _syncPrayerTimesInBackground(position, selectedDate.value);
        } else {
          print('📴 Offline - using cached data only');
        }
      } else {
        print('⚠️ No cached data found for date: $dateStr');

        // No cached data - need to fetch from API
        if (isOnline.value) {
          print('📥 No cached data, fetching from API...');

          final times = await _prayerTimesService.getPrayerTimesByCoordinates(
            latitude: position.latitude,
            longitude: position.longitude,
            date: selectedDate.value,
          );

          if (times != null) {
            // Update location name
            await _updateLocationName(position);

            // Save to database
            await _database.insertPrayerTimes(
              times,
              position.latitude,
              position.longitude,
              locationName.value,
            );

            // Display the data
            prayerTimes.value = times;
            nextPrayer.value = times.getNextPrayer();
            lastSyncTime.value = DateTime.now();

            print('✅ Successfully fetched and saved to local database');
          } else {
            errorMessage.value = 'Failed to fetch prayer times. Please try again.';
            print('❌ Failed to fetch prayer times from API');
          }
        } else {
          // Offline and no cache - try to find nearest available data
          print('📴 Offline with no cached data for today');

          // Try to get any available data from database
          final anyAvailableData = await _getAnyAvailableData(position);

          if (anyAvailableData != null) {
            prayerTimes.value = anyAvailableData;
            nextPrayer.value = anyAvailableData.getNextPrayer();
            locationName.value = anyAvailableData.location ?? 'Unknown Location';
            isLoading.value = false;

            Get.snackbar(
              'Offline Mode',
              'Showing prayer times from ${anyAvailableData.date}.\nConnect to internet for today\'s times.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: const Duration(seconds: 5),
            );
            print('✅ Loaded alternative cached data from: ${anyAvailableData.date}');
          } else {
            errorMessage.value =
                'No internet connection.\n'
                'Prayer times not available offline.\n'
                'Please connect to internet.';
            print('❌ No cached data available at all');
          }
        }
      }
    } catch (e) {
      errorMessage.value = 'Error loading prayer times: ${e.toString()}';
      print('❌ Error fetching prayer times: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Background sync - updates local DB without blocking UI
  Future<void> _syncPrayerTimesInBackground(Position position, DateTime date) async {
    if (isSyncingInBackground.value) {
      print('⏳ Background sync already in progress, skipping...');
      return;
    }

    try {
      isSyncingInBackground.value = true;
      print('🔄 Starting background sync...');

      final times = await _prayerTimesService.getPrayerTimesByCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
        date: date,
      );

      if (times != null) {
        // Update location name if needed
        if (locationName.value.isEmpty || locationName.value.startsWith('Lat:')) {
          await _updateLocationName(position);
        }

        // Save to database
        await _database.insertPrayerTimes(
          times,
          position.latitude,
          position.longitude,
          locationName.value,
        );

        // Update UI with fresh data
        prayerTimes.value = times;
        nextPrayer.value = times.getNextPrayer();
        lastSyncTime.value = DateTime.now();

        print('✅ Background sync completed successfully');
      } else {
        print('⚠️ Background sync failed - keeping cached data');
      }
    } catch (e) {
      print('⚠️ Background sync error (keeping cached data): $e');
    } finally {
      isSyncingInBackground.value = false;
    }
  }

  Future<void> fetchAndCacheMonthlyPrayerTimes() async {
    if (currentLocation.value == null) return;

    try {
      // Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      isOnline.value = connectivityResult.first != ConnectivityResult.none;

      // STEP 1: Always load from database first (instant display)
      final cachedTimes = await _database.getUpcomingPrayerTimes(
        DateTime.now(),
        currentLocation.value!.latitude,
        currentLocation.value!.longitude,
      );

      if (cachedTimes.isNotEmpty) {
        monthlyPrayerTimes.value = cachedTimes;
        print('✅ Loaded ${cachedTimes.length} days from local database');

        // STEP 2: If online, update in background
        if (isOnline.value) {
          _syncMonthlyPrayerTimesInBackground();
        }
      } else if (isOnline.value) {
        // No cached data and online - fetch from API
        print('📥 No cached monthly data, fetching from API...');
        await _fetchAndSaveMonthlyPrayerTimes();
      } else {
        // No cached data and offline
        print('❌ No cached monthly data and offline');
      }
    } catch (e) {
      print('❌ Error in fetchAndCacheMonthlyPrayerTimes: $e');

      // Try to use whatever cache we have
      final fallbackTimes = await _database.getUpcomingPrayerTimes(
        DateTime.now(),
        currentLocation.value!.latitude,
        currentLocation.value!.longitude,
      );

      if (fallbackTimes.isNotEmpty) {
        monthlyPrayerTimes.value = fallbackTimes;
        print('⚠️ Using ${fallbackTimes.length} cached entries after error');
      }
    }
  }

  // Background sync for monthly prayer times
  Future<void> _syncMonthlyPrayerTimesInBackground() async {
    if (isSyncingInBackground.value) {
      print('⏳ Monthly background sync already in progress, skipping...');
      return;
    }

    try {
      isSyncingInBackground.value = true;
      print('🔄 Starting monthly background sync...');

      await _fetchAndSaveMonthlyPrayerTimes();

      print('✅ Monthly background sync completed');
    } catch (e) {
      print('⚠️ Monthly background sync error (keeping cached data): $e');
    } finally {
      isSyncingInBackground.value = false;
    }
  }

  // Fetch and save monthly prayer times to database
  Future<void> _fetchAndSaveMonthlyPrayerTimes() async {
    if (currentLocation.value == null) return;

    // Fetch current month
    final currentMonthTimes = await _prayerTimesService.getMonthlyPrayerTimes(
      latitude: currentLocation.value!.latitude,
      longitude: currentLocation.value!.longitude,
      date: selectedDate.value,
    );

    if (currentMonthTimes.isNotEmpty) {
      // Save to database
      await _database.insertMultiplePrayerTimes(
        currentMonthTimes,
        currentLocation.value!.latitude,
        currentLocation.value!.longitude,
        locationName.value,
      );

      print('✅ Saved ${currentMonthTimes.length} days for current month');

      // Fetch next month
      final nextMonth = DateTime(selectedDate.value.year, selectedDate.value.month + 1);

      final nextMonthTimes = await _prayerTimesService.getMonthlyPrayerTimes(
        latitude: currentLocation.value!.latitude,
        longitude: currentLocation.value!.longitude,
        date: nextMonth,
      );

      if (nextMonthTimes.isNotEmpty) {
        // Save to database
        await _database.insertMultiplePrayerTimes(
          nextMonthTimes,
          currentLocation.value!.latitude,
          currentLocation.value!.longitude,
          locationName.value,
        );

        print('✅ Saved ${nextMonthTimes.length} days for next month');
      }

      // Reload from database to get all data
      final allTimes = await _database.getUpcomingPrayerTimes(
        DateTime.now(),
        currentLocation.value!.latitude,
        currentLocation.value!.longitude,
      );

      monthlyPrayerTimes.value = allTimes;
      lastSyncTime.value = DateTime.now();

      // Schedule notifications if enabled
      print(
        '🔔 _fetchAndSaveMonthlyPrayerTimes: notificationsEnabled = ${notificationsEnabled.value}',
      );
      print('🔔 _fetchAndSaveMonthlyPrayerTimes: allTimes.length = ${allTimes.length}');

      if (notificationsEnabled.value && allTimes.isNotEmpty) {
        print('🔔 _fetchAndSaveMonthlyPrayerTimes: Scheduling notifications...');
        await _scheduleAllNotifications();
      } else {
        print(
          '⚠️ _fetchAndSaveMonthlyPrayerTimes: NOT scheduling - notificationsEnabled=${notificationsEnabled.value}, hasData=${allTimes.isNotEmpty}',
        );
      }

      // Clean up old data
      await _database.deleteOldPrayerTimes();

      print('✅ Total ${allTimes.length} days available in database');
    } else {
      print('⚠️ API returned empty monthly prayer times');
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
        } else if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          name = place.subAdministrativeArea!;
        } else if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
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

  /// Get any available cached data for the location (fallback when no exact date match)
  Future<PrayerTimesModel?> _getAnyAvailableData(Position position) async {
    try {
      print('🔍 Searching for any available offline data...');

      // First try: Search ±7 days from today
      final today = DateTime.now();

      // Try last 7 days
      for (int i = 0; i < 7; i++) {
        final checkDate = today.subtract(Duration(days: i));
        final dateStr = _formatDate(checkDate);

        final data = await _database.getPrayerTimes(dateStr, position.latitude, position.longitude);

        if (data != null) {
          print('✅ Found cached data from $dateStr ($i days ago)');
          return data;
        }
      }

      // Try next 7 days
      for (int i = 1; i <= 7; i++) {
        final checkDate = today.add(Duration(days: i));
        final dateStr = _formatDate(checkDate);

        final data = await _database.getPrayerTimes(dateStr, position.latitude, position.longitude);

        if (data != null) {
          print('✅ Found cached data from $dateStr ($i days ahead)');
          return data;
        }
      }

      // Second try: Get ANY available data from database (last resort)
      print('⚠️ No data within 7 days, trying ANY available data...');
      final anyData = await _database.getAnyAvailablePrayerTimes(
        position.latitude,
        position.longitude,
      );

      if (anyData != null) {
        print('✅ Found fallback data from: ${anyData.date}');
        return anyData;
      }

      // Log database status for debugging
      final cachedCount = await _database.getCachedCount();
      print('❌ No cached data found. Total entries in database: $cachedCount');

      return null;
    } catch (e) {
      print('❌ Error getting any available data: $e');
      return null;
    }
  }
}
