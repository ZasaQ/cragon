import 'dart:math' show asin, cos, pi, sin, sqrt;
import 'dart:developer' as developer;
import 'package:location/location.dart';

import 'package:cragon/services/utilities.dart';


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
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.deniedForever) {
      showAlertMessage("Access to localization can't be denied");
      return false;
    }

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        showAlertMessage("Access to localization can't be denied");
        return false;
      }
    }

    LocationData currentPosition = await location.getLocation();

    double distance = calculateDistance(
      currentPosition.latitude!,
      currentPosition.longitude!,
      targetLat,
      targetLon,
    );

    return distance <= thresholdInMeters;
  }
}
