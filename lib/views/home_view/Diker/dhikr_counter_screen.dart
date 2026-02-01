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
    'Astaghfirullah': {
      'arabic': 'أَسْتَغْفِرُ اللَّهَ',
      'transliteration': 'Astaghfirullah',
      'meaning': 'I seek forgiveness from Allah',
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
    HapticFeedback.mediumImpact();
  }

  void resetCount() {
    count.value = 0;
    saveCount();
  }

  void selectDhikr(String dhikr) {
    selectedDhikr.value = dhikr;
    loadCount();
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

  // App Theme Colors - Matching app design
  static const Color primaryPurple = Color(0xFF8F66FF);
  static const Color lightPurple = Color(0xFFAB80FF);
  static const Color darkPurple = Color(0xFF2D1B69);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color starWhite = Color(0xFFF8F4E9);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DhikrCounterController());
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: starWhite,
      appBar: AppBar(
        backgroundColor: primaryPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Tasbih Counter',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => _showResetDialog(context, controller),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight;
          final counterSize = isSmallScreen ? 140.0 : 160.0;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: availableHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: 12),

                    // Dhikr Selection Chips
                    Obx(() => _buildDhikrSelector(controller)),

                    SizedBox(height: isSmallScreen ? 12 : 16),

                    // Arabic Text Card - Compact
                    Obx(() => _buildArabicCard(controller, isSmallScreen)),

                    SizedBox(height: isSmallScreen ? 16 : 24),

                    // Counter Button
                    Obx(() => _buildCounterButton(controller, counterSize)),

                    SizedBox(height: isSmallScreen ? 12 : 20),

                    // Target Progress - Compact
                    Obx(() => _buildTargetProgress(controller, isSmallScreen)),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDhikrSelector(DhikrCounterController controller) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: controller.dhikrList.keys.map((dhikrKey) {
        final isSelected = controller.selectedDhikr.value == dhikrKey;
        return GestureDetector(
          onTap: () => controller.selectDhikr(dhikrKey),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: isSelected ? LinearGradient(colors: [primaryPurple, darkPurple]) : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? goldAccent : primaryPurple.withOpacity(0.3),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? primaryPurple.withOpacity(0.25)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              controller.dhikrList[dhikrKey]!['transliteration']!,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildArabicCard(DhikrCounterController controller, bool isSmall) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isSmall ? 16 : 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryPurple, darkPurple],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldAccent.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            controller.currentDhikr['arabic']!,
            style: GoogleFonts.amiri(
              fontSize: isSmall ? 28 : 32,
              fontWeight: FontWeight.w700,
              color: goldAccent,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: isSmall ? 8 : 10),
          Text(
            controller.currentDhikr['transliteration']!,
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 14 : 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.currentDhikr['meaning']!,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton(DhikrCounterController controller, double size) {
    return GestureDetector(
      onTap: controller.incrementCount,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryPurple, darkPurple],
          ),
          border: Border.all(color: goldAccent, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${controller.count.value}',
                style: GoogleFonts.poppins(
                  fontSize: size * 0.3,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: goldAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, color: darkPurple, size: 12),
                    const SizedBox(width: 3),
                    Text(
                      'TAP',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: darkPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetProgress(DhikrCounterController controller, bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryPurple.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Goals label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.emoji_events_rounded, color: goldAccent, size: 18),
              const SizedBox(height: 4),
              Text(
                'Goals',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Target chips
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTargetChip(controller, 33, isSmall),
                _buildTargetChip(controller, 99, isSmall),
                _buildTargetChip(controller, 100, isSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetChip(DhikrCounterController controller, int target, bool isSmall) {
    final progress = (controller.count.value / target).clamp(0.0, 1.0);
    final isCompleted = controller.count.value >= target;

    return Container(
      width: isSmall ? 70 : 75,
      padding: EdgeInsets.symmetric(vertical: isSmall ? 8 : 10),
      decoration: BoxDecoration(
        gradient: isCompleted
            ? LinearGradient(colors: [const Color(0xFF4CAF50), const Color(0xFF66BB6A)])
            : null,
        color: isCompleted ? null : primaryPurple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? const Color(0xFF4CAF50) : primaryPurple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: isSmall ? 32 : 36,
                height: isSmall ? 32 : 36,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.white : primaryPurple,
                  ),
                  strokeWidth: 3,
                ),
              ),
              Icon(
                isCompleted ? Icons.check : Icons.flag,
                color: isCompleted ? Colors.white : primaryPurple,
                size: isSmall ? 14 : 16,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$target',
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 13 : 14,
              fontWeight: FontWeight.w700,
              color: isCompleted ? Colors.white : primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, DhikrCounterController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.refresh_rounded, color: primaryPurple, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Reset Counter?',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          'This will reset ${controller.currentDhikr['transliteration']} counter to 0.',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.resetCount();
              Get.back();
              Get.snackbar(
                'Reset Complete',
                'Counter has been reset to 0',
                backgroundColor: primaryPurple,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Reset',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
