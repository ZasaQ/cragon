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
                await createUser(userCredential: userCredential);
              }
            }
          );
        }
      },
    );
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

  Future<bool> createUser({required UserCredential userCredential}) async {
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
      },
    );

    return userCreated;
  }

  void userSignOut(String currentUser) async{
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: currentUser).get();

      await FirebaseFirestore.instance.collection("users").doc(querySnapshot.docs.first.id).update(
        {
          'token': "",
        },
      );

      developer.log("Log: token is now empty");
      FirebaseAuth.instance.signOut();
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
      developer.log("Log: user exists");
    } else {
      developer.log("Log: user does not exist");
    }

    return exists;
  }
}