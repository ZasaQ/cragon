import 'package:cragon/services/authentication_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        title: const Text("Home Page"),
        actions: [],
      ),
      drawer: Drawer(
        child: Column(children: [
          ListTile(
            tileColor: Colors.black,
            leading: const Icon(Icons.logout,color: Colors.white,),
            title: const Text("Log out"),
            titleTextStyle: const TextStyle(color: Colors.white),
            onTap: () {
              authenticationServices.userSignOut(FirebaseAuth.instance.currentUser!.uid);
            },
          )
        ]),
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.blue[400]),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        authenticationServices.userSignOut(FirebaseAuth.instance.currentUser!.uid);
                      },
                      child: const Text("SIGN OUT"),
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