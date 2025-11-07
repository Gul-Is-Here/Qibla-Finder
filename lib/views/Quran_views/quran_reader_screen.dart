import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/quran_controller/quran_controller.dart';
import '../../widgets/shimmer_widget/shimmer_loading_widgets.dart';

class QuranReaderScreen extends StatelessWidget {
  const QuranReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuranController>();
    final surahNumber = Get.arguments as int;

    // Load surah on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadSurah(surahNumber);
      // Update last read position using controller method
      controller.updateLastRead(surahNumber, 1);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ShimmerLoadingWidgets.quranReaderShimmer();
        }

        final quranData = controller.currentQuranData.value;
        if (quranData == null) {
          return const Center(child: Text('No data available'));
        }

        return SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildModernAppBar(context, quranData.surah, controller),

              // Surah Card Header
              _buildSurahCard(quranData.surah),

              // Ayahs list
              Expanded(
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: quranData.ayahs.length,
                  itemBuilder: (context, index) {
                    final ayah = quranData.ayahs[index];
                    return _buildModernAyahTile(context, ayah, index, controller);
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Modern App Bar matching the screenshot
  Widget _buildModernAppBar(BuildContext context, surah, QuranController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF7C4DFF)),
              onPressed: () => Get.back(),
            ),
          ),

          const SizedBox(width: 16),

          // Surah name
          Expanded(
            child: Text(
              surah.englishName,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7C4DFF),
              ),
            ),
          ),

          // Search button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Color(0xFF7C4DFF)),
              onPressed: () => _showSettingsBottomSheet(controller),
            ),
          ),
        ],
      ),
    );
  }

  // Modern Surah Card Header matching the screenshot
  Widget _buildSurahCard(surah) {
    final isMeccan = surah.revelationType.toLowerCase() == 'meccan';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFAB80FF), Color(0xFF8F66FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8F66FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Surah name in English
          Text(
            surah.englishName,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          // Translation
          Text(
            surah.englishNameTranslation,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white.withOpacity(0.9)),
          ),

          const SizedBox(height: 16),

          // Divider
          Container(height: 1, width: 150, color: Colors.white.withOpacity(0.3)),

          const SizedBox(height: 16),

          // Revelation type and verses count
          Text(
            '${isMeccan ? 'MECCAN' : 'MEDINAN'} • ${surah.numberOfAyahs} VERSES',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 20),

          // Bismillah in Arabic
          if (surah.number != 1 && surah.number != 9)
            Text(
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
              style: GoogleFonts.amiriQuran(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  // Modern Ayah Tile matching the screenshot
  Widget _buildModernAyahTile(BuildContext context, ayah, int index, QuranController controller) {
    return Obx(() {
      final showTranslation = controller.showTranslation.value;
      final isCurrentAyah = controller.currentAyahIndex.value == index;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isCurrentAyah
                  ? const Color(0xFF8F66FF).withOpacity(0.15)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isCurrentAyah ? 15 : 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: isCurrentAyah
              ? Border.all(color: const Color(0xFF8F66FF).withOpacity(0.3), width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top row with ayah number and action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ayah number in circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: const Color(0xFF8F66FF), shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      '${ayah.numberInSurah}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Action buttons
                Row(
                  children: [
                    // Share button
                    IconButton(
                      onPressed: () => _shareAyah(ayah, controller.currentQuranData.value!.surah),
                      icon: const Icon(Icons.share_outlined, color: Color(0xFF8F66FF)),
                      iconSize: 24,
                    ),

                    // Play button
                    IconButton(
                      onPressed: () {
                        if (isCurrentAyah && controller.isPlaying.value) {
                          controller.pauseAudio();
                        } else {
                          controller.playAyah(index);
                        }
                      },
                      icon: Icon(
                        isCurrentAyah && controller.isPlaying.value
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: const Color(0xFF8F66FF),
                      ),
                      iconSize: 32,
                    ),

                    // Bookmark button
                    IconButton(
                      onPressed: () =>
                          _toggleBookmark(ayah, controller.currentQuranData.value!.surah, context),
                      icon: const Icon(Icons.bookmark_border, color: Color(0xFF8F66FF)),
                      iconSize: 24,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Arabic text
            Text(
              ayah.text,
              style: GoogleFonts.amiriQuran(
                fontSize: 28,
                height: 2.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D1B69),
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),

            // Translation
            if (showTranslation && ayah.translation != null) ...[
              const SizedBox(height: 20),
              Text(
                ayah.translation!,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  height: 1.7,
                  color: const Color(0xFF4A4A4A),
                ),
                textAlign: TextAlign.left,
              ),
            ],
          ],
        ),
      );
    });
  }

  void _showSettingsBottomSheet(QuranController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Color(0xFF7C4DFF),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Show translation toggle
            Obx(
              () => SwitchListTile(
                title: Text(
                  'Show Translation',
                  style: GoogleFonts.poppins(color: Color(0xFF7C4DFF)),
                ),
                value: controller.showTranslation.value,
                onChanged: (_) => controller.toggleTranslation(),
                activeThumbColor: const Color(0xFF7C4DFF),
              ),
            ),

            // Auto-scroll toggle
            Obx(
              () => SwitchListTile(
                title: Text('Auto-scroll', style: GoogleFonts.poppins(color: Color(0xFF7C4DFF))),
                value: controller.autoScroll.value,
                onChanged: (_) => controller.toggleAutoScroll(),
                activeThumbColor: const Color(0xFF7C4DFF),
              ),
            ),

            const SizedBox(height: 16),

            // Reciter selection
            ListTile(
              title: Text('Reciter', style: GoogleFonts.poppins(color: Color(0xFF7C4DFF))),
              subtitle: Obx(() {
                final selected = controller.reciters.firstWhere(
                  (r) => r['id'] == controller.selectedReciter.value,
                  orElse: () => {'name': 'Select'},
                );
                return Text(
                  selected['name']!,
                  style: GoogleFonts.poppins(fontSize: 12, color: Color(0xFF7C4DFF)),
                );
              }),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF7C4DFF)),
              onTap: () => _showReciterDialog(controller),
            ),

            // Translation selection
            ListTile(
              title: Text('Translation', style: GoogleFonts.poppins()),
              subtitle: Obx(() {
                final selected = controller.translations.firstWhere(
                  (t) => t['id'] == controller.selectedTranslation.value,
                  orElse: () => {'name': 'Select'},
                );
                return Text(selected['name']!, style: GoogleFonts.poppins(fontSize: 12));
              }),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showTranslationDialog(controller),
            ),
          ],
        ),
      ),
    );
  }

  void _showReciterDialog(QuranController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Color(0xFF7C4DFF),
        title: Text('Select Reciter', style: GoogleFonts.poppins()),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.reciters.length,
            itemBuilder: (context, index) {
              final reciter = controller.reciters[index];
              return Obx(
                () => RadioListTile<String>(
                  title: Text(reciter['name']!, style: GoogleFonts.poppins()),
                  value: reciter['id']!,
                  groupValue: controller.selectedReciter.value,
                  onChanged: (value) {
                    controller.changeReciter(value!);
                    Get.back();
                  },
                  activeColor: const Color.fromARGB(255, 255, 255, 255),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showTranslationDialog(QuranController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('Select Translation', style: GoogleFonts.poppins()),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.translations.length,
            itemBuilder: (context, index) {
              final translation = controller.translations[index];
              return Obx(
                () => RadioListTile<String>(
                  title: Text(translation['name']!, style: GoogleFonts.poppins()),
                  value: translation['id']!,
                  groupValue: controller.selectedTranslation.value,
                  onChanged: (value) {
                    controller.changeTranslation(value!);
                    Get.back();
                  },
                  activeColor: const Color(0xFF7C4DFF),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Share Ayah functionality
  void _shareAyah(ayah, surah) async {
    final arabicText = ayah.text;
    final translation = ayah.translation ?? '';
    final ayahNumber = ayah.numberInSurah;
    final surahName = surah.englishName;

    final shareText =
        '''📖 Quran - $surahName (Ayah $ayahNumber)

$arabicText

$translation

Shared from Qibla Compass App 🕌''';

    try {
      await Share.share(shareText, subject: '$surahName - Ayah $ayahNumber');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share ayah',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  // Bookmark/Copy Ayah functionality
  void _toggleBookmark(ayah, surah, BuildContext context) {
    final arabicText = ayah.text;
    final translation = ayah.translation ?? '';
    final ayahNumber = ayah.numberInSurah;
    final surahName = surah.englishName;

    final ayahText =
        '''$arabicText

$translation

— $surahName, Ayah $ayahNumber''';

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: ayahText));

    // Show bottom sheet with options
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Success icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF8F66FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF8F66FF), size: 48),
            ),

            const SizedBox(height: 16),

            Text(
              'Ayah Saved!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF7C4DFF),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Copied to clipboard',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      _shareAyah(ayah, surah);
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: Text('Share', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF8F66FF),
                      side: const BorderSide(color: Color(0xFF8F66FF)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.check),
                    label: Text('Done', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8F66FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }
}
