// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../controllers/quran_controller/quran_controller.dart';
// import '../../routes/app_pages.dart';

// class QuranListScreen extends StatefulWidget {
//   const QuranListScreen({super.key});

//   @override
//   State<QuranListScreen> createState() => _QuranListScreenState();
// }

// class _QuranListScreenState extends State<QuranListScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _searchFocusNode = FocusNode();
//   bool _isSearching = false;
//   List<dynamic> _filteredSurahs = [];

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _searchFocusNode.dispose();
//     super.dispose();
//   }

//   void _toggleSearch() {
//     setState(() {
//       _isSearching = !_isSearching;
//       if (!_isSearching) {
//         _searchController.clear();
//         _filteredSurahs.clear();
//       } else {
//         _searchFocusNode.requestFocus();
//       }
//     });
//   }

//   void _performSearch(String query, QuranController controller) {
//     if (query.isEmpty) {
//       setState(() {
//         _filteredSurahs.clear();
//       });
//       return;
//     }

//     final lowercaseQuery = query.toLowerCase();
//     final results = controller.surahs.where((surah) {
//       // Search by surah number
//       if (query.contains(RegExp(r'^\d+$'))) {
//         return surah.number.toString() == query;
//       }

//       // Search by English name
//       if (surah.englishName.toLowerCase().contains(lowercaseQuery)) {
//         return true;
//       }

//       // Search by Arabic name
//       if (surah.name.contains(query)) {
//         return true;
//       }

//       // Search by translation/meaning
//       if (surah.englishNameTranslation.toLowerCase().contains(lowercaseQuery)) {
//         return true;
//       }

//       return false;
//     }).toList();

//     setState(() {
//       _filteredSurahs = results;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(QuranController());

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [const Color(0xFF00332F), const Color(0xFF004D40), const Color(0xFFF8F9FA)],
//             stops: const [0.0, 0.3, 0.3],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Custom Header
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFF00332F), Color(0xFF004D40)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     // Top bar with back and search
//                     Row(
//                       children: [
//                         if (_isSearching)
//                           IconButton(
//                             icon: const Icon(Icons.arrow_back, color: Colors.white),
//                             onPressed: _toggleSearch,
//                           )
//                         else
//                           IconButton(
//                             icon: const Icon(Icons.menu, color: Colors.white),
//                             onPressed: () => Get.back(),
//                           ),
//                         Expanded(
//                           child: _isSearching
//                               ? Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withOpacity(0.15),
//                                     borderRadius: BorderRadius.circular(25),
//                                     border: Border.all(
//                                       color: Colors.white.withOpacity(0.3),
//                                       width: 1,
//                                     ),
//                                   ),
//                                   child: TextField(
//                                     controller: _searchController,
//                                     focusNode: _searchFocusNode,
//                                     style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
//                                     decoration: InputDecoration(
//                                       hintText: 'Search surah name, number...',
//                                       hintStyle: GoogleFonts.poppins(
//                                         color: Colors.white60,
//                                         fontSize: 14,
//                                       ),
//                                       prefixIcon: const Icon(
//                                         Icons.search,
//                                         color: Colors.white60,
//                                         size: 20,
//                                       ),
//                                       border: InputBorder.none,
//                                       contentPadding: const EdgeInsets.symmetric(
//                                         horizontal: 16,
//                                         vertical: 12,
//                                       ),
//                                     ),
//                                     onChanged: (value) => _performSearch(value, controller),
//                                   ),
//                                 )
//                               : Center(
//                                   child: Column(
//                                     children: [
//                                       Text(
//                                         'القرآن الكريم',
//                                         style: GoogleFonts.amiriQuran(
//                                           fontSize: 32,
//                                           fontWeight: FontWeight.w700,
//                                           color: Colors.white,
//                                           shadows: [
//                                             Shadow(
//                                               color: Colors.black.withOpacity(0.3),
//                                               offset: const Offset(0, 2),
//                                               blurRadius: 4,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         'The Holy Quran',
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 13,
//                                           fontWeight: FontWeight.w400,
//                                           color: Colors.white.withOpacity(0.85),
//                                           letterSpacing: 1.2,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                         ),
//                         if (_isSearching && _searchController.text.isNotEmpty)
//                           IconButton(
//                             icon: const Icon(Icons.clear, color: Colors.white),
//                             onPressed: () {
//                               _searchController.clear();
//                               _performSearch('', controller);
//                             },
//                           ),
//                         if (!_isSearching)
//                           IconButton(
//                             icon: const Icon(Icons.search, color: Colors.white),
//                             onPressed: _toggleSearch,
//                           ),
//                       ],
//                     ),

