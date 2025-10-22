import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class Mosque {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distance;
  final String category;
  final List<String> prayerTimes;
  final String phone;

  Mosque({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.category,
    required this.prayerTimes,
    required this.phone,
  });
}

class MosqueFinderController extends GetxController {
  final RxList<Mosque> mosques = <Mosque>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;

  final List<String> categories = [
    'All',
    'Masjid',
    'Jamia Masjid',
    'Islamic Center',
    'Community Center',
  ];

  @override
  void onInit() {
    super.onInit();
    loadSampleMosques();
  }

  void loadSampleMosques() {
    isLoading.value = true;

    // Sample mosque data - In a real app, this would come from a location-based API
    final sampleMosques = [
      Mosque(
        name: 'Masjid Al-Noor',
        address: '123 Main Street, City Center',
        latitude: 31.5204,
        longitude: 74.3587,
        distance: 0.5,
        category: 'Masjid',
        prayerTimes: ['5:30 AM', '1:15 PM', '5:45 PM', '7:30 PM', '8:45 PM'],
        phone: '+92-xxx-xxxxxxx',
      ),
      Mosque(
        name: 'Jamia Masjid Central',
        address: '456 Community Road, Downtown',
        latitude: 31.5254,
        longitude: 74.3637,
        distance: 1.2,
        category: 'Jamia Masjid',
        prayerTimes: ['5:25 AM', '1:10 PM', '5:40 PM', '7:25 PM', '8:40 PM'],
        phone: '+92-xxx-xxxxxxx',
      ),
      Mosque(
        name: 'Islamic Center',
        address: '789 Unity Avenue, Suburb',
        latitude: 31.5304,
        longitude: 74.3687,
        distance: 2.1,
        category: 'Islamic Center',
        prayerTimes: ['5:35 AM', '1:20 PM', '5:50 PM', '7:35 PM', '8:50 PM'],
        phone: '+92-xxx-xxxxxxx',
      ),
      Mosque(
        name: 'Masjid Al-Huda',
        address: '321 Peace Street, Old City',
        latitude: 31.5154,
        longitude: 74.3537,
        distance: 3.4,
        category: 'Masjid',
        prayerTimes: ['5:30 AM', '1:15 PM', '5:45 PM', '7:30 PM', '8:45 PM'],
        phone: '+92-xxx-xxxxxxx',
      ),
      Mosque(
        name: 'Community Islamic Center',
        address: '654 Harmony Road, New Town',
        latitude: 31.5404,
        longitude: 74.3787,
        distance: 4.8,
        category: 'Community Center',
        prayerTimes: ['5:28 AM', '1:12 PM', '5:42 PM', '7:28 PM', '8:42 PM'],
        phone: '+92-xxx-xxxxxxx',
      ),
    ];

    mosques.assignAll(sampleMosques);
    isLoading.value = false;
  }

  void searchMosques(String query) {
    searchQuery.value = query;
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
  }

  List<Mosque> get filteredMosques {
    var filtered = mosques.where((mosque) {
      final matchesSearch =
          searchQuery.value.isEmpty ||
          mosque.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          mosque.address.toLowerCase().contains(searchQuery.value.toLowerCase());

      final matchesCategory =
          selectedCategory.value == 'All' || mosque.category == selectedCategory.value;

      return matchesSearch && matchesCategory;
    }).toList();

    // Sort by distance
    filtered.sort((a, b) => a.distance.compareTo(b.distance));
    return filtered;
  }
}

class MosqueFinderScreen extends StatelessWidget {
  const MosqueFinderScreen({super.key});

  Color get primary => const Color(0xFF00332F);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MosqueFinderController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        title: Text(
          'Mosque Finder',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => controller.loadSampleMosques(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: controller.searchMosques,
                  decoration: InputDecoration(
                    hintText: 'Search mosques...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primary),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    itemBuilder: (context, index) {
                      final category = controller.categories[index];
                      return Obx(
                        () => GestureDetector(
                          onTap: () => controller.filterByCategory(category),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: controller.selectedCategory.value == category
                                  ? primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: primary),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: controller.selectedCategory.value == category
                                      ? Colors.white
                                      : primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Mosques List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredMosques = controller.filteredMosques;

              if (filteredMosques.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No mosques found',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Try adjusting your search or filters',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredMosques.length,
                itemBuilder: (context, index) {
                  final mosque = filteredMosques[index];
                  return _buildMosqueCard(mosque);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMosqueCard(Mosque mosque) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.mosque, color: primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mosque.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        mosque.category,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${mosque.distance.toStringAsFixed(1)} km',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Address
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    mosque.address,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Phone
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  mosque.phone,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Prayer Times
            Text(
              'Prayer Times:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildPrayerTime('Fajr', mosque.prayerTimes[0]),
                _buildPrayerTime('Dhuhr', mosque.prayerTimes[1]),
                _buildPrayerTime('Asr', mosque.prayerTimes[2]),
                _buildPrayerTime('Maghrib', mosque.prayerTimes[3]),
                _buildPrayerTime('Isha', mosque.prayerTimes[4]),
              ],
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDirections(mosque),
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(color: primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _callMosque(mosque),
                    icon: const Icon(Icons.call),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTime(String prayer, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
      child: Text(
        '$prayer: $time',
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  void _showDirections(Mosque mosque) async {
    try {
      // Create Google Maps URL for directions
      final String googleMapsUrl =
          'https://www.google.com/maps/search/?api=1&query=${mosque.latitude},${mosque.longitude}';

      // Try to launch Google Maps URL
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
      } else {
        // Fallback to Apple Maps on iOS
        final String appleMapsUrl =
            'https://maps.apple.com/?q=${mosque.latitude},${mosque.longitude}';
        if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
          await launchUrl(Uri.parse(appleMapsUrl), mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch maps';
        }
      }
    } catch (e) {
      // Fallback: Show snackbar if maps app is not available
      Get.snackbar(
        'Directions',
        'Please install Google Maps or Apple Maps to get directions',
        backgroundColor: primary.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _callMosque(Mosque mosque) async {
    final phoneNumber = mosque.phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Get.snackbar(
          'Cannot Call',
          'Unable to make phone calls on this device',
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initiate call: ${e.toString()}',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
