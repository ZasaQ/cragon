import "package:cloud_firestore/cloud_firestore.dart";
import "package:cragon/services/api_utils.dart";
import "package:flutter/material.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:flutter_polyline_points/flutter_polyline_points.dart";
import "package:location/location.dart";
import 'dart:developer' as developer;
import "dart:async";


class MapPage extends StatefulWidget {
  const MapPage({
    super.key,
    required this.dragonLocation
  });

  final GeoPoint dragonLocation;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final LatLng defaultLocation                       = const LatLng(50.061814, 19.939275);
  LatLng? currentLocation;
  final double defaultZoom                           = 16.0;
  double? currentZoom;
  Location locationController                        = Location();
  final Completer<GoogleMapController> mapController = Completer<GoogleMapController>();
  late StreamSubscription<LocationData> locationListener;
  BitmapDescriptor? dragonIcon;
  Map<PolylineId, Polyline> polylines = {};
  bool followUser = true;

  @override
  void initState() {
    super.initState();
      
    getCurrentLocationUpdated();
  }

  @override
  void dispose() {
    locationListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(),
      'lib/images/dragon_location_icon.png').then((onValue) {dragonIcon = onValue;});

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Navigation",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color.fromRGBO(128, 128, 0, 1),
            fontWeight: FontWeight.bold
          )
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color.fromRGBO(128, 128, 0, 1)),
        backgroundColor: const Color.fromRGBO(38, 45, 53, 1),
        actions: <Widget>[
          TextButton(onPressed: () {
            setState(() {
              followUser = !followUser;
            });
          },
            child: followUser 
              ? const Icon(Icons.my_location)
              : const Icon(Icons.location_searching))
        ],
      ),
      body: currentLocation == null 
        ? const CircularProgressIndicator() 
        : GoogleMap(
            mapType: MapType.terrain,
            initialCameraPosition: CameraPosition(
              target: currentLocation!,
              zoom: currentZoom ?? defaultZoom
            ),
            onMapCreated: (GoogleMapController controller) =>
              mapController.complete(controller),
            onCameraMove: (position) {
              if (position.zoom != currentZoom) {
                currentZoom = position.zoom;
              }
            },
            markers: {
              Marker(
                markerId: const MarkerId("currentLocation"),
                icon: BitmapDescriptor.defaultMarker,
                position: currentLocation!
              ),
              Marker(
                markerId: const MarkerId("dragonLocation"),
                icon: dragonIcon ?? BitmapDescriptor.defaultMarker,
                position: LatLng(widget.dragonLocation.latitude, widget.dragonLocation.longitude)
              ),
            },
            polylines: Set<Polyline>.of(polylines.values)
          ),
    );
  }

  Future<void> cameraToPosition(LatLng toPosition) async {
    final GoogleMapController controller = await mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: toPosition, zoom: currentZoom ?? defaultZoom)
      )
    );
  }

  Future<void> getCurrentLocationUpdated() async {
    bool isLocalizationAvailable;
    PermissionStatus localizationPermissionGranted;

    isLocalizationAvailable = await locationController.serviceEnabled();

    if (isLocalizationAvailable) {
      isLocalizationAvailable = await locationController.requestService();
    } else {
      return;
    }

    localizationPermissionGranted = await locationController.hasPermission();

    if (localizationPermissionGranted == PermissionStatus.denied) {
      localizationPermissionGranted = await locationController.requestPermission();

      if (localizationPermissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationListener = locationController.onLocationChanged.listen((LocationData newCurrentLocation) {
      if (newCurrentLocation.latitude == null || newCurrentLocation.longitude == null) {
        return;
      }

      setState(() {
        currentLocation = LatLng(newCurrentLocation.latitude!, newCurrentLocation.longitude!);
        developer.log("Log: currentLocation: $currentLocation");

        if (followUser) {
          cameraToPosition(currentLocation!);
        }

        generatePolylinePoints().then((coordinates) => generatePolylineRoute(coordinates));
      });
    });
  }

  Future<List<LatLng>> generatePolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    if (currentLocation == null) {
      return [];
    }

    PolylineResult polylineResult = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(currentLocation!.latitude, currentLocation!.longitude),
      PointLatLng(widget.dragonLocation.latitude, widget.dragonLocation.longitude),
      travelMode: TravelMode.walking
    );
    
    if (polylineResult.points.isEmpty) {
      developer.log("Log: generatePolylineRoute() -> ${polylineResult.errorMessage}");
    } else {
      for (PointLatLng element in polylineResult.points) {
        polylineCoordinates.add(LatLng(element.latitude, element.longitude));
      }
    }

    return polylineCoordinates;
  }

  void generatePolylineRoute(List<LatLng> polylineCoordinates) async {
    if (polylineCoordinates.isEmpty) {
      return;
    }

    PolylineId id = const PolylineId("route");
    Polyline inPolyline = Polyline(
      polylineId: id,
      color: const Color.fromRGBO(128, 128, 0, 1),
      points: polylineCoordinates,
      width: 8
    );

    setState(() {
      polylines[id] = inPolyline;
    });
  }
}