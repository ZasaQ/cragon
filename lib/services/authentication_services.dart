import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import 'package:cragon/services/utilities.dart';

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
                    await usersCollection.doc(userCredential.user!.uid).update(
                      {
                        'token': token,
                      },
                    );
                  },
                );
              } else {
                await createUserWithCredentials(userCredential: userCredential);
              }
            }
          );
        }
      },
    );
  }

  void signUpWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (excep) {
      return showAlertMessage(excep.code);
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
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((userCredential) => null);
      User? currentUser = FirebaseAuth.instance.currentUser;

      await FirebaseMessaging.instance.getToken().then(
      (token) async {
        await usersCollection.doc(FirebaseAuth.instance.currentUser!.uid).set(
          {
            'uid': currentUser?.uid,
            'email': currentUser?.email,
            'isAdmin': false,
            'token': token,
          },
        );
        developer.log("Log: user ${currentUser?.email} has been added to collection");
      },
    );
    } on FirebaseAuthException catch (excep) {
      return showAlertMessage(excep.code);
    }
  }

  Future<bool> createUserWithCredentials({required UserCredential userCredential}) async {
    bool userCreated = false;
    
    await FirebaseMessaging.instance.getToken().then(
      (token) async {
        await usersCollection.doc(userCredential.user?.uid).set(
          {
            'uid': userCredential.user?.uid,
            'email': userCredential.user?.email,
            'isAdmin': false,
            'token': token,
          },
        ).then((value) => userCreated = true);
        developer.log("Log: user ${userCredential.user?.email} has been added to collection");
      },
    );

    return userCreated;
  }

  void userSignOut(String uid) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: uid).get();

      await FirebaseFirestore.instance.collection("users").doc(querySnapshot.docs.first.id).update(
        {
          'token': "",
        },
      );

      developer.log("Log: token is now empty");
      FirebaseAuth.instance.signOut();
      developer.log("Log: user has been signed out");
    } catch (e){
      developer.log("Log: can't delete token value");
    }
  }

  Future<bool> userExists({required String uid}) async {
    bool exists = false;
    await usersCollection.where('uid', isEqualTo: uid).get().then(
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
}