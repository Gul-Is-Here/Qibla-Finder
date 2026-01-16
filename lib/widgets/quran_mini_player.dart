import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/quran_controller/quran_controller.dart';

/// A mini player widget that shows when Quran audio is playing
/// Displays at the bottom of screens when user navigates away from Quran
class QuranMiniPlayer extends StatelessWidget {
  final VoidCallback? onTap;

  const QuranMiniPlayer({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Check if QuranController exists
    if (!Get.isRegistered<QuranController>()) {
      return const SizedBox.shrink();
    }

    final controller = Get.find<QuranController>();

    return Obx(() {
      // Only show if audio is playing or paused with data
      final isVisible =
          controller.isPlaying.value ||
          (controller.currentQuranData.value != null && controller.currentAyahIndex.value > 0);

      if (!isVisible || controller.currentQuranData.value == null) {
        return const SizedBox.shrink();
      }

      final quranData = controller.currentQuranData.value!;
      final currentAyah = controller.currentAyahIndex.value + 1;
      final totalAyahs = quranData.surah.numberOfAyahs;
      final progress = controller.audioProgress.value;

      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2D1B69), Color(0xFF4A2C8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2D1B69).withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Progress bar at top
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFAB80FF)),
                  minHeight: 3,
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      // Quran icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.menu_book, color: Color(0xFFAB80FF), size: 24),
                      ),
                      const SizedBox(width: 12),
                      // Title and subtitle
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quranData.surah.englishName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Ayah $currentAyah of $totalAyahs',
                              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Control buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Previous button
                          _MiniPlayerButton(
                            icon: Icons.skip_previous,
                            onPressed: controller.playPreviousAyah,
                          ),
                          const SizedBox(width: 4),
                          // Play/Pause button
                          Obx(
                            () => _MiniPlayerButton(
                              icon: controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                              onPressed: controller.togglePlayPause,
                              isMain: true,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Next button
                          _MiniPlayerButton(
                            icon: Icons.skip_next,
                            onPressed: controller.playNextAyah,
                          ),
                          const SizedBox(width: 4),
                          // Close button
                          _MiniPlayerButton(
                            icon: Icons.close,
                            onPressed: controller.stopAudio,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _MiniPlayerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isMain;
  final double size;

  const _MiniPlayerButton({
    required this.icon,
    required this.onPressed,
    this.isMain = false,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: isMain ? 36 : 32,
          height: isMain ? 36 : 32,
          decoration: BoxDecoration(
            color: isMain ? const Color(0xFFAB80FF) : Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: isMain ? 24 : size),
        ),
      ),
    );
  }
}
