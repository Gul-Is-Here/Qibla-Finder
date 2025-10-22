import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes/app_pages.dart';

class IslamicResourcesController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;
  final RxString selectedQuickAction = ''.obs;

  final List<Map<String, dynamic>> dailyReminders = [
    {
      'title': 'Morning Dhikr',
      'subtitle': 'Start your day with remembrance',
      'time': 'After Fajr',
      'icon': Icons.wb_sunny_outlined,
      'route': Routes.DUA_COLLECTION,
    },
    {
      'title': 'Prayer Time',
      'subtitle': 'Dhuhr prayer approaching',
      'time': 'In 2 hours',
      'icon': Icons.schedule,
      'route': Routes.PRAYER_TIMES,
    },
    {
      'title': 'Quran Reading',
      'subtitle': 'Continue your daily recitation',
      'time': 'Today',
      'icon': Icons.book,
      'route': Routes.QURAN_LIST,
    },
  ];

  final List<Map<String, dynamic>> quickActions = [
    {'title': 'Find Qibla', 'icon': Icons.explore, 'color': Colors.blue, 'route': Routes.HOME},
    {
      'title': 'Prayer Times',
      'icon': Icons.access_time,
      'color': Colors.green,
      'route': Routes.PRAYER_TIMES,
    },
    {
      'title': 'Make Dua',
      'icon': Icons.favorite,
      'color': Colors.red,
      'route': Routes.DUA_COLLECTION,
    },
    {
      'title': 'Count Dhikr',
      'icon': Icons.fingerprint,
      'color': Colors.purple,
      'route': Routes.DHIKR_COUNTER,
    },
  ];

  void navigateToFeature(String route) {
    Get.toNamed(route);
  }

  void selectQuickAction(String action) {
    selectedQuickAction.value = action;
  }
}

class EnhancedIslamicFeaturesScreen extends StatelessWidget {
  const EnhancedIslamicFeaturesScreen({super.key});

  Color get primary => const Color(0xFF00332F);
  Color get accent => const Color(0xFF8BC34A);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IslamicResourcesController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: Text(
          'Islamic Resources',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Islamic Greeting
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [primary, primary.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.mosque, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assalamu Alaikum',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'May peace be upon you',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '"And whoever relies upon Allah - then He is sufficient for him. Indeed, Allah will accomplish His purpose."',
                      style: GoogleFonts.amiri(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Quick Actions',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.quickActions.length,
                itemBuilder: (context, index) {
                  final action = controller.quickActions[index];
                  return _buildQuickActionCard(action, controller);
                },
              ),
            ),

            const SizedBox(height: 24),

            // Daily Reminders
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Reminders',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...controller.dailyReminders.map(
              (reminder) => _buildReminderCard(reminder, controller),
            ),

            const SizedBox(height: 24),

            // Islamic Tools Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Islamic Tools',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildToolCard(
                    icon: Icons.calendar_month,
                    title: 'Islamic Calendar',
                    description: 'Hijri dates & events',
                    onTap: () => controller.navigateToFeature(Routes.ISLAMIC_CALENDAR),
                  ),
                  _buildToolCard(
                    icon: Icons.menu_book,
                    title: 'Dua Collection',
                    description: 'Daily prayers',
                    onTap: () => controller.navigateToFeature(Routes.DUA_COLLECTION),
                  ),
                  _buildToolCard(
                    icon: Icons.star,
                    title: '99 Names',
                    description: 'Names of Allah',
                    onTap: () => controller.navigateToFeature(Routes.NAMES_OF_ALLAH),
                  ),
                  _buildToolCard(
                    icon: Icons.location_on,
                    title: 'Mosque Finder',
                    description: 'Nearby mosques',
                    onTap: () => controller.navigateToFeature(Routes.MOSQUE_FINDER),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Wide Dhikr Counter Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildFeaturedCard(
                icon: Icons.fingerprint,
                title: 'Digital Dhikr Counter',
                description: 'Count your dhikr and tasbeeh with our digital counter',
                features: ['Multiple dhikr options', 'Progress tracking', 'Offline counting'],
                onTap: () => controller.navigateToFeature(Routes.DHIKR_COUNTER),
              ),
            ),

            const SizedBox(height: 24),

            // Islamic Knowledge Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: accent, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Did You Know?',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'The word "Dhikr" means remembrance of Allah. It is one of the most beloved acts of worship and can be performed at any time.',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 8),
                      Text(
                        'Tap on any tool to start your spiritual journey',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(Map<String, dynamic> action, IslamicResourcesController controller) {
    return GestureDetector(
      onTap: () => controller.navigateToFeature(action['route']),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: action['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: action['color'].withOpacity(0.3)),
              ),
              child: Icon(action['icon'], color: action['color'], size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              action['title'],
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder, IslamicResourcesController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () => controller.navigateToFeature(reminder['route']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(reminder['icon'], color: accent, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      reminder['subtitle'],
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    reminder['time'],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard({
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Icon(Icons.arrow_forward_ios, size: 14, color: primary)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard({
    required IconData icon,
    required String title,
    required String description,
    required List<String> features,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary.withOpacity(0.05), accent.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600], height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: features
                        .map(
                          (feature) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: accent.withOpacity(0.3)),
                            ),
                            child: Text(
                              feature,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: accent,
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
