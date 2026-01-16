import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/quran_controller/quran_controller.dart';

/// A full audio player widget for the Quran reader screen
/// Shows playback controls, progress bar, and current ayah info
class QuranAudioPlayer extends StatelessWidget {
  const QuranAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if QuranController exists
    if (!Get.isRegistered<QuranController>()) {
      return const SizedBox.shrink();
    }

    final controller = Get.find<QuranController>();

    return Obx(() {
      // Only show if we have surah data loaded
      if (controller.currentQuranData.value == null) {
        return const SizedBox.shrink();
      }

      final quranData = controller.currentQuranData.value!;
      final currentAyah = controller.currentAyahIndex.value + 1;
      final totalAyahs = quranData.surah.numberOfAyahs;
      final isPlaying = controller.isPlaying.value;
      final progress = controller.audioProgress.value;

      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2D1B69), Color(0xFF4A2C8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D1B69).withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Progress bar with time
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  children: [
                    // Progress bar
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFFAB80FF),
                        inactiveTrackColor: Colors.white.withOpacity(0.2),
                        thumbColor: Colors.white,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: progress.clamp(0.0, 1.0),
                        onChanged: (value) {
                          controller.seekTo(value);
                        },
                      ),
                    ),

                    // Time display
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(controller.currentDuration.value),
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            _formatDuration(controller.totalDuration.value),
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Ayah info and controls
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    // Quran icon and info
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.menu_book, color: Color(0xFFAB80FF), size: 28),
                    ),
                    const SizedBox(width: 12),

                    // Surah and ayah info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quranData.surah.englishName,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Ayah $currentAyah of $totalAyahs',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    // Control buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Previous button
                        _PlayerButton(
                          icon: Icons.skip_previous_rounded,
                          onPressed: controller.playPreviousAyah,
                          size: 28,
                        ),
                        const SizedBox(width: 8),

                        // Play/Pause button (main)
                        _PlayerButton(
                          icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          onPressed: controller.togglePlayPause,
                          isMain: true,
                          size: 32,
                        ),
                        const SizedBox(width: 8),

                        // Next button
                        _PlayerButton(
                          icon: Icons.skip_next_rounded,
                          onPressed: controller.playNextAyah,
                          size: 28,
                        ),
                        const SizedBox(width: 8),

                        // Stop button
                        _PlayerButton(
                          icon: Icons.stop_rounded,
                          onPressed: controller.stopAudio,
                          size: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _PlayerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isMain;
  final double size;

  const _PlayerButton({
    required this.icon,
    required this.onPressed,
    this.isMain = false,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: isMain ? 56 : 44,
          height: isMain ? 56 : 44,
          decoration: BoxDecoration(
            color: isMain ? const Color(0xFFAB80FF) : Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }
}