//                     // Info card
//                     if (!_isSearching) ...[
//                       const SizedBox(height: 16),
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             colors: [
//                               Colors.white.withOpacity(0.15),
//                               Colors.white.withOpacity(0.08),
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 8,
//                               offset: const Offset(0, 4),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           children: [
//                             _buildInfoItem(icon: Icons.book_outlined, label: '114 Surahs'),
//                             Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
//                             _buildInfoItem(icon: Icons.playlist_play, label: '6236 Ayahs'),
//                             Container(width: 1, height: 30, color: Colors.white.withOpacity(0.3)),
//                             _buildInfoItem(icon: Icons.download_outlined, label: 'Offline'),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),

//               // Content area
//               Expanded(
//                 child: Obx(() {
//                   if (controller.isLoading.value && controller.surahs.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF00332F).withOpacity(0.1),
//                               shape: BoxShape.circle,
//                             ),
//                             child: const CircularProgressIndicator(
//                               valueColor: AlwaysStoppedAnimation(Color(0xFF00332F)),
//                               strokeWidth: 3,
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                           Text(
//                             'Loading Surahs...',
//                             style: GoogleFonts.poppins(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   if (controller.errorMessage.value.isNotEmpty) {
//                     return Center(
//                       child: Padding(
//                         padding: const EdgeInsets.all(24),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(20),
//                               decoration: BoxDecoration(
//                                 color: Colors.red.withOpacity(0.1),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(Icons.error_outline, size: 64, color: Colors.red),
//                             ),
//                             const SizedBox(height: 24),
//                             Text(
//                               'Oops!',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: const Color(0xFF00332F),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               controller.errorMessage.value,
//                               style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700]),
//                               textAlign: TextAlign.center,
//                             ),
//                             const SizedBox(height: 24),
//                             ElevatedButton.icon(
//                               onPressed: () => controller.loadSurahs(),
//                               icon: const Icon(Icons.refresh),
//                               label: const Text('Try Again'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF00332F),
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(25),
//                                 ),
//                                 elevation: 2,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }

//                   // Determine which list to show
//                   final displayList = _isSearching && _searchController.text.isNotEmpty
//                       ? _filteredSurahs
//                       : controller.surahs;

//                   // Show "No results" message for empty search results
//                   if (_isSearching &&
//                       _searchController.text.isNotEmpty &&
//                       _filteredSurahs.isEmpty) {
//                     return Center(
//                       child: Padding(
//                         padding: const EdgeInsets.all(24),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(20),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.withOpacity(0.1),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
//                             ),
//                             const SizedBox(height: 24),
//                             Text(
//                               'No Surahs Found',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.grey[700],
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Try searching by surah name, number,\nor meaning',
//                               style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
//                               textAlign: TextAlign.center,
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }

//                   return Column(
//                     children: [
//                       // Search results counter
//                       if (_isSearching && _searchController.text.isNotEmpty)
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(6),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFF00332F).withOpacity(0.1),
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: Icon(
//                                   Icons.filter_list,
//                                   size: 16,
//                                   color: const Color(0xFF00332F),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Text(
//                                 '${_filteredSurahs.length} result${_filteredSurahs.length != 1 ? 's' : ''} found',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14,
//                                   color: const Color(0xFF00332F),
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                       // Surah list
//                       Expanded(
//                         child: ListView.builder(
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                           itemCount: displayList.length,
//                           itemBuilder: (context, index) {
//                             final surah = displayList[index];
//                             return _buildModernSurahTile(
//                               context,
//                               surah,
//                               controller,
//                               highlightText: _searchController.text,
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper method for info items
//   Widget _buildInfoItem({required IconData icon, required String label}) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, color: Colors.white, size: 18),
//         const SizedBox(width: 6),
//         Text(
//           label,
//           style: GoogleFonts.poppins(
//             color: Colors.white,
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   // Modern Surah Tile Design
//   Widget _buildModernSurahTile(
//     BuildContext context,
//     surah,
//     QuranController controller, {
//     String highlightText = '',
//   }) {
//     final isMeccan = surah.revelationType.toLowerCase() == 'meccan';
//     final bool hasMatch = highlightText.isNotEmpty;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.white, hasMatch ? const Color(0xFFFFF9E6) : Colors.white],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: hasMatch
//                 ? const Color(0xFF00332F).withOpacity(0.15)
//                 : Colors.black.withOpacity(0.06),
//             blurRadius: hasMatch ? 12 : 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//         border: hasMatch
//             ? Border.all(color: const Color(0xFF00332F).withOpacity(0.2), width: 1.5)
//             : null,
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () {
//             Get.toNamed(Routes.QURAN_READER, arguments: surah.number);
//           },
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: const EdgeInsets.all(14),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     // Decorative number badge
//                     Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         // Outer decorative ring
//                         Container(
//                           width: 52,
//                           height: 52,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             gradient: LinearGradient(
//                               colors: [const Color(0xFF00332F), const Color(0xFF004D40)],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(0xFF00332F).withOpacity(0.3),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                         ),
//                         // Inner circle
//                         Container(
//                           width: 46,
//                           height: 46,
//                           decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
//                         ),
//                         // Number
//                         Text(
//                           '${surah.number}',
//                           style: GoogleFonts.poppins(
//                             color: const Color(0xFF00332F),
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(width: 14),

//                     // Surah info
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: _buildHighlightedText(
//                                   surah.englishName,
//                                   highlightText,
//                                   GoogleFonts.poppins(
//                                     fontSize: 17,
//                                     fontWeight: FontWeight.w600,
//                                     color: const Color(0xFF00332F),
//                                     letterSpacing: 0.2,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               // Revelation type badge
//                               Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                                 decoration: BoxDecoration(
//                                   color: isMeccan
//                                       ? const Color(0xFFFFEBEE)
//                                       : const Color(0xFFE8F5E9),
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: Border.all(
//                                     color: isMeccan
//                                         ? const Color(0xFFEF5350)
//                                         : const Color(0xFF66BB6A),
//                                     width: 1,
//                                   ),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Icon(
//                                       isMeccan ? Icons.circle : Icons.location_city,
//                                       size: 10,
//                                       color: isMeccan
//                                           ? const Color(0xFFEF5350)
//                                           : const Color(0xFF66BB6A),
//                                     ),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       isMeccan ? 'Meccan' : 'Medinan',
//                                       style: GoogleFonts.poppins(
//                                         fontSize: 9,
//                                         fontWeight: FontWeight.w600,
//                                         color: isMeccan
//                                             ? const Color(0xFFEF5350)
//                                             : const Color(0xFF66BB6A),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 6),
//                           Row(
//                             children: [
//                               Icon(Icons.menu_book, size: 12, color: Colors.grey[500]),
//                               const SizedBox(width: 4),
//                               Expanded(
//                                 child: _buildHighlightedText(
//                                   '${surah.englishNameTranslation} • ${surah.numberOfAyahs} Ayahs',
//                                   highlightText,
//                                   GoogleFonts.poppins(
//                                     fontSize: 12,
//                                     color: Colors.grey[600],
//                                     fontWeight: FontWeight.w400,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(width: 12),

//                     // Arabic name with decorative background
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             const Color(0xFF00332F).withOpacity(0.05),
//                             const Color(0xFF004D40).withOpacity(0.08),
//                           ],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: const Color(0xFF00332F).withOpacity(0.1)),
//                       ),
//                       child: Text(
//                         surah.name,
//                         style: GoogleFonts.amiriQuran(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: const Color(0xFF00332F),
//                           height: 1.2,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 // Action buttons row
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     // Download status indicator
//                     Expanded(
//                       child: Obx(() {
//                         final isDownloading = controller.isSurahDownloading(surah.number);

//                         if (isDownloading) {
//                           final progress = controller.getSurahDownloadProgress(surah.number);
//                           return Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF00332F).withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: const Color(0xFF00332F), width: 1),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 SizedBox(
//                                   width: 14,
//                                   height: 14,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     valueColor: AlwaysStoppedAnimation(const Color(0xFF00332F)),
//                                     value: progress,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 6),
//                                 Text(
//                                   'Downloading ${(progress * 100).toInt()}%',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.w600,
//                                     color: const Color(0xFF00332F),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }

//                         return FutureBuilder<bool>(
//                           future: controller.isSurahDownloaded(surah.number, surah.numberOfAyahs),
//                           builder: (context, snapshot) {
//                             final isDownloaded = snapshot.data ?? false;

//                             return Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                               decoration: BoxDecoration(
//                                 color: isDownloaded
//                                     ? const Color(0xFFE8F5E9)
//                                     : const Color(0xFFFFF9E6),
//                                 borderRadius: BorderRadius.circular(8),
//                                 border: Border.all(
//                                   color: isDownloaded
//                                       ? const Color(0xFF66BB6A)
//                                       : const Color(0xFFFFB300),
//                                   width: 1,
//                                 ),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     isDownloaded
//                                         ? Icons.offline_pin
//                                         : Icons.cloud_download_outlined,
//                                     size: 14,
//                                     color: isDownloaded
//                                         ? const Color(0xFF66BB6A)
//                                         : const Color(0xFFFFB300),
//                                   ),
//                                   const SizedBox(width: 6),
//                                   Text(
//                                     isDownloaded ? 'Downloaded' : 'Not Downloaded',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w600,
//                                       color: isDownloaded
//                                           ? const Color(0xFF66BB6A)
//                                           : const Color(0xFFFFB300),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         );
//                       }),
//                     ),
//                     const SizedBox(width: 8),

//                     // Download/Delete button
//                     FutureBuilder<bool>(
//                       future: controller.isSurahDownloaded(surah.number, surah.numberOfAyahs),
//                       builder: (context, snapshot) {
//                         final isDownloaded = snapshot.data ?? false;

//                         return Obx(() {
//                           // Check if this specific surah is downloading
//                           final isDownloading = controller.isSurahDownloading(surah.number);
//                           final downloadProgress = controller.getSurahDownloadProgress(
//                             surah.number,
//                           );

//                           if (isDownloading) {
//                             // Show progress for this specific surah
//                             return Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF00332F).withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   SizedBox(
//                                     width: 14,
//                                     height: 14,
//                                     child: CircularProgressIndicator(
//                                       strokeWidth: 2,
//                                       valueColor: AlwaysStoppedAnimation(const Color(0xFF00332F)),
//                                       value: downloadProgress,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 6),
//                                   Text(
//                                     '${(downloadProgress * 100).toInt()}%',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 11,
//                                       fontWeight: FontWeight.w600,
//                                       color: const Color(0xFF00332F),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           } else if (isDownloaded) {
//                             // Delete button (when downloaded)
//                             return Material(
//                               color: Colors.transparent,
//                               child: InkWell(
//                                 onTap: () async {
//                                   await controller.deleteSurah(surah.number, surah.numberOfAyahs);
//                                   // Force rebuild to update button state
//                                   if (context.mounted) {
//                                     (context as Element).markNeedsBuild();
//                                   }
//                                 },
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                                   decoration: BoxDecoration(
//                                     color: Colors.red.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(8),
//                                     border: Border.all(color: Colors.red, width: 1.5),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       const Icon(Icons.delete_outline, size: 16, color: Colors.red),
//                                       const SizedBox(width: 6),
//                                       Text(
//                                         'Delete',
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.w600,
//                                           color: Colors.red,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           } else {
//                             // Download button (when not downloaded)
//                             return Material(
//                               color: Colors.transparent,
//                               child: InkWell(
//                                 onTap: () async {
//                                   await controller.downloadSurah(surah.number, surah.numberOfAyahs);
//                                   // Force rebuild to update button state
//                                   if (context.mounted) {
//                                     (context as Element).markNeedsBuild();
//                                   }
//                                 },
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                                   decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                       colors: [const Color(0xFF00332F), const Color(0xFF004D40)],
//                                     ),
//                                     borderRadius: BorderRadius.circular(8),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: const Color(0xFF00332F).withOpacity(0.3),
//                                         blurRadius: 4,
//                                         offset: const Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       const Icon(
//                                         Icons.download_rounded,
//                                         size: 16,
//                                         color: Colors.white,
//                                       ),
//                                       const SizedBox(width: 6),
//                                       Text(
//                                         'Download',
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.w600,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }
//                         });
//                       },
//                     ),

//                     const SizedBox(width: 8),

//                     // Play button
//                     Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         onTap: () {
//                           // Load surah and play first ayah
//                           controller.loadSurah(surah.number).then((_) {
//                             controller.playAyah(0);
//                           });
//                           Get.toNamed(Routes.QURAN_READER, arguments: surah.number);
//                         },
//                         borderRadius: BorderRadius.circular(8),
//                         child: Container(
//                           padding: const EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFFFB300).withOpacity(0.15),
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
//                           ),
//                           child: const Icon(
//                             Icons.play_arrow_rounded,
//                             size: 18,
//                             color: Color(0xFFFFB300),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Build text with highlighted search term
//   Widget _buildHighlightedText(String text, String highlight, TextStyle style) {
//     if (highlight.isEmpty) {
//       return Text(text, style: style);
//     }

//     final lowercaseText = text.toLowerCase();
//     final lowercaseHighlight = highlight.toLowerCase();
//     final index = lowercaseText.indexOf(lowercaseHighlight);

//     if (index == -1) {
//       return Text(text, style: style);
//     }

//     return RichText(
//       text: TextSpan(
//         children: [
//           TextSpan(text: text.substring(0, index), style: style),
//           TextSpan(
//             text: text.substring(index, index + highlight.length),
//             style: style.copyWith(
//               backgroundColor: const Color(0xFFFFEB3B).withOpacity(0.4),
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF00332F),
//             ),
//           ),
//           TextSpan(text: text.substring(index + highlight.length), style: style),
//         ],
//       ),
//     );
//   }
// }
