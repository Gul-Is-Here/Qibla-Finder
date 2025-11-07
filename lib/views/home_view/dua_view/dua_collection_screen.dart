import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DuaCollectionScreen extends StatefulWidget {
  const DuaCollectionScreen({super.key});

  @override
  State<DuaCollectionScreen> createState() => _DuaCollectionScreenState();
}

class _DuaCollectionScreenState extends State<DuaCollectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Color get primary => const Color(0xFF8F66FF);

  // Dua collections from open source Islamic resources
  final List<Map<String, dynamic>> _morningDuas = [
    {
      'title': 'Morning Adhkar',
      'arabic': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
      'transliteration': 'Asbahna wa asbahal-mulku lillah',
      'translation':
          'We have reached the morning and at this very time unto Allah belongs all sovereignty.',
      'reference': 'Muslim 2723',
    },
    {
      'title': 'Seeking Protection',
      'arabic': 'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا',
      'transliteration': 'Allahumma bika asbahna wa bika amsayna',
      'translation':
          'O Allah, by Your leave we have reached the morning and by Your leave we have reached the evening.',
      'reference': 'Abu Dawud 5071',
    },
    {
      'title': 'Ayat al-Kursi',
      'arabic': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      'transliteration': 'Allahu la ilaha illa huwa al-hayyu al-qayyum',
      'translation':
          'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence.',
      'reference': 'Quran 2:255',
    },
  ];

  final List<Map<String, dynamic>> _eveningDuas = [
    {
      'title': 'Evening Adhkar',
      'arabic': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
      'transliteration': 'Amsayna wa amsal-mulku lillah',
      'translation':
          'We have reached the evening and at this very time unto Allah belongs all sovereignty.',
      'reference': 'Muslim 2723',
    },
    {
      'title': 'Seeking Forgiveness',
      'arabic':
          'أَسْتَغْفِرُ اللَّهَ الَّذِي لَا إِلَٰهَ إِلَّا هُوَ الْحَيَّ الْقَيُّومَ وَأَتُوبُ إِلَيْهِ',
      'transliteration': 'Astaghfirullaha rabbee min kulli dhanbin wa atubu ilayh',
      'translation': 'I seek forgiveness from Allah, my Lord, from every sin I committed.',
      'reference': 'Abu Dawud 1517',
    },
  ];

  final List<Map<String, dynamic>> _prayerDuas = [
    {
      'title': 'Opening Dua (Dua al-Istiftah)',
      'arabic': 'اللَّهُمَّ بَاعِدْ بَيْنِي وَبَيْنَ خَطَايَايَ',
      'transliteration': 'Allahumma ba\'id bayni wa bayna khatayaya',
      'translation':
          'O Allah, distance me from my sins just as You have distanced the East from the West.',
      'reference': 'Bukhari 744',
    },
    {
      'title': 'After Salam',
      'arabic': 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ',
      'transliteration': 'Allahumma antas-salamu wa minkas-salam',
      'translation': 'O Allah, You are As-Salaam (Peace) and from You comes peace.',
      'reference': 'Muslim 591',
    },
    {
      'title': 'Seeking Guidance',
      'arabic': 'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ',
      'transliteration': 'Allahum-mahdini fiman hadayt',
      'translation': 'O Allah, guide me among those whom You have guided.',
      'reference': 'Abu Dawud 1425',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E4F3),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: Text(
          'Dua Collection',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Morning'),
            Tab(text: 'Evening'),
            Tab(text: 'Prayer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDuaList(_morningDuas),
          _buildDuaList(_eveningDuas),
          _buildDuaList(_prayerDuas),
        ],
      ),
    );
  }

  Widget _buildDuaList(List<Map<String, dynamic>> duas) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: duas.length,
      itemBuilder: (context, index) {
        return _buildDuaCard(duas[index]);
      },
    );
  }

  Widget _buildDuaCard(Map<String, dynamic> dua) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    dua['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.copy, color: Colors.grey[600], size: 20),
                  onPressed: () => _copyToClipboard(dua['arabic']),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Arabic Text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dua['arabic'],
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.8,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),

            const SizedBox(height: 12),

            // Transliteration
            Text(
              dua['transliteration'],
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 8),

            // Translation
            Text(
              dua['translation'],
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87, height: 1.5),
            ),

            const SizedBox(height: 12),

            // Reference
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Reference: ${dua['reference']}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.amber[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    // In a real app, you'd use Clipboard.setData()
    Get.snackbar(
      'Copied',
      'Dua copied to clipboard',
      backgroundColor: primary.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
