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
  Color get moonWhite => const Color(0xFFF8F4E9);
  Color get darkBg => const Color(0xFF1A1A2E);
  Color get cardBg => const Color(0xFF2A2A3E);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DhikrCounterController());

    return Scaffold(
      backgroundColor: darkBg,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [darkPurple, primary.withOpacity(0.3), darkBg],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced App Bar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primary.withOpacity(0.3), Colors.transparent]),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: moonWhite.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: goldAccent.withOpacity(0.3), width: 1.5),
                        ),
                        child: Icon(Icons.arrow_back_rounded, color: moonWhite, size: 22),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dhikr Counter',
                            style: GoogleFonts.cinzel(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: moonWhite,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Remember Allah',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: moonWhite.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showResetDialog(controller),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [goldAccent.withOpacity(0.3), goldAccent.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: goldAccent.withOpacity(0.5), width: 1.5),
                        ),
                        child: Icon(Icons.refresh_rounded, color: goldAccent, size: 22),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Main Counter Area with enhanced design
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: darkBg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    border: Border(top: BorderSide(color: goldAccent.withOpacity(0.3), width: 2)),
                  ),
                  child: Obx(
                    () => SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Dhikr Selection Section with enhanced design
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [goldAccent.withOpacity(0.2), Colors.transparent],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.menu_book_rounded, color: goldAccent, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Select Dhikr',
                                style: GoogleFonts.cinzel(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: moonWhite,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: controller.dhikrList.keys.map((dhikrKey) {
                              final isSelected = controller.selectedDhikr.value == dhikrKey;
                              return GestureDetector(
                                onTap: () => controller.selectDhikr(dhikrKey),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: [primary, primary.withOpacity(0.7)],
                                          )
                                        : null,
                                    color: isSelected ? null : cardBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? goldAccent : primary.withOpacity(0.3),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: primary.withOpacity(0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    controller.dhikrList[dhikrKey]!['transliteration']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? moonWhite : moonWhite.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 32),

                          // Enhanced Arabic Text Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [primary.withOpacity(0.2), darkPurple.withOpacity(0.3)],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: goldAccent.withOpacity(0.4), width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Decorative top line
                                Container(
                                  height: 2,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.transparent, goldAccent, Colors.transparent],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  controller.currentDhikr['arabic']!,
                                  style: GoogleFonts.amiri(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w700,
                                    color: goldAccent,
                                    height: 1.6,
                                    shadows: [
                                      Shadow(color: goldAccent.withOpacity(0.3), blurRadius: 10),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: moonWhite.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    controller.currentDhikr['transliteration']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: moonWhite,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  controller.currentDhikr['meaning']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: moonWhite.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 14),
                                // Decorative bottom line
                                Container(
                                  height: 2,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.transparent, goldAccent, Colors.transparent],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Enhanced Counter Display with Beautiful Tap Button
                          GestureDetector(
                            onTap: controller.incrementCount,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [goldAccent, goldAccent.withOpacity(0.8), primary],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: goldAccent.withOpacity(0.4),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                    spreadRadius: 5,
                                  ),
                                  BoxShadow(
                                    color: primary.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, -5),
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(colors: [darkBg, cardBg]),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: goldAccent.withOpacity(0.3), width: 2),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${controller.count.value}',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 56,
                                          fontWeight: FontWeight.bold,
                                          foreground: Paint()
                                            ..shader = LinearGradient(
                                              colors: [goldAccent, moonWhite, goldAccent],
                                            ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                                          shadows: [
                                            Shadow(
                                              color: goldAccent.withOpacity(0.5),
                                              blurRadius: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [goldAccent, goldAccent.withOpacity(0.8)],
                                          ),
                                          borderRadius: BorderRadius.circular(18),
                                          boxShadow: [
                                            BoxShadow(
                                              color: goldAccent.withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.touch_app_rounded,
                                              color: darkPurple,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'TAP HERE',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: darkPurple,
                                                letterSpacing: 1.2,
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

                          const SizedBox(height: 32),

                          // Enhanced Target Section
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [goldAccent.withOpacity(0.2), Colors.transparent],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.flag_rounded, color: goldAccent, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Targets',
                                style: GoogleFonts.cinzel(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: moonWhite,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
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
          gradient: isCompleted
              ? LinearGradient(
                  colors: [
                    const Color(0xFF4CAF50).withOpacity(0.3),
                    const Color(0xFF66BB6A).withOpacity(0.2),
                  ],
                )
              : LinearGradient(colors: [cardBg, darkPurple.withOpacity(0.5)]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCompleted ? const Color(0xFF4CAF50) : primary.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
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
                    backgroundColor: moonWhite.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? const Color(0xFF4CAF50) : goldAccent,
                    ),
                    strokeWidth: 5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF4CAF50).withOpacity(0.2)
                        : goldAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle_rounded : Icons.flag_rounded,
                    color: isCompleted ? const Color(0xFF4CAF50) : goldAccent,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$target',
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isCompleted ? const Color(0xFF4CAF50) : goldAccent,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              isCompleted ? 'Done!' : 'Goal',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isCompleted ? const Color(0xFF4CAF50) : moonWhite.withOpacity(0.6),
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
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: goldAccent.withOpacity(0.3), width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [goldAccent.withOpacity(0.3), goldAccent.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(Icons.refresh_rounded, color: goldAccent, size: 22),
            ),
            const SizedBox(width: 11),
            Text(
              'Reset Counter',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: moonWhite,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to reset the counter for ${controller.currentDhikr['transliteration']}?',
          style: GoogleFonts.poppins(fontSize: 13, color: moonWhite.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: moonWhite.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [goldAccent, goldAccent.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(11),
              boxShadow: [
                BoxShadow(
                  color: goldAccent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                controller.resetCount();
                Get.back();
                Get.snackbar(
                  'Reset Complete',
                  'Counter has been reset to 0',
                  backgroundColor: cardBg,
                  colorText: moonWhite,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(14),
                  borderRadius: 11,
                  borderColor: goldAccent.withOpacity(0.5),
                  borderWidth: 2,
                  icon: Icon(Icons.check_circle, color: goldAccent, size: 20),
                  titleText: Text(
                    'Reset Complete',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: moonWhite,
                    ),
                  ),
                  messageText: Text(
                    'Counter has been reset to 0',
                    style: GoogleFonts.poppins(fontSize: 12, color: moonWhite.withOpacity(0.8)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              ),
              child: Text(
                'Reset',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: darkPurple,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
