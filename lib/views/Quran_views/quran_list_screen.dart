import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/quran_controller/quran_controller.dart';
import '../../routes/app_pages.dart';
import '../../widgets/quran_mini_player.dart';

class QuranListScreen extends StatefulWidget {
  const QuranListScreen({super.key});

  @override
  State<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends State<QuranListScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<dynamic> _filteredSurahs = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredSurahs.clear();
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _performSearch(String query, QuranController controller) {
    if (query.isEmpty) {
      setState(() {
        _filteredSurahs.clear();
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    final results = controller.surahs.where((surah) {
      if (query.contains(RegExp(r'^\d+$'))) {
        return surah.number.toString() == query;
      }
      if (surah.englishName.toLowerCase().contains(lowercaseQuery)) return true;
      if (surah.name.contains(query)) return true;
      if (surah.englishNameTranslation.toLowerCase().contains(lowercaseQuery)) return true;
      return false;
    }).toList();

    setState(() {
      _filteredSurahs = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(QuranController());

    return Scaffold(
      backgroundColor: const Color(0xFFE8E4F3),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF8F66FF), const Color(0xFFAB80FF), const Color(0xFFE8E4F3)],
            stops: const [0.0, 0.35, 0.35],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with purple theme
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8F66FF), Color(0xFFAB80FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Top bar
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Read Quran',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white, size: 28),
                          onPressed: _toggleSearch,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search Bar (appears when search is active)
                    if (_isSearching)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: (query) {
                            _performSearch(query, controller);
                            setState(() {}); // Trigger rebuild to show/hide clear button
                          },
                          style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF2D1B69)),
                          decoration: InputDecoration(
                            hintText: 'Search Surah by name or number...',
                            hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: const Color(0xFF8F66FF)),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, color: Colors.grey[400]),
                                    onPressed: () {
                                      _searchController.clear();
                                      _performSearch('', controller);
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),

                    // Last Read Card (hide when searching)
                    if (!_isSearching) _buildLastReadCard(controller),
                  ],
                ),
              ),

              // Tabs
              Container(
                color: const Color(0xFFE8E4F3),
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF8F66FF),
                  unselectedLabelColor: const Color(0xFF9E9E9E),
                  indicatorColor: const Color(0xFF8F66FF),
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'Surah'),
                    Tab(text: 'Para'),
                    Tab(text: 'Page'),
                    Tab(text: 'Hijb'),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSurahList(controller),
                    _buildParaList(controller),
                    _buildPageList(controller),
                    _buildHijbList(controller),
                  ],
                ),
              ),

              // Mini Player - shows when audio is playing
              QuranMiniPlayer(
                onTap: () {
                  // Navigate to the reader screen for the currently playing surah
                  if (controller.currentQuranData.value != null) {
                    Get.toNamed(
                      Routes.QURAN_READER,
                      arguments: controller.currentQuranData.value!.surah.number,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastReadCard(QuranController controller) {
    return Obx(() {
      // Trigger rebuild when surahs are loaded
      if (controller.surahs.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFAB80FF), const Color(0xFF9F70FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Last Read',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Al-Fatiah',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ayah No: 1',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 120,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 60,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        );
      }

      // Get last read data from controller (reactive)
      final lastReadSurahNumber = controller.lastReadSurah.value;
      final lastReadAyahNumber = controller.lastReadAyah.value;

      // Find the surah name
      String surahName = 'Al-Fatiah';
      final surah = controller.surahs.firstWhere(
        (s) => s.number == lastReadSurahNumber,
        orElse: () => controller.surahs.first,
      );
      surahName = surah.englishName;

      return InkWell(
        onTap: () => Get.toNamed(Routes.QURAN_READER, arguments: lastReadSurahNumber),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFAB80FF), const Color(0xFF9F70FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/images/Quraniocn.png", height: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Last Read',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      surahName,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ayah No: $lastReadAyahNumber',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              // Book icon
              Container(
                width: 120,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset("assets/images/Quraniocn.png"),
              ),
            ],
          ),
        ),
      );
    });
  }

  // Surah List Tab
  Widget _buildSurahList(QuranController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.surahs.isEmpty) {
        return Center(child: CircularProgressIndicator(color: const Color(0xFF8F66FF)));
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Text(controller.errorMessage.value, style: GoogleFonts.poppins(color: Colors.red)),
        );
      }

      // Use filtered surahs if searching, otherwise show all
      final surahsToDisplay = _isSearching && _searchController.text.isNotEmpty
          ? _filteredSurahs
          : controller.surahs;

      // Show "No results" message when searching but nothing found
      if (_isSearching && _searchController.text.isNotEmpty && _filteredSurahs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No Surahs found',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: surahsToDisplay.length,
        itemBuilder: (context, index) {
          final surah = surahsToDisplay[index];
          return _buildPurpleSurahTile(surah, controller);
        },
      );
    });
  }

  // Purple-themed Surah Tile
  Widget _buildPurpleSurahTile(surah, QuranController controller) {
    final isMeccan = surah.revelationType.toLowerCase() == 'meccan';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () => Get.toNamed(Routes.QURAN_READER, arguments: surah.number),
        leading: Stack(
          alignment: Alignment.center,
          children: [
            // Purple star/badge background
            Icon(Icons.star, size: 50, color: const Color(0xFF8F66FF).withOpacity(0.2)),
            Text(
              '${surah.number}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8F66FF),
              ),
            ),
          ],
        ),
        title: Text(
          surah.englishName,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D1B69),
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              isMeccan ? 'MECCAN' : 'MEDINAN',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${surah.numberOfAyahs} VERSES',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Text(
          surah.name,
          style: GoogleFonts.amiriQuran(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF8F66FF),
          ),
        ),
      ),
    );
  }

  // Para (Juz) List Tab
  Widget _buildParaList(QuranController controller) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: controller.quranService.getAllJuz(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF8F66FF)));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading Juz data', style: GoogleFonts.poppins(color: Colors.red)),
          );
        }

        final juzList = snapshot.data ?? [];
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: juzList.length,
          itemBuilder: (context, index) {
            final juz = juzList[index];
            return _buildPurpleParaTile(juz, controller);
          },
        );
      },
    );
  }

  Widget _buildPurpleParaTile(Map<String, dynamic> juz, QuranController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, const Color(0xFFF5F3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8F66FF).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () async {
          final startSurah = juz['startSurah'] as int;
          Get.toNamed(Routes.QURAN_READER, arguments: startSurah);
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFF8F66FF), const Color(0xFFAB80FF)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${juz['number']}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        title: Text(
          'Juz ${juz['number']}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D1B69),
          ),
        ),
        subtitle: Text(
          'Surah ${juz['startSurah']} - ${juz['endSurah']}',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: const Color(0xFF8F66FF)),
      ),
    );
  }

  // Page List Tab
  Widget _buildPageList(QuranController controller) {
    final pages = controller.quranService.getAllPages();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pages.length,
      itemBuilder: (context, index) {
        final page = pages[index];
        return _buildPurplePageTile(page, controller);
      },
    );
  }

  Widget _buildPurplePageTile(Map<String, dynamic> page, QuranController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () async {
          try {
            final pageData = await controller.quranService.getPage(page['number']);
            if (pageData['ayahs'] != null && pageData['ayahs'].isNotEmpty) {
              final firstAyah = pageData['ayahs'][0];
              final surahNumber = firstAyah['surah']['number'] as int;
              Get.toNamed(Routes.QURAN_READER, arguments: surahNumber);
            }
          } catch (e) {
            Get.snackbar(
              'Error',
              'Failed to load page',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF8F66FF), width: 2),
          ),
          child: Center(
            child: Text(
              '${page['number']}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8F66FF),
              ),
            ),
          ),
        ),
        title: Text(
          'Page ${page['number']}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D1B69),
          ),
        ),
        subtitle: Text(
          'Juz ${page['juz']}',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.article_outlined, size: 24, color: const Color(0xFF8F66FF)),
      ),
    );
  }

  // Hijb List Tab
  Widget _buildHijbList(QuranController controller) {
    final hizbs = controller.quranService.getAllHizbs();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hizbs.length,
      itemBuilder: (context, index) {
        final hizb = hizbs[index];
        return _buildPurpleHijbTile(hizb, controller);
      },
    );
  }

  Widget _buildPurpleHijbTile(Map<String, dynamic> hizb, QuranController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFF5F3FF), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8F66FF).withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () async {
          try {
            final hizbData = await controller.quranService.getHizb(hizb['number']);
            if (hizbData['ayahs'] != null && hizbData['ayahs'].isNotEmpty) {
              final firstAyah = hizbData['ayahs'][0];
              final surahNumber = firstAyah['surah']['number'] as int;
              Get.toNamed(Routes.QURAN_READER, arguments: surahNumber);
            }
          } catch (e) {
            Get.snackbar(
              'Error',
              'Failed to load Hizb',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFFAB80FF), const Color(0xFF9F70FF)]),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${hizb['number']}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        title: Text(
          'Hizb ${hizb['number']}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D1B69),
          ),
        ),
        subtitle: Text(
          'Juz ${hizb['juz']}',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.menu_book, size: 24, color: const Color(0xFF8F66FF)),
      ),
    );
  }
}
