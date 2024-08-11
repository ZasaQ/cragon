import 'package:cragon/pages/camera_object_detection_page.dart';
import 'package:cragon/pages/gallery_object_detection_page.dart';
import 'package:cragon/pages/image_object_detection_page.dart';
import 'package:cragon/services/utilities.dart';
import 'package:flutter/material.dart';

import 'package:cragon/main.dart';


Widget floatingCameraButton() {
  return Container(
    decoration: const BoxDecoration(
      color: Color.fromRGBO(128, 128, 0, 1),
      shape: BoxShape.circle,
    ),  
    child: IconButton(
      iconSize: 50,
      icon: const Icon(Icons.camera),
      onPressed: () {
        switch (utilchoosenObjectDetectionMethod) {
          case "Gallery":
            MyApp.navigatorKey.currentState!.push(
              MaterialPageRoute(builder: (context) => const GalleryObjectDetectionPage()));
            break;
    
          case "Image":
            MyApp.navigatorKey.currentState!.push(
              MaterialPageRoute(builder: (context) => const ImageObjectDetectionPage()));
            break;
    
          case "CameraStream":
            MyApp.navigatorKey.currentState!.push(
              MaterialPageRoute(builder: (context) => const CameraObjectDetectionPage()));
            break;
        }
      },
    ),
  );
}