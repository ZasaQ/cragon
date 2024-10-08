import 'package:cragon/pages/change_object_detection_method_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import 'package:cragon/services/firestore_data_handler.dart';
import 'package:cragon/services/utilities.dart';
import 'package:cragon/components/user_avatar.dart';
import 'package:cragon/components/settings_group.dart';
import 'package:cragon/components/settings_item.dart';
import 'package:cragon/main.dart';
import 'package:cragon/pages/change_password.dart';
import 'package:cragon/pages/delete_user_page.dart';
import 'package:cragon/pages/bulk_delete_users_page.dart';
import 'package:cragon/pages/manage_users_privileges_page.dart';
import 'package:cragon/components/bottom_navigation_bar.dart';
import 'package:cragon/components/floating_camera_button.dart';


class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  @override
  void initState() {
    super.initState();

    developer.log(
      name: "UserPage -> initState",
      "Current user has entered UserPage");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Stack(
                children: [
                  Stack(
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                          if (userSnapshot.hasError) {
                            return Text("Error while loading user's account: ${userSnapshot.error.toString()}");
                          }
                      
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
        
                          if (!userSnapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
        
                          if (!userSnapshot.data!.exists) {
                            return const CircularProgressIndicator();
                          }
                           
                          Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                          String avatarImageUrl = userData["avatarImage"].toString();

                          utilCaughtDragonsAmount = userData["caughtDragons"].length;
                      
                          return userAvatarViaSnapshot(
                            imageUrl: avatarImageUrl,
                            radius: 70,
                            fontSize: 50
                          );
                        }
                      ),
        
                      Positioned(
                        bottom: 0,
                        right: -10,
                        child: ElevatedButton(
                          onPressed: () async {
                            Uint8List image = await pickGalleryImage(ImageSource.gallery);
                            if (image.isEmpty) {
                              return;
                            }
        
                            FirestoreDataHandler().updateUserAvatarImage(image: image);
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(const CircleBorder()),
                            padding: MaterialStateProperty.all(const EdgeInsets.all(2)),
                            backgroundColor: MaterialStateProperty.all(utilMainTextColor) 
                          ), 
                          child: const Icon(Icons.add_a_photo, color: Colors.white,),
                        ),
                      )
                    ],
                  ),
                ],
              ),
                  
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "${FirebaseAuth.instance.currentUser!.email}",
                  style: const TextStyle(fontSize: 20)
                ),
              ),
                  
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  "Caught dragons: $utilCaughtDragonsAmount / $utilDragonsAmount",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
                ),
              ),
                  
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20),
                child: Divider(
                  thickness: 2,
                  color: Colors.black
                ),
              ),
              
              Column(
                children: <Widget>[
                  SettingsGroup(
                    settingsGroupTitle: "User settings",
                    items: [
                      SettingsItem(
                        onTap: () {
                          MyApp.navigatorKey.currentState!.push(
                            MaterialPageRoute(builder: (context) => const ChangeObjectDetectionMethodPage()));
                        },
                        titleText: 'Change object detection method',
                        leadingIcon: const Icon(Icons.camera_front, color: Colors.black),
                        trailingIcon: const Icon(Icons.arrow_right)
                      ),

                      SettingsItem(
                        onTap: () {
                          showConfirmationMessage("Are you sure?", () =>
                            {FirestoreDataHandler().releaseAllDragons()});
                        },
                        titleText: 'Release all caught dragons',
                        leadingIcon: const Icon(Icons.remove, color: Colors.black),
                      ),

                      SettingsItem(
                        onTap: () {
                          MyApp.navigatorKey.currentState!.push(
                            MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
                        },
                        titleText: 'Change password',
                        leadingIcon: const Icon(Icons.password_sharp, color: Colors.black),
                        trailingIcon: const Icon(Icons.arrow_right)
                      ),
                
                      SettingsItem(
                        onTap: () async {
                          FirestoreDataHandler().removeUserAvatarImage();
                        },
                        titleText: 'Remove avatar image',
                        leadingIcon: const Icon(Icons.remove_circle_outline_sharp, color: Colors.black)
                      ),
                
                      SettingsItem(
                        onTap: () {
                          MyApp.navigatorKey.currentState!.push(
                            MaterialPageRoute(builder: (context) => const DeleteUserPage()));
                        },
                        titleText: 'Delete account',
                        titleStyle: TextStyle(color: Colors.red.shade500),
                        leadingIcon: Icon(Icons.person_remove, color: Colors.red.shade500),
                        trailingIcon: const Icon(Icons.arrow_right)
                      )
                    ]
                  ),
                
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                      if (userSnapshot.hasError) {
                        return Text("Error while loading user's account: ${userSnapshot.error.toString()}");
                      }
                  
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
        
                      if (userSnapshot.data?.data() == null) {
                          return const CircularProgressIndicator();
                      }             
                  
                      Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                      bool isAdmin = userData['isAdmin'];
                
                      if (isAdmin) {
                        return SettingsGroup(
                          settingsGroupTitle: "Admin utilities",
                          items: [
                            SettingsItem(
                              onTap: () {
                                MyApp.navigatorKey.currentState!.push(
                                  MaterialPageRoute(builder: (context) => const BulkDeleteUsersPage()));
                              },
                              titleText: 'Delete users',
                              leadingIcon: const Icon(Icons.group_remove, color: Colors.black),
                              trailingIcon: const Icon(Icons.arrow_right)
                            ),
                            SettingsItem(
                              onTap: () {
                                MyApp.navigatorKey.currentState!.push(
                                  MaterialPageRoute(builder: (context) => const ManageUsersPrivilegesPage()));
                              },
                              titleText: 'Manage users privileges',
                              leadingIcon: const Icon(Icons.admin_panel_settings, color: Colors.black),
                              trailingIcon: const Icon(Icons.arrow_right)
                            ),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    }
                  ),
                ]
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar(),
      floatingActionButton: floatingCameraButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}