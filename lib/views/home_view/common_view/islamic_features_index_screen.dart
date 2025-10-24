import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/app_pages.dart';

class IslamicFeaturesIndexScreen extends StatelessWidget {
  const IslamicFeaturesIndexScreen({super.key});

  Color get primary => const Color(0xFF00332F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: Text(
          'Islamic Features',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primary.withOpacity(0.1), primary.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(Icons.star, size: 48, color: primary),
                  const SizedBox(height: 12),
                  Text(
                    'Islamic Spiritual Tools',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enhance your spiritual journey with authentic Islamic resources',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Features Grid
            Text(
              'Available Features',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: [
                _buildFeatureCard(
                  icon: Icons.calendar_month,
                  title: 'Islamic Calendar',
                  description: 'View Hijri dates, Islamic months, and important religious events',
                  onTap: () => Get.toNamed(Routes.ISLAMIC_CALENDAR),
                ),
                _buildFeatureCard(
                  icon: Icons.menu_book,
                  title: 'Dua Collection',
                  description: 'Daily duas with Arabic text, transliteration, and meanings',
                  onTap: () => Get.toNamed(Routes.DUA_COLLECTION),
                ),
                _buildFeatureCard(
                  icon: Icons.star,
                  title: '99 Names of Allah',
                  description: 'Beautiful names of Allah with meanings and pronunciation',
                  onTap: () => Get.toNamed(Routes.NAMES_OF_ALLAH),
                ),
                _buildFeatureCard(
                  icon: Icons.location_on,
                  title: 'Mosque Finder',
                  description: 'Find nearby mosques with prayer times and directions',
                  onTap: () => Get.toNamed(Routes.MOSQUE_FINDER),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Wide feature card for Dhikr Counter
            _buildWideFeatureCard(
              icon: Icons.fingerprint,
              title: 'Dhikr Counter',
              description: 'Digital tasbih to count your dhikr and remembrance of Allah',
              features: ['Multiple dhikr options', 'Progress tracking', 'Offline counting'],
              onTap: () => Get.toNamed(Routes.DHIKR_COUNTER),
            ),

            const SizedBox(height: 24),

            // Quote Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Text(
                    '"And whoever relies upon Allah - then He is sufficient for him. Indeed, Allah will accomplish His purpose."',
                    style: GoogleFonts.amiri(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: primary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '- Quran 65:3',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                description,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600], height: 1.4),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Icon(Icons.arrow_forward_ios, size: 16, color: primary)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required List<String> features,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600], height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: features
                        .map(
                          (feature) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              feature,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: primary,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 20, color: primary),
          ],
        ),
      ),
    );
  }
}
