import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/quran_controller.dart';
import '../routes/app_pages.dart';

class QuranListScreen extends StatefulWidget {
  const QuranListScreen({super.key});

  @override
  State<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends State<QuranListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  List<dynamic> _filteredSurahs = [];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
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
      // Search by surah number
      if (query.contains(RegExp(r'^\d+$'))) {
        return surah.number.toString() == query;
      }

      // Search by English name
      if (surah.englishName.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }

      // Search by Arabic name
      if (surah.name.contains(query)) {
        return true;
      }

      // Search by translation/meaning
      if (surah.englishNameTranslation.toLowerCase().contains(lowercaseQuery)) {
        return true;
      }

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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00332F),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search surah name, number...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: (value) => _performSearch(value, controller),
              )
            : Text(
                'القرآن الكريم',
                style: GoogleFonts.amiriQuran(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
        centerTitle: !_isSearching,
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _toggleSearch,
              )
            : null,
        actions: [
          if (_isSearching && _searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                _searchController.clear();
                _performSearch('', controller);
              },
            ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: _toggleSearch,
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

        // Determine which list to show
        final displayList = _isSearching && _searchController.text.isNotEmpty
            ? _filteredSurahs
            : controller.surahs;

        // Show "No results" message for empty search results
        if (_isSearching &&
            _searchController.text.isNotEmpty &&
            _filteredSurahs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No surahs found',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try searching by surah name, number,\nor meaning',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Search suggestions/filters (when searching)
            if (_isSearching && _searchController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.white,
                child: Row(
                  children: [
                    Icon(Icons.filter_list, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${_filteredSurahs.length} result${_filteredSurahs.length != 1 ? 's' : ''} found',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Surah list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final surah = displayList[index];
                  return _buildSurahTile(
                    context,
                    surah,
                    controller,
                    highlightText: _searchController.text,
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSurahTile(
    BuildContext context,
    surah,
    QuranController controller, {
    String highlightText = '',
  }) {
    final isMeccan = surah.revelationType.toLowerCase() == 'meccan';
    final bool hasMatch = highlightText.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: hasMatch ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasMatch
            ? BorderSide(
                color: const Color(0xFF00332F).withOpacity(0.3),
                width: 1.5,
              )
            : BorderSide.none,
      ),
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
                        _buildHighlightedText(
                          surah.englishName,
                          highlightText,
                          GoogleFonts.poppins(
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
                    _buildHighlightedText(
                      '${surah.englishNameTranslation} • ${surah.numberOfAyahs} Ayahs',
                      highlightText,
                      GoogleFonts.poppins(
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

  // Build text with highlighted search term
  Widget _buildHighlightedText(String text, String highlight, TextStyle style) {
    if (highlight.isEmpty) {
      return Text(text, style: style);
    }

    final lowercaseText = text.toLowerCase();
    final lowercaseHighlight = highlight.toLowerCase();
    final index = lowercaseText.indexOf(lowercaseHighlight);

    if (index == -1) {
      return Text(text, style: style);
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: text.substring(0, index), style: style),
          TextSpan(
            text: text.substring(index, index + highlight.length),
            style: style.copyWith(
              backgroundColor: Colors.yellow.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00332F),
            ),
          ),
          TextSpan(
            text: text.substring(index + highlight.length),
            style: style,
          ),
        ],
      ),
    );
  }
}
