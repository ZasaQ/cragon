import 'package:cragon/pages/camera_object_detection_page.dart';
import 'package:cragon/pages/gallery_object_detection_page.dart';
import 'package:cragon/pages/image_object_detection_page.dart';
import 'package:flutter/material.dart';

import 'package:cragon/main.dart';


Widget floatingCameraButton() {
  return IconButton(
    iconSize: 50,
    icon: const Icon(Icons.camera),
    onPressed: () {
      MyApp.navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (context) => const ImageObjectDetectionPage()));
    },
  );
}