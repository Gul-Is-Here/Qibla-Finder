import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../models/prayer_model/prayer_times_model.dart';

class PrayerTimesService {
  static const String baseUrl = 'https://api.aladhan.com/v1';
  final storage = GetStorage();

  // HTTP client with custom settings
  static final http.Client _httpClient = http.Client();

  // Timeout duration
  static const Duration _timeout = Duration(seconds: 15);

  // Get prayer times by coordinates
  Future<PrayerTimesModel?> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final timestamp = targetDate.millisecondsSinceEpoch ~/ 1000;

      final uri = Uri.parse(
        '$baseUrl/timings/$timestamp?latitude=$latitude&longitude=$longitude&method=2',
      );

      print('Fetching prayer times from: $uri');

      final response = await _httpClient
          .get(uri)
          .timeout(
            _timeout,
            onTimeout: () {
              print('Prayer times API request timed out');
              throw TimeoutException('Request timed out after ${_timeout.inSeconds} seconds');
            },
          );

      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prayerTimes = PrayerTimesModel.fromJson(data);

        // Cache the prayer times
        await _cachePrayerTimes(prayerTimes, targetDate);

        print('Successfully fetched and cached prayer times');
        return prayerTimes;
      } else {
        print('API returned status code: ${response.statusCode}');
        return null;
      }
    } on TimeoutException catch (e) {
      print('Timeout error fetching prayer times: $e');
      // Try to get cached data
      return _getCachedPrayerTimes(date ?? DateTime.now());
    } on SocketException catch (e) {
      print('Network error fetching prayer times: $e');
      // Try to get cached data
      return _getCachedPrayerTimes(date ?? DateTime.now());
    } on HandshakeException catch (e) {
      print('SSL handshake error fetching prayer times: $e');
      // Try to get cached data
      return _getCachedPrayerTimes(date ?? DateTime.now());
    } catch (e) {
      print('Error fetching prayer times: $e');
      // Try to get cached data
      return _getCachedPrayerTimes(date ?? DateTime.now());
    }
  }

  // Get prayer times by city
  Future<PrayerTimesModel?> getPrayerTimesByCity({
    required String city,
    required String country,
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final timestamp = targetDate.millisecondsSinceEpoch ~/ 1000;

      final uri = Uri.parse(
        '$baseUrl/timingsByCity/$timestamp?city=$city&country=$country&method=2',
      );

      print('Fetching prayer times by city from: $uri');

      final response = await _httpClient
          .get(uri)
          .timeout(
            _timeout,
            onTimeout: () {
              print('City prayer times API request timed out');
              throw TimeoutException('Request timed out after ${_timeout.inSeconds} seconds');
            },
          );

      print('City response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Successfully fetched prayer times by city');
        return PrayerTimesModel.fromJson(data);
      }
      print('City API returned status code: ${response.statusCode}');
      return null;
    } on TimeoutException catch (e) {
      print('Timeout error fetching prayer times by city: $e');
      return null;
    } on SocketException catch (e) {
      print('Network error fetching prayer times by city: $e');
      return null;
    } on HandshakeException catch (e) {
      print('SSL handshake error fetching prayer times by city: $e');
      return null;
    } catch (e) {
      print('Error fetching prayer times by city: $e');
      return null;
    }
  }

  // Get monthly prayer times calendar
  Future<List<PrayerTimesModel>> getMonthlyPrayerTimes({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final uri = Uri.parse(
        '$baseUrl/calendar/${targetDate.year}/${targetDate.month}?latitude=$latitude&longitude=$longitude&method=2',
      );

      print('Fetching monthly prayer times from: $uri');

      final response = await _httpClient
          .get(uri)
          .timeout(
            _timeout,
            onTimeout: () {
              print('Monthly prayer times API request timed out');
              throw TimeoutException('Request timed out after ${_timeout.inSeconds} seconds');
            },
          );

      print('Monthly response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> timingsData = data['data'];

        final prayerTimesList = timingsData.map((item) {
          return PrayerTimesModel.fromJson({'data': item});
        }).toList();

        print('Successfully fetched ${prayerTimesList.length} days of prayer times');
        return prayerTimesList;
      }
      print('Monthly API returned status code: ${response.statusCode}');
      return [];
    } on TimeoutException catch (e) {
      print('Timeout error fetching monthly prayer times: $e');
      return [];
    } on SocketException catch (e) {
      print('Network error fetching monthly prayer times: $e');
      return [];
    } on HandshakeException catch (e) {
      print('SSL handshake error fetching monthly prayer times: $e');
      return [];
    } catch (e) {
      print('Error fetching monthly prayer times: $e');
      return [];
    }
  }

  // Cache prayer times locally
  Future<void> _cachePrayerTimes(PrayerTimesModel prayerTimes, DateTime date) async {
    final key = 'prayer_times_${date.year}_${date.month}_${date.day}';
    await storage.write(key, {
      'fajr': prayerTimes.fajr,
      'sunrise': prayerTimes.sunrise,
      'dhuhr': prayerTimes.dhuhr,
      'asr': prayerTimes.asr,
      'maghrib': prayerTimes.maghrib,
      'isha': prayerTimes.isha,
      'date': prayerTimes.date,
      'hijriDate': prayerTimes.hijriDate,
    });
  }

  // Get cached prayer times
  PrayerTimesModel? _getCachedPrayerTimes(DateTime date) {
    final key = 'prayer_times_${date.year}_${date.month}_${date.day}';
    final cached = storage.read(key);

    if (cached != null) {
      return PrayerTimesModel(
        fajr: cached['fajr'],
        sunrise: cached['sunrise'],
        dhuhr: cached['dhuhr'],
        asr: cached['asr'],
        maghrib: cached['maghrib'],
        isha: cached['isha'],
        date: cached['date'],
        hijriDate: cached['hijriDate'],
      );
    }
    return null;
  }

  // Clear cached data
  Future<void> clearCache() async {
    // Implement cache clearing logic if needed
  }
}
