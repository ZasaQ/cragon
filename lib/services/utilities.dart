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