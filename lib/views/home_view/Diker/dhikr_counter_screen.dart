import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class DhikrCounterController extends GetxController {
  final RxInt count = 0.obs;
  final RxString selectedDhikr = 'SubhanAllah'.obs;
  final storage = GetStorage();

  final Map<String, Map<String, String>> dhikrList = {
    'SubhanAllah': {
      'arabic': 'سُبْحَانَ اللَّهِ',
      'transliteration': 'SubhanAllah',
      'meaning': 'Glory be to Allah',
    },
    'Alhamdulillah': {
      'arabic': 'الْحَمْدُ لِلَّهِ',
      'transliteration': 'Alhamdulillah',
      'meaning': 'All praise is due to Allah',
    },
    'AllahuAkbar': {
      'arabic': 'اللَّهُ أَكْبَرُ',
      'transliteration': 'Allahu Akbar',
      'meaning': 'Allah is the Greatest',
    },
    'LaIlahaIllallah': {
      'arabic': 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      'transliteration': 'La ilaha illallah',
      'meaning': 'There is no god but Allah',
    },
    'AstaghfirullahRabbee': {
      'arabic': 'أَسْتَغْفِرُ اللَّهَ رَبِّي',
      'transliteration': 'Astaghfirullah Rabbee',
      'meaning': 'I seek forgiveness from Allah, my Lord',
    },
  };

  @override
  void onInit() {
    super.onInit();
    loadCount();
  }

  void incrementCount() {
    count.value++;
    saveCount();
    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  void resetCount() {
    count.value = 0;
    saveCount();
  }

  void selectDhikr(String dhikr) {
    selectedDhikr.value = dhikr;
    loadCount(); // Load count for selected dhikr
  }

  void saveCount() {
    storage.write('dhikr_count_${selectedDhikr.value}', count.value);
  }

  void loadCount() {
    count.value = storage.read('dhikr_count_${selectedDhikr.value}') ?? 0;
  }

  Map<String, String> get currentDhikr => dhikrList[selectedDhikr.value]!;
}

class DhikrCounterScreen extends StatelessWidget {
  const DhikrCounterScreen({super.key});

  Color get primary => const Color(0xFF8F66FF);
  Color get lightPurple => const Color(0xFFAB80FF);
  Color get darkPurple => const Color(0xFF2D1B69);
  Color get goldAccent => const Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DhikrCounterController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primary, primary.withOpacity(0.8), Colors.white],
            stops: const [0.0, 0.3, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Dhikr Counter',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showResetDialog(controller),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.refresh_rounded, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Main Counter Area
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Obx(
                    () => SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Dhikr Selection Chips
                          Text(
                            'Select Dhikr',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: controller.dhikrList.keys.map((dhikrKey) {
                              final isSelected = controller.selectedDhikr.value == dhikrKey;
                              return GestureDetector(
                                onTap: () => controller.selectDhikr(dhikrKey),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(colors: [primary, lightPurple])
                                        : null,
                                    color: isSelected ? null : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? primary : Colors.grey[300]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    controller.dhikrList[dhikrKey]!['transliteration']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 32),

                          // Arabic Text Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [lightPurple.withOpacity(0.1), primary.withOpacity(0.05)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: primary.withOpacity(0.3), width: 1.5),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  controller.currentDhikr['arabic']!,
                                  style: GoogleFonts.amiri(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                    color: darkPurple,
                                    height: 1.8,
                                  ),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  controller.currentDhikr['transliteration']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: primary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  controller.currentDhikr['meaning']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Counter Display with Tap Button
                          GestureDetector(
                            onTap: controller.incrementCount,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [primary, lightPurple, primary],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withOpacity(0.4),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${controller.count.value}',
                                        style: GoogleFonts.robotoMono(
                                          fontSize: 56,
                                          fontWeight: FontWeight.bold,
                                          foreground: Paint()
                                            ..shader = LinearGradient(
                                              colors: [primary, lightPurple],
                                            ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(colors: [primary, lightPurple]),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.touch_app_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'TAP TO COUNT',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Target Indicators
                          Text(
                            'Targets',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTargetIndicator(controller, 33),
                              _buildTargetIndicator(controller, 99),
                              _buildTargetIndicator(controller, 100),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetIndicator(DhikrCounterController controller, int target) {
    return Obx(() {
      final progress = (controller.count.value / target).clamp(0.0, 1.0);
      final isCompleted = controller.count.value >= target;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isCompleted ? Colors.green : Colors.grey[300]!, width: 2),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : primary),
                    strokeWidth: 5,
                  ),
                ),
                Icon(
                  isCompleted ? Icons.check_circle_rounded : Icons.flag_rounded,
                  color: isCompleted ? Colors.green : primary,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$target',
              style: GoogleFonts.robotoMono(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.green : primary,
              ),
            ),
            Text(
              isCompleted ? 'Completed!' : 'Goal',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isCompleted ? Colors.green : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showResetDialog(DhikrCounterController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.refresh_rounded, color: primary, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Reset Counter',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkPurple,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to reset the counter for ${controller.currentDhikr['transliteration']}?',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [primary, lightPurple]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ElevatedButton(
              onPressed: () {
                controller.resetCount();
                Get.back();
                Get.snackbar(
                  'Reset Complete',
                  'Counter has been reset to 0',
                  backgroundColor: primary,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                  borderRadius: 12,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Reset',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
