import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/ramadan_controller/ramadan_controller.dart';
import '../../models/ramadan_model.dart';

class RamadanScreen extends StatelessWidget {
  RamadanScreen({super.key});

  final controller = Get.put(RamadanController());

  // Theme colors
  static const Color primaryPurple = Color(0xFF8F66FF);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color cardBg = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: primaryPurple));
        }

        return CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCountdownCard(),
                    const SizedBox(height: 16),
                    _buildSuhoorIftarCard(),
                    const SizedBox(height: 16),
                    _buildDailyTipCard(),
                    const SizedBox(height: 16),
                    _buildProgressCard(),
                    const SizedBox(height: 16),
                    _buildFastingTracker(),
                    const SizedBox(height: 16),
                    _buildDuasSection(),
                    const SizedBox(height: 16),
                    _buildSpecialNightsCard(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: primaryPurple,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () => controller.shareFastingProgress(),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => controller.refresh(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Ramadan 🌙',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryPurple, primaryPurple.withOpacity(0.8)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: 20,
                child: Icon(Icons.nights_stay, size: 120, color: Colors.white.withOpacity(0.1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownCard() {
    final info = controller.ramadanInfo.value;
    if (info == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            info.isRamadan ? '🌙 Ramadan Mubarak!' : '🌙 Ramadan Countdown',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryPurple,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            controller.countdownText,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: goldAccent,
            ),
          ),
          if (info.isRamadan) ...[
            const SizedBox(height: 8),
            Text(
              '${info.daysRemaining} days remaining',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSuhoorIftarCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTimeCard('🌅 Suhoor Ends', controller.suhoorTime.value, Colors.indigo),
          ),
          Container(
            height: 60,
            width: 1,
            color: Colors.grey[200],
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(child: _buildTimeCard('🌙 Iftar Time', controller.iftarTime.value, goldAccent)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTimeCard(String label, String time, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          time,
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildDailyTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryPurple.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('💡', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Tip',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.dailyTip.value,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildProgressCard() {
    final info = controller.ramadanInfo.value;
    if (info == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📊 Fasting Progress',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${info.daysFasted}/${info.totalDays}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: controller.progressValue,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(primaryPurple),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${info.progressPercentage.toStringAsFixed(1)}% completed',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildFastingTracker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📅 Fasting Tracker',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to mark days you fasted',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Obx(
            () => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: controller.fastingTracker.length,
              itemBuilder: (context, index) {
                final day = controller.fastingTracker[index];
                final isSpecial = controller.isSpecialNight(day.day);
                return _buildDayTile(day, isSpecial);
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDayTile(FastingDayModel day, bool isSpecial) {
    return GestureDetector(
      onTap: () => controller.toggleFastingDay(day.day),
      child: Container(
        decoration: BoxDecoration(
          color: day.isFasted
              ? primaryPurple
              : isSpecial
              ? goldAccent.withOpacity(0.2)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSpecial ? goldAccent : Colors.transparent, width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${day.day}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: day.isFasted ? Colors.white : Colors.grey[700],
              ),
            ),
            if (isSpecial && !day.isFasted)
              Positioned(top: 2, right: 2, child: Text('⭐', style: TextStyle(fontSize: 8))),
            if (day.isFasted)
              Positioned(
                bottom: 2,
                child: Icon(Icons.check_circle, size: 12, color: Colors.white.withOpacity(0.8)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuasSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🤲 Ramadan Duas',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildDuaCategory('Suhoor Dua', 'suhoor', '🌅'),
          const SizedBox(height: 12),
          _buildDuaCategory('Iftar Dua', 'iftar', '🌙'),
          const SizedBox(height: 12),
          _buildDuaCategory('Laylatul Qadr', 'laylatul_qadr', '✨'),
          const SizedBox(height: 12),
          _buildDuaCategory('General Duas', 'general', '📿'),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDuaCategory(String title, String occasion, String emoji) {
    final duas = controller.getDuasByOccasion(occasion);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${duas.length}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: primaryPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      children: duas.map((dua) => _buildDuaCard(dua)).toList(),
    );
  }

  Widget _buildDuaCard(RamadanDuaModel dua) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            dua.arabicText,
            style: GoogleFonts.amiri(fontSize: 20, height: 2, color: Colors.grey[800]),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 12),
          Text(
            dua.transliteration,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: primaryPurple,
            ),
          ),
          const SizedBox(height: 8),
          Text(dua.englishText, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📚 ${dua.reference}',
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
              ),
              IconButton(
                icon: Icon(Icons.share, size: 18, color: primaryPurple),
                onPressed: () => controller.shareDua(dua),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialNightsCard() {
    final specialNights = controller.getSpecialNights();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryPurple.withOpacity(0.1), goldAccent.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goldAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'Special Nights',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...specialNights.map((night) => _buildSpecialNightItem(night)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSpecialNightItem(Map<String, dynamic> night) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(night['icon'] as String, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  night['name'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  night['description'] as String,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: (night['nights'] as List<int>)
                      .take(5)
                      .map(
                        (n) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: goldAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$n',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: goldAccent,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
