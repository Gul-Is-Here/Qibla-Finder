import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/qibla_controller.dart';

class SimpleCompassWidget extends StatelessWidget {
  final QiblaController controller;
  final double compassSize;

  const SimpleCompassWidget({
    super.key,
    required this.controller,
    required this.compassSize,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final headingRad = controller.heading.value * (pi / 180);
      final qiblaRad = controller.qiblaAngle.value * (pi / 180);
      final compassRotation = -headingRad;
      final qiblaIndicatorAngle = qiblaRad - headingRad;

      return SizedBox(
        width: compassSize,
        height: compassSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Compass circle background
            Container(
              width: compassSize,
              height: compassSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // North indicator (fixed)
            Positioned(
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'N',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Compass needle (rotates with heading)
            Transform.rotate(
              angle: compassRotation,
              child: Container(
                width: 4,
                height: compassSize * 0.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.red,
                      Colors.white,
                      Colors.white,
                      Colors.blue,
                    ],
                    stops: [0.0, 0.45, 0.55, 1.0],
                  ),
                ),
              ),
            ),

            // Qibla direction indicator
            Transform.rotate(
              angle: qiblaIndicatorAngle,
              child: Positioned(
                top: 15,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF8BC34A),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Center dot
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
            ),

            // Direction indicators
            ...List.generate(8, (index) {
              final angle = index * pi / 4;
              final isCardinal = index % 2 == 0;
              final direction = [
                'N',
                'NE',
                'E',
                'SE',
                'S',
                'SW',
                'W',
                'NW',
              ][index];

              return Transform.rotate(
                angle: angle + compassRotation,
                child: Positioned(
                  top: 25,
                  child: Transform.rotate(
                    angle: -angle - compassRotation,
                    child: Text(
                      direction,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isCardinal ? 12 : 10,
                        fontWeight: isCardinal
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}
