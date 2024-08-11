import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:developer' as developer;

import 'package:cragon/services/utilities.dart';
import 'package:cragon/services/localization_services.dart';


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
      developer.log(
        name: "FirestoreDataHandler -> getDragonGalleryImages",
        "$dragonDirectoryName's gallery directory is empty");
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
      developer.log(
        name: "FirestoreDataHandler -> getDragonGalleryUrl",
        "$dragonDirectoryName's gallery directory is empty");
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

      developer.log(
        name: "FirestoreDataHandler -> deleteImageFromFirebaseStorage",
        "Log: Avatar image has been removed from FirebaseStorage");
    } catch(e) {
      developer.log(
        name: "FirestoreDataHandler -> deleteImageFromFirebaseStorage -> exception",
        "$e");
    }
  }

  Future<void> updateUserAvatarImage({
    required Uint8List image
  }) async {
      try {
        String imageUrl = await uploadImageToFirebaseStorage(avatarImageDirectory, image);
        String uid = FirebaseAuth.instance.currentUser!.uid;

        await utilsUsersCollection.doc(uid).update(
          {
            'avatarImage': imageUrl,
          },
        );

        showAlertMessage("Avatar image has been updated", 2);
        developer.log(
          name: "FirestoreDataHandler -> updateUserAvatarImage",
          "Avatar image has been updated");
        
      } catch(e) {
        developer.log(
          name: "FirestoreDataHandler -> updateAvatarImage -> exception",
          "$e");
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
        showAlertMessage("Avatar image is already empty", 2);
        developer.log(
          name: "FirestoreDataHandler -> removeUserAvatarImage",
          "Avatar image is already empty");
        return;
      }
      String fileName = "${FirebaseAuth.instance.currentUser!.email}_avatar.jpg";

      deleteFileFromFirebaseStorage(avatarImageDirectory, fileName);

      await utilsUsersCollection.doc(uid).update(
        {
          'avatarImage': ''
        },
      );

      showAlertMessage("Avatar image has been removed", 2);
      developer.log(
        name: "FirestoreDataHandler -> removeUserAvatarImage",
        "Avatar image has been removed");
    } catch(e) {
      developer.log(
        name: "FirestoreDataHandler -> removeUserAvatarImage -> exception",
        "$e");
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

  void adminManageDragon({required String dragonDirectoryName, required bool toCatch}) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      developer.log(
        name: "FirestoreDataHandler -> adminManageDragon",
        "Current user is null");
      return;
    }

    try {
      if (toCatch) {
        await utilsUsersCollection.doc(currentUser.uid).update(
          {
            'caughtDragons': FieldValue.arrayUnion([dragonDirectoryName]),
          },
        );
        developer.log(
          name: "FirestoreDataHandler -> adminManageDragon",
          "$dragonDirectoryName has been caught");
      } else {
          await utilsUsersCollection.doc(currentUser.uid).update(
            {
              'caughtDragons': FieldValue.arrayRemove([dragonDirectoryName]),
            },
          );
          developer.log(
            name: "FirestoreDataHandler -> adminManageDragon",
            "$dragonDirectoryName has been released");
      }
    } catch (e) {
      developer.log(
        name: "FirestoreDataHandler -> adminManageDragon -> exception",
        "Log: catchDragon() -> $e");
      return;
    }
  }

  void tryCatchDragon({required double imageScore}) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      developer.log(
        name: "FirestoreDataHandler -> tryCatchDragon",
        "Current user is null");
      return;
    }

    if (imageScore < utilImageScoreThreshold) {
      showAlertMessage("Couldn't find dragon on the image", 4);
      developer.log(
        name: "FirestoreDataHandler -> tryCatchDragon",
        "Couldn't find dragon on the image");
      return;
    }

    try {
      QuerySnapshot dragonsSnapshot = await utilsDragonsCollection.get();

      for (QueryDocumentSnapshot dragonDocument in dragonsSnapshot.docs) {
        Map<String, dynamic> data = dragonDocument.data() as Map<String, dynamic>;
        GeoPoint dragonGeoPoint = data["dragonLocation"];
        
        bool isNear = await LocalizationServices().isCurrentLocationCloseTo(
          dragonGeoPoint.latitude, dragonGeoPoint.longitude, 50);

        if (!isNear) {
          developer.log(
            name: "FirestoreDataHandler -> tryCatchDragon",
            "${data["displayName"]} is too far from user");
          continue;
        }

        await utilsUsersCollection.doc(currentUser.uid).update(
          {
            'caughtDragons': FieldValue.arrayUnion([data["directoryName"]]),
          },
        );
        
        showAlertMessage("You have caught a ${data["displayName"]}!", 2);
        developer.log(
          name: "FirestoreDataHandler -> tryCatchDragon",
          "Caught ${data["directoryName"]}");
        return;  
      }
    } catch (e) {
      developer.log(
        name: "FirestoreDataHandler -> tryCatchDragon -> exception",
        "$e");
      return;
    }

    showAlertMessage("You are too far away from any of the dragons!", 2);
    developer.log(
      name: "FirestoreDatahandler -> tryCatchDragon",
      "None of the dragons is near");
  }

  void releaseAllDragons() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      developer.log(
        name: "FirestoreDataHandler -> releaseAllDragons",
        "Current user is null");
      return;
    }

    try {
      QuerySnapshot dragonsSnapshot = await utilsDragonsCollection.get();

      DocumentSnapshot userSnapshot = await utilsUsersCollection.doc(currentUser.uid).get();
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

      if (userData["caughtDragons"].isEmpty) {
        showAlertMessage("None of the dragons need to be released", 2);
        developer.log("None of the dragons need to be released");
        return;
      }

      for (QueryDocumentSnapshot dragonDocument in dragonsSnapshot.docs) {
        Map<String, dynamic> dragonData = dragonDocument.data() as Map<String, dynamic>;

        await utilsUsersCollection.doc(currentUser.uid).update(
          {
            'caughtDragons': FieldValue.arrayRemove([dragonData["directoryName"]]),
          },
        );
        
        developer.log(
          name: "FirestoreDataHandler -> tryCatchDragon",
          "Released ${dragonData["directoryName"]}");
      }

      showAlertMessage("You have released all the dragons!", 2);
    } catch (e) {
      developer.log(
        name: "FirestoreDataHandler -> releaseAllDragons -> exception",
        "$e");
    }
  }
}

  