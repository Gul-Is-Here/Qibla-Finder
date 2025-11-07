import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class NamesOfAllahScreen extends StatefulWidget {
  const NamesOfAllahScreen({super.key});

  @override
  State<NamesOfAllahScreen> createState() => _NamesOfAllahScreenState();
}

class _NamesOfAllahScreenState extends State<NamesOfAllahScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredNames = [];

  Color get primary => const Color(0xFF8F66FF);

  // 99 Names of Allah with meanings (open source Islamic data)
  final List<Map<String, dynamic>> _allahNames = [
    {
      'arabic': 'الرَّحْمَٰنُ',
      'transliteration': 'Ar-Rahman',
      'meaning': 'The Beneficent, The Merciful',
    },
    {'arabic': 'الرَّحِيمُ', 'transliteration': 'Ar-Raheem', 'meaning': 'The Merciful'},
    {'arabic': 'الْمَلِكُ', 'transliteration': 'Al-Malik', 'meaning': 'The King, The Sovereign'},
    {'arabic': 'الْقُدُّوسُ', 'transliteration': 'Al-Quddus', 'meaning': 'The Holy, The Pure'},
    {'arabic': 'السَّلَامُ', 'transliteration': 'As-Salam', 'meaning': 'The Peace, The Security'},
    {
      'arabic': 'الْمُؤْمِنُ',
      'transliteration': 'Al-Mumin',
      'meaning': 'The Faithful, The Trusted',
    },
    {
      'arabic': 'الْمُهَيْمِنُ',
      'transliteration': 'Al-Muhaymin',
      'meaning': 'The Guardian, The Witness',
    },
    {'arabic': 'الْعَزِيزُ', 'transliteration': 'Al-Aziz', 'meaning': 'The Mighty, The Strong'},
    {
      'arabic': 'الْجَبَّارُ',
      'transliteration': 'Al-Jabbar',
      'meaning': 'The Compeller, The Restorer',
    },
    {
      'arabic': 'الْمُتَكَبِّرُ',
      'transliteration': 'Al-Mutakabbir',
      'meaning': 'The Majestic, The Supreme',
    },
    {'arabic': 'الْخَالِقُ', 'transliteration': 'Al-Khaliq', 'meaning': 'The Creator'},
    {
      'arabic': 'الْبَارِئُ',
      'transliteration': 'Al-Bari',
      'meaning': 'The Originator, The Producer',
    },
    {
      'arabic': 'الْمُصَوِّرُ',
      'transliteration': 'Al-Musawwir',
      'meaning': 'The Fashioner, The Bestower of Form',
    },
    {'arabic': 'الْغَفَّارُ', 'transliteration': 'Al-Ghaffar', 'meaning': 'The Great Forgiver'},
    {
      'arabic': 'الْقَهَّارُ',
      'transliteration': 'Al-Qahhar',
      'meaning': 'The Subduer, The Dominant',
    },
    {'arabic': 'الْوَهَّابُ', 'transliteration': 'Al-Wahhab', 'meaning': 'The Bestower, The Giver'},
    {
      'arabic': 'الرَّزَّاقُ',
      'transliteration': 'Ar-Razzaq',
      'meaning': 'The Provider, The Sustainer',
    },
    {'arabic': 'الْفَتَّاحُ', 'transliteration': 'Al-Fattah', 'meaning': 'The Opener, The Judge'},
    {
      'arabic': 'الْعَلِيمُ',
      'transliteration': 'Al-Aleem',
      'meaning': 'The All-Knowing, The Omniscient',
    },
    {
      'arabic': 'الْقَابِضُ',
      'transliteration': 'Al-Qabid',
      'meaning': 'The Restrainer, The Straightener',
    },
    {
      'arabic': 'الْبَاسِطُ',
      'transliteration': 'Al-Basit',
      'meaning': 'The Expander, The Munificent',
    },
    {'arabic': 'الْخَافِضُ', 'transliteration': 'Al-Khafid', 'meaning': 'The Abaser, The Humbler'},
    {'arabic': 'الرَّافِعُ', 'transliteration': 'Ar-Rafi', 'meaning': 'The Exalter, The Elevator'},
    {
      'arabic': 'الْمُعِزُّ',
      'transliteration': 'Al-Muizz',
      'meaning': 'The Honorer, The Bestower of Honor',
    },
    {
      'arabic': 'الْمُذِلُّ',
      'transliteration': 'Al-Mudhill',
      'meaning': 'The Humiliator, The Degrader',
    },
    {'arabic': 'السَّمِيعُ', 'transliteration': 'As-Samee', 'meaning': 'The All-Hearing'},
    {'arabic': 'الْبَصِيرُ', 'transliteration': 'Al-Baseer', 'meaning': 'The All-Seeing'},
    {'arabic': 'الْحَكَمُ', 'transliteration': 'Al-Hakam', 'meaning': 'The Judge, The Arbitrator'},
    {'arabic': 'الْعَدْلُ', 'transliteration': 'Al-Adl', 'meaning': 'The Utterly Just'},
    {
      'arabic': 'اللَّطِيفُ',
      'transliteration': 'Al-Lateef',
      'meaning': 'The Gentle, The Subtle One',
    },
    {'arabic': 'الْخَبِيرُ', 'transliteration': 'Al-Khabeer', 'meaning': 'The All-Aware'},
    {
      'arabic': 'الْحَلِيمُ',
      'transliteration': 'Al-Haleem',
      'meaning': 'The Forbearing, The Indulgent',
    },
    {
      'arabic': 'الْعَظِيمُ',
      'transliteration': 'Al-Azeem',
      'meaning': 'The Magnificent, The Infinite',
    },
    {'arabic': 'الْغَفُورُ', 'transliteration': 'Al-Ghafoor', 'meaning': 'The Forgiving'},
    {'arabic': 'الشَّكُورُ', 'transliteration': 'Ash-Shakoor', 'meaning': 'The Appreciative'},
    {'arabic': 'الْعَلِيُّ', 'transliteration': 'Al-Ali', 'meaning': 'The Sublime, The Most High'},
    {
      'arabic': 'الْكَبِيرُ',
      'transliteration': 'Al-Kabeer',
      'meaning': 'The Greatest, The Most Grand',
    },
    {'arabic': 'الْحَفِيظُ', 'transliteration': 'Al-Hafeez', 'meaning': 'The Preserver'},
    {'arabic': 'الْمُقِيتُ', 'transliteration': 'Al-Muqeet', 'meaning': 'The Nourisher'},
    {'arabic': 'الْحَسِيبُ', 'transliteration': 'Al-Haseeb', 'meaning': 'The Reckoner'},
    {'arabic': 'الْجَلِيلُ', 'transliteration': 'Al-Jaleel', 'meaning': 'The Majestic'},
    {'arabic': 'الْكَرِيمُ', 'transliteration': 'Al-Kareem', 'meaning': 'The Generous, The Noble'},
    {'arabic': 'الرَّقِيبُ', 'transliteration': 'Ar-Raqeeb', 'meaning': 'The Watchful'},
    {'arabic': 'الْمُجِيبُ', 'transliteration': 'Al-Mujeeb', 'meaning': 'The Responsive'},
    {'arabic': 'الْوَاسِعُ', 'transliteration': 'Al-Wasi', 'meaning': 'The All-Encompassing'},
    {'arabic': 'الْحَكِيمُ', 'transliteration': 'Al-Hakeem', 'meaning': 'The Wise'},
    {'arabic': 'الْوَدُودُ', 'transliteration': 'Al-Wadood', 'meaning': 'The Loving'},
    {'arabic': 'الْمَجِيدُ', 'transliteration': 'Al-Majeed', 'meaning': 'The Glorious'},
    {'arabic': 'الْبَاعِثُ', 'transliteration': 'Al-Ba\'ith', 'meaning': 'The Resurrector'},
    {'arabic': 'الشَّهِيدُ', 'transliteration': 'Ash-Shaheed', 'meaning': 'The Witness'},
    // Adding more names for completeness...
    {'arabic': 'الْحَقُّ', 'transliteration': 'Al-Haqq', 'meaning': 'The Truth'},
    {'arabic': 'الْوَكِيلُ', 'transliteration': 'Al-Wakeel', 'meaning': 'The Trustee'},
    {'arabic': 'الْقَوِيُّ', 'transliteration': 'Al-Qawiyy', 'meaning': 'The Strong'},
    {'arabic': 'الْمَتِينُ', 'transliteration': 'Al-Mateen', 'meaning': 'The Firm'},
    {'arabic': 'الْوَلِيُّ', 'transliteration': 'Al-Waliyy', 'meaning': 'The Protecting Friend'},
    {'arabic': 'الْحَمِيدُ', 'transliteration': 'Al-Hameed', 'meaning': 'The Praiseworthy'},
    {'arabic': 'الْمُحْصِي', 'transliteration': 'Al-Muhsee', 'meaning': 'The Counter'},
    {'arabic': 'الْمُبْدِئُ', 'transliteration': 'Al-Mubdi', 'meaning': 'The Originator'},
    {'arabic': 'الْمُعِيدُ', 'transliteration': 'Al-Mu\'eed', 'meaning': 'The Restorer'},
    {'arabic': 'الْمُحْيِي', 'transliteration': 'Al-Muhyee', 'meaning': 'The Giver of Life'},
    {'arabic': 'الْمُمِيتُ', 'transliteration': 'Al-Mumeet', 'meaning': 'The Creator of Death'},
    {'arabic': 'الْحَيُّ', 'transliteration': 'Al-Hayy', 'meaning': 'The Ever Living'},
    {'arabic': 'الْقَيُّومُ', 'transliteration': 'Al-Qayyoom', 'meaning': 'The Self Sustaining'},
    {'arabic': 'الْوَاجِدُ', 'transliteration': 'Al-Wajid', 'meaning': 'The Perceiver'},
    {'arabic': 'الْمَاجِدُ', 'transliteration': 'Al-Majid', 'meaning': 'The Illustrious'},
    {'arabic': 'الْوَاحِدُ', 'transliteration': 'Al-Wahid', 'meaning': 'The One'},
    {'arabic': 'الأَحَدُ', 'transliteration': 'Al-Ahad', 'meaning': 'The Unique'},
    {'arabic': 'الصَّمَدُ', 'transliteration': 'As-Samad', 'meaning': 'The Eternal'},
    {'arabic': 'الْقَادِرُ', 'transliteration': 'Al-Qadir', 'meaning': 'The Able'},
    {'arabic': 'الْمُقْتَدِرُ', 'transliteration': 'Al-Muqtadir', 'meaning': 'The Powerful'},
    {'arabic': 'الْمُقَدِّمُ', 'transliteration': 'Al-Muqaddim', 'meaning': 'The Expediter'},
    {'arabic': 'الْمُؤَخِّرُ', 'transliteration': 'Al-Mu\'akhkhir', 'meaning': 'The Delayer'},
    {'arabic': 'الأَوَّلُ', 'transliteration': 'Al-Awwal', 'meaning': 'The First'},
    {'arabic': 'الآخِرُ', 'transliteration': 'Al-Akhir', 'meaning': 'The Last'},
    {'arabic': 'الظَّاهِرُ', 'transliteration': 'Az-Zahir', 'meaning': 'The Manifest'},
    {'arabic': 'الْبَاطِنُ', 'transliteration': 'Al-Batin', 'meaning': 'The Hidden'},
    {'arabic': 'الْوَالِي', 'transliteration': 'Al-Wali', 'meaning': 'The Governor'},
    {'arabic': 'الْمُتَعَالِي', 'transliteration': 'Al-Muta\'ali', 'meaning': 'The Self Exalted'},
    {'arabic': 'الْبَرُّ', 'transliteration': 'Al-Barr', 'meaning': 'The Source of All Goodness'},
    {
      'arabic': 'التَّوَّابُ',
      'transliteration': 'At-Tawwab',
      'meaning': 'The Acceptor of Repentance',
    },
    {'arabic': 'الْمُنْتَقِمُ', 'transliteration': 'Al-Muntaqim', 'meaning': 'The Avenger'},
    {'arabic': 'الْعَفُوُّ', 'transliteration': 'Al-\'Afuww', 'meaning': 'The Pardoner'},
    {'arabic': 'الرَّؤُوفُ', 'transliteration': 'Ar-Ra\'oof', 'meaning': 'The Compassionate'},
    {
      'arabic': 'مَالِكُ الْمُلْكِ',
      'transliteration': 'Malik-ul-Mulk',
      'meaning': 'Master of the Kingdom',
    },
    {
      'arabic': 'ذُو الْجَلَالِ وَالْإِكْرَامِ',
      'transliteration': 'Dhul-Jalali wal-Ikram',
      'meaning': 'Lord of Majesty and Generosity',
    },
    {'arabic': 'الْمُقْسِطُ', 'transliteration': 'Al-Muqsit', 'meaning': 'The Just'},
    {'arabic': 'الْجَامِعُ', 'transliteration': 'Al-Jami\'', 'meaning': 'The Gatherer'},
    {'arabic': 'الْغَنِيُّ', 'transliteration': 'Al-Ghaniyy', 'meaning': 'The Self-Sufficient'},
    {'arabic': 'الْمُغْنِي', 'transliteration': 'Al-Mughni', 'meaning': 'The Enricher'},
    {'arabic': 'الْمَانِعُ', 'transliteration': 'Al-Mani\'', 'meaning': 'The Preventer'},
    {'arabic': 'الضَّارُّ', 'transliteration': 'Ad-Darr', 'meaning': 'The Distresser'},
    {'arabic': 'النَّافِعُ', 'transliteration': 'An-Nafi\'', 'meaning': 'The Benefiter'},
    {'arabic': 'النُّورُ', 'transliteration': 'An-Nur', 'meaning': 'The Light'},
    {'arabic': 'الْهَادِي', 'transliteration': 'Al-Hadi', 'meaning': 'The Guide'},
    {'arabic': 'الْبَدِيعُ', 'transliteration': 'Al-Badi\'', 'meaning': 'The Incomparable'},
    {'arabic': 'الْبَاقِي', 'transliteration': 'Al-Baqi', 'meaning': 'The Everlasting'},
    {'arabic': 'الْوَارِثُ', 'transliteration': 'Al-Warith', 'meaning': 'The Inheritor'},
    {'arabic': 'الرَّشِيدُ', 'transliteration': 'Ar-Rasheed', 'meaning': 'The Guide to Right Path'},
    {'arabic': 'الصَّبُورُ', 'transliteration': 'As-Saboor', 'meaning': 'The Patient'},
  ];

  @override
  void initState() {
    super.initState();
    _filteredNames = _allahNames;
  }

  void _filterNames(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredNames = _allahNames;
      } else {
        _filteredNames = _allahNames.where((name) {
          return name['transliteration'].toLowerCase().contains(query.toLowerCase()) ||
              name['meaning'].toLowerCase().contains(query.toLowerCase()) ||
              name['arabic'].contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E4F3),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '99 Names of Allah',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              'أسماء الله الحسنى',
              style: GoogleFonts.amiri(fontSize: 14, color: Colors.white.withOpacity(0.9)),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: primary,
            child: TextField(
              controller: _searchController,
              onChanged: _filterNames,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search names...',
                hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
              ),
            ),
          ),

          // Names List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredNames.length,
              itemBuilder: (context, index) {
                return _buildNameCard(_filteredNames[index], index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameCard(Map<String, dynamic> name, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Number Circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Center(
                child: Text(
                  '$number',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Name Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arabic Name
                  Text(
                    name['arabic'],
                    style: GoogleFonts.amiri(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: primary,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 4),
                  // Transliteration
                  Text(
                    name['transliteration'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Meaning
                  Text(
                    name['meaning'],
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Play Button (for future audio implementation)
            IconButton(
              icon: Icon(Icons.play_circle_outline, color: primary, size: 28),
              onPressed: () {
                // Future: Add audio pronunciation
                Get.snackbar(
                  'Audio',
                  'Audio pronunciation coming soon!',
                  backgroundColor: primary.withOpacity(0.9),
                  colorText: Colors.white,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
