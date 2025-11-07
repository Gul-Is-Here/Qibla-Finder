import 'dart:math' show pi, cos, sin;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../routes/app_pages.dart';

class IslamicResourcesController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;
  final RxString selectedQuickAction = ''.obs;
  final RxInt currentPage = 0.obs;

  final List<Map<String, dynamic>> featuredContent = [
    {
      'title': 'Learn Quran',
      'subtitle': 'Read, Listen & Understand',
      'description': 'Access 114 Surahs with translations',
      'icon': Icons.menu_book_outlined,
      'gradient': [Color(0xFF8F66FF), Color(0xFF9F70FF)],
      'route': Routes.QURAN_LIST,
    },
    {
      'title': 'Prayer Times',
      'subtitle': 'Never Miss a Prayer',
      'description': 'Accurate times for your location',
      'icon': Icons.access_time_outlined,
      'gradient': [Color(0xFF7E57C2), Color(0xFF9F70FF)],
      'route': Routes.PRAYER_TIMES,
    },
    {
      'title': 'Qibla Direction',
      'subtitle': 'Find Accurate Direction',
      'description': 'Compass to locate Kaaba',
      'icon': Icons.explore_outlined,
      'gradient': [Color(0xFFAB80FF), Color(0xFFB896FF)],
      'route': Routes.HOME,
    },
  ];

  final List<Map<String, dynamic>> dailyReminders = [
    {
      'title': 'Morning Adhkar',
      'subtitle': 'Start your day with remembrance',
      'time': 'After Fajr',
      'icon': Icons.wb_sunny_outlined,
      'color': Color(0xFF9F70FF),
      'route': Routes.DUA_COLLECTION,
    },
    {
      'title': 'Dhuhr Prayer',
      'subtitle': 'Prayer time approaching',
      'time': 'In 2 hours',
      'icon': Icons.notifications_active_outlined,
      'color': Color(0xFF8F66FF),
      'route': Routes.PRAYER_TIMES,
    },
    {
      'title': 'Quran Reading',
      'subtitle': 'Continue your daily recitation',
      'time': 'Today',
      'icon': Icons.auto_stories_outlined,
      'color': Color(0xFFAB80FF),
      'route': Routes.QURAN_LIST,
    },
  ];

  final List<Map<String, dynamic>> quickActions = [
    {
      'title': 'Qibla',
      'icon': Icons.explore_outlined,
      'gradient': [Color(0xFF8F66FF), Color(0xFF9F70FF)],
      'route': Routes.HOME,
    },
    {
      'title': 'Prayers',
      'icon': Icons.calendar_today_outlined,
      'gradient': [Color(0xFF7E57C2), Color(0xFF9F70FF)],
      'route': Routes.PRAYER_TIMES,
    },
    {
      'title': 'Quran',
      'icon': Icons.menu_book_outlined,
      'gradient': [Color(0xFFAB80FF), Color(0xFFB896FF)],
      'route': Routes.QURAN_LIST,
    },
    {
      'title': 'Dhikr',
      'icon': Icons.fingerprint_outlined,
      'gradient': [Color(0xFF9F70FF), Color(0xFFAB80FF)],
      'route': Routes.DHIKR_COUNTER,
    },
    {
      'title': 'Dua',
      'icon': Icons.favorite_outline,
      'gradient': [Color(0xFF8F66FF), Color(0xFFAB80FF)],
      'route': Routes.DUA_COLLECTION,
    },
    {
      'title': 'Mosques',
      'icon': Icons.mosque_outlined,
      'gradient': [Color(0xFFB896FF), Color(0xFFC5ACFF)],
      'route': Routes.MOSQUE_FINDER,
    },
  ];

  final List<Map<String, dynamic>> islamicTools = [
    {
      'title': 'Islamic Calendar',
      'description': 'Hijri dates & important events',
      'icon': Icons.calendar_month_outlined,
      'color': Color(0xFF8F66FF),
      'route': Routes.ISLAMIC_CALENDAR,
    },
    {
      'title': '99 Names of Allah',
      'description': 'Learn Asma ul Husna',
      'icon': Icons.auto_awesome_outlined,
      'color': Color(0xFF9F70FF),
      'route': Routes.NAMES_OF_ALLAH,
    },
    {
      'title': 'Dua Collection',
      'description': 'Daily supplications',
      'icon': Icons.menu_book_outlined,
      'color': Color(0xFFAB80FF),
      'route': Routes.DUA_COLLECTION,
    },
    {
      'title': 'Mosque Finder',
      'description': 'Nearby mosques',
      'icon': Icons.location_on_outlined,
      'color': Color(0xFF7E57C2),
      'route': Routes.MOSQUE_FINDER,
    },
  ];

  void navigateToFeature(String route) {
    try {
      Get.toNamed(route);
    } catch (e) {
      // Handle navigation error gracefully
      Get.snackbar(
        'Navigation Error',
        'Unable to open this feature. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF8F66FF),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void selectQuickAction(String action) {
    selectedQuickAction.value = action;
  }
}

class EnhancedIslamicFeaturesScreen extends StatelessWidget {
  const EnhancedIslamicFeaturesScreen({super.key});

  Color get primary => const Color(0xFF8F66FF);
  Color get accent => const Color(0xFF9F70FF);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(IslamicResourcesController());

    return Scaffold(
      backgroundColor: const Color(0xFFE8E4F3),
      body: CustomScrollView(
        slivers: [
          // Beautiful App Bar with Gradient & Islamic Pattern
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Gradient Background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF8F66FF),
                          const Color(0xFF9F70FF),
                          const Color(0xFFAB80FF),
                        ],
                      ),
                    ),
                  ),
                  // Islamic Pattern Overlay
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: CustomPaint(painter: IslamicPatternPainter()),
                    ),
                  ),
                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Greeting Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(
                                    Icons.mosque_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'السَّلاَمُ عَلَيْكُمْ',
                                        style: GoogleFonts.amiri(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Assalamu Alaikum',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.white.withOpacity(0.95),
                                          letterSpacing: 0.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Remove the title to have a cleaner header
              title: null,
              centerTitle: false,
            ),
            actions: [],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Featured Content Carousel
                _buildFeaturedCarousel(controller),

                const SizedBox(height: 24),

                // Quick Actions Grid
                _buildQuickActionsSection(controller),

                const SizedBox(height: 24),

                // Daily Reminders
                _buildDailyReminders(controller),

                const SizedBox(height: 24),

                // Islamic Tools
                _buildIslamicToolsSection(controller),

                const SizedBox(height: 24),

                // Hadith of the Day
                _buildHadithCard(),

                const SizedBox(height: 24),

                // Digital Dhikr Counter Highlight
                _buildDhikrCounterHighlight(controller),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Featured Content Carousel
  Widget _buildFeaturedCarousel(IslamicResourcesController controller) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: controller.featuredContent.length,
        onPageChanged: (index) => controller.currentPage.value = index,
        itemBuilder: (context, index) {
          final item = controller.featuredContent[index];
          return GestureDetector(
            onTap: () => controller.navigateToFeature(item['route']),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: item['gradient'],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: item['gradient'][0].withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative Pattern
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: -30,
                    child: Container(
                      width: 120,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item['icon'], color: Colors.white, size: 32),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['subtitle'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),

                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              'Explore',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Quick Actions Grid Section
  Widget _buildQuickActionsSection(IslamicResourcesController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Quick Access',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: controller.quickActions.length,
            itemBuilder: (context, index) {
              final action = controller.quickActions[index];
              return GestureDetector(
                onTap: () => controller.navigateToFeature(action['route']),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: action['gradient'],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: action['gradient'][0].withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(action['icon'], color: Colors.white, size: 24),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Daily Reminders Section
  Widget _buildDailyReminders(IslamicResourcesController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Reminders',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...controller.dailyReminders.map((reminder) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.navigateToFeature(reminder['route']),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: reminder['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(reminder['icon'], color: reminder['color'], size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reminder['title'],
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              reminder['subtitle'],
                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: reminder['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          reminder['time'],
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: reminder['color'],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // Islamic Tools Section
  Widget _buildIslamicToolsSection(IslamicResourcesController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Islamic Tools',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: controller.islamicTools.length,
            itemBuilder: (context, index) {
              final tool = controller.islamicTools[index];
              return GestureDetector(
                onTap: () => controller.navigateToFeature(tool['route']),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: tool['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(tool['icon'], color: tool['color'], size: 22),
                      ),
                      const Spacer(),
                      Text(
                        tool['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tool['description'],
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Hadith of the Day Card
  Widget _buildHadithCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFF3E8FF), const Color(0xFFE8DEFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF9F70FF).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9F70FF).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF8F66FF), Color(0xFF9F70FF)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8F66FF).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.auto_stories_outlined, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hadith of the Day',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D1B69),
                      ),
                    ),
                    Text(
                      'Sahih Bukhari',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF8F66FF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8F66FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF8F66FF).withOpacity(0.3)),
                ),
                child: Text(
                  'Today',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8F66FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF9F70FF).withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"The best among you are those who have the best manners and character."',
                  style: GoogleFonts.amiri(
                    fontSize: 15,
                    height: 1.8,
                    color: const Color(0xFF2D1B69),
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '— Sahih al-Bukhari 3559',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF8F66FF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.bookmark_border, size: 18, color: const Color(0xFF8F66FF)),
                        const SizedBox(width: 12),
                        Icon(Icons.share_outlined, size: 18, color: const Color(0xFF8F66FF)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dhikr Counter Highlight
  Widget _buildDhikrCounterHighlight(IslamicResourcesController controller) {
    return GestureDetector(
      onTap: () => controller.navigateToFeature(Routes.DHIKR_COUNTER),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8F66FF), Color(0xFF9F70FF), Color(0xFFAB80FF)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8F66FF).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.fingerprint_outlined, color: Colors.white, size: 40),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Digital Dhikr Counter',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Track your daily remembrance of Allah with ease',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFeatureBadge('Offline'),
                      const SizedBox(width: 8),
                      _buildFeatureBadge('Multiple Dhikr'),
                      const SizedBox(width: 8),
                      _buildFeatureBadge('Progress'),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }
}

// Islamic Pattern Painter for beautiful background
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 6;

    // Draw multiple overlapping circles (Islamic geometric pattern)
    for (var i = 0; i < 6; i++) {
      final angle = (i * 60) * (pi / 180);
      final x = centerX + radius * 1.5 * cos(angle);
      final y = centerY + radius * 1.5 * sin(angle);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw center circle
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // Draw outer circle
    canvas.drawCircle(Offset(centerX, centerY), radius * 2.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
