import 'package:cragon/services/authentication_services.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  AuthenticationServices authenticationServices = AuthenticationServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(128, 128, 0, 1),
        title: const Text("Home Page"),
        actions: [],
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