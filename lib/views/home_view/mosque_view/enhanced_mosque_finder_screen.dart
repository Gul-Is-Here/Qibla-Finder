import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/location/location_service_helper.dart';
import '../../../services/location/mosque_data_service.dart' as MosqueData;

class Mosque {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distance;
  final String category;
  final List<String> prayerTimes;
  final String phone;
  final String description;

  Mosque({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.category,
    required this.prayerTimes,
    required this.phone,
    required this.description,
  });
}

class EnhancedMosqueFinderController extends GetxController {
  final RxList<Mosque> mosques = <Mosque>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = 'All'.obs;
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isMapView = false.obs;

  GoogleMapController? mapController;
  final Set<Marker> markers = <Marker>{}.obs;

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
    getCurrentLocation();
    loadMosques();
  }

  Future<void> getCurrentLocation() async {
    Position? position = await LocationServiceHelper.getCurrentLocation();
    if (position != null) {
      currentPosition.value = position;
      calculateDistances();
    }
  }

  void loadMosques() {
    isLoading.value = true;

    // Use real Pakistani mosque data
    final mosqueData = MosqueData.MosqueDataService.getSampleMosques();
    final mosqueList = mosqueData
        .map(
          (data) => Mosque(
            id: data['id'],
            name: data['name'],
            address: data['address'],
            latitude: data['latitude'],
            longitude: data['longitude'],
            distance: 0.0, // Will be calculated
            category: data['category'],
            prayerTimes: List<String>.from(data['prayerTimes']),
            phone: data['phone'],
            description: data['description'],
          ),
        )
        .toList();

    mosques.assignAll(mosqueList);
    calculateDistances();
    createMarkers();
    isLoading.value = false;
  }

  void calculateDistances() {
    if (currentPosition.value == null) return;

    for (var mosque in mosques) {
      double distance =
          Geolocator.distanceBetween(
            currentPosition.value!.latitude,
            currentPosition.value!.longitude,
            mosque.latitude,
            mosque.longitude,
          ) /
          1000; // Convert to kilometers

      // Update mosque distance (this is a simplified approach)
      mosques[mosques.indexOf(mosque)] = Mosque(
        id: mosque.id,
        name: mosque.name,
        address: mosque.address,
        latitude: mosque.latitude,
        longitude: mosque.longitude,
        distance: distance,
        category: mosque.category,
        prayerTimes: mosque.prayerTimes,
        phone: mosque.phone,
        description: mosque.description,
      );
    }

    // Sort by distance
    mosques.sort((a, b) => a.distance.compareTo(b.distance));
  }

  void createMarkers() {
    markers.clear();

    for (var mosque in mosques) {
      markers.add(
        Marker(
          markerId: MarkerId(mosque.id),
          position: LatLng(mosque.latitude, mosque.longitude),
          infoWindow: InfoWindow(
            title: mosque.name,
            snippet: mosque.address,
            onTap: () => showMosqueDetails(mosque),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }
  }

  void searchMosques(String query) {
    searchQuery.value = query;
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
  }

  void toggleView() {
    isMapView.value = !isMapView.value;
  }

  void showMosqueDetails(Mosque mosque) {
    Get.bottomSheet(
      _buildMosqueDetailsSheet(mosque),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildMosqueDetailsSheet(Mosque mosque) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00332F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.mosque, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mosque.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${mosque.distance.toStringAsFixed(1)} km away',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            mosque.description,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDirections(mosque),
                  icon: const Icon(Icons.directions),
                  label: const Text('Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00332F),
                    foregroundColor: Colors.white,
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
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
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
      Get.back(); // Close bottom sheet
    } catch (e) {
      Get.snackbar(
        'Directions',
        'Please install Google Maps or Apple Maps to get directions',
        backgroundColor: const Color(0xFF00332F).withOpacity(0.9),
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
        Get.back(); // Close bottom sheet
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

    filtered.sort((a, b) => a.distance.compareTo(b.distance));
    return filtered;
  }
}

class EnhancedMosqueFinderScreen extends StatelessWidget {
  const EnhancedMosqueFinderScreen({super.key});

  Color get primary => const Color(0xFF00332F);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EnhancedMosqueFinderController());

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
          Obx(
            () => IconButton(
              icon: Icon(controller.isMapView.value ? Icons.list : Icons.map, color: Colors.white),
              onPressed: controller.toggleView,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: controller.getCurrentLocation,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
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

            // Main Content
            Expanded(
              child: Obx(
                () => controller.isMapView.value
                    ? _buildMapView(controller)
                    : _buildListView(controller),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMapView(EnhancedMosqueFinderController controller) {
    return Obx(() {
      if (controller.currentPosition.value == null) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Getting your location...'),
            ],
          ),
        );
      }

      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            controller.currentPosition.value!.latitude,
            controller.currentPosition.value!.longitude,
          ),
          zoom: 14,
        ),
        markers: controller.markers,
        onMapCreated: (GoogleMapController mapController) {
          controller.mapController = mapController;
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        compassEnabled: true,
        zoomControlsEnabled: false,
      );
    });
  }

  Widget _buildListView(EnhancedMosqueFinderController controller) {
    return Obx(() {
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
          return _buildMosqueCard(mosque, controller);
        },
      );
    });
  }

  Widget _buildMosqueCard(Mosque mosque, EnhancedMosqueFinderController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.showMosqueDetails(mosque),
        borderRadius: BorderRadius.circular(12),
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

              // Description
              Text(
                mosque.description,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700], height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Quick Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller._showDirections(mosque),
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
                      onPressed: () => controller._callMosque(mosque),
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
      ),
    );
  }
}
