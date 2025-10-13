class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;
  final String hijriDate;
  final String? location;
  final String? hijriMonth;
  final String? hijriYear;

  PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
    required this.hijriDate,
    this.location,
    this.hijriMonth,
    this.hijriYear,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    final date = json['data']['date'];
    final hijri = date['hijri'];
    final gregorian = date['gregorian'];

    return PrayerTimesModel(
      fajr: timings['Fajr'],
      sunrise: timings['Sunrise'],
      dhuhr: timings['Dhuhr'],
      asr: timings['Asr'],
      maghrib: timings['Maghrib'],
      isha: timings['Isha'],
      date:
          '${gregorian['day']} ${gregorian['month']['en']} ${gregorian['year']}',
      hijriDate: '${hijri['day']} ${hijri['month']['en']} ${hijri['year']}',
      hijriMonth: hijri['month']['en'],
      hijriYear: hijri['year'],
    );
  }

  // Factory constructor for database
  factory PrayerTimesModel.fromDatabase(Map<String, dynamic> map) {
    return PrayerTimesModel(
      fajr: map['fajr'] as String,
      sunrise: map['sunrise'] as String,
      dhuhr: map['dhuhr'] as String,
      asr: map['asr'] as String,
      maghrib: map['maghrib'] as String,
      isha: map['isha'] as String,
      date: map['date'] as String,
      hijriDate: map['hijri_date'] as String,
      location: map['location_name'] as String?,
      hijriMonth: map['hijri_month'] as String?,
      hijriYear: map['hijri_year'] as String?,
    );
  }

  Map<String, String> getAllPrayerTimes() {
    return {
      'Fajr': fajr,
      'Sunrise': sunrise,
      'Dhuhr': dhuhr,
      'Asr': asr,
      'Maghrib': maghrib,
      'Isha': isha,
    };
  }

  String getNextPrayer() {
    final now = DateTime.now();
    final prayers = {
      'Fajr': _parseTime(fajr),
      'Dhuhr': _parseTime(dhuhr),
      'Asr': _parseTime(asr),
      'Maghrib': _parseTime(maghrib),
      'Isha': _parseTime(isha),
    };

    // Find the next upcoming prayer
    for (var entry in prayers.entries) {
      if (entry.value.isAfter(now)) {
        return entry.key;
      }
    }

    // If no prayer is left today, return Fajr (next day)
    return 'Fajr';
  }

  DateTime _parseTime(String time) {
    try {
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
      print('Error parsing time in model "$time": $e');
      return DateTime.now();
    }
  }
}
