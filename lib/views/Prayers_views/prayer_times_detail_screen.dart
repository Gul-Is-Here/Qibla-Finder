import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/prayer_controller/prayer_times_controller.dart';
import '../../models/prayer_model/prayer_times_model.dart';

class PrayerTimesDetailScreen extends StatelessWidget {
  const PrayerTimesDetailScreen({super.key});

  // App Theme Colors - Purple
  static const Color primaryPurple = Color(0xFF8F66FF);
  static const Color lightPurple = Color(0xFFAB80FF);
  static const Color darkPurple = Color(0xFF2D1B69);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PrayerTimesController>();

    // Set status bar to match app bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: primaryPurple,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Prayer Timings',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareCurrentPrayerTimes(controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.prayerTimes.value == null) {
          return const Center(child: CircularProgressIndicator(color: primaryPurple));
        }

        // Get prayer times for the selected date
        final selectedDate = controller.selectedDate.value;
        final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

        // Find the prayer times for the selected date
        dynamic selectedPrayerTimes = controller.prayerTimes.value;

        // Check if we have monthly data and find the matching date
        if (controller.monthlyPrayerTimes.isNotEmpty) {
          try {
            selectedPrayerTimes = controller.monthlyPrayerTimes.firstWhere(
              (pt) => pt.date == dateStr,
              orElse: () => controller.prayerTimes.value!,
            );
          } catch (e) {
            selectedPrayerTimes = controller.prayerTimes.value;
          }
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Date Navigator
              _buildDateNavigator(controller),

              const SizedBox(height: 20),

              // Sunrise & Sunset Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSunCard(
                        icon: Icons.wb_sunny,
                        title: 'Sunrise',
                        time: selectedPrayerTimes?.sunrise ?? '',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSunCard(
                        icon: Icons.nightlight_round,
                        title: 'Sunset',
                        time: selectedPrayerTimes?.maghrib ?? '',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Prayer Times List
              _buildPrayerTimesList(controller, selectedPrayerTimes),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDateNavigator(PrayerTimesController controller) {
    return Obx(() {
      final selectedDate = controller.selectedDate.value;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: controller.goToPreviousDay,
                icon: const Icon(Icons.chevron_left, color: Colors.black87, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Expanded(
                child: Text(
                  DateFormat('EEEE, MMM d, yyyy').format(selectedDate),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: controller.goToNextDay,
                icon: const Icon(Icons.chevron_right, color: Colors.black87, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSunCard({required IconData icon, required String title, required String time}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: primaryPurple),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: GoogleFonts.robotoMono(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesList(
    PrayerTimesController controller,
    PrayerTimesModel? selectedPrayerTimes,
  ) {
    return Obx(() {
      final prayerTimes = selectedPrayerTimes;
      if (prayerTimes == null) return const SizedBox();

      final prayers = [
        {'name': 'Fajr', 'time': prayerTimes.fajr},
        {'name': 'Dhuhr', 'time': prayerTimes.dhuhr},
        {'name': 'Asr', 'time': prayerTimes.asr},
        {'name': 'Maghrib', 'time': prayerTimes.maghrib},
        {'name': 'Isha', 'time': prayerTimes.isha},
      ];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: prayers.map((prayer) {
            final isNext = controller.nextPrayer.value == prayer['name'];
            return _buildPrayerTimeItem(prayer['name']!, prayer['time']!, isNext);
          }).toList(),
        ),
      );
    });
  }

  Widget _buildPrayerTimeItem(String name, String time, bool isNext) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isNext ? lightPurple : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isNext ? Colors.white.withOpacity(0.3) : primaryPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.access_time, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isNext ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.robotoMono(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isNext ? Colors.white : primaryPurple,
            ),
          ),
          const SizedBox(width: 8),
          if (isNext)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle, color: Colors.white, size: 18),
            ),
        ],
      ),
    );
  }

  void _shareCurrentPrayerTimes(PrayerTimesController controller) {
    final prayerTimes = controller.prayerTimes.value;
    if (prayerTimes == null) return;

    final date = controller.selectedDate.value;
    final dateStr = DateFormat('EEEE, MMMM dd, yyyy').format(date);

    final text =
        '''
🕌 Prayer Times for $dateStr

🌅 Fajr: ${prayerTimes.fajr}
🌄 Sunrise: ${prayerTimes.sunrise}
☀️ Dhuhr: ${prayerTimes.dhuhr}
🌤️ Asr: ${prayerTimes.asr}
🌆 Maghrib: ${prayerTimes.maghrib}
🌙 Isha: ${prayerTimes.isha}

Shared from Qibla Compass App
    ''';

    Share.share(text, subject: 'Prayer Times - $dateStr');
  }
}
