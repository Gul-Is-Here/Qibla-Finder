import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../models/prayer_times_model.dart';

class PrayerTimesService {
  static const String baseUrl = 'https://api.aladhan.com/v1';
  final storage = GetStorage();

  // Get prayer times by coordinates
  Future<PrayerTimesModel?> getPrayerTimesByCoordinates({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final timestamp = targetDate.millisecondsSinceEpoch ~/ 1000;

      final response = await http.get(
        Uri.parse('$baseUrl/timings/$timestamp?latitude=$latitude&longitude=$longitude&method=2'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prayerTimes = PrayerTimesModel.fromJson(data);

        // Cache the prayer times
        await _cachePrayerTimes(prayerTimes, targetDate);

        return prayerTimes;
      }
      return null;
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

      final response = await http.get(
        Uri.parse('$baseUrl/timingsByCity/$timestamp?city=$city&country=$country&method=2'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PrayerTimesModel.fromJson(data);
      }
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
      final response = await http.get(
        Uri.parse(
          '$baseUrl/calendar/${targetDate.year}/${targetDate.month}?latitude=$latitude&longitude=$longitude&method=2',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> timingsData = data['data'];

        return timingsData.map((item) {
          return PrayerTimesModel.fromJson({'data': item});
        }).toList();
      }
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
