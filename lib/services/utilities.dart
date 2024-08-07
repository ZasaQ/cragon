import 'package:flutter/material.dart';

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:cragon/main.dart';


CollectionReference usersCollection = FirebaseFirestore.instance.collection("users");
CollectionReference dragonsCollection = FirebaseFirestore.instance.collection("dragons");
int utilDragonsAmount = 0;
int utilCaughtDragonsAmount = 0;
CameraDescription? utilFirstCamera;
Map<String, LatLng> utilsDragonsPositions = {};

void showAlertMessage(final String message) {
  Timer timer = Timer(const Duration(seconds: 2), () {
    Navigator.of(MyApp.navigatorKey.currentContext!).pop();
  });

  showDialog<String>(context: MyApp.navigatorKey.currentContext!, builder: (context) => Center(
    child: AlertDialog(
      backgroundColor: const Color.fromRGBO(128, 128, 0, 1),
      title: Text(
        message,
        style: const TextStyle(color: Colors.black),
        textAlign: TextAlign.center
      )
    )
  )).then((value) => timer.cancel());
}

void showConfirmationMessage(final String message, Function() onPressed) {
  showDialog<String>(context: MyApp.navigatorKey.currentContext!, builder: (context) => Center(
    child: AlertDialog(
      backgroundColor: const Color.fromRGBO(128, 128, 0, 1),
      title: Text(
        message,
        style: const TextStyle(color: Colors.black),
        textAlign: TextAlign.center
      ),
      actions: <Widget>[
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: onPressed,
                child: const Text('Confirm'),
              ),
              TextButton(
                onPressed: () {Navigator.of(context).pop();},
                child: const Text('Cancel'),
              ),
            ],
          ),
        )
      ]
    )
  ));
}

Future<Uint8List> pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? pickedImage = await imagePicker.pickImage(source: source);

  if (pickedImage == null) {
    developer.log("Log: pickImage() -> No image picked");
    return Uint8List(0);
  }

  return await pickedImage.readAsBytes();
}

Future<CameraDescription?> initBackCamera() async {
  final cameras = await availableCameras();

  for (var inCamera in cameras) {
    if (inCamera.lensDirection == CameraLensDirection.back) {
      return inCamera;
    }
  }
  
  return null;
}