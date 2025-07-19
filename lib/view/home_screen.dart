import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qibla_compass_offline/constants/strings.dart';

import '../controller/qibla_controller.dart';
import '../routes/app_pages.dart';
import '../widget/compass_widget.dart';
import '../widget/customized_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QiblaController controller = Get.find();

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF00332F),
      appBar: AppBar(
        title: Text(
          'Qibla Compass',
          style: GoogleFonts.poppins(
            // fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(color: Colors.white, height: 2.0),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Obx(
            () => IconButton(
              icon: Badge(
                isLabelVisible: !controller.isOnline.value,
                child: const Icon(Icons.wifi, color: Colors.white),
              ),
              onPressed: () {
                Get.snackbar(
                  'Connection Status',
                  controller.isOnline.value
                      ? 'You are online'
                      : 'You are offline - using device sensors only',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.white,
                );
              },
            ),
          ),
        ],
      ),
      drawer: buildDrawer(context),
      body: Stack(
        children: [
          // Background image fitted to bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              compassBg, // Replace with your asset path
              width: screenWidth,
              fit: BoxFit.fitWidth,
              alignment: Alignment.bottomCenter,
            ),
          ),

          // Main content
          Column(
            children: [
              SizedBox(height: 20),
              // Compass header
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.symmetric(vertical: 8),
                width: screenWidth * 0.7,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF01823D), Color(0xFF01823D)],
                    stops: [0.1, 0.9],
                  ),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Compass',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Info cards
              SizedBox(height: 20),
              // Compass with indicators
              Expanded(
                child: Obx(() {
                  
                  if (!controller.compassReady.value ||
                      !controller.locationReady.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Compass Widget
                      
                      CompassWidget(controller: controller),

                      // Qibla Indicator
                    ],
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
