import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qibla_compass_offline/constants/strings.dart';

import '../controller/qibla_controller.dart';

class CompassWidget extends StatelessWidget {
  final QiblaController controller;

  const CompassWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Angle display cards
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Your angle to Qibla (dynamic difference between heading and Qibla)
              Obx(
                () => _buildInfoCard(
                  'Your angle to Qibla',
                  '${((controller.heading.value - controller.qiblaAngle.value + 360) % 360).toStringAsFixed(0)}°',
                ),
              ),
              // Qibla angle from North (static Qibla direction)
              Obx(
                () => _buildInfoCard(
                  'Qibla angle from N',
                  '${(controller.qiblaAngle % 360).toStringAsFixed(0)}°',
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 50),
        // Compass visualization
        SizedBox(height: 20),
        Obx(() {
          final headingRad = controller.heading.value * (pi / 180);
          final qiblaRad = controller.qiblaAngle.value * (pi / 180);
          final compassRotation = -headingRad;
          final qiblaIndicatorAngle = qiblaRad - headingRad;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Outer compass circle
              Image.asset(circle, height: 230, width: 229),

              // Rotating compass face
              Transform.rotate(
                angle: compassRotation,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset(compass),
                ),
              ),

              // Qibla indicator
              Transform.rotate(
                angle: qiblaIndicatorAngle,
                child: Transform.translate(
                  offset: const Offset(0, -130),
                  child: Image.asset(qiblaIcons3, height: 34, width: 34),
                ),
              ),

              // Current angle display
              Text(
                "${controller.qiblaAngle.value.toStringAsFixed(0)}°",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF004D40),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.tealAccent, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
