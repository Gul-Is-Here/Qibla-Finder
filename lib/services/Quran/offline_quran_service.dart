import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/quran_model/quran_model.dart';

/// Service to load Quran data from local JSON files when offline
/// Uses assets/dist/chapters/ for Arabic text with English translation
/// Each surah is stored in a separate file for efficient loading
class OfflineQuranService {
  static OfflineQuranService? _instance;
  static OfflineQuranService get instance => _instance ??= OfflineQuranService._();

  OfflineQuranService._();

  // Cache for loaded data
  List<Map<String, dynamic>>? _surahIndex;
  final Map<int, Map<String, dynamic>> _cachedSurahs = {};
  List<Surah>? _cachedSurahList;
  bool _indexLoaded = false;

  /// Load the surah index (metadata for all 114 surahs)
  Future<void> _loadSurahIndex() async {
    if (_indexLoaded && _surahIndex != null) return;

    try {
      print('📖 Loading offline Quran index...');
      final jsonString = await rootBundle.loadString('assets/dist/chapters/index.json');
      final List<dynamic> decoded = json.decode(jsonString);
      _surahIndex = decoded.cast<Map<String, dynamic>>();
      _indexLoaded = true;
      print('✅ Offline Quran index loaded: ${_surahIndex!.length} surahs');
    } catch (e) {
      print('❌ Error loading offline Quran index: $e');
      _indexLoaded = false;
      rethrow;
    }
  }

  /// Check if offline data is available
  Future<bool> isOfflineDataAvailable() async {
    try {
      if (_indexLoaded) return true;
      await _loadSurahIndex();
      return _indexLoaded;
    } catch (e) {
      return false;
    }
  }

  /// Get list of all surahs from offline data (metadata only)
  Future<List<Surah>> getAllSurahs() async {
    if (_cachedSurahList != null) return _cachedSurahList!;

    await _loadSurahIndex();

    if (_surahIndex == null) {
      throw Exception('Offline Quran data not available');
    }

    _cachedSurahList = _surahIndex!
        .map(
          (surah) => Surah.fromJson({
            'number': surah['id'],
            'name': surah['name'],
            'englishName': surah['transliteration'],
            'englishNameTranslation': surah['transliteration'],
            'numberOfAyahs': surah['total_verses'],
            'revelationType': surah['type'],
          }),
        )
        .toList();

    return _cachedSurahList!;
  }

  /// Load a specific surah with English translation from assets/dist/chapters/en/
  Future<Map<String, dynamic>> _loadSurahData(int surahNumber) async {
    if (_cachedSurahs.containsKey(surahNumber)) {
      return _cachedSurahs[surahNumber]!;
    }

    try {
      print('📖 Loading offline surah $surahNumber...');
      final jsonString = await rootBundle.loadString('assets/dist/chapters/en/$surahNumber.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      _cachedSurahs[surahNumber] = data;
      print('✅ Surah $surahNumber loaded offline');
      return data;
    } catch (e) {
      print('❌ Error loading surah $surahNumber: $e');
      rethrow;
    }
  }

  /// Get a specific surah with Arabic text and English translation
  Future<QuranData> getSurahWithTranslation(int surahNumber) async {
    final surahData = await _loadSurahData(surahNumber);

    final surah = Surah.fromJson({
      'number': surahData['id'],
      'name': surahData['name'],
      'englishName': surahData['transliteration'],
      'englishNameTranslation': surahData['translation'] ?? surahData['transliteration'],
      'numberOfAyahs': surahData['total_verses'],
      'revelationType': surahData['type'],
    });

    final List<dynamic> versesList = surahData['verses'];
    final ayahs = versesList
        .map(
          (verse) => Ayah.fromJson({
            'number': verse['id'],
            'text': verse['text'],
            'numberInSurah': verse['id'],
            'juz': 1,
            'manzil': 1,
            'page': 1,
            'ruku': 1,
            'hizbQuarter': 1,
            'sajda': false,
            'translation': verse['translation'] ?? '',
          }),
        )
        .toList();

    return QuranData(surah: surah, ayahs: ayahs);
  }

  /// Clear cached data (useful for memory management)
  void clearCache() {
    _surahIndex = null;
    _cachedSurahs.clear();
    _cachedSurahList = null;
    _indexLoaded = false;
  }
}
