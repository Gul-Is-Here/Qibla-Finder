import 'package:get_storage/get_storage.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../models/ramadan_model.dart';

/// Service for Ramadan-related functionality
class RamadanService {
  static final RamadanService _instance = RamadanService._internal();
  factory RamadanService() => _instance;
  RamadanService._internal();

  final _storage = GetStorage();
  static const String _fastingKey = 'ramadan_fasting_tracker';
  static const String _yearKey = 'ramadan_year';

  /// Get current Ramadan info
  RamadanInfoModel getRamadanInfo() {
    final now = DateTime.now();
    final hijri = HijriCalendar.fromDate(now);
    final currentHijriYear = hijri.hYear;

    // Check if we're in Ramadan (month 9)
    final isRamadan = hijri.hMonth == 9;
    final currentDay = isRamadan ? hijri.hDay : 0;

    // Calculate days until Ramadan
    int daysUntilRamadan = 0;
    if (!isRamadan) {
      if (hijri.hMonth < 9) {
        // Before Ramadan this year
        daysUntilRamadan = _calculateDaysUntilRamadan(hijri);
      } else {
        // After Ramadan, calculate for next year
        daysUntilRamadan = _calculateDaysUntilNextRamadan(hijri);
      }
    }

    // Get fasting data
    final fastingData = getFastingTracker(currentHijriYear);
    final daysFasted = fastingData.where((d) => d.isFasted).length;

    return RamadanInfoModel(
      currentYear: currentHijriYear,
      totalDays: 30,
      currentDay: currentDay,
      isRamadan: isRamadan,
      daysUntilRamadan: daysUntilRamadan,
      daysFasted: daysFasted,
    );
  }

  int _calculateDaysUntilRamadan(HijriCalendar hijri) {
    int days = 0;
    // Days remaining in current month
    days += _getDaysInHijriMonth(hijri.hMonth, hijri.hYear) - hijri.hDay;
    // Add full months until Ramadan
    for (int m = hijri.hMonth + 1; m < 9; m++) {
      days += _getDaysInHijriMonth(m, hijri.hYear);
    }
    return days;
  }

  int _calculateDaysUntilNextRamadan(HijriCalendar hijri) {
    int days = 0;
    // Days remaining in current month
    days += _getDaysInHijriMonth(hijri.hMonth, hijri.hYear) - hijri.hDay;
    // Add remaining months of this year
    for (int m = hijri.hMonth + 1; m <= 12; m++) {
      days += _getDaysInHijriMonth(m, hijri.hYear);
    }
    // Add months of next year until Ramadan
    for (int m = 1; m < 9; m++) {
      days += _getDaysInHijriMonth(m, hijri.hYear + 1);
    }
    return days;
  }

  int _getDaysInHijriMonth(int month, int year) {
    // Hijri months alternate between 30 and 29 days
    // Odd months have 30 days, even months have 29
    // Exception: month 12 can have 30 days in leap years
    if (month % 2 == 1) return 30;
    if (month == 12 && _isHijriLeapYear(year)) return 30;
    return 29;
  }

  bool _isHijriLeapYear(int year) {
    // Hijri leap years follow a 30-year cycle
    // Years 2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29 are leap years
    final leapYears = [2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29];
    return leapYears.contains(year % 30);
  }

