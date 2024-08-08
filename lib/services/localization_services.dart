import 'dart:math' show asin, cos, pi, sin, sqrt;
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as developer;

class LocalizationServices {
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Radius of the Earth in meters
    double dLat = _deg2rad(lat2 - lat1);
    double dLon = _deg2rad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
               cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
               sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * asin(sqrt(a));

    developer.log(name: "LocalizationServices -> calculateDistance", "R * c: ${R * c}");

    return R * c;
  }

  double _deg2rad(double deg) {
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
