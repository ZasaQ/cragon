import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:cragon/main.dart';
import 'package:cragon/services/utilities.dart';
import 'package:cragon/services/firestore_data_handler.dart';


class AuthenticationServices {
  Future authenticateGoogleUser({required BuildContext context}) async {
    await signInWithGoogle().then(
      (UserCredential userCredential) async {
        if (userCredential.user?.uid != null) {
          await userExists(uid: userCredential.user!.uid).then(
            (exists) async {
              if (exists) {
                FirebaseMessaging.instance.getToken().then(
                  (token) async {
                    await utilsUsersCollection.doc(userCredential.user!.uid).update(
                      {
                        'token': token,
                      },
                    );
                  },
                );
              } else {
                await addUserToCollection(userCredential: userCredential);
              }
            }
          );
        }
      },
    );
  }

  void signUpWithEmail(String email, String password, String confirmPassword) async {
    if (email.isEmpty) {
      return showAlertMessage('Email can not be empty', 2);
    }

    if (password.isEmpty || confirmPassword.isEmpty) {
      return showAlertMessage('Password can not be empty', 2);
    }

    try {
      if (password != confirmPassword) {
        return showAlertMessage("Password must be the same", 2);
      }

      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

      User? currentUser = FirebaseAuth.instance.currentUser;

      await FirebaseMessaging.instance.getToken().then(
      (token) async {
        await utilsUsersCollection.doc(FirebaseAuth.instance.currentUser!.uid).set(
          {
            'uid': currentUser?.uid,
            'email': currentUser?.email,
            'isAdmin': false,
            'token': token,
            'avatarImage': "",
            'caughtDragons': [],
          },
        );
        developer.log("Log: user ${currentUser?.email} has been added to collection");
      },
    );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return showAlertMessage('The account already exists for that email.', 2);
      } else if (e.code == 'weak-password') {
        return showAlertMessage('The password provided is too weak.', 2);
      }

      return showAlertMessage(e.code, 2);
    } catch (e) {
      developer.log("Log: signUpWithEmail() -> exception: $e");
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleSignInAuthentication = await googleSignInAccount?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication?.accessToken,
      idToken: googleSignInAuthentication?.idToken
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void signInWithEmail(String email, String password) async {
    if (email.isEmpty) {
      return showAlertMessage('Email can not be empty', 2);
    }

    if (password.isEmpty) {
      return showAlertMessage('Password can not be empty', 2);
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      FirebaseMessaging.instance.getToken().then(
        (token) async {
          await utilsUsersCollection.doc(FirebaseAuth.instance.currentUser!.uid).update(
            {
              'token': token,
            },
          );
        },
      );

    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        return showAlertMessage('Wrong email or password', 2);
      } else if (e.code == 'user-not-found') {
        return showAlertMessage('No user found for that email.', 2);
      } else if (e.code == 'wrong-password') {
        return showAlertMessage('Wrong password provided for that user.', 2);
      } else if (e.code == 'email-already-in-use') {
        return showAlertMessage('The account already exists for that email.', 2);
      }

      return showAlertMessage(e.code, 2);
    } catch (e) {
      developer.log("Log: signInWithEmail() -> exception: $e");
    }
  }

  Future<bool> addUserToCollection({required UserCredential userCredential}) async {
    bool userCreated = false;
    
    await FirebaseMessaging.instance.getToken().then(
      (token) async {
        await utilsUsersCollection.doc(userCredential.user?.uid).set(
          {
            'uid': userCredential.user?.uid,
            'email': userCredential.user?.email,
            'isAdmin': false,
            'token': token,
            'avatarImage': "",
            'caughtDragons': [],
          },
        ).then((value) => userCreated = true);
        developer.log("Log: user ${userCredential.user?.email} has been added to collection");
      },
    );

    return userCreated;
  }

