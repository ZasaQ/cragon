import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

import 'package:cragon/components/lr_button.dart';
import 'package:cragon/services/authentication_services.dart';
import 'package:cragon/services/utilities.dart';


class BulkDeleteUsersPage extends StatefulWidget {
  const BulkDeleteUsersPage({super.key});

  @override
  State<BulkDeleteUsersPage> createState() => _BulkDeleteUsersPageState();
}

class _BulkDeleteUsersPageState extends State<BulkDeleteUsersPage> {
  Map<String, bool> checkedItems = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(128, 128, 0, 1),
      ),
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<QuerySnapshot>(
        stream: utilsUsersCollection.orderBy('email').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
      
          if (!userSnapshot.hasData) {
            return const Center(
              child: Text('No users found.'),
            );
          }
                
          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Image(
                image: AssetImage('lib/images/delete_account_icon.png'),
                height: 100.0,
                width: 100.0,
              ),
              const Center(
                child: Text('Here you can delete multiple accounts remotly', 
                  style: TextStyle(color: Colors.black, fontSize: 16.0)
                ),
              ),

              const SizedBox(height: 50,),
          
              Flexible(
                child: SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: userSnapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final userItem = userSnapshot.data!.docs[index];
                      String userId = userItem['uid'];
                      String userMail = userItem['email'];
                      bool canDelete = true;
                  
                      if (userMail == FirebaseAuth.instance.currentUser!.email) {
                        canDelete = false;
                      }
                  
                      return CheckboxListTile(
                        title: Text(userMail),
                        value: checkedItems[userId] ?? false,
                        onChanged: canDelete
                        ? (bool? value) {
                            setState(
                              () {
                                checkedItems[userId] = value ?? false;
                              },
                            );
                          }
                        : null
                      );
                    }
                  ),
                )
              ),

              const SizedBox(height: 50,),

              LRButton(inText: "Confirm", onPressed: () {
                if (checkedItems.isEmpty) {
                  showAlertMessage("No user has been selected", 2);
                  return;
                }

                showConfirmationMessage("Are you sure?", () {
                  checkedItems.forEach((key, value) {
                    if (value) {
                      developer.log(name: "BulkDeleteUsesPage -> deleteUser", "Delete user $key");
                      AuthenticationServices().deleteUser(uid: key);
                    }
                  });
                });
              })
            ],
          );
        }
      ),
    );
  }
}