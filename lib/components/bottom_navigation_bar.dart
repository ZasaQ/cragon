import 'package:cragon/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:cragon/main.dart';
import 'package:cragon/pages/user_page.dart';
import 'package:cragon/services/authentication_services.dart';


Widget bottomNavigationBar() {
  return BottomAppBar(
    color: const Color.fromRGBO(38, 45, 53, 1),
    shape: const CircularNotchedRectangle(),
    notchMargin: 6,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          iconSize: 30,
          icon: const Icon(
            Icons.home,
            color: Color.fromRGBO(128, 128, 0, 1),
          ),
          onPressed: () {
            MyApp.navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(builder: (context) => const HomePage()));
          },
        ),
        IconButton(
          iconSize: 30,
          icon: const Icon(
            Icons.person,
            color: Color.fromRGBO(128, 128, 0, 1),
          ),
          onPressed: () {
            MyApp.navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(builder: (context) => const UserPage()));
          },
        ),
        const SizedBox(
          width: 40,
        ),
        IconButton(
          iconSize: 30,
          icon: const Icon(
            Icons.map,
            color: Color.fromRGBO(128, 128, 0, 1),
          ),
          onPressed: () {},
        ),
        IconButton(
          iconSize: 30,
          icon: const Icon(
            Icons.logout,
            color: Color.fromRGBO(128, 128, 0, 1),
          ),
          onPressed: () {
            AuthenticationServices().signOutCurrentUser();
            developer.log("User has signed out");
          },
        ),
      ],
    ),
  );
}