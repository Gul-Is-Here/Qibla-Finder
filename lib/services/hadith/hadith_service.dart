import 'dart:math';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../models/hadith_model.dart';

/// Service to manage Hadiths - provides daily hadith and random hadiths
/// Uses local data for offline support (no API needed)
class HadithService extends GetxService {
  final _storage = GetStorage();

  // Keys for storage
  static const String _dailyHadithKey = 'daily_hadith';
  static const String _dailyHadithDateKey = 'daily_hadith_date';
  static const String _favoriteHadithsKey = 'favorite_hadiths';

  // Observable states
  final dailyHadith = Rx<HadithModel?>(null);
  final favoriteHadiths = <int>[].obs;
  final isLoading = false.obs;

  // Collection of authentic hadiths (Sahih Bukhari & Muslim)
  static final List<HadithModel> _hadithCollection = [
    HadithModel(
      id: 1,
      arabicText: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
      englishText:
          'Actions are judged by intentions, and every person will get what they intended.',
      narrator: 'Umar ibn Al-Khattab (RA)',
      source: 'Sahih Bukhari',
      grade: 'Sahih',
      chapter: 'Revelation',
    ),
    HadithModel(
      id: 2,
      arabicText:
          'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
      englishText: 'Whoever believes in Allah and the Last Day should speak good or remain silent.',
      narrator: 'Abu Hurairah (RA)',
      source: 'Sahih Bukhari & Muslim',
      grade: 'Sahih',
      chapter: 'Faith',
    ),
    HadithModel(
      id: 3,
      arabicText: 'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
      englishText:
          'None of you truly believes until he loves for his brother what he loves for himself.',
      narrator: 'Anas ibn Malik (RA)',
      source: 'Sahih Bukhari & Muslim',
      grade: 'Sahih',
      chapter: 'Faith',
    ),
    HadithModel(
      id: 4,
      arabicText: 'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
      englishText: 'A Muslim is one from whose tongue and hand other Muslims are safe.',
      narrator: 'Abdullah ibn Amr (RA)',
      source: 'Sahih Bukhari & Muslim',
      grade: 'Sahih',
      chapter: 'Faith',
    ),
    HadithModel(
      id: 5,
      arabicText: 'مَنْ صَلَّى عَلَيَّ صَلَاةً وَاحِدَةً صَلَّى اللَّهُ عَلَيْهِ عَشْرَ صَلَوَاتٍ',
      englishText:
          'Whoever sends blessings upon me once, Allah will send blessings upon him ten times.',
      narrator: 'Abu Hurairah (RA)',
      source: 'Sahih Muslim',
      grade: 'Sahih',
      chapter: 'Prayer',
    ),
    HadithModel(
      id: 6,
      arabicText: 'الطُّهُورُ شَطْرُ الإِيمَانِ',
      englishText: 'Cleanliness is half of faith.',
      narrator: 'Abu Malik Al-Ashari (RA)',
      source: 'Sahih Muslim',
      grade: 'Sahih',
      chapter: 'Purification',
    ),
    HadithModel(
      id: 7,
      arabicText: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
      englishText: 'The best among you are those who learn the Quran and teach it.',
      narrator: 'Uthman ibn Affan (RA)',
      source: 'Sahih Bukhari',
      grade: 'Sahih',
      chapter: 'Virtues of Quran',
    ),
    HadithModel(
      id: 8,
      arabicText: 'الدُّعَاءُ هُوَ الْعِبَادَةُ',
      englishText: 'Supplication (dua) is the essence of worship.',
      narrator: 'Nu\'man ibn Bashir (RA)',
      source: 'Sunan Tirmidhi',
      grade: 'Sahih',
      chapter: 'Supplication',
    ),
    HadithModel(
      id: 9,
      arabicText: 'إِنَّ اللَّهَ جَمِيلٌ يُحِبُّ الْجَمَالَ',
      englishText: 'Indeed, Allah is beautiful and He loves beauty.',
      narrator: 'Abdullah ibn Masud (RA)',
      source: 'Sahih Muslim',
      grade: 'Sahih',
      chapter: 'Faith',
    ),
    HadithModel(
      id: 10,
      arabicText: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ صَدَقَةٌ',
      englishText: 'Your smiling in the face of your brother is an act of charity.',
      narrator: 'Abu Dharr (RA)',
      source: 'Sunan Tirmidhi',
      grade: 'Sahih',
      chapter: 'Good Character',
    ),
    HadithModel(
      id: 11,
      arabicText: 'مَا مَلَأَ آدَمِيٌّ وِعَاءً شَرًّا مِنْ بَطْنٍ',
      englishText: 'No human fills a container worse than his stomach.',
      narrator: 'Miqdaam ibn Ma\'dikarib (RA)',
      source: 'Sunan Tirmidhi',
      grade: 'Sahih',
      chapter: 'Food',
    ),
    HadithModel(
      id: 12,
      arabicText:
          'الْمُؤْمِنُ الْقَوِيُّ خَيْرٌ وَأَحَبُّ إِلَى اللَّهِ مِنْ الْمُؤْمِنِ الضَّعِيفِ',
      englishText:
          'The strong believer is better and more beloved to Allah than the weak believer.',
      narrator: 'Abu Hurairah (RA)',
      source: 'Sahih Muslim',
      grade: 'Sahih',
      chapter: 'Destiny',
    ),
    HadithModel(
      id: 13,
      arabicText: 'الْكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ',
      englishText: 'A good word is charity.',
      narrator: 'Abu Hurairah (RA)',
      source: 'Sahih Bukhari & Muslim',
      grade: 'Sahih',
      chapter: 'Good Character',
    ),
    HadithModel(
      id: 14,
      arabicText: 'مَنْ لَمْ يَشْكُرِ النَّاسَ لَمْ يَشْكُرِ اللَّهَ',
      englishText: 'He who does not thank people does not thank Allah.',
      narrator: 'Abu Hurairah (RA)',
      source: 'Sunan Abu Dawud',
      grade: 'Sahih',
      chapter: 'Good Character',
    ),
    HadithModel(
      id: 15,
      arabicText: 'خَيْرُ النَّاسِ أَنْفَعُهُمْ لِلنَّاسِ',
      englishText: 'The best of people are those who are most beneficial to people.',
      narrator: 'Jabir (RA)',
      source: 'Al-Mu\'jam Al-Awsat',
      grade: 'Hasan',
      chapter: 'Good Character',
    ),
    HadithModel(
      id: 16,
      arabicText: 'اتَّقُوا النَّارَ وَلَوْ بِشِقِّ تَمْرَةٍ',
      englishText: 'Protect yourselves from the Fire, even if with half a date (in charity).',
      narrator: 'Adi ibn Hatim (RA)',
      source: 'Sahih Bukhari & Muslim',
      grade: 'Sahih',
      chapter: 'Charity',
    ),
    HadithModel(
      id: 17,
      arabicText: 'الدُّنْيَا سِجْنُ الْمُؤْمِنِ وَجَنَّةُ الْكَافِرِ',
      englishText: 'This world is a prison for the believer and a paradise for the disbeliever.',
      narrator: 'Abu Hurairah (RA)',
      source: 'Sahih Muslim',
      grade: 'Sahih',
      chapter: 'Asceticism',
    ),
    HadithModel(
      id: 18,
      arabicText: 'إِذَا أَرَادَ اللَّهُ بِعَبْدٍ خَيْرًا فَقَّهَهُ فِي الدِّينِ',
      englishText:
          'When Allah wants good for a person, He gives him understanding of the religion.',
      narrator: 'Muawiyah (RA)',
      source: 'Sahih Bukhari',
      grade: 'Sahih',
      chapter: 'Knowledge',
    ),
    HadithModel(
      id: 19,
      arabicText:
          'مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا سَهَّلَ اللَّهُ لَهُ طَرِيقًا إِلَى الْجَنَّةِ',
      englishText:
          'Whoever takes a path seeking knowledge, Allah will make easy for him a path to Paradise.',
      narrator: 'Abu Hurairah (RA)',
      source: 'Sahih Muslim',
      grade: 'Sahih',
      chapter: 'Knowledge',
    ),
    HadithModel(
      id: 20,
      arabicText: 'الْجَنَّةُ تَحْتَ أَقْدَامِ الْأُمَّهَاتِ',
      englishText: 'Paradise lies at the feet of mothers.',
      narrator: 'Anas ibn Malik (RA)',
      source: 'Sunan An-Nasai',
      grade: 'Hasan',
      chapter: 'Parents',
    ),
    HadithModel(
      id: 21,
      arabicText: 'لَا ضَرَرَ وَلَا ضِرَارَ',
      englishText: 'There should be no harm and no reciprocating harm.',
      narrator: 'Abu Said Al-Khudri (RA)',
      source: 'Ibn Majah',
      grade: 'Sahih',
      chapter: 'Transactions',
    ),
    HadithModel(
      id: 22,
      arabicText: 'بُنِيَ الْإِسْلَامُ عَلَى خَمْسٍ',
      englishText: 'Islam is built upon five pillars.',
      narrator: 'Abdullah ibn Umar (RA)',
      source: 'Sahih Bukhari & Muslim',
      grade: 'Sahih',
      chapter: 'Faith',
    ),
    HadithModel(
      id: 23,
      arabicText:
          'إِنَّ مِنْ أَحَبِّكُمْ إِلَيَّ وَأَقْرَبِكُمْ مِنِّي مَجْلِسًا يَوْمَ الْقِيَامَةِ أَحَاسِنُكُمْ أَخْلَاقًا',
      englishText:
          'The dearest to me and closest to me on the Day of Resurrection will be those of you with the best character.',
      narrator: 'Jabir (RA)',
      source: 'Sunan Tirmidhi',
      grade: 'Sahih',
      chapter: 'Good Character',
    ),
    HadithModel(
      id: 24,
      arabicText: 'الصَّبْرُ عِنْدَ الصَّدْمَةِ الْأُولَى',
      englishText: 'Patience is at the first strike of calamity.',
      narrator: 'Anas ibn Malik (RA)',
      source: 'Sahih Bukhari',
      grade: 'Sahih',
      chapter: 'Patience',
    ),
    HadithModel(
      id: 25,
      arabicText: 'أَكْمَلُ الْمُؤْمِنِينَ إِيمَانًا أَحْسَنُهُمْ خُلُقًا',
      englishText: 'The most complete of believers in faith are those with the best character.',
      narrator: 'Abu Hurairah (RA)',
      source: 'Sunan Tirmidhi',
      grade: 'Sahih',
      chapter: 'Faith',
    ),
    HadithModel(
      id: 26,
      arabicText: 'الْمُسْلِمُ أَخُو الْمُسْلِمِ لَا يَظْلِمُهُ وَلَا يَخْذُلُهُ',
      englishText:
          'A Muslim is a brother to another Muslim. He does not wrong him nor abandon him.',
      narrator: 'Abdullah ibn Umar (RA)',
      source: 'Sahih Bukhari & Muslim',
      grade: 'Sahih',
      chapter: 'Brotherhood',
    ),
    HadithModel(
      id: 27,
      arabicText:
          'مَنْ قَامَ رَمَضَانَ إِيمَانًا وَاحْتِسَابًا غُفِرَ لَهُ مَا تَقَدَّمَ مِنْ ذَنْبِهِ',
      englishText:
          'Whoever stands in prayer during Ramadan with faith and seeking reward, his previous sins will be forgiven.',
      narrator: 'Abu Hurairah (RA)',
      source: 'Sahih Bukhari & Muslim',
      grade: 'Sahih',
      chapter: 'Ramadan',
    ),
    HadithModel(
      id: 28,
      arabicText: 'صَلَاةُ الْجَمَاعَةِ تَفْضُلُ صَلَاةَ الْفَذِّ بِسَبْعٍ وَعِشْرِينَ دَرَجَةً',
      englishText: 'Prayer in congregation is twenty-seven times more virtuous than prayer alone.',
      narrator: 'Abdullah ibn Umar (RA)',
      source: 'Sahih Bukhari & Muslim',
      grade: 'Sahih',
      chapter: 'Prayer',
    ),
    HadithModel(
      id: 29,
      arabicText:
          'إِنَّ اللَّهَ لَا يَنْظُرُ إِلَى صُوَرِكُمْ وَأَمْوَالِكُمْ وَلَكِنْ يَنْظُرُ إِلَى قُلُوبِكُمْ وَأَعْمَالِكُمْ',
      englishText:
          'Allah does not look at your appearance or wealth, but He looks at your hearts and deeds.',
      narrator: 'Abu Hurairah (RA)',
      source: 'Sahih Muslim',
      grade: 'Sahih',
      chapter: 'Faith',
    ),
    HadithModel(
      id: 30,
      arabicText:
          'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ وَأَتْبِعِ السَّيِّئَةَ الْحَسَنَةَ تَمْحُهَا وَخَالِقِ النَّاسَ بِخُلُقٍ حَسَنٍ',
      englishText:
          'Fear Allah wherever you are, follow a bad deed with a good deed to erase it, and treat people with good character.',
      narrator: 'Abu Dharr (RA)',
      source: 'Sunan Tirmidhi',
      grade: 'Hasan',
      chapter: 'Good Character',
    ),
    HadithModel(
      id: 31,
      arabicText: 'مَنْ حَفِظَ مَا بَيْنَ لَحْيَيْهِ وَمَا بَيْنَ رِجْلَيْهِ دَخَلَ الْجَنَّةَ',
      englishText:
          'Whoever guards what is between his jaws (tongue) and between his legs, will enter Paradise.',
      narrator: 'Sahl ibn Sa\'d (RA)',
      source: 'Sahih Bukhari',
      grade: 'Sahih',
      chapter: 'Modesty',
    ),
    HadithModel(
      id: 32,
      arabicText:
          'الإِيمَانُ بِضْعٌ وَسَبْعُونَ شُعْبَةً أَعْلَاهَا لَا إِلَهَ إِلَّا اللَّهُ وَأَدْنَاهَا إِمَاطَةُ الْأَذَى عَنِ الطَّرِيقِ',
      englishText:
          'Faith has over seventy branches. The highest is saying La ilaha illallah, and the lowest is removing harm from the path.',
      narrator: 'Abu Hurairah (RA)',
      source: 'Sahih Muslim',
      grade: 'Sahih',
      chapter: 'Faith',
    ),
    HadithModel(
      id: 33,
      arabicText: 'كُلُّ بَنِي آدَمَ خَطَّاءٌ وَخَيْرُ الْخَطَّائِينَ التَّوَّابُونَ',
      englishText:
          'Every son of Adam makes mistakes, and the best of those who make mistakes are those who repent.',
      narrator: 'Anas ibn Malik (RA)',
      source: 'Sunan Tirmidhi',
      grade: 'Hasan',
      chapter: 'Repentance',
    ),
    HadithModel(
      id: 34,
      arabicText: 'أَفْضَلُ الصَّدَقَةِ سَقْيُ الْمَاءِ',
      englishText: 'The best charity is giving water to drink.',
      narrator: 'Sa\'d ibn Ubadah (RA)',
      source: 'Sunan Abu Dawud',
      grade: 'Sahih',
      chapter: 'Charity',
    ),
    HadithModel(
      id: 35,
      arabicText: 'الدُّعَاءُ لَا يُرَدُّ بَيْنَ الْأَذَانِ وَالْإِقَامَةِ',
      englishText: 'Supplication between the Adhan and Iqamah is not rejected.',
      narrator: 'Anas ibn Malik (RA)',
      source: 'Sunan Abu Dawud',
      grade: 'Sahih',
      chapter: 'Supplication',
    ),
    HadithModel(
      id: 36,
      arabicText:
          'مَنْ قَرَأَ آيَةَ الْكُرْسِيِّ فِي كُلِّ صَلَاةٍ مَكْتُوبَةٍ لَمْ يَمْنَعْهُ مِنْ دُخُولِ الْجَنَّةِ إِلَّا أَنْ يَمُوتَ',
      englishText:
          'Whoever recites Ayat al-Kursi after every obligatory prayer, nothing prevents him from entering Paradise except death.',
      narrator: 'Abu Umamah (RA)',
      source: 'Sunan An-Nasai',
      grade: 'Sahih',
      chapter: 'Virtues of Quran',
    ),
    HadithModel(
      id: 37,
      arabicText: 'أَقْرَبُ مَا يَكُونُ الْعَبْدُ مِنْ رَبِّهِ وَهُوَ سَاجِدٌ',
      englishText: 'The closest a servant is to his Lord is when he is prostrating.',
      narrator: 'Abu Hurairah (RA)',
      source: 'Sahih Muslim',
      grade: 'Sahih',
      chapter: 'Prayer',
    ),
    HadithModel(
      id: 38,
      arabicText:
          'ثَلَاثَةٌ لَا تُرَدُّ دَعْوَتُهُمْ الصَّائِمُ حَتَّى يُفْطِرَ وَالْإِمَامُ الْعَادِلُ وَدَعْوَةُ الْمَظْلُومِ',
      englishText:
          'Three whose supplications are not rejected: the fasting person until he breaks his fast, the just ruler, and the oppressed.',
      narrator: 'Abu Hurairah (RA)',
      source: 'Sunan Tirmidhi',
      grade: 'Hasan',
      chapter: 'Supplication',
    ),
    HadithModel(
      id: 39,
      arabicText: 'صِلَةُ الرَّحِمِ تَزِيدُ فِي الْعُمُرِ',
      englishText: 'Maintaining family ties increases one\'s lifespan.',
      narrator: 'Anas ibn Malik (RA)',
      source: 'Sahih Bukhari',
      grade: 'Sahih',
      chapter: 'Family',
    ),
    HadithModel(
      id: 40,
      arabicText:
          'مَنْ صَامَ رَمَضَانَ ثُمَّ أَتْبَعَهُ سِتًّا مِنْ شَوَّالٍ كَانَ كَصِيَامِ الدَّهْرِ',
      englishText:
          'Whoever fasts Ramadan and follows it with six days of Shawwal, it is as if he fasted the entire year.',
      narrator: 'Abu Ayyub Al-Ansari (RA)',
      source: 'Sahih Muslim',
      grade: 'Sahih',
      chapter: 'Fasting',
    ),
  ];

