import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer loading widgets for various screens
class ShimmerLoadingWidgets {
  /// Purple Theme Shimmer colors (matching app theme)
  static const Color baseColor = Color(0xFFE8E4F3); // Light purple background
  static const Color highlightColor = Color(0xFFF5F0FF); // Very light purple highlight
  static const Color purpleAccent = Color(0xFF8F66FF); // Main purple for accents

  /// Shimmer for Prayer Times Screen
  static Widget prayerTimesShimmer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Next Prayer Card Shimmer
          _nextPrayerCardShimmer(),

          const SizedBox(height: 16),

          // Date Navigator Shimmer
          _dateNavigatorShimmer(),

          const SizedBox(height: 16),

          // Prayer Tiles Shimmer (6 prayers)
          ...List.generate(6, (index) => _prayerTileShimmer()),

          const SizedBox(height: 28),
        ],
      ),
    );
  }

  /// Next Prayer Card Shimmer
  static Widget _nextPrayerCardShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          height: 200,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Next Prayer label
                Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),

                // Prayer name
                Container(
                  height: 32,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),

                // Time left
                Container(
                  height: 40,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 16),

                // Location
                Container(
                  height: 14,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Date Navigator Shimmer
  static Widget _dateNavigatorShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          height: 50,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  /// Prayer Tile Shimmer
  static Widget _prayerTileShimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          height: 85,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Icon
                Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
                const SizedBox(width: 16),

                // Prayer details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Prayer name
                      Container(
                        height: 16,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Time
                      Container(
                        height: 20,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status indicator
                Container(
                  height: 24,
                  width: 24,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shimmer for Quran Reader Screen
  static Widget quranReaderShimmer() {
    return Column(
      children: [
        // Surah Header Shimmer
        _quranHeaderShimmer(),

        // Ayahs List Shimmer
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) => _ayahTileShimmer(),
          ),
        ),

        // Audio Player Shimmer
        _audioPlayerShimmer(),
      ],
    );
  }

  /// Quran Header Shimmer
  static Widget _quranHeaderShimmer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D1B69), Color(0xFF8F66FF), Color(0xFFAB80FF)], // Purple gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.6),
        child: Column(
          children: [
            // Bismillah placeholder
            Container(
              height: 28,
              width: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 20),

            // Info chips
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 36,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 36,
                  width: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Ayah Tile Shimmer - Enhanced with purple theme
  static Widget _ayahTileShimmer() {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: purpleAccent.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: purpleAccent.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with ayah number and action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ayah number badge
                Container(
                  height: 32,
                  width: 50,
                  decoration: BoxDecoration(
                    color: purpleAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Row(
                  children: [
                    // Play button
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: purpleAccent.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Bookmark button
                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: purpleAccent.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Arabic text lines with varied widths for natural look
            _buildShimmerLine(height: 24, widthFactor: 1.0, alignment: Alignment.centerRight),
            const SizedBox(height: 10),
            _buildShimmerLine(height: 24, widthFactor: 0.85, alignment: Alignment.centerRight),
            const SizedBox(height: 10),
            _buildShimmerLine(height: 24, widthFactor: 0.75, alignment: Alignment.centerRight),

            const SizedBox(height: 16),

            // Translation text lines
            _buildShimmerLine(height: 16, widthFactor: 1.0),
            const SizedBox(height: 8),
            _buildShimmerLine(height: 16, widthFactor: 0.9),

            const SizedBox(height: 12),

            // Info tags (Juz, Ruku, etc.)
            Row(
              children: [
                Container(
                  height: 26,
                  width: 70,
                  decoration: BoxDecoration(
                    color: purpleAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 26,
                  width: 80,
                  decoration: BoxDecoration(
                    color: purpleAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 26,
                  width: 60,
                  decoration: BoxDecoration(
                    color: purpleAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build shimmer line with varying width
  static Widget _buildShimmerLine({
    required double height,
    required double widthFactor,
    Alignment alignment = Alignment.centerLeft,
  }) {
    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: height,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  /// Audio Player Shimmer - Enhanced with purple theme
  static Widget _audioPlayerShimmer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: purpleAccent.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress slider
            Container(
              height: 4,
              width: double.infinity,
              decoration: BoxDecoration(
                color: purpleAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 12),

            // Time labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 14,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  height: 14,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous button
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: purpleAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 24),
                // Play/Pause button (larger)
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: purpleAccent.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 24),
                // Next button
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: purpleAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Current ayah label
            Container(
              height: 14,
              width: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
