import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';
import 'dart:developer' as developer;

import 'package:cragon/components/user_avatar.dart';
import 'package:cragon/main.dart';
import 'package:cragon/pages/camera_page.dart';
import 'package:cragon/pages/user_page.dart';
import 'package:cragon/services/authentication_services.dart';
import 'package:cragon/pages/dragon_page.dart';
import 'package:cragon/services/firestore_data_handler.dart';
import 'package:cragon/pages/map_page.dart';
import 'package:cragon/services/utilities.dart';


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
        title: const Text("Cragon", style: TextStyle(color: Color.fromRGBO(128, 128, 0, 1)),),
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
                  future: userAvatarViaFuture(radius: 40),
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
                  MaterialPageRoute(builder: (context) => const Placeholder()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.map, color: Color.fromRGBO(128, 128, 0, 1),),
              title: const Text("Map", style: TextStyle(fontSize: 18)),
              titleTextStyle: const TextStyle(color: Color.fromRGBO(128, 128, 0, 1)),
              onTap: () {
                MyApp.navigatorKey.currentState!.push(
                  MaterialPageRoute(builder: (context) => const Placeholder()));
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
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text("Error while loading user's account: ${snapshot.error.toString()}");
                      }
                  
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      List<dynamic> usersCaughtDragons = snapshot.data?.get("caughtDragons");
                      List<String> usersCaughtDragonsValues = [];

                      utilCaughtDragonsAmount = usersCaughtDragons.length;

                      for (var element in usersCaughtDragons) {
                        usersCaughtDragonsValues.add(element.toString());
                      }
                      
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                          .collection("dragons")
                          .snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> dragonsSnapshot) {
                          if (dragonsSnapshot.hasError) {
                            return Text("Error while loading dragon item: ${dragonsSnapshot.error.toString()}");
                          }
                      
                          if (dragonsSnapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          utilDragonsAmount = dragonsSnapshot.data!.docs.length;

                          return Expanded(
                            child: ListView(
                              children: dragonsSnapshot.data!.docs.map((DocumentSnapshot document) {
                                Map<String,dynamic> dragonData = document.data()! as Map<String, dynamic>;
                                bool isDragonCaught = usersCaughtDragonsValues.contains(
                                  dragonData["directoryName"]);

                                return ExpansionTile(
                                  leading: isDragonCaught ? const Icon(Icons.check) : null,
                                  title:Text(dragonData["displayName"], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  children: <Widget>[
                                    Wrap(
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            MyApp.navigatorKey.currentState!.push(
                                              MaterialPageRoute(builder: (context) =>
                                                DragonPage(dragonDirectoryName: dragonData["directoryName"].toString(),
                                                            dragonDisplayName: dragonData["displayName"].toString())
                                              )
                                            );
                                          },
                                          child: const Text("Show Gallery", style: TextStyle(color: Colors.black))
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            MyApp.navigatorKey.currentState!.push(
                                              MaterialPageRoute(builder: (context) => 
                                                MapPage(dragonLocation: dragonData['dragonLocation'])
                                              )
                                            );
                                          },
                                          child: const Text("Navigate", style: TextStyle(color: Colors.black))
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            FirestoreDataHandler().manageDragon(dragonDirectoryName: dragonData["directoryName"], toCatch: true);
                                          },
                                          child: const Text("Catch Dragon", style: TextStyle(color: Colors.black))
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            FirestoreDataHandler().manageDragon(dragonDirectoryName: dragonData["directoryName"], toCatch: false);
                                          },
                                          child: const Text("Release Dragon", style: TextStyle(color: Colors.black))
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              }).toList()
                            ),
                          );
                        }
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