import 'dart:math';

class QiblaCalculator {
  static const double kaabaLat = 21.422487;
  static const double kaabaLng = 39.826206;

  static double calculateQiblaDirection(double lat, double lng) {
    final double phiK = kaabaLat * pi / 180.0;
    final double lambdaK = kaabaLng * pi / 180.0;
    final double phi = lat * pi / 180.0;
    final double lambda = lng * pi / 180.0;

    final double psi = 180.0 / pi *
        atan2(
          sin(lambdaK - lambda),
          cos(phi) * tan(phiK) - sin(phi) * cos(lambdaK - lambda),
        );

    return psi;
  }
}