  /// Initialize the service and load daily hadith
  Future<HadithService> init() async {
    await _loadFavorites();
    await getDailyHadith();
    return this;
  }

  /// Get today's hadith - changes daily
  Future<HadithModel> getDailyHadith() async {
    isLoading.value = true;

    try {
      // Get stored date
      final storedDate = _storage.read<String>(_dailyHadithDateKey);
      final today = DateTime.now().toIso8601String().substring(0, 10); // YYYY-MM-DD

      // If we have a hadith for today, return it
      if (storedDate == today) {
        final storedHadith = _storage.read<Map<String, dynamic>>(_dailyHadithKey);
        if (storedHadith != null) {
          dailyHadith.value = HadithModel.fromJson(storedHadith);
          isLoading.value = false;
          return dailyHadith.value!;
        }
      }

      // Otherwise, select a new hadith for today
      // Use day of year as seed for consistent daily hadith
      final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
      final index = dayOfYear % _hadithCollection.length;

      dailyHadith.value = _hadithCollection[index];

      // Store for today
      await _storage.write(_dailyHadithKey, dailyHadith.value!.toJson());
      await _storage.write(_dailyHadithDateKey, today);

      isLoading.value = false;
      return dailyHadith.value!;
    } catch (e) {
      print('Error getting daily hadith: $e');
      // Return a default hadith if error
      dailyHadith.value = _hadithCollection[0];
      isLoading.value = false;
      return dailyHadith.value!;
    }
  }

