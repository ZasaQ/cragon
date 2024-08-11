import 'dart:math' show asin, cos, pi, sin, sqrt;
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;


class LocalizationServices {
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Radius of the Earth in meters
    double dLat = degToRad(lat2 - lat1);
    double dLon = degToRad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
               cos(degToRad(lat1)) * cos(degToRad(lat2)) *
               sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * asin(sqrt(a));

    double rc = R * c;

    developer.log(
      name: "LocalizationServices -> calculateDistance",
      "R * c: $rc");

    return rc;
  }

  double degToRad(double deg) {
    return deg * (pi / 180);
  }

  Future<bool> isCurrentLocationCloseTo(double targetLat, double targetLon, double thresholdInMeters) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    Position currentPosition = await Geolocator.getCurrentPosition();

    double distance = calculateDistance(
      currentPosition.latitude,
      currentPosition.longitude,
      targetLat,
      targetLon,
    );

    return distance <= thresholdInMeters;
  }
}
