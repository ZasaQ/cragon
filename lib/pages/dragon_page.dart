import 'package:flutter/material.dart';
import 'package:cragon/services/firestore_data_handler.dart';


class DragonPage extends StatefulWidget {
  const DragonPage({
    super.key,
    required this.dragonName
  });

  final String dragonName;

  @override
  State<DragonPage> createState() => _DragonPageState();
}

class _DragonPageState extends State<DragonPage> {
  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(128, 128, 0, 1),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Color.fromRGBO(128, 128, 0, 1)),
        backgroundColor: const Color.fromRGBO(38, 45, 53, 1),
        title: Text(widget.dragonName, style: const TextStyle(color: Color.fromRGBO(128, 128, 0, 1))),
      ),
      body: FutureBuilder<List<Image>>(
        future: FirestoreDataHandler().getDragonGallery(widget.dragonName),
        builder: (context, imageSnapshot) {   
          if (imageSnapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
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
      )
    );
  }
}