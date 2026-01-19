import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/hadith_controller/hadith_controller.dart';
import '../../models/hadith_model.dart';
import '../../widgets/ads_widget/optimized_banner_ad.dart';

class DailyHadithScreen extends StatefulWidget {
  const DailyHadithScreen({super.key});

  @override
  State<DailyHadithScreen> createState() => _DailyHadithScreenState();
}

class _DailyHadithScreenState extends State<DailyHadithScreen> {
  late HadithController controller;

  // Simple light theme colors
  static const Color primaryPurple = Color(0xFF8F66FF);
  static const Color lightBg = Color(0xFFF5F5F7);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color accentGold = Color(0xFFE8B923);

  @override
  void initState() {
    super.initState();
    controller = Get.put(HadithController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textDark, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Daily Hadith',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_rounded, color: primaryPurple, size: 24),
            onPressed: () => Get.to(() => const AllHadithsScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: primaryPurple));
        }

        final hadith = controller.currentHadith.value;
        if (hadith == null) {
          return const Center(child: Text('No hadith available'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Today's Badge
              _buildTodayBadge(),
              const SizedBox(height: 16),

              // Main Hadith Card
              _buildHadithCard(hadith),
              const SizedBox(height: 16),

              // Action Buttons
              _buildActionButtons(hadith),
              const SizedBox(height: 16),

              // Ad Banner
              const OptimizedBannerAdWidget(padding: EdgeInsets.zero),
              const SizedBox(height: 16),

              // Quick Stats
              // _buildQuickStats(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTodayBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: accentGold.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: accentGold, size: 16),
          const SizedBox(width: 6),
          Text(
            "Today's Hadith",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: accentGold.withOpacity(0.9),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildHadithCard(HadithModel hadith) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Arabic Text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              hadith.arabicText,
              style: GoogleFonts.amiri(
                fontSize: 22,
                color: textDark,
                fontWeight: FontWeight.w600,
                height: 1.8,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),

          const SizedBox(height: 16),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.format_quote, color: primaryPurple, size: 20),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),

          const SizedBox(height: 16),

          // English Translation
          Text(
            hadith.englishText,
            style: GoogleFonts.poppins(fontSize: 15, color: textDark, height: 1.6),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Narrator & Source
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, size: 16, color: textGrey),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    hadith.narrator,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: textGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Source & Grade Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildInfoChip(Icons.book_outlined, hadith.source),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.verified_outlined, hadith.grade),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: primaryPurple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryPurple),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: primaryPurple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(HadithModel hadith) {
    return Row(
      children: [
        // Save Button
        Expanded(
          child: Obx(
            () => _buildActionButton(
              icon: controller.isFavorite(hadith.id) ? Icons.favorite : Icons.favorite_outline,
              label: 'Save',
              color: controller.isFavorite(hadith.id) ? Colors.red : primaryPurple,
              bgColor: controller.isFavorite(hadith.id)
                  ? Colors.red.withOpacity(0.1)
                  : primaryPurple.withOpacity(0.1),
              onTap: () => controller.toggleFavorite(hadith.id),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Share Button
        Expanded(
          child: _buildActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            color: primaryPurple,
            bgColor: primaryPurple.withOpacity(0.1),
            onTap: () => controller.shareHadith(hadith),
          ),
        ),
        const SizedBox(width: 12),

        // Random Button
        Expanded(
          child: _buildActionButton(
            icon: Icons.shuffle_rounded,
            label: 'Random',
            color: accentGold,
            bgColor: accentGold.withOpacity(0.1),
            onTap: () => controller.getRandomHadith(),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.menu_book_rounded, '${controller.totalHadiths}', 'Total'),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatItem(Icons.favorite_rounded, '${controller.favoriteCount}', 'Saved'),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatItem(Icons.category_rounded, '${controller.chapters.length - 1}', 'Topics'),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: primaryPurple, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: textDark),
        ),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: textGrey)),
      ],
    );
  }
}

// ==================== All Hadiths Screen ====================

class AllHadithsScreen extends StatelessWidget {
  const AllHadithsScreen({super.key});

  static const Color primaryPurple = Color(0xFF8F66FF);
  static const Color lightBg = Color(0xFFF5F5F7);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF2D2D2D);
  static const Color textGrey = Color(0xFF6B7280);
  static const Color accentGold = Color(0xFFE8B923);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HadithController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: lightBg,
        appBar: AppBar(
          backgroundColor: cardBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: textDark, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Hadith Collection',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: textDark),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: primaryPurple,
            indicatorWeight: 3,
            labelColor: primaryPurple,
            unselectedLabelColor: textGrey,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildHadithList(controller, isAll: true),
            _buildHadithList(controller, isAll: false),
          ],
        ),
      ),
    );
  }

  Widget _buildHadithList(HadithController controller, {required bool isAll}) {
    return Column(
      children: [
        // Category Filter (only for All tab)
        if (isAll)
          Obx(
            () => Container(
              height: 50,
              margin: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.chapters.length,
                itemBuilder: (context, index) {
                  final chapter = controller.chapters[index];
                  final isSelected = controller.selectedChapter.value == chapter;
                  return GestureDetector(
                    onTap: () => controller.filterByChapter(chapter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryPurple : cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? primaryPurple : Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Text(
                          chapter,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: isSelected ? Colors.white : textGrey,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // Hadith List
        Expanded(
          child: Obx(() {
            final hadiths = isAll ? controller.allHadiths : controller.favoriteHadiths;

            if (hadiths.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isAll ? Icons.menu_book_outlined : Icons.favorite_outline,
                      size: 56,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isAll ? 'No hadiths found' : 'No favorites yet',
                      style: GoogleFonts.poppins(color: textGrey, fontSize: 15),
                    ),
                    if (!isAll)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Tap ❤️ to save hadiths',
                          style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
                        ),
                      ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: hadiths.length,
              itemBuilder: (context, index) {
                final hadith = hadiths[index];
                return _buildHadithTile(controller, hadith);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHadithTile(HadithController controller, HadithModel hadith) {
    return GestureDetector(
      onTap: () {
        controller.setCurrentHadith(hadith);
        Get.back();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Number & Category
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${hadith.id}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        hadith.chapter,
                        style: GoogleFonts.poppins(fontSize: 10, color: textGrey),
                      ),
                    ),
                  ],
                ),
                // Favorite
                Obx(
                  () => GestureDetector(
                    onTap: () => controller.toggleFavorite(hadith.id),
                    child: Icon(
                      controller.isFavorite(hadith.id) ? Icons.favorite : Icons.favorite_outline,
                      color: controller.isFavorite(hadith.id) ? Colors.red : Colors.grey[400],
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Text
            Text(
              hadith.englishText,
              style: GoogleFonts.poppins(fontSize: 14, color: textDark, height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 10),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(hadith.narrator, style: GoogleFonts.poppins(fontSize: 11, color: accentGold)),
                Text(hadith.source, style: GoogleFonts.poppins(fontSize: 11, color: textGrey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
