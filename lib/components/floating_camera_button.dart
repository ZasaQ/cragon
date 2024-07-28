import 'package:flutter/material.dart';

import 'package:cragon/main.dart';
import 'package:cragon/pages/camera_page.dart';
import 'package:cragon/pages/object_detection_page.dart';


Widget floatingCameraButton() {
  return IconButton(
    iconSize: 50,
    icon: const Icon(Icons.camera),
    onPressed: () {
      MyApp.navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (context) => ObjectDetectionPage()));
    },
  );
}