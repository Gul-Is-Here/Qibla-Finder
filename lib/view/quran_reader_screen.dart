import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/quran_controller.dart';
import '../widget/shimmer_loading_widgets.dart';

class QuranReaderScreen extends StatelessWidget {
  const QuranReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuranController>();
    final surahNumber = Get.arguments as int;

    // Load surah on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadSurah(surahNumber);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(controller),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ShimmerLoadingWidgets.quranReaderShimmer();
        }

        final quranData = controller.currentQuranData.value;
        if (quranData == null) {
          return const Center(child: Text('No data available'));
        }

        return Column(
          children: [
            // Surah header
            _buildSurahHeader(quranData.surah),

            // Download progress indicator
            Obx(() {
              if (controller.isDownloadingAudio.value &&
                  controller.downloadProgress.value > 0) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: const Color(0xFF00332F).withOpacity(0.1),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                Color(0xFF00332F),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Downloading audio for offline playback...',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Text(
                            '${(controller.downloadProgress.value * 100).toInt()}%',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00332F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: controller.downloadProgress.value,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF00332F),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),

            // Ayahs list
            Expanded(
              child: ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: quranData.ayahs.length,
                itemBuilder: (context, index) {
                  final ayah = quranData.ayahs[index];
                  return _buildAyahTile(context, ayah, index, controller);
                },
              ),
            ),

            // Audio player controls
            _buildAudioPlayer(controller),
          ],
        );
      }),
    );
  }

  PreferredSizeWidget _buildAppBar(QuranController controller) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF00332F),
      title: Obx(() {
        final quranData = controller.currentQuranData.value;
        if (quranData == null) return const Text('');
        return Column(
          children: [
            Text(
              quranData.surah.name,
              style: GoogleFonts.amiriQuran(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              quranData.surah.englishName,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
            ),
          ],
        );
      }),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => _showSettingsBottomSheet(controller),
        ),
      ],
    );
  }

  Widget _buildSurahHeader(surah) {
    final isMeccan = surah.revelationType.toLowerCase() == 'meccan';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00332F),
            const Color(0xFF00332F).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Bismillah
          if (surah.number != 1 && surah.number != 9)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                style: GoogleFonts.amiriQuran(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Surah info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _infoChip(
                icon: isMeccan ? Icons.circle : Icons.location_city,
                label: surah.revelationType,
              ),
              const SizedBox(width: 12),
              _infoChip(
                icon: Icons.format_list_numbered,
                label: '${surah.numberOfAyahs} Ayahs',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahTile(
    BuildContext context,
    ayah,
    int index,
    QuranController controller,
  ) {
    return Obx(() {
      final showTranslation = controller.showTranslation.value;
      final isCurrentAyah = controller.currentAyahIndex.value == index;

      return GestureDetector(
        onTap: () => controller.playAyah(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCurrentAyah
                ? const Color(0xFF00332F).withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrentAyah
                  ? const Color(0xFF00332F)
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: isCurrentAyah
                ? [
                    BoxShadow(
                      color: const Color(0xFF00332F).withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ayah number and play button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ayah number badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrentAyah
                          ? const Color(0xFF00332F)
                          : const Color(0xFF00332F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${ayah.numberInSurah}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCurrentAyah
                            ? Colors.white
                            : const Color(0xFF00332F),
                      ),
                    ),
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
                      color: const Color(0xFF00332F),
                      size: 32,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Arabic text
              Text(
                ayah.text,
                style: GoogleFonts.amiriQuran(
                  fontSize: 26,
                  height: 2.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF00332F),
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),

              // Translation
              if (showTranslation && ayah.translation != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  ayah.translation!,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.left,
                ),
              ],

              // Ayah info (Juz, Page)
              const SizedBox(height: 12),
              Row(
                children: [
                  _ayahInfoTag('Juz ${ayah.juz}'),
                  const SizedBox(width: 8),
                  _ayahInfoTag('Page ${ayah.page}'),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _ayahInfoTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildAudioPlayer(QuranController controller) {
    return Obx(() {
      if (controller.currentQuranData.value == null) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress slider
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: controller.audioProgress.value.clamp(0.0, 1.0),
                onChanged: (value) => controller.seekTo(value),
                activeColor: const Color(0xFF00332F),
                inactiveColor: Colors.grey[300],
              ),
            ),

            // Time labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    controller.formatDuration(controller.currentDuration.value),
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    controller.formatDuration(controller.totalDuration.value),
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous ayah
                IconButton(
                  onPressed: controller.playPreviousAyah,
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 36,
                  color: const Color(0xFF00332F),
                ),

                const SizedBox(width: 20),

                // Play/Pause
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00332F),
                  ),
                  child: IconButton(
                    onPressed: controller.togglePlayPause,
                    icon: Icon(
                      controller.isPlaying.value
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    iconSize: 36,
                  ),
                ),

                const SizedBox(width: 20),

                // Next ayah
                IconButton(
                  onPressed: controller.playNextAyah,
                  icon: const Icon(Icons.skip_next),
                  iconSize: 36,
                  color: const Color(0xFF00332F),
                ),
              ],
            ),

            // Current ayah indicator
            const SizedBox(height: 8),
            Text(
              'Ayah ${controller.currentAyahIndex.value + 1} of ${controller.currentQuranData.value!.ayahs.length}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
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
                color: Color(0xFF00332F),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),

            // Show translation toggle
            Obx(
              () => SwitchListTile(
                title: Text('Show Translation', style: GoogleFonts.poppins()),
                value: controller.showTranslation.value,
                onChanged: (_) => controller.toggleTranslation(),
                activeColor: const Color(0xFF00332F),
              ),
            ),

            // Auto-scroll toggle
            Obx(
              () => SwitchListTile(
                title: Text(
                  'Auto-scroll',
                  style: GoogleFonts.poppins(color: Color(0xFF00332F)),
                ),
                value: controller.autoScroll.value,
                onChanged: (_) => controller.toggleAutoScroll(),
                activeColor: const Color(0xFF00332F),
              ),
            ),

            const SizedBox(height: 16),

            // Reciter selection
            ListTile(
              title: Text(
                'Reciter',
                style: GoogleFonts.poppins(color: Color(0xFF00332F)),
              ),
              subtitle: Obx(() {
                final selected = controller.reciters.firstWhere(
                  (r) => r['id'] == controller.selectedReciter.value,
                  orElse: () => {'name': 'Select'},
                );
                return Text(
                  selected['name']!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Color(0xFF00332F),
                  ),
                );
              }),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF00332F),
              ),
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
                return Text(
                  selected['name']!,
                  style: GoogleFonts.poppins(fontSize: 12),
                );
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
                  activeColor: const Color(0xFF00332F),
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
                  title: Text(
                    translation['name']!,
                    style: GoogleFonts.poppins(),
                  ),
                  value: translation['id']!,
                  groupValue: controller.selectedTranslation.value,
                  onChanged: (value) {
                    controller.changeTranslation(value!);
                    Get.back();
                  },
                  activeColor: const Color(0xFF00332F),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
