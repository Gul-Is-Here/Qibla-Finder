import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer loading widgets for various screens
class ShimmerLoadingWidgets {
  /// Purple Theme Shimmer colors (matching app theme)
  static const Color baseColor = Color(0xFFE8E4F3); // Light purple background
  static const Color highlightColor = Color(0xFFF5F0FF); // Very light purple highlight
  static const Color purpleAccent = Color(0xFF8F66FF); // Main purple for accents
  static const Color darkPurple = Color(0xFF2D1B69); // Dark purple

  /// Shimmer for Prayer Times Screen - Modern Design
  static Widget prayerTimesShimmer() {
    return Container(
      color: const Color(0xFFF5F3FF),
      child: Column(
        children: [
          // Header Shimmer (matching the purple header)
          _modernHeaderShimmer(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Next Prayer Top Card Shimmer
                  _modernNextPrayerCardShimmer(),

                  const SizedBox(height: 20),

                  // Prayer Times Horizontal Card Shimmer
                  _prayerTimesHeaderShimmer(),
                  const SizedBox(height: 12),
                  _horizontalPrayerTimesShimmer(),

                  const SizedBox(height: 24),

                  // Daily Verse Card Shimmer
                  _dailyVerseShimmer(),

                  const SizedBox(height: 24),

                  // Quick Actions Shimmer
                  _quickActionsShimmer(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Modern Header Shimmer matching the purple gradient header
  static Widget _modernHeaderShimmer() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [purpleAccent, purpleAccent, darkPurple],
          stops: [0.0, 0.3, 1.0],
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.white.withOpacity(0.15),
        highlightColor: Colors.white.withOpacity(0.4),
        child: Row(
          children: [
            // Mosque icon placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            // Location text placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 12,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
            // Notification icon placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Modern Next Prayer Card Shimmer
  static Widget _modernNextPrayerCardShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [purpleAccent.withOpacity(0.9), darkPurple.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5), width: 2),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sunrise/Sunset row
              Row(
                children: [
                  Expanded(child: _sunTimeShimmerItem()),
                  const SizedBox(width: 12),
                  Expanded(child: _sunTimeShimmerItem()),
                ],
              ),
              const SizedBox(height: 20),
              // Next prayer name
              Container(
                height: 28,
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 10),
              // Time row
              Row(
                children: [
                  Container(
                    height: 24,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const Spacer(),
                  // Remaining time
                  Column(
                    children: [
                      Container(
                        height: 10,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 14,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Share and View Times links
              Row(
                children: [
                  Container(
                    height: 16,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    height: 16,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _sunTimeShimmerItem() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 10,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 14,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Prayer Times Header Shimmer
  static Widget _prayerTimesHeaderShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          height: 14,
          width: 100,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }

  /// Horizontal Prayer Times Card Shimmer
  static Widget _horizontalPrayerTimesShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              purpleAccent.withOpacity(0.9),
              darkPurple.withOpacity(0.85),
              const Color(0xFF9F70FF).withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFAB80FF).withOpacity(0.4), width: 1.5),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) => _prayerDotShimmer()),
          ),
        ),
      ),
    );
  }

  static Widget _prayerDotShimmer() {
    return Column(
      children: [
        // Dot
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
        ),
        const SizedBox(height: 8),
        // Name
        Container(
          height: 12,
          width: 40,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(height: 6),
        // Time
        Container(
          height: 10,
          width: 50,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
        ),
      ],
    );
  }

  /// Daily Verse Shimmer
  static Widget _dailyVerseShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: purpleAccent.withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 14,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Arabic text
              Container(
                height: 24,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 12),
              // Translation
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 16,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 10),
              // Reference
              Container(
                height: 12,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Quick Actions Shimmer
  static Widget _quickActionsShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 16,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Grid of cards
          Row(
            children: [
              Expanded(child: _quickActionCardShimmer()),
              const SizedBox(width: 10),
              Expanded(child: _quickActionCardShimmer()),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _quickActionCardShimmer()),
              const SizedBox(width: 10),
              Expanded(child: _quickActionCardShimmer()),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _quickActionCardShimmer() {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            // Text
            Expanded(
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Arrow
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== OLD SHIMMER METHODS (kept for backward compatibility) ==========

  /// Next Prayer Card Shimmer (legacy)
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

  /// Date Navigator Shimmer (legacy)
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

  /// Prayer Tile Shimmer (legacy)
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
