import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/quran_model/quran_model.dart';

/// Service to fetch Quran data from Alquran Cloud API
/// API Documentation: https://alquran.cloud/api
class QuranService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';

  /// Get list of all surahs
  Future<List<Surah>> getAllSurahs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/surah'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['status'] == 'OK') {
          final List<dynamic> surahs = data['data'];
          return surahs.map((surah) => Surah.fromJson(surah)).toList();
        }
      }
      throw Exception('Failed to load surahs');
    } catch (e) {
      print('Error fetching surahs: $e');
      rethrow;
    }
  }

  /// Get a specific surah with Arabic text
  Future<QuranData> getSurah(int surahNumber) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/surah/$surahNumber'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['status'] == 'OK') {
          return QuranData.fromJson(data['data']);
        }
      }
      throw Exception('Failed to load surah');
    } catch (e) {
      print('Error fetching surah: $e');
      rethrow;
    }
  }

  /// Get surah with translation
  Future<QuranData> getSurahWithTranslation(
    int surahNumber, {
    String translationEdition = 'en.sahih', // English - Sahih International
  }) async {
    try {
      // Get Arabic text
      final arabicResponse = await http.get(Uri.parse('$baseUrl/surah/$surahNumber'));

      // Get translation
      final translationResponse = await http.get(
        Uri.parse('$baseUrl/surah/$surahNumber/$translationEdition'),
      );

      if (arabicResponse.statusCode == 200 && translationResponse.statusCode == 200) {
        final arabicData = json.decode(arabicResponse.body);
        final translationData = json.decode(translationResponse.body);

        if (arabicData['code'] == 200 && translationData['code'] == 200) {
          final surah = Surah.fromJson(arabicData['data']);
          final arabicAyahs = arabicData['data']['ayahs'] as List;
          final translationAyahs = translationData['data']['ayahs'] as List;

          // Merge Arabic text with translation
          List<Ayah> ayahs = [];
          for (int i = 0; i < arabicAyahs.length; i++) {
            final ayahData = arabicAyahs[i];
            ayahData['translation'] = translationAyahs[i]['text'];
            ayahs.add(Ayah.fromJson(ayahData));
          }

          return QuranData(surah: surah, ayahs: ayahs);
        }
      }
      throw Exception('Failed to load surah with translation');
    } catch (e) {
      print('Error fetching surah with translation: $e');
      rethrow;
    }
  }

  /// Get audio for specific ayah
  /// Returns audio URL from different reciters
  String getAyahAudio(
    int surahNumber,
    int ayahNumber, {
    String reciter = 'ar.alafasy', // Mishary Rashid Alafasy (default)
  }) {
    // Format: https://cdn.islamic.network/quran/audio/128/{reciter}/{ayahNumber}.mp3
    final ayahGlobalNumber = _getGlobalAyahNumber(surahNumber, ayahNumber);
    return 'https://cdn.islamic.network/quran/audio/128/$reciter/$ayahGlobalNumber.mp3';
  }

  /// Get continuous audio for entire surah
  List<String> getSurahAudio(int surahNumber, int numberOfAyahs, {String reciter = 'ar.alafasy'}) {
    List<String> audioUrls = [];
    for (int i = 1; i <= numberOfAyahs; i++) {
      audioUrls.add(getAyahAudio(surahNumber, i, reciter: reciter));
    }
    return audioUrls;
  }

  /// Calculate global ayah number (needed for audio)
  int _getGlobalAyahNumber(int surahNumber, int ayahNumberInSurah) {
    // Number of ayahs before this surah
    final ayahsBeforeSurah = [
      0, 7, 293, 493, 669, 789, 954, 1160, 1235, 1364, // 1-10
      1473, 1596, 1707, 1750, 1802, 1901, 2029, 2140, 2250, 2348, // 11-20
      2483, 2595, 2673, 2791, 2855, 2932, 3159, 3252, 3340, 3409, // 21-30
      3469, 3503, 3533, 3606, 3660, 3705, 3788, 3970, 4058, 4133, // 31-40
      4272, 4325, 4414, 4473, 4510, 4545, 4583, 4612, 4630, 4675, // 41-50
      4735, 4784, 4846, 4901, 4979, 5075, 5104, 5126, 5150, 5163, // 51-60
      5177, 5188, 5199, 5217, 5229, 5241, 5271, 5323, 5375, 5419, // 61-70
      5447, 5475, 5495, 5551, 5591, 5622, 5672, 5712, 5758, 5800, // 71-80
      5829, 5848, 5884, 5910, 5931, 5948, 5965, 5993, 6023, 6043, // 81-90
      6058, 6079, 6090, 6098, 6106, 6125, 6133, 6144, 6152, 6163, // 91-100
      6176, 6185, 6193, 6229, 6237, 6243, 6248, 6252, 6258, // 101-109
      6263, 6270, 6277, 6282, 6287, // 110-114
    ];

    if (surahNumber > 0 && surahNumber <= 114) {
      return ayahsBeforeSurah[surahNumber - 1] + ayahNumberInSurah;
    }
    return 0;
  }

  /// Get list of popular reciters
  List<Map<String, String>> getReciters() {
    return [
      {'id': 'ar.alafasy', 'name': 'Mishary Rashid Alafasy'},
      {'id': 'ar.abdulbasitmurattal', 'name': 'Abdul Basit (Murattal)'},
      {'id': 'ar.abdurrahmaansudais', 'name': 'Abdurrahman As-Sudais'},
      {'id': 'ar.shaatree', 'name': 'Abu Bakr Ash-Shaatree'},
      {'id': 'ar.husary', 'name': 'Mahmoud Khalil Al-Hussary'},
      {'id': 'ar.minshawi', 'name': 'Mohamed Siddiq Al-Minshawi'},
      {'id': 'ar.muhammadayyoub', 'name': 'Muhammad Ayyub'},
      {'id': 'ar.muhammadjibreel', 'name': 'Muhammad Jibreel'},
    ];
  }

  /// Get list of available translations
  List<Map<String, String>> getTranslations() {
    return [
      {'id': 'en.sahih', 'name': 'Sahih International'},
      {'id': 'en.pickthall', 'name': 'Mohammed Marmaduke Pickthall'},
      {'id': 'en.yusufali', 'name': 'Abdullah Yusuf Ali'},
      {'id': 'en.hilali', 'name': 'Hilali & Khan'},
      {'id': 'ur.ahmedali', 'name': 'Urdu - Ahmed Ali'},
      {'id': 'ur.jalandhry', 'name': 'Urdu - Fateh Muhammad Jalandhry'},
    ];
  }

  /// Get Juz (Para) data - There are 30 Juz in the Quran
  Future<List<Map<String, dynamic>>> getAllJuz() async {
    // Juz information with starting surah and ayah
    final juzData = [
      {'number': 1, 'startSurah': 1, 'startAyah': 1, 'endSurah': 2, 'endAyah': 141},
      {'number': 2, 'startSurah': 2, 'startAyah': 142, 'endSurah': 2, 'endAyah': 252},
      {'number': 3, 'startSurah': 2, 'startAyah': 253, 'endSurah': 3, 'endAyah': 92},
      {'number': 4, 'startSurah': 3, 'startAyah': 93, 'endSurah': 4, 'endAyah': 23},
      {'number': 5, 'startSurah': 4, 'startAyah': 24, 'endSurah': 4, 'endAyah': 147},
      {'number': 6, 'startSurah': 4, 'startAyah': 148, 'endSurah': 5, 'endAyah': 81},
      {'number': 7, 'startSurah': 5, 'startAyah': 82, 'endSurah': 6, 'endAyah': 110},
      {'number': 8, 'startSurah': 6, 'startAyah': 111, 'endSurah': 7, 'endAyah': 87},
      {'number': 9, 'startSurah': 7, 'startAyah': 88, 'endSurah': 8, 'endAyah': 40},
      {'number': 10, 'startSurah': 8, 'startAyah': 41, 'endSurah': 9, 'endAyah': 92},
      {'number': 11, 'startSurah': 9, 'startAyah': 93, 'endSurah': 11, 'endAyah': 5},
      {'number': 12, 'startSurah': 11, 'startAyah': 6, 'endSurah': 12, 'endAyah': 52},
      {'number': 13, 'startSurah': 12, 'startAyah': 53, 'endSurah': 14, 'endAyah': 52},
      {'number': 14, 'startSurah': 15, 'startAyah': 1, 'endSurah': 16, 'endAyah': 128},
      {'number': 15, 'startSurah': 17, 'startAyah': 1, 'endSurah': 18, 'endAyah': 74},
      {'number': 16, 'startSurah': 18, 'startAyah': 75, 'endSurah': 20, 'endAyah': 135},
      {'number': 17, 'startSurah': 21, 'startAyah': 1, 'endSurah': 22, 'endAyah': 78},
      {'number': 18, 'startSurah': 23, 'startAyah': 1, 'endSurah': 25, 'endAyah': 20},
      {'number': 19, 'startSurah': 25, 'startAyah': 21, 'endSurah': 27, 'endAyah': 55},
      {'number': 20, 'startSurah': 27, 'startAyah': 56, 'endSurah': 29, 'endAyah': 45},
      {'number': 21, 'startSurah': 29, 'startAyah': 46, 'endSurah': 33, 'endAyah': 30},
      {'number': 22, 'startSurah': 33, 'startAyah': 31, 'endSurah': 36, 'endAyah': 27},
      {'number': 23, 'startSurah': 36, 'startAyah': 28, 'endSurah': 39, 'endAyah': 31},
      {'number': 24, 'startSurah': 39, 'startAyah': 32, 'endSurah': 41, 'endAyah': 46},
      {'number': 25, 'startSurah': 41, 'startAyah': 47, 'endSurah': 45, 'endAyah': 37},
      {'number': 26, 'startSurah': 46, 'startAyah': 1, 'endSurah': 51, 'endAyah': 30},
      {'number': 27, 'startSurah': 51, 'startAyah': 31, 'endSurah': 57, 'endAyah': 29},
      {'number': 28, 'startSurah': 58, 'startAyah': 1, 'endSurah': 66, 'endAyah': 12},
      {'number': 29, 'startSurah': 67, 'startAyah': 1, 'endSurah': 77, 'endAyah': 50},
      {'number': 30, 'startSurah': 78, 'startAyah': 1, 'endSurah': 114, 'endAyah': 6},
    ];

    return juzData;
  }

  /// Get specific Juz data
  Future<Map<String, dynamic>> getJuz(int juzNumber) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/juz/$juzNumber'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['status'] == 'OK') {
          return data['data'];
        }
      }
      throw Exception('Failed to load juz');
    } catch (e) {
      print('Error fetching juz: $e');
      rethrow;
    }
  }

  /// Get Page data - There are 604 pages in the Quran
  Future<Map<String, dynamic>> getPage(int pageNumber) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/page/$pageNumber'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['status'] == 'OK') {
          return data['data'];
        }
      }
      throw Exception('Failed to load page');
    } catch (e) {
      print('Error fetching page: $e');
      rethrow;
    }
  }

  /// Get all pages list (1-604)
  List<Map<String, dynamic>> getAllPages() {
    List<Map<String, dynamic>> pages = [];
    for (int i = 1; i <= 604; i++) {
      pages.add({'number': i, 'juz': _getJuzForPage(i)});
    }
    return pages;
  }

  /// Get Juz number for a specific page
  int _getJuzForPage(int pageNumber) {
    if (pageNumber <= 21) return 1;
    if (pageNumber <= 41) return 2;
    if (pageNumber <= 61) return 3;
    if (pageNumber <= 81) return 4;
    if (pageNumber <= 101) return 5;
    if (pageNumber <= 121) return 6;
    if (pageNumber <= 141) return 7;
    if (pageNumber <= 161) return 8;
    if (pageNumber <= 181) return 9;
    if (pageNumber <= 201) return 10;
    if (pageNumber <= 221) return 11;
    if (pageNumber <= 241) return 12;
    if (pageNumber <= 261) return 13;
    if (pageNumber <= 281) return 14;
    if (pageNumber <= 301) return 15;
    if (pageNumber <= 321) return 16;
    if (pageNumber <= 341) return 17;
    if (pageNumber <= 361) return 18;
    if (pageNumber <= 381) return 19;
    if (pageNumber <= 401) return 20;
    if (pageNumber <= 421) return 21;
    if (pageNumber <= 441) return 22;
    if (pageNumber <= 461) return 23;
    if (pageNumber <= 481) return 24;
    if (pageNumber <= 501) return 25;
    if (pageNumber <= 521) return 26;
    if (pageNumber <= 541) return 27;
    if (pageNumber <= 561) return 28;
    if (pageNumber <= 581) return 29;
    return 30;
  }

  /// Get Hijb data - There are 240 Hizbs in the Quran (60 Hizbs per quarter)
  List<Map<String, dynamic>> getAllHizbs() {
    List<Map<String, dynamic>> hizbs = [];
    for (int i = 1; i <= 240; i++) {
      hizbs.add({
        'number': i,
        'juz': ((i - 1) ~/ 8) + 1, // 8 hizbs per juz
        'quarter': ((i - 1) % 8) + 1,
      });
    }
    return hizbs;
  }

  /// Get specific Hizb data
  Future<Map<String, dynamic>> getHizb(int hizbNumber) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/hizbQuarter/$hizbNumber'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['status'] == 'OK') {
          return data['data'];
        }
      }
      throw Exception('Failed to load hizb');
    } catch (e) {
      print('Error fetching hizb: $e');
      rethrow;
    }
  }
}
