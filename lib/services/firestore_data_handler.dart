import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:developer' as developer;

import 'package:cragon/services/utilities.dart';


class FirestoreDataHandler {
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final String avatarImageDirectory = "avatarImages";
  final String dragonsDirectory = "dragonsGalleries";

  Future<List<Image>> getDragonGalleryImages(String dragonDirectoryName) async {
    Reference ref = firebaseStorage.ref().child(dragonsDirectory).child(dragonDirectoryName);
    ListResult refList = await ref.listAll();
    List<Image> imageWidgets = [];

    if (refList.items.isEmpty) {
      developer.log("Log: getDragonGallery() -> refList.items.isEmpty");
      return [];
    }

    await Future.forEach(refList.items, (Reference reference) async {
      String downloadURL = await reference.getDownloadURL();
      Image image = Image.network(downloadURL);
      imageWidgets.add(image);
    });

    return imageWidgets;
  }

  Future<List<String>> getDragonGalleryUrl(String dragonDirectoryName) async {
    Reference ref = firebaseStorage.ref().child(dragonsDirectory).child(dragonDirectoryName);
    ListResult refList = await ref.listAll();
    List<String> imagesUrl = [];

    if (refList.items.isEmpty) {
      developer.log("Log: getDragonGallery() -> refList.items.isEmpty");
      return [];
    }

    await Future.forEach(refList.items, (Reference reference) async {
      String downloadURL = await reference.getDownloadURL();
      imagesUrl.add(downloadURL);
    });

    return imagesUrl;
  }

  Future<String> uploadImageToFirebaseStorage(String fileDirectory, Uint8List image) async {
    Reference ref = firebaseStorage.ref().child(fileDirectory).child("${FirebaseAuth.instance.currentUser!.email}_avatar.jpg");
    UploadTask uploadTask = ref.putData(image, SettableMetadata(contentType: "image/jpeg"));
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  void deleteFileFromFirebaseStorage(String fileDirectory, String name) async {
    try {
      Reference ref = firebaseStorage.ref().child(fileDirectory).child(name);
      await ref.delete();
      developer.log("Log: Avatar image has been removed from FirebaseStorage");
    } catch(e) {
      developer.log("Log: deleteImageFromFirebaseStorage() -> $e");
    }
  }

  Future<void> updateUserAvatarImage({
    required Uint8List image
  }) async {
      try {
        String imageUrl = await uploadImageToFirebaseStorage(avatarImageDirectory, image);
        String uid = FirebaseAuth.instance.currentUser!.uid;

        await usersCollection.doc(uid).update(
          {
            'avatarImage': imageUrl,
          },
        );
        
      } catch(e) {
        developer.log("Log: updateAvatarImage() -> $e");
      }
  }

  Future<void> removeUserAvatarImage({String inUid = ""}) async {
    try {
      String uid;
      if (inUid.isEmpty) {
        uid = FirebaseAuth.instance.currentUser!.uid;
      } else {
        uid = inUid;
      }

      String imageUrl = await getUserAvatarImage(inUid: uid);

      if (imageUrl.isEmpty) {
        developer.log("Log: Avatar image is already empty");
        showAlertMessage("Avatar image is already empty");
        return;
      }
      String fileName = "${FirebaseAuth.instance.currentUser!.email}_avatar.jpg";

      deleteFileFromFirebaseStorage(avatarImageDirectory, fileName);

      await usersCollection.doc(uid).update(
        {
          'avatarImage': ''
        },
      );
    } catch(e) {
      developer.log("Log: removeAvatarImage() -> $e");
    }
  }

  
  Future<String> getUserAvatarImage({String inUid = ""}) async {
    try {
      String uid;

      if (inUid.isEmpty) {
        uid = FirebaseAuth.instance.currentUser!.uid;
      } else {
        uid = inUid;
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: uid).get();

      return await querySnapshot.docs.first['avatarImage'];
    } catch (e) {
      developer.log("Log: getUserAvatarImage() -> $e");
      
      return "";
    }
  }

  void manageDragon({required String dragonDirectoryName, required bool toCatch}) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      developer.log("Log: catchDragon() -> currentUser is null");
      return;
    }

    try {
      if (toCatch) {
        await usersCollection.doc(currentUser.uid).update(
          {
            'caughtDragons': FieldValue.arrayUnion([dragonDirectoryName]),
          },
        );
      } else {
        await usersCollection.doc(currentUser.uid).update(
          {
            'caughtDragons': FieldValue.arrayRemove([dragonDirectoryName]),
          },
        );
      }
    } catch (e) {
      developer.log("Log: catchDragon() -> $e");
      return;
    }
  }
}