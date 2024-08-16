import 'package:cragon/main.dart';
import 'package:cragon/pages/map_page.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:cragon/services/firestore_data_handler.dart';


class DragonPage extends StatefulWidget {
  const DragonPage({
    super.key,
    required this.dragonData,
  });

  final Map<String,dynamic> dragonData;

  @override
  State<DragonPage> createState() => _DragonPageState();
}

class _DragonPageState extends State<DragonPage> {
  @override
  void initState() {
    super.initState();

    developer.log(
      name: "DragonPage -> initState",
      "Current user has entered DragonPage");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.dragonData["displayName"]} Gallery"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Flexible(
            child: FutureBuilder<List<Image>>(
              future: FirestoreDataHandler().getDragonGalleryImages(widget.dragonData["directoryName"]),
              builder: (context, imageSnapshot) {
                if (imageSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
            
                if (imageSnapshot.hasError) {
                  return Text('Error: ${imageSnapshot.error.toString()}');
                }
            
                List<Image>? imageWidgets = imageSnapshot.data;
            
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Image(image: imageWidgets[index].image),
                            );
                          },
                        );
                      },
                      child: Ink.image(
                        image: imageWidgets[index].image,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                  itemCount: imageWidgets!.length,
                );
              }
            ),
          ),

          Container(
            margin: const EdgeInsets.only(bottom: 50),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(0, 0, 0, 0.1),
            ),
            child: IconButton(
              iconSize: 50,
              icon: const Icon(Icons.location_pin),
              onPressed: () {
                MyApp.navigatorKey.currentState!.push(
                  MaterialPageRoute(builder: (context) => 
                    MapPage(targetDragonData: widget.dragonData)
                  )
                );
              },
            )
          )
        ],
      ),
    );
  }
}