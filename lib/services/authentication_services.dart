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
      developer.log(
        name: "AuthenticationServices -> signUpWithEmail",
        "Email can not be empty");
      return showAlertMessageWithTimer('Email can not be empty', 2);
    }

    if (password.isEmpty || confirmPassword.isEmpty) {
      developer.log(
        name: "AuthenticationServices -> signUpWithEmail",
        "Password can not be empty");
      return showAlertMessageWithTimer('Password can not be empty', 2);
    }

    try {
      if (password != confirmPassword) {
        developer.log(
          name: "AuthenticationServices -> signUpWithEmail",
          "Password must be the same");
        return showAlertMessageWithTimer("Password must be the same", 2);
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
        developer.log(
          name: "AuthenticationServices -> signUpWithEmail -> exception",
          "User ${currentUser?.email} has been added to collection");
      },
    );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        developer.log(
          name: "AuthenticationServices -> signUpWithEmail -> FirebaseAuthException",
          "$e");
        return showAlertMessageWithTimer('The account already exists for that email', 2);
      } else if (e.code == 'weak-password') {
        developer.log(
          name: "AuthenticationServices -> signUpWithEmail -> FirebaseAuthException",
          "$e");
        return showAlertMessageWithTimer('Provided password is too weak', 2);
      }

      return showAlertMessageWithTimer(e.code, 2);
    } catch (e) {
      developer.log(
        name: "AuthenticationServices -> signUpWithEmail -> exception",
        "$e");
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
      developer.log(
        name: "AuthenticationServices -> signInWithEmail ->",
        "Email can not be empty");
      return showAlertMessageWithTimer('Email can not be empty', 2);
    }

    if (password.isEmpty) {
      developer.log(
        name: "AuthenticationServices -> signInWithEmail ->",
        "Password can not be empty");
      return showAlertMessageWithTimer('Password can not be empty', 2);
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
        developer.log(
          name: "AuthenticationServices -> signInWithEmail -> FirebaseAuthException",
          "$e");
        return showAlertMessageWithTimer('Wrong email or password', 2);
      } else if (e.code == 'user-not-found') {
        developer.log(
          name: "AuthenticationServices -> signInWithEmail -> FirebaseAuthException",
          "$e");
        return showAlertMessageWithTimer('No user found for that email.', 2);
      } else if (e.code == 'wrong-password') {
        developer.log(
          name: "AuthenticationServices -> signInWithEmail -> FirebaseAuthException",
          "$e");
        return showAlertMessageWithTimer('Wrong password provided for that user.', 2);
      } else if (e.code == 'email-already-in-use') {
        developer.log(
          name: "AuthenticationServices -> signInWithEmail -> FirebaseAuthException",
          "$e");
        return showAlertMessageWithTimer('The account already exists for that email.', 2);
      }

      return showAlertMessageWithTimer(e.code, 2);
    } catch (e) {
      developer.log(
        name: "AuthenticationServices -> signInWithEmail -> exception",
        "$e");
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
        developer.log(
          name: "AuthenticationServices -> addUserToCollection",
          "User ${userCredential.user?.email} has been added to collection");
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
        showAlertMessageWithTimer('Form fields can not be empty!', 2);
        developer.log(
          name: "AuthenticationServices -> changePassword",
          "Form fields can not be empty");
        isError = true;
        return;
      }

      if (newPassword != confirmPassword) {
        showAlertMessageWithTimer('New password and confirmation must be the same!', 2);
        developer.log(
          name: "AuthenticationServices -> changePassword",
          "New password and confirmation must be the same");
        isError = true;
        return;
      }

      try {
        await currentUser.reauthenticateWithCredential(credential).then((value) {
          currentUser.updatePassword(newPassword);
        });
      } on FirebaseAuthException catch (e) {
        developer.log(
          name: "AuthenticationServices -> changePassword -> FirebaseAuthException",
          "$e");
        showAlertMessageWithTimer(e.code, 2);
        isError = true;
      }

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      if (!isError) {
        showAlertMessageWithTimer("Password has been changed!", 2);
        developer.log(
          name: "AuthenticationServices -> changePassword",
          "Password has been changed");
        return;
      }

    } on FirebaseAuthException catch (e) {
      showAlertMessageWithTimer(e.code, 2);
      developer.log(
        name: "AuthenticationServices -> changePassword -> FirebaseAuthException",
        "$e");
      return;
    }
  }

  void signOutCurrentUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      developer.log(
        name: "AuthenticationServices -> signOutCurrentUser",
        "Current user is null");
      return;
    }

    try {
      QuerySnapshot<Map<String, dynamic>> userQuerySnapshot =
        await FirebaseFirestore.instance.collection('users')
        .where('uid', isEqualTo: currentUser.uid).get();

      await FirebaseFirestore.instance.collection("users")
      .doc(userQuerySnapshot.docs.first.id).update(
        {
          'token': "",
        },
      );

      developer.log(
        name: "AuthenticationServices -> signOutCurrentUser",
        "User Token has been removed");

      FirebaseAuth.instance.signOut();
      developer.log(
        name: "AuthenticationServices -> signOutCurrentUser",
        "User has been signed out");
    } catch (e) {
      developer.log(
        name: "AuthenticationServices -> signOutCurrentUser -> exception",
        "$e");
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
      developer.log(
        name: "AuthenticationServices -> userExists",
        "User with $uid already exists");
    } else {
      developer.log(
        name: "AuthenticationServices -> userExists",
        "User with $uid does not exist");
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
      developer.log(
        name: "AuthenticationServices -> reauthenticateCurrentUser -> FirebaseAuthException",
        "$e");
      return false;
    }
  }

  void deleteCurrentUser() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String avatarImage = "";

    if (currentUser == null) {
      developer.log(
        name: "AuthenticationServices -> deleteCurrentUser",
        "Current user is null");
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

      developer.log(
        name: "AuthenticationServices -> deleteCurrentUser",
        "Current user has been deleted correctly");
    } on FirebaseAuthException catch (e) {
      developer.log(
        name: "AuthenticationServices -> deleteCurrentUser -> FirebaseAuthException",
        "$e");
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

      developer.log(
        name: "AuthenticationServices -> deleteUser",
        "User has been deleted correctly");
    } on FirebaseAuthException catch (e) {
      developer.log(
        name: "AuthenticationServices -> deleteUser -> FirebaseAuthException",
        "$e");
    }
  }
}