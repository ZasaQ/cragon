import 'package:camera/camera.dart';
import 'package:cragon/main.dart';
import 'package:cragon/pages/camera_page.dart';
import 'package:flutter/material.dart';
import 'package:cragon/services/authentication_services.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  AuthenticationServices authenticationServices = AuthenticationServices();
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
        backgroundColor: const Color.fromRGBO(128, 128, 0, 1),
        title: const Text("Home Page"),
        actions: <Widget> [
          IconButton(
            icon: const Icon(Icons.camera, color: Colors.black,),
            tooltip: 'Open Camera',
            onPressed: () {
              MyApp.navigatorKey.currentState!.push(
                MaterialPageRoute(builder: (context) => CameraPage(camera: firstCamera)));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(128, 128, 0, 1),
              ),
              child: Text('Drawer Header'),
            ),

            ListTile(
              tileColor: const Color.fromRGBO(128, 128, 0, 1),
              leading: const Icon(Icons.logout,color: Colors.white,),
              title: const Text("Log out"),
              titleTextStyle: const TextStyle(color: Colors.white),
              onTap: () {
                authenticationServices.signOutCurrentUser();
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
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        authenticationServices.signOutCurrentUser();
                      },
                      child: const Text("SIGN OUT"),
                    ),
                  ),

                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        authenticationServices.deleteCurrentUser();
                      },
                      child: const Text("DELETE USER"),
                    ),
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