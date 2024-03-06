import 'package:cragon/main.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;


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
      backgroundColor: Colors.lightBlue.shade300,
      title: Text(
        message, 
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center
      )
    )
  ));
}