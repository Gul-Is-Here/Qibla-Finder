import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/ramadan_model.dart';
import '../../services/ramadan/ramadan_service.dart';
import '../prayer_controller/prayer_times_controller.dart';

class RamadanController extends GetxController {
  final RamadanService _service = RamadanService();

  // Observables
  var ramadanInfo = Rxn<RamadanInfoModel>();
  var fastingTracker = <FastingDayModel>[].obs;
  var ramadanDuas = <RamadanDuaModel>[].obs;
  var selectedTab = 0.obs;
  var isLoading = true.obs;
  var dailyTip = ''.obs;
  var suhoorTime = ''.obs;
  var iftarTime = ''.obs;

  // Get prayer controller for Suhoor/Iftar times
  PrayerTimesController? get _prayerController {
    try {
      return Get.find<PrayerTimesController>();
    } catch (_) {
      return null;
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadRamadanData();
  }

  Future<void> loadRamadanData() async {
    isLoading.value = true;
    try {
      // Load Ramadan info
      final info = _service.getRamadanInfo();
      ramadanInfo.value = info;

      // Load fasting tracker
      fastingTracker.value = _service.getFastingTracker(info.currentYear);

      // Load duas
      ramadanDuas.value = _service.getRamadanDuas();

      // Get daily tip
      dailyTip.value = _service.getDailyTip(info.currentDay);

      // Get Suhoor/Iftar times from prayer times
      _updateSuhoorIftarTimes();
    } finally {
      isLoading.value = false;
    }
  }

  void _updateSuhoorIftarTimes() {
    final prayerTimes = _prayerController?.prayerTimes.value;
    if (prayerTimes != null) {
      suhoorTime.value = _service.getSuhoorEndTime(prayerTimes.fajr);
      iftarTime.value = _service.getIftarTime(prayerTimes.maghrib);
    } else {
      suhoorTime.value = '--:--';
      iftarTime.value = '--:--';
    }
  }

  /// Toggle fasting status for a day
  Future<void> toggleFastingDay(int day) async {
    final info = ramadanInfo.value;
    if (info == null) return;

    await _service.toggleFastingDay(day, info.currentYear);
    fastingTracker.value = _service.getFastingTracker(info.currentYear);

    // Update info with new fasted count
    ramadanInfo.value = _service.getRamadanInfo();
  }

  /// Get duas by occasion
  List<RamadanDuaModel> getDuasByOccasion(String occasion) {
    return _service.getDuasByOccasion(occasion);
  }

  /// Get special nights info
  List<Map<String, dynamic>> getSpecialNights() {
    return _service.getSpecialNights();
  }

  /// Check if a day is a special night
  bool isSpecialNight(int day) {
    return _service.isSpecialNight(day);
  }

  /// Share Ramadan dua
  Future<void> shareDua(RamadanDuaModel dua) async {
    final text =
        '''
${dua.arabicText}

${dua.transliteration}

"${dua.englishText}"

📚 ${dua.reference}

🌙 Shared from Muslim Pro: Quran & Prayer
''';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// Share fasting progress
  Future<void> shareFastingProgress() async {
    final info = ramadanInfo.value;
    if (info == null) return;

    final text =
        '''
🌙 My Ramadan Progress

✅ Days Fasted: ${info.daysFasted} / ${info.totalDays}
📊 Progress: ${info.progressPercentage.toStringAsFixed(1)}%
📅 Current Day: ${info.currentDay > 0 ? 'Day ${info.currentDay}' : 'Ramadan has not started'}

May Allah accept our fasts! 🤲

Shared from Muslim Pro: Quran & Prayer
''';
    await SharePlus.instance.share(ShareParams(text: text));
  }

  /// Get countdown text
  String get countdownText {
    final info = ramadanInfo.value;
    if (info == null) return 'Loading...';

    if (info.isRamadan) {
      return 'Day ${info.currentDay} of Ramadan';
    } else if (info.daysUntilRamadan > 0) {
      return '${info.daysUntilRamadan} days until Ramadan';
    }
    return 'Ramadan has ended';
  }

  /// Get progress color based on percentage
  double get progressValue {
    final info = ramadanInfo.value;
    if (info == null) return 0;
    return info.progressPercentage / 100;
  }

  /// Refresh data
  @override
  Future<void> refresh() async {
    await loadRamadanData();
  }
}
