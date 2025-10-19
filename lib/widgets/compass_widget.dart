import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/strings.dart';
import '../controllers/qibla_controller.dart';

class CompassWidget extends StatelessWidget {
  final QiblaController controller;
  final double compassSize;

  const CompassWidget({
    super.key,
    required this.controller,
    required this.compassSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // <- important
      children: [
        // angle cards row ...
        // (unchanged)
        // const SizedBox(height: 10),

        // strictly sized compass stack
        Obx(() {
          final headingRad = controller.heading.value * (pi / 180);
          final qiblaRad = controller.qiblaAngle.value * (pi / 180);
          final compassRotation = -headingRad;
          final qiblaIndicatorAngle = qiblaRad - headingRad;

          final double faceSize = compassSize * 0.6;
          final double ringSize = compassSize * 0.7;
          final double indicatorOffset = -(compassSize * 0.4);

          return SizedBox(
            width: compassSize,
            height: compassSize,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Image.asset(
                  circle,
                  width: ringSize,
                  height: ringSize,
                  fit: BoxFit.contain,
                ),
                Transform.rotate(
                  angle: compassRotation,
                  child: SizedBox(
                    width: faceSize,
                    height: faceSize,
                    child: Image.asset(compass, fit: BoxFit.contain),
                  ),
                ),
                Transform.rotate(
                  angle: qiblaIndicatorAngle,
                  child: Transform.translate(
                    offset: Offset(0, indicatorOffset),
                    child: Image.asset(
                      qiblaIcons3,
                      height: compassSize * 0.12,
                      width: compassSize * 0.12,
                    ),
                  ),
                ),
                Text(
                  "${controller.qiblaAngle.value.toStringAsFixed(0)}°",
                  style: GoogleFonts.poppins(
                    fontSize: compassSize * 0.08,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
