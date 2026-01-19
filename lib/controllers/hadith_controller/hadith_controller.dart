import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/hadith_model.dart';
import '../../services/hadith/hadith_service.dart';

/// Controller for managing Hadith feature
class HadithController extends GetxController {
  late HadithService _hadithService;

  // Observable states
  final dailyHadith = Rx<HadithModel?>(null);
  final currentHadith = Rx<HadithModel?>(null);
  final allHadiths = <HadithModel>[].obs;
  final favoriteHadiths = <HadithModel>[].obs;
  final isLoading = false.obs;
  final selectedChapter = 'All'.obs;
  final chapters = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initService();
  }

  Future<void> _initService() async {
    isLoading.value = true;
    try {
      // Get or initialize service
      if (Get.isRegistered<HadithService>()) {
        _hadithService = Get.find<HadithService>();
      } else {
        _hadithService = await Get.putAsync(() => HadithService().init());
      }

      // Load data
      dailyHadith.value = await _hadithService.getDailyHadith();
      currentHadith.value = dailyHadith.value;
      allHadiths.value = _hadithService.getAllHadiths();
      favoriteHadiths.value = _hadithService.getFavoriteHadiths();
      chapters.value = ['All', ..._hadithService.getAllChapters()];
    } catch (e) {
      debugPrint('Error initializing hadith controller: $e');
    }
    isLoading.value = false;
  }

  /// Get today's hadith
  Future<void> refreshDailyHadith() async {
    isLoading.value = true;
    dailyHadith.value = await _hadithService.getDailyHadith();
    currentHadith.value = dailyHadith.value;
    isLoading.value = false;
  }

  /// Get a new random hadith
  void getRandomHadith() {
    currentHadith.value = _hadithService.getRandomHadith();
  }

  /// Set current hadith to display
  void setCurrentHadith(HadithModel hadith) {
    currentHadith.value = hadith;
  }

  /// Toggle favorite status
  void toggleFavorite(int hadithId) {
    _hadithService.toggleFavorite(hadithId);
    favoriteHadiths.value = _hadithService.getFavoriteHadiths();
    // Trigger UI update
    favoriteHadiths.refresh();
    currentHadith.refresh();
  }

  /// Check if hadith is favorited
  bool isFavorite(int hadithId) => _hadithService.isFavorite(hadithId);

  /// Share hadith
  void shareHadith(HadithModel hadith) {
    final shareText =
        '''
📜 Daily Hadith

"${hadith.englishText}"

Arabic: ${hadith.arabicText}

📚 Source: ${hadith.source}
🏷️ Narrator: ${hadith.narrator}
✅ Grade: ${hadith.grade}

Shared from Muslim Pro: Quran & Prayer App
''';
    SharePlus.instance.share(ShareParams(text: shareText));
  }

  /// Filter by chapter
  void filterByChapter(String chapter) {
    selectedChapter.value = chapter;
    if (chapter == 'All') {
      allHadiths.value = _hadithService.getAllHadiths();
    } else {
      allHadiths.value = _hadithService.getHadithsByChapter(chapter);
    }
  }

  /// Get total count
  int get totalHadiths => _hadithService.hadithCount;

  /// Get favorite count
  int get favoriteCount => favoriteHadiths.length;
}
