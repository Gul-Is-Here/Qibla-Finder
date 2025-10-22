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
    HapticFeedback.lightImpact();
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

  Color get primary => const Color(0xFF00332F);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DhikrCounterController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: Text(
          'Dhikr Counter',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _showResetDialog(controller),
          ),
        ],
      ),
      body: Column(
        children: [
          // Dhikr Selection
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Dhikr:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.dhikrList.length,
                    itemBuilder: (context, index) {
                      final dhikrKey = controller.dhikrList.keys.elementAt(index);
                      return Obx(
                        () => GestureDetector(
                          onTap: () => controller.selectDhikr(dhikrKey),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: controller.selectedDhikr.value == dhikrKey
                                  ? primary
                                  : primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: primary, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                controller.dhikrList[dhikrKey]!['transliteration']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: controller.selectedDhikr.value == dhikrKey
                                      ? Colors.white
                                      : primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Main Counter Area
          Expanded(
            child: Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Arabic Text
                  Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Text(
                          controller.currentDhikr['arabic']!,
                          style: GoogleFonts.amiri(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: primary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          controller.currentDhikr['transliteration']!,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
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

                  // Counter Display
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: primary, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        '${controller.count.value}',
                        style: GoogleFonts.robotoMono(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Count Button
                  GestureDetector(
                    onTap: controller.incrementCount,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.touch_app, color: Colors.white, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              'TAP',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Target Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTargetIndicator(controller, 33, 'Target: 33'),
                      _buildTargetIndicator(controller, 99, 'Target: 99'),
                      _buildTargetIndicator(controller, 100, 'Target: 100'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetIndicator(DhikrCounterController controller, int target, String label) {
    return Obx(() {
      final progress = (controller.count.value / target).clamp(0.0, 1.0);
      final isCompleted = controller.count.value >= target;

      return Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.green : primary),
                  strokeWidth: 4,
                ),
              ),
              Icon(
                isCompleted ? Icons.check : Icons.flag,
                color: isCompleted ? Colors.green : primary,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isCompleted ? Colors.green : Colors.grey[600],
            ),
          ),
        ],
      );
    });
  }

  void _showResetDialog(DhikrCounterController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reset Counter',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
        ),
        content: Text(
          'Are you sure you want to reset the counter for ${controller.currentDhikr['transliteration']}?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              controller.resetCount();
              Get.back();
              Get.snackbar(
                'Reset',
                'Counter has been reset',
                backgroundColor: primary.withOpacity(0.9),
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Reset', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
