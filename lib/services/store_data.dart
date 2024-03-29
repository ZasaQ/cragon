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
      developer.log("Log: deleteImageFromFirebaseStorage -> $e");
    }
  }

  void updateUserAvatarImage({
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

  void removeUserAvatarImage() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      String imageUrl = await getUserAvatarImage();

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

  
  Future<String> getUserAvatarImage() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: uid).get();

      return await querySnapshot.docs.first['avatarImage'];
    } catch (e) {
      developer.log("$e");
      
      return "";
    }
  }
}