import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/compass_controller/qibla_controller.dart';

class IslamicCompassWidget extends StatefulWidget {
  final QiblaController controller;
  final double compassSize;

  const IslamicCompassWidget({super.key, required this.controller, required this.compassSize});

  @override
  State<IslamicCompassWidget> createState() => _IslamicCompassWidgetState();
}

class _IslamicCompassWidgetState extends State<IslamicCompassWidget> with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;

  // Islamic color palette
  static const Color goldAccent = Color.fromARGB(255, 237, 184, 10);
  static const Color deepTeal = Color(0xFF8F66FF);
  static const Color emeraldGreen = Color(0xFF8F66FF);
  static const Color moonWhite = Color(0xFFF8F4E9);
  static const Color darkNight = Color(0xFF0A1F2E);

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)
      ..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final headingRad = widget.controller.heading.value * (pi / 180);
      final qiblaRad = widget.controller.qiblaAngle.value * (pi / 180);
      final compassRotation = -headingRad;
      final qiblaIndicatorAngle = qiblaRad - headingRad;

      // Check if user is facing Qibla (within 5 degrees)
      final headingDiff =
          ((widget.controller.heading.value - widget.controller.qiblaAngle.value) % 360).abs();
      final isFacingQibla = headingDiff < 5 || headingDiff > 355;

      return SizedBox(
        width: widget.compassSize,
        height: widget.compassSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Outer glow ring when facing Qibla
            if (isFacingQibla)
              AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    width: widget.compassSize,
                    height: widget.compassSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: goldAccent.withOpacity(0.3 + _glowController.value * 0.4),
                          blurRadius: 40 + (_glowController.value * 20),
                          spreadRadius: 10 + (_glowController.value * 10),
                        ),
                        BoxShadow(
                          color: emeraldGreen.withOpacity(0.2 + _glowController.value * 0.3),
                          blurRadius: 60,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  );
                },
              ),

            // Compass ring with degrees
            _buildCompassRing(compassRotation),

            // Inner decorative circle
            Container(
              width: widget.compassSize * 0.75,
              height: widget.compassSize * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: goldAccent.withOpacity(0.3), width: 2),
              ),
            ),

            // Main compass face
            Transform.rotate(
              angle: compassRotation,
              child: Container(
                width: widget.compassSize * 0.65,
                height: widget.compassSize * 0.65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [deepTeal.withOpacity(0.8), darkNight.withOpacity(0.9)],
                  ),
                ),
                child: CustomPaint(
                  painter: _CompassFacePainter(goldColor: goldAccent, whiteColor: moonWhite),
                  size: Size(widget.compassSize * 0.65, widget.compassSize * 0.65),
                ),
              ),
            ),

            // Qibla direction indicator
            Transform.rotate(
              angle: qiblaIndicatorAngle,
              child: _buildQiblaIndicator(isFacingQibla),
            ),

            // Center Kaaba icon with glow
            _buildCenterKaabaIcon(isFacingQibla),

            // Facing Qibla indicator text
            if (isFacingQibla)
              Positioned(top: widget.compassSize * 1.1, child: _buildFacingQiblaIndicator()),
          ],
        ),
      );
    });
  }

  Widget _buildCompassRing(double rotation) {
    return Transform.rotate(
      angle: rotation,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: widget.compassSize,
            height: widget.compassSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  goldAccent.withOpacity(0.4),
                  emeraldGreen.withOpacity(0.3),
                  goldAccent.withOpacity(0.2),
                  emeraldGreen.withOpacity(0.3),
                  goldAccent.withOpacity(0.4),
                ],
              ),
              border: Border.all(color: goldAccent.withOpacity(0.5), width: 2),
            ),
          ),
          // Degree markers
          CustomPaint(
            size: Size(widget.compassSize, widget.compassSize),
            painter: _DegreeMarkersPainter(goldColor: goldAccent, whiteColor: moonWhite),
          ),
        ],
      ),
    );
  }

  Widget _buildQiblaIndicator(bool isFacingQibla) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Qibla direction line
        Container(
          width: 3,
          height: widget.compassSize * 0.4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [isFacingQibla ? goldAccent : emeraldGreen, Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Qibla icon at top
        Positioned(
          top: -widget.compassSize * 0.05,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = isFacingQibla ? 1.0 + (_pulseController.value * 0.15) : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isFacingQibla ? goldAccent : emeraldGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isFacingQibla ? goldAccent : emeraldGreen).withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.mosque,
                    color: isFacingQibla ? darkNight : moonWhite,
                    size: widget.compassSize * 0.08,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCenterKaabaIcon(bool isFacingQibla) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: widget.compassSize * 0.25,
          height: widget.compassSize * 0.25,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                (isFacingQibla ? goldAccent : emeraldGreen).withOpacity(0.3),
                Colors.transparent,
              ],
            ),
            border: Border.all(color: goldAccent.withOpacity(0.5), width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.controller.qiblaAngle.value.toStringAsFixed(0)}°',
                  style: GoogleFonts.cinzel(
                    fontSize: widget.compassSize * 0.06,
                    fontWeight: FontWeight.bold,
                    color: goldAccent,
                  ),
                ),
                Text(
                  'QIBLA',
                  style: GoogleFonts.poppins(
                    fontSize: widget.compassSize * 0.025,
                    color: moonWhite.withOpacity(0.8),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFacingQiblaIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [goldAccent.withOpacity(0.3), emeraldGreen.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: goldAccent, width: 2),
        boxShadow: [BoxShadow(color: goldAccent.withOpacity(0.5), blurRadius: 20, spreadRadius: 2)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: goldAccent, size: 20),
          const SizedBox(width: 8),
          Text(
            'Facing Qibla',
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: moonWhite),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}

// Compass face painter with cardinal directions
class _CompassFacePainter extends CustomPainter {
  final Color goldColor;
  final Color whiteColor;

  _CompassFacePainter({required this.goldColor, required this.whiteColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Cardinal directions
    final directions = ['N', 'E', 'S', 'W'];

    for (int i = 0; i < 4; i++) {
      final angle = (i * pi / 2) - (pi / 2);
      final textOffset = Offset(
        center.dx + (radius * 0.75) * cos(angle),
        center.dy + (radius * 0.75) * sin(angle),
      );

      // Draw cardinal letter
      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: i == 0 ? goldColor : whiteColor.withOpacity(0.9),
            fontSize: size.width * 0.1,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, textOffset - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    // Draw inner circle
    final innerCirclePaint = Paint()
      ..color = goldColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.5, innerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Degree markers painter
class _DegreeMarkersPainter extends CustomPainter {
  final Color goldColor;
  final Color whiteColor;

  _DegreeMarkersPainter({required this.goldColor, required this.whiteColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final majorTickPaint = Paint()
      ..color = goldColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final minorTickPaint = Paint()
      ..color = whiteColor.withOpacity(0.4)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    // Draw tick marks
    for (int i = 0; i < 360; i += 5) {
      final angle = (i * pi / 180) - (pi / 2);
      final isMajor = i % 30 == 0;
      final innerRadius = radius * (isMajor ? 0.85 : 0.9);
      final outerRadius = radius * 0.95;

      final start = Offset(
        center.dx + innerRadius * cos(angle),
        center.dy + innerRadius * sin(angle),
      );
      final end = Offset(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );

      canvas.drawLine(start, end, isMajor ? majorTickPaint : minorTickPaint);

      // Draw degree numbers for major ticks
      if (i % 30 == 0 && i % 90 != 0) {
        final textOffset = Offset(
          center.dx + (radius * 0.75) * cos(angle),
          center.dy + (radius * 0.75) * sin(angle),
        );

        final textPainter = TextPainter(
          text: TextSpan(
            text: '$i°',
            style: TextStyle(color: whiteColor.withOpacity(0.6), fontSize: size.width * 0.04),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          textOffset - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
