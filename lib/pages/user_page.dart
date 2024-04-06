import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import 'package:cragon/services/firestore_data_handler.dart';
import 'package:cragon/services/utilities.dart';
import 'package:cragon/components/user_avatar.dart';
import 'package:cragon/components/settings_group.dart';
import 'package:cragon/components/settings_item.dart';
import 'package:cragon/main.dart';
import 'package:cragon/pages/change_password.dart';
import 'package:cragon/pages/delete_user_page.dart';


class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(128, 128, 0, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(128, 128, 0, 1),
      ),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          decoration: const BoxDecoration(color: Color.fromRGBO(128, 128, 0, 1)),
          child: Column(
            children: <Widget>[
              Stack(
                children: [
                  FutureBuilder<Widget>(
                    future: userAvatar(radius: 50, fontSize: 30),
                    builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        developer.log("Log: Snapshot error -> ${snapshot.error}");
                        return Text("Log: Snapshot error -> ${snapshot.error}");
                      } else {
                        return Align(
                          alignment: Alignment.topCenter,
                          child: snapshot.data!,
                        );
                      }
                    },
                  ),
                  Positioned(
                    bottom: -5,
                    left: 230,
                    child: IconButton(onPressed: () async {
                      Uint8List image = await pickImage(ImageSource.gallery);
                      if (image.isEmpty) {
                        return;
                      }

                      FirestoreDataHandler().updateUserAvatarImage(image: image).then(
                        (value) => setState(() => {})
                      );
                    }, icon: const Icon(Icons.add_a_photo), color: Colors.black),
                  ) 
                ],
              ),
              
              const SizedBox(height: 30),
        
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(
                      "${FirebaseAuth.instance.currentUser!.email}",
                      style: const TextStyle(fontSize: 20)
                    ),

                    const SizedBox(height: 60),

                    SettingsGroup(
                      items: [
                        SettingsItem(
                          onTap: () {
                            MyApp.navigatorKey.currentState!.push(
                              MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
                          },
                          titleText: 'Change password',
                          leadingIcon: const Icon(Icons.password_sharp, color: Colors.black),
                        ),

                        SettingsItem(
                          onTap: () async {
                            FirestoreDataHandler().removeUserAvatarImage().then(
                              (value) => setState(() => {})
                            );
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
                          leadingIcon: Icon(Icons.remove, color: Colors.red.shade500),
                        )
                      ]
                    ),
                  ]
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}