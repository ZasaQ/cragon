import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

import 'package:cragon/main.dart';
import 'package:cragon/pages/dragon_page.dart';
import 'package:cragon/services/firestore_data_handler.dart';
import 'package:cragon/pages/map_page.dart';
import 'package:cragon/services/utilities.dart';
import 'package:cragon/components/bottom_navigation_bar.dart';
import 'package:cragon/components/floating_camera_button.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  @override
  initState() {
    super.initState();

    if (utilFirstCamera == null) {
      initBackCamera().then((value) => utilFirstCamera = value!).then(
        (value) => developer.log("Log: initBackCamera() -> $value")
      );
    }

    developer.log("Log: User has entered HomePage()");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color.fromRGBO(128, 128, 0, 1)),
        backgroundColor: const Color.fromRGBO(38, 45, 53, 1),
        centerTitle: true,
        title: const Text(
          "Cragon",
          style: TextStyle(
            color: Color.fromRGBO(128, 128, 0, 1),
            fontWeight: FontWeight.bold
          ),
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
                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                      if (userSnapshot.hasError) {
                        return Text("Error while loading user's account: ${userSnapshot.error.toString()}");
                      }
                  
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (!userSnapshot.data!.exists) {
                        return const CircularProgressIndicator();
                      }

                      List<dynamic> usersCaughtDragons = userSnapshot.data!.get("caughtDragons");
                      List<String> usersCaughtDragonsValues = [];

                      if (usersCaughtDragons.isEmpty || usersCaughtDragons.first == "") {
                        utilCaughtDragonsAmount = 0;
                      } else {
                        utilCaughtDragonsAmount = usersCaughtDragons.length;
                      }

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

                                return Container(
                                  decoration: BoxDecoration(
                                    color: isDragonCaught
                                    ? const Color.fromRGBO(0, 0, 0, 0.2)
                                    : const Color.fromRGBO(0, 0, 0, 0.1)
                                  ),
                                  child: ExpansionTile(
                                    leading: isDragonCaught ? const Icon(Icons.check) : null,
                                    
                                    title: Text(
                                      dragonData["displayName"],
                                      style: isDragonCaught 
                                        ? const TextStyle(fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.lineThrough)
                                        : const TextStyle(fontWeight: FontWeight.bold)
                                    ),
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
                                  ),
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
      bottomNavigationBar: bottomNavigationBar(),
      floatingActionButton: floatingCameraButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}