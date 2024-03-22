import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:cragon/main.dart';


CollectionReference usersCollection = FirebaseFirestore.instance.collection("users");

Future<String?> getUserIdByUid(String currentUserId) async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: currentUserId).get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      return null;
    }
  } catch (e) {
    developer.log('Log: error getting user ID by UID: $e');
    return null;
  }
}

void showAlertMessage(final String message) {
  showDialog(context: MyApp.navigatorKey.currentContext!, builder: (context) => Center(
    child: AlertDialog(
      backgroundColor: const Color.fromRGBO(128, 128, 0, 1),
      title: Text(
        message, 
        style: const TextStyle(color: Colors.black),
        textAlign: TextAlign.center
      )
    )
  ));
}

Future<Uint8List> pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? pickedImage = await imagePicker.pickImage(source: source);

  if (pickedImage == null) {
    developer.log("Log: No image picked");
    return Uint8List(0);
  }

  return await pickedImage.readAsBytes();
}