import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/quran_controller.dart';
import '../routes/app_pages.dart';

class QuranListScreen extends StatelessWidget {
  const QuranListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuranController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00332F),
        title: Text(
          'القرآن الكريم',
          style: GoogleFonts.amiriQuran(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => _showSearchDialog(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.surahs.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFF00332F)),
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  style: GoogleFonts.poppins(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadSurahs(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00332F),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.surahs.length,
          itemBuilder: (context, index) {
            final surah = controller.surahs[index];
            return _buildSurahTile(context, surah, controller);
          },
        );
      }),
    );
  }

  Widget _buildSurahTile(
    BuildContext context,
    surah,
    QuranController controller,
  ) {
    final isMeccan = surah.revelationType.toLowerCase() == 'meccan';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Get.toNamed(Routes.QURAN_READER, arguments: surah.number);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Surah number in circle
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF00332F),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${surah.number}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Surah info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          surah.englishName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00332F),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isMeccan ? Icons.circle : Icons.location_city,
                          size: 14,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${surah.englishNameTranslation} • ${surah.numberOfAyahs} Ayahs',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Arabic name
              Text(
                surah.name,
                style: GoogleFonts.amiriQuran(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00332F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, QuranController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Search Surah',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter surah name or number...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            // Implement search logic here
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
