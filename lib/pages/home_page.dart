import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

    developer.log(
      name: "HomePage -> initState",
      "Current user has entered HomePage");
  }

  Future<AssetImage> getFirstImageInGallery(String directoryName) async {
    List<String> galleryUrlList = await FirestoreDataHandler().getDragonGalleryUrl(directoryName);
    
    return AssetImage(galleryUrlList.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cragon"),
      ),
      backgroundColor: utilMainBackgroundColor,
      body: Column(
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
      
                    bool userIsAdmin = userSnapshot.data!.get("isAdmin");
      
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
      
                        return Flexible(
                          child: ListView(
                            children: dragonsSnapshot.data!.docs.map((DocumentSnapshot document) {
                              Map<String,dynamic> dragonData = document.data()! as Map<String, dynamic>;
                              bool isDragonCaught = usersCaughtDragonsValues.contains(
                                dragonData["directoryName"]);

                              GeoPoint dragonGeoPoint = dragonData["dragonLocation"];
                              utilsDragonsPositions[dragonData["directoryName"]] = 
                                LatLng(dragonGeoPoint.latitude, dragonGeoPoint.longitude);
                              
                              return FutureBuilder<AssetImage>(
                                future: getFirstImageInGallery(dragonData["directoryName"]),
                                builder: (context, imageSnapshot) {
                                  if (imageSnapshot.hasError) {
                                    developer.log(
                                      name: "HomePage -> getFirstImageInGallery",
                                      "Error while loading first image item: ${imageSnapshot.error.toString()}");
                                  }
                              
                                  if (imageSnapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
      
                                  return Container(
                                    decoration: BoxDecoration(
                                      image: !imageSnapshot.hasError 
                                        ? DecorationImage(
                                            alignment: Alignment.centerLeft,
                                            image: NetworkImage(imageSnapshot.data!.assetName),
                                            fit: BoxFit.cover,
                                            opacity: 0.2
                                          )
                                        : null,
                                      color: isDragonCaught
                                        ? const Color.fromRGBO(0, 0, 0, 0.4)
                                        : const Color.fromRGBO(0, 0, 0, 0.1)
                                    ),
                                    child: ExpansionTile(
                                      leading: isDragonCaught
                                        ? const Icon(Icons.check, color: Colors.black,)
                                        : null,
                                      title: Text(
                                        dragonData["displayName"],
                                        style: isDragonCaught 
                                          ? const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.lineThrough)
                                          : const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)
                                      ),
                                      children: <Widget>[
                                        Wrap(
                                          alignment: WrapAlignment.center,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                MyApp.navigatorKey.currentState!.push(
                                                  MaterialPageRoute(builder: (context) =>
                                                    DragonPage(dragonData: dragonData)
                                                  )
                                                );
                                              },
                                              child: const Text(
                                                "Show Gallery",
                                                style: TextStyle(color: Colors.black)
                                              )
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                MyApp.navigatorKey.currentState!.push(
                                                  MaterialPageRoute(builder: (context) => 
                                                    MapPage(targetDragonData: dragonData)
                                                  )
                                                );
                                              },
                                              child: const Text(
                                                "Navigate",
                                                style: TextStyle(color: Colors.black)
                                              )
                                            ),
                                            userIsAdmin
                                            ? TextButton(
                                                onPressed: () {
                                                  FirestoreDataHandler().adminManageDragon(
                                                    dragonDirectoryName: dragonData["directoryName"].toString(),
                                                    toCatch: true
                                                  );
                                                },
                                                child: const Text(
                                                  "Catch Dragon",
                                                  style: TextStyle(color: Colors.black)
                                                )
                                              )
                                            : Container(),
                                            userIsAdmin
                                            ? TextButton(
                                                onPressed: () {
                                                  FirestoreDataHandler().adminManageDragon(
                                                    dragonDirectoryName: dragonData["directoryName"].toString(),
                                                    toCatch: false
                                                  );
                                                },
                                                child: const Text(
                                                  "Release Dragon",
                                                  style: TextStyle(color: Colors.black)
                                                )
                                              )
                                            : Container()
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
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
      bottomNavigationBar: bottomNavigationBar(),
      floatingActionButton: floatingCameraButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}