  /// Get fasting tracker for a specific Hijri year
  List<FastingDayModel> getFastingTracker(int hijriYear) {
    final savedYear = _storage.read<int>(_yearKey);
    if (savedYear != hijriYear) {
      // New year, reset tracker
      _storage.write(_yearKey, hijriYear);
      _storage.remove(_fastingKey);
      return _generateEmptyTracker(hijriYear);
    }

    final saved = _storage.read<List>(_fastingKey);
    if (saved == null) return _generateEmptyTracker(hijriYear);

    return saved.map((e) => FastingDayModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  List<FastingDayModel> _generateEmptyTracker(int hijriYear) {
    final tracker = <FastingDayModel>[];
    for (int day = 1; day <= 30; day++) {
      // Create approximate date (this is simplified)
      final hijriDate = '$day Ramadan $hijriYear';
      tracker.add(
        FastingDayModel(
          day: day,
          date: DateTime.now().add(Duration(days: day - 1)),
          hijriDate: hijriDate,
        ),
      );
    }
    return tracker;
  }

  /// Toggle fasting status for a day
  Future<void> toggleFastingDay(int day, int hijriYear) async {
    final tracker = getFastingTracker(hijriYear);
    final index = tracker.indexWhere((d) => d.day == day);
    if (index != -1) {
      tracker[index] = tracker[index].copyWith(isFasted: !tracker[index].isFasted);
      await _saveFastingTracker(tracker);
    }
  }

  /// Update fasting day with notes
  Future<void> updateFastingDay(int day, int hijriYear, {String? notes}) async {
    final tracker = getFastingTracker(hijriYear);
    final index = tracker.indexWhere((d) => d.day == day);
    if (index != -1) {
      tracker[index] = tracker[index].copyWith(notes: notes);
      await _saveFastingTracker(tracker);
    }
  }

  Future<void> _saveFastingTracker(List<FastingDayModel> tracker) async {
    await _storage.write(_fastingKey, tracker.map((e) => e.toJson()).toList());
  }

  /// Get Ramadan Duas
  List<RamadanDuaModel> getRamadanDuas() {
    return _ramadanDuas;
  }

  /// Get duas by occasion
  List<RamadanDuaModel> getDuasByOccasion(String occasion) {
    return _ramadanDuas.where((d) => d.occasion == occasion).toList();
  }

  /// Get Suhoor dua
  RamadanDuaModel getSuhoorDua() {
    return _ramadanDuas.firstWhere((d) => d.occasion == 'suhoor');
  }

  /// Get Iftar dua
  RamadanDuaModel getIftarDua() {
    return _ramadanDuas.firstWhere((d) => d.occasion == 'iftar');
  }

  /// Calculate Suhoor end time (same as Fajr) - formatted in AM/PM
  String getSuhoorEndTime(String fajrTime) {
    return _formatTimeToAmPm(fajrTime);
  }

  /// Calculate Iftar time (same as Maghrib) - formatted in AM/PM
  String getIftarTime(String maghribTime) {
    return _formatTimeToAmPm(maghribTime);
  }

  /// Format time string to 12-hour AM/PM format
  String _formatTimeToAmPm(String time) {
    try {
      final cleanTime = time.trim();

      // If already has AM/PM, return as is
      if (cleanTime.toLowerCase().contains('am') || cleanTime.toLowerCase().contains('pm')) {
        return cleanTime;
      }

      final parts = cleanTime.split(':');
      if (parts.length < 2) return time;

      int hour = int.parse(parts[0]);
      final minute = parts[1].split(' ')[0]; // Remove any extra text

      String period = 'AM';
      int displayHour = hour;

      if (hour == 0) {
        displayHour = 12;
        period = 'AM';
      } else if (hour == 12) {
        displayHour = 12;
        period = 'PM';
      } else if (hour > 12) {
        displayHour = hour - 12;
        period = 'PM';
      }

      return '$displayHour:$minute $period';
    } catch (e) {
      return time; // Return original if parsing fails
    }
  }

  /// Get special nights info
  List<Map<String, dynamic>> getSpecialNights() {
    return [
      {
        'name': 'Laylatul Qadr',
        'description': 'The Night of Power - Better than 1000 months',
        'nights': [21, 23, 25, 27, 29],
        'icon': '✨',
      },
      {
        'name': 'Last 10 Nights',
        'description': 'The most blessed nights of Ramadan',
        'nights': List.generate(10, (i) => 21 + i),
        'icon': '🌙',
      },
      {
        'name': 'Odd Nights',
        'description': 'Seek Laylatul Qadr in the odd nights',
        'nights': [21, 23, 25, 27, 29],
        'icon': '⭐',
      },
    ];
  }

  /// Check if today is a special night
  bool isSpecialNight(int ramadanDay) {
    return ramadanDay >= 21 && ramadanDay % 2 == 1;
  }

  /// Get daily Ramadan tip
  String getDailyTip(int day) {
    if (day <= 0 || day > 30) return _ramadanTips[0];
    return _ramadanTips[(day - 1) % _ramadanTips.length];
  }

  // Ramadan Duas Collection
  static final List<RamadanDuaModel> _ramadanDuas = [
    RamadanDuaModel(
      id: 1,
      arabicText: 'وَبِصَوْمِ غَدٍ نَّوَيْتُ مِنْ شَهْرِ رَمَضَانَ',
      englishText: 'I intend to keep the fast for tomorrow in the month of Ramadan.',
      transliteration: 'Wa bisawmi ghadinn nawaytu min shahri Ramadan',
      occasion: 'suhoor',
      reference: 'Intention for Fasting',
    ),
    RamadanDuaModel(
      id: 2,
      arabicText:
          'اللَّهُمَّ إِنِّي لَكَ صُمْتُ وَبِكَ آمَنْتُ وَعَلَيْكَ تَوَكَّلْتُ وَعَلَى رِزْقِكَ أَفْطَرْتُ',
      englishText:
          'O Allah! I fasted for You and I believe in You and I put my trust in You and I break my fast with Your sustenance.',
      transliteration:
          "Allahumma inni laka sumtu wa bika aamantu wa 'alayka tawakkaltu wa 'ala rizqika aftartu",
      occasion: 'iftar',
      reference: 'Abu Dawud',
    ),
    RamadanDuaModel(
      id: 3,
      arabicText: 'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ',
      englishText:
          'The thirst has gone, the veins are moistened, and the reward is confirmed, if Allah wills.',
      transliteration: "Dhahaba al-zama' wa abtallatil-'urooq, wa thabatal-ajru insha'Allah",
      occasion: 'iftar',
      reference: 'Abu Dawud',
    ),
    RamadanDuaModel(
      id: 4,
      arabicText: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
      englishText: 'O Allah, You are Forgiving and love forgiveness, so forgive me.',
      transliteration: "Allahumma innaka 'afuwwun tuhibbul-'afwa fa'fu 'anni",
      occasion: 'laylatul_qadr',
      reference: 'Tirmidhi',
    ),
    RamadanDuaModel(
      id: 5,
      arabicText:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      englishText:
          'Our Lord, give us in this world good and in the Hereafter good and protect us from the punishment of the Fire.',
      transliteration:
          "Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina 'adhaban-nar",
      occasion: 'general',
      reference: 'Quran 2:201',
    ),
    RamadanDuaModel(
      id: 6,
      arabicText: 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
      englishText:
          'O Allah, help me to remember You, to thank You, and to worship You in the best manner.',
      transliteration: "Allahumma a'inni 'ala dhikrika wa shukrika wa husni 'ibadatika",
      occasion: 'general',
      reference: 'Abu Dawud',
    ),
    RamadanDuaModel(
      id: 7,
      arabicText: 'اللَّهُمَّ بَارِكْ لَنَا فِي رَجَبٍ وَشَعْبَانَ وَبَلِّغْنَا رَمَضَانَ',
      englishText: 'O Allah, bless us in Rajab and Sha\'ban and let us reach Ramadan.',
      transliteration: 'Allahumma barik lana fi Rajab wa Sha\'ban wa ballighna Ramadan',
      occasion: 'before_ramadan',
      reference: 'Ahmad',
    ),
    RamadanDuaModel(
      id: 8,
      arabicText:
          'اللَّهُمَّ سَلِّمْنِي لِرَمَضَانَ وَسَلِّمْ رَمَضَانَ لِي وَسَلِّمْهُ لِي مُتَقَبَّلاً',
      englishText:
          'O Allah, safeguard me for Ramadan, safeguard Ramadan for me, and accept it from me.',
      transliteration:
          'Allahumma sallimni li-Ramadan wa sallim Ramadana li wa sallimhu li mutaqabbala',
      occasion: 'general',
      reference: 'Tabarani',
    ),
    RamadanDuaModel(
      id: 9,
      arabicText: 'اللَّهُمَّ تَقَبَّلْ مِنَّا إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ',
      englishText: 'O Allah, accept from us. Indeed, You are the All-Hearing, All-Knowing.',
      transliteration: 'Allahumma taqabbal minna innaka antas-Sami\'ul-\'Alim',
      occasion: 'general',
      reference: 'Quran 2:127',
    ),
    RamadanDuaModel(
      id: 10,
      arabicText: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْجَنَّةَ وَأَعُوذُ بِكَ مِنَ النَّارِ',
      englishText: 'O Allah, I ask You for Paradise and seek refuge in You from the Fire.',
      transliteration: "Allahumma inni as'alukal-jannata wa a'udhu bika minan-nar",
      occasion: 'general',
      reference: 'Abu Dawud',
    ),
  ];

  // Daily Ramadan Tips
  static final List<String> _ramadanTips = [
    '🌅 Wake up 15 minutes before Suhoor to pray Tahajjud',
    '📖 Read at least 1 Juz of Quran daily to complete it this Ramadan',
    '💧 Stay hydrated - drink water between Iftar and Suhoor',
    '🤲 Make dua before breaking your fast - it\'s accepted',
    '💰 Give Sadaqah daily, even if small',
    '🕌 Pray Taraweeh at the mosque for extra rewards',
    '❤️ Forgive others and seek forgiveness',
    '📵 Reduce screen time and increase worship time',
    '🍽️ Don\'t overeat at Iftar - eat moderately',
    '😴 Take a short nap after Dhuhr if needed',
    '🤝 Feed others to break their fast for extra rewards',
    '📿 Increase your Dhikr throughout the day',
    '🌙 Search for Laylatul Qadr in the last 10 nights',
    '👨‍👩‍👧‍👦 Spend quality time with family in worship',
    '📚 Learn a new Surah or Islamic knowledge',
    '🙏 Make a list of duas and pray for them daily',
    '😊 Control your anger - fasting includes behavior',
    '🌟 Do I\'tikaf in the last 10 days if possible',
    '💝 Be extra kind to parents and elders',
    '🎯 Set spiritual goals for each day',
    '⏰ Wake up for Suhoor - don\'t skip it',
    '🕋 Increase Salawat upon the Prophet ﷺ',
    '📱 Share Islamic reminders with others',
    '🍎 Eat dates and fruits at Iftar',
    '🌺 Visit the sick and elderly',
    '💭 Reflect on your actions and improve',
    '🎁 Prepare for Eid while maintaining worship',
    '📝 Keep a Ramadan journal',
    '🤲 Make dua for the Ummah',
    '✨ End Ramadan strong - last days are most blessed',
  ];
}
