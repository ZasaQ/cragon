import "package:cloud_firestore/cloud_firestore.dart";
import "package:google_maps_flutter/google_maps_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_polyline_points/flutter_polyline_points.dart";
import "package:location/location.dart";
import 'dart:developer' as developer;
import "dart:async";

import "package:cragon/services/api_utils.dart";


class MapPage extends StatefulWidget {
  const MapPage({super.key, this.targetDragonData});

  final Map<String, dynamic>? targetDragonData;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final LatLng defaultLocation = const LatLng(50.061814, 19.939275);
  final double defaultZoom = 16.0;
  LatLng? currentLocation;
  double? currentZoom;
  Location locationController = Location();
  final Completer<GoogleMapController> mapController = Completer<GoogleMapController>();
  late StreamSubscription<LocationData> locationListener;
  BitmapDescriptor? dragonMarkerIcon;
  Map<PolylineId, Polyline> polylines = {};
  bool followUser = true;
  bool isUserInteracting = false;
  bool isProgrammaticMove = false;
  GeoPoint? targetedDragonLocation;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    if (widget.targetDragonData != null) {
      targetedDragonLocation = widget.targetDragonData!["dragonLocation"];
      onDragonMarkerSelected(widget.targetDragonData!["directoryName"]);
    } else {
      fetchDragonMarkers();
    }
    getCurrentLocationUpdated();
  }

  void addDragonMarkerIcon() async {
    if (dragonMarkerIcon == null) {
      await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(),
        'lib/images/dragon_location_icon.png').then((onValue) {dragonMarkerIcon = onValue;});
    }
  }

  Future<void> fetchDragonMarkers() async {
    addDragonMarkerIcon();

    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('dragons').get();
    final List<QueryDocumentSnapshot> documents = snapshot.docs;

    Set<Marker> inMarkers = documents.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final GeoPoint location = data['dragonLocation'];
      final String markerId = data['directoryName'];

      return Marker(
        markerId: MarkerId(markerId),
        icon: dragonMarkerIcon ?? BitmapDescriptor.defaultMarker,
        position: LatLng(location.latitude, location.longitude),
        infoWindow: InfoWindow(
          title: data['displayName'],
          snippet: 'Navigate to',
          onTap: () {
            setState(() {
              targetedDragonLocation = location;
              onDragonMarkerSelected(markerId);
            });
          }
        )
      );
    }).toSet();

    markers.addAll(inMarkers);
  }

  Future<void> onDragonMarkerSelected(String targetDragonId) async {
    clearAllDragonMarkers();
    addDragonMarkerIcon();

    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('dragons').get();
    final List<QueryDocumentSnapshot> documents = snapshot.docs;

    for (QueryDocumentSnapshot document in documents) {
      Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

      if (data == null) continue;

      if (data['directoryName'] != targetDragonId) continue;

      final GeoPoint location = data['dragonLocation'];

      Marker targetDragonMarker = Marker(
        markerId: MarkerId(targetDragonId),
        icon: dragonMarkerIcon ?? BitmapDescriptor.defaultMarker,
        position: LatLng(location.latitude, location.longitude),
        infoWindow: InfoWindow(
          title: data['displayName'],
          snippet: 'Stop navigation',
          onTap: () {
            setState(() {
              targetedDragonLocation = null;
              fetchDragonMarkers();
            });
          }
        )
      );

      markers.add(targetDragonMarker);
      break;
    }

    generatePolylinePoints().then((coordinates) => generatePolylineRoute(coordinates));
  }

  Future<void> onDragonMarkerSelectedByLocation(Map<String, dynamic> inDragonData) async {
    targetedDragonLocation = inDragonData["dragonLocation"];
    onDragonMarkerSelected(inDragonData["directoryName"]);
    generatePolylinePoints().then((coordinates) => generatePolylineRoute(coordinates));
  }

  void clearDragonMarkers(String exceptionDragonId) {
    markers.removeWhere((element) =>
      element.markerId.value != exceptionDragonId && element.markerId.value != "currentLocation");
  }

  void clearAllDragonMarkers() {
    markers.removeWhere((element) =>
      element.markerId.value != "currentLocation");
  }

  @override
  void dispose() {
    locationListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        ? const Center(
            child: CircularProgressIndicator()
          )
        : GoogleMap(
            mapType: MapType.terrain,
            initialCameraPosition: CameraPosition(
              target: currentLocation!,
              zoom: currentZoom ?? defaultZoom
            ),
            onMapCreated: (GoogleMapController controller) =>
              mapController.complete(controller),
            onCameraMoveStarted: () {
              if (!isProgrammaticMove) {
                setState(() {
                  isUserInteracting = true;
                });
                developer.log("Log: Camera movement started by user.");
                followUser = false;
              }
            },
            onCameraMove: (position) {
              if (position.zoom != currentZoom) {
                currentZoom = position.zoom;
              }
            },
            onCameraIdle: () {
              if (isUserInteracting) {
                setState(() {
                  isUserInteracting = false;
                });
                developer.log("Log: Camera movement stopped by user.");
              }
              if (isProgrammaticMove) {
                isProgrammaticMove = false;
              }
            },
            markers: markers,
            polylines: targetedDragonLocation != null ? Set<Polyline>.of(polylines.values) : const <Polyline>{}
          ),
    );
  }

  Future<void> cameraToPosition(LatLng toPosition) async {
    final GoogleMapController controller = await mapController.future;
    setState(() {
      isProgrammaticMove = true;
    });
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

    bool initUpdate = false;
    if (currentLocation == null) {
      initUpdate = true;
    }

    locationListener = locationController.onLocationChanged.listen((LocationData newCurrentLocation) {
      if (newCurrentLocation.latitude == null || newCurrentLocation.longitude == null) {
        return;
      }

      setState(() {
        currentLocation = LatLng(newCurrentLocation.latitude!, newCurrentLocation.longitude!);
        developer.log("Log: currentLocation: $currentLocation");

        if (initUpdate && currentLocation != null) {
          markers.add(Marker(
            markerId: const MarkerId("currentLocation"),
            icon: BitmapDescriptor.defaultMarker,
            position: currentLocation!
          ));
          initUpdate = false;
        }

        if (followUser) {
          cameraToPosition(currentLocation!);
        }

        if (targetedDragonLocation != null)
        {
          generatePolylinePoints().then((coordinates) => generatePolylineRoute(coordinates));
        }
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
      PointLatLng(targetedDragonLocation!.latitude, targetedDragonLocation!.longitude),
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