  /// Get a random hadith
  HadithModel getRandomHadith() {
    final random = Random();
    return _hadithCollection[random.nextInt(_hadithCollection.length)];
  }

  /// Get all hadiths
  List<HadithModel> getAllHadiths() => List.unmodifiable(_hadithCollection);

  /// Get total hadith count
  int get hadithCount => _hadithCollection.length;

  /// Get hadith by ID
  HadithModel? getHadithById(int id) {
    try {
      return _hadithCollection.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Toggle favorite status for a hadith
  Future<void> toggleFavorite(int hadithId) async {
    if (favoriteHadiths.contains(hadithId)) {
      favoriteHadiths.remove(hadithId);
    } else {
      favoriteHadiths.add(hadithId);
    }
    await _saveFavorites();
  }

  /// Check if hadith is favorited
  bool isFavorite(int hadithId) => favoriteHadiths.contains(hadithId);

  /// Get all favorite hadiths
  List<HadithModel> getFavoriteHadiths() {
    return _hadithCollection.where((h) => favoriteHadiths.contains(h.id)).toList();
  }

  /// Load favorites from storage
  Future<void> _loadFavorites() async {
    final stored = _storage.read<List<dynamic>>(_favoriteHadithsKey);
    if (stored != null) {
      favoriteHadiths.value = stored.cast<int>();
    }
  }

  /// Save favorites to storage
  Future<void> _saveFavorites() async {
    await _storage.write(_favoriteHadithsKey, favoriteHadiths.toList());
  }

  /// Get hadiths by chapter
  List<HadithModel> getHadithsByChapter(String chapter) {
    return _hadithCollection
        .where((h) => h.chapter.toLowerCase() == chapter.toLowerCase())
        .toList();
  }

  /// Get all unique chapters
  List<String> getAllChapters() {
    return _hadithCollection.map((h) => h.chapter).toSet().toList()..sort();
  }
}
