import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quran_model.dart';

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
}
