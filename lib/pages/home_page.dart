import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cragon/pages/dragon_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';
import 'dart:developer' as developer;

import 'package:cragon/components/user_avatar.dart';
import 'package:cragon/main.dart';
import 'package:cragon/pages/camera_page.dart';
import 'package:cragon/pages/user_page.dart';
import 'package:cragon/services/authentication_services.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  late CameraDescription firstCamera;

  Future<CameraDescription?> initBackCamera() async {
  final cameras = await availableCameras();

  for (var inCamera in cameras) {
    if (inCamera.lensDirection == CameraLensDirection.back) {
      return inCamera;
    }
  }
  
  return null;
}

  @override
  initState() {
    super.initState();

    initBackCamera().then((value) => firstCamera = value!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color.fromRGBO(128, 128, 0, 1)),
        backgroundColor: const Color.fromRGBO(38, 45, 53, 1),
        title: const Text("Home Page", style: TextStyle(color: Color.fromRGBO(128, 128, 0, 1)),),
        actions: <Widget> [
          IconButton(
            icon: const Icon(Icons.camera),
            tooltip: 'Open Camera',
            onPressed: () {
              MyApp.navigatorKey.currentState!.push(
                MaterialPageRoute(builder: (context) => CameraPage(camera: firstCamera)));
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromRGBO(38, 45, 53, 1),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountEmail: Text(
                FirebaseAuth.instance.currentUser!.email.toString(),
                style: const TextStyle(color:  Color.fromRGBO(38, 45, 53, 1), fontSize: 20)
              ),
              accountName: null,
              currentAccountPicture: GestureDetector(
                onTap: () {
                  MyApp.navigatorKey.currentState!.push(
                    MaterialPageRoute(builder: (context) => const UserPage()));
                },
                child: FutureBuilder<Widget>(
                  future: userAvatar(radius: 40),
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
              ),
              currentAccountPictureSize: const Size.fromRadius(40),
            ),

            ListTile(
              leading: const Icon(Icons.settings, color: Color.fromRGBO(128, 128, 0, 1),),
              title: const Text("Settings", style: TextStyle(fontSize: 18)),
              titleTextStyle: const TextStyle(color: Color.fromRGBO(128, 128, 0, 1)),
              onTap: () {
                MyApp.navigatorKey.currentState!.push(
                  MaterialPageRoute(builder: (context) => Placeholder()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Color.fromRGBO(128, 128, 0, 1),),
              title: const Text("Log out", style: TextStyle(fontSize: 18)),
              titleTextStyle: const TextStyle(color: Color.fromRGBO(128, 128, 0, 1)),
              onTap: () {
                AuthenticationServices().signOutCurrentUser();
              },
            )
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color.fromRGBO(128, 128, 0, 1)),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                    .collection("dragons")
                    .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text("Error while loading dragon item: ${snapshot.error.toString()}");
                      }
                  
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                  
                      return SizedBox(
                        height: 150,
                        child: ListView(
                          children: snapshot.data!.docs.map((DocumentSnapshot document) {
                            Map<String,dynamic> data = document.data()! as Map<String, dynamic>;
                            return ExpansionTile(
                              title:Text(data["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        MyApp.navigatorKey.currentState!.push(
                                          MaterialPageRoute(builder: (context) => DragonPage(dragonName: data["name"].toString())));
                                      },
                                      child: const Text("Show Gallery", style: TextStyle(color: Colors.black))
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        MyApp.navigatorKey.currentState!.push(
                                          MaterialPageRoute(builder: (context) => const Placeholder()));
                                      },
                                      child: const Text("Navigation", style: TextStyle(color: Colors.black))
                                    )
                                  ],
                                )
                              ],
                            );
                          }).toList()
                        ),
                      );
                    }
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}