  void changePassword(TextEditingController currentPasswordController, TextEditingController newPasswordController, TextEditingController confirmPasswordController) async {
    bool isError = false;
    try {
      String currentPassword = currentPasswordController.text.toString();
      String newPassword = newPasswordController.text.toString();
      String confirmPassword = confirmPasswordController.text.toString();

      final currentUser = FirebaseAuth.instance.currentUser;
      final AuthCredential credential = EmailAuthProvider.credential(email: currentUser!.email.toString(), password: currentPassword);

      if (currentPassword.isEmpty || newPassword.isEmpty ||  confirmPassword.isEmpty) {
        showAlertMessage('Form fields can not be empty!', 2);
        isError = true;
        return;
      }

      if (newPassword != confirmPassword) {
        showAlertMessage('New password and confirmation must be the same!', 2);
        isError = true;
        return;
      }

      try {
        await currentUser.reauthenticateWithCredential(credential).then((value) {
          currentUser.updatePassword(newPassword);
        });
      } on FirebaseAuthException catch (e) {
        developer.log("Log: changePassword -> ${e.code}");
        showAlertMessage(e.code, 2);
        isError = true;
      }

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      if (!isError) {
        developer.log("Log: changePassword -> Password has been changed!");
        showAlertMessage("Password has been changed!", 2);
        return;
      }

    } on FirebaseAuthException catch (e) {
      showAlertMessage(e.code, 2);
      return;
    }
  }

  void signOutCurrentUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      developer.log("Log: signOutCurrentUser() -> currentUser is null");
    }

    try {
      QuerySnapshot<Map<String, dynamic>> userQuerySnapshot =
        await FirebaseFirestore.instance.collection('users')
        .where('uid', isEqualTo: currentUser!.uid).get();

      await FirebaseFirestore.instance.collection("users")
      .doc(userQuerySnapshot.docs.first.id).update(
        {
          'token': "",
        },
      );

      developer.log("Log: token is now empty");
      FirebaseAuth.instance.signOut();
      developer.log("Log: current user has been signed out");
    } catch (e) {
      developer.log("Log: signOutCurrentUser() -> exception: $e");
    }
  }

  Future<bool> userExists({required String uid}) async {
    bool exists = false;
    await utilsUsersCollection.where('uid', isEqualTo: uid).get().then(
      (user) {
        exists = user.docs.isEmpty ? false : true;
      },
    );

    if (exists) {
      developer.log("Log: user with $uid already exists");
    } else {
      developer.log("Log: user with $uid does not exist");
    }

    return exists;
  }

  Future<bool> reauthenticateCurrentUser({required String password}) async {
    if (password.isEmpty) {
        return false;
    }

    try {
      User currentUser = FirebaseAuth.instance.currentUser!;

      String userEmail = currentUser.email.toString();
      AuthCredential userCredential = EmailAuthProvider.credential(
        email: userEmail,
        password: password
      );

      await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(userCredential);

      return true;
    } on FirebaseAuthException catch (e) {
      developer.log("Log: reauthenticateCurrentUser() -> ${e.code}");
      return false;
    }
  }

  void deleteCurrentUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String avatarImage = "";

    if (currentUser == null) {
      developer.log("Log: deleteCurrentUser() -> currentUser is null");
      return;
    }

    try {
      await utilsUsersCollection.doc(currentUser.uid).get().then((DocumentSnapshot userSnapshot) {
        avatarImage = userSnapshot.get("avatarImage") as String;
      });

      await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .delete();

      if (avatarImage.isNotEmpty) {
        await FirestoreDataHandler().removeUserAvatarImage();
      }

      await currentUser.delete();
      FirebaseAuth.instance.signOut();

      await MyApp.navigatorKey.currentState!.pushNamedAndRemoveUntil("/login", (route) => false);

      developer.log("Log: deleteCurrentUser() -> user has been deleted correctly");
    } on FirebaseAuthException catch (e) {
      developer.log("Log: deleteCurrentUser() -> $e");
    }
  }

  Future<void> deleteUser({required String uid}) async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('deleteFirebaseAuthUser');
      await callable.call({'uid' : uid});

      await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .delete();

      await FirestoreDataHandler().removeUserAvatarImage(inUid: uid);

      developer.log("Log: deleteUser() -> user has been deleted correctly");
    } on FirebaseAuthException catch (e) {
      developer.log("Log: deleteUser() -> $e");
    }
  }
}