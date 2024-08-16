import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:cragon/main.dart';
import 'package:cragon/pages/user_page.dart';
import 'package:cragon/services/authentication_services.dart';
import 'package:cragon/pages/home_page.dart';
import 'package:cragon/pages/map_page.dart';
import 'package:cragon/services/utilities.dart';


Widget bottomNavigationBar() {
  return BottomAppBar(
    color: utilMainTextColor,
    shape: const CircularNotchedRectangle(),
    notchMargin: 6.0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          iconSize: 30,
          icon: const Icon(
            Icons.home,
            color: utilMainBackgroundColor,
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
            color: utilMainBackgroundColor,
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
            color: utilMainBackgroundColor,
          ),
          onPressed: () {
            MyApp.navigatorKey.currentState!.push(
                MaterialPageRoute(builder: (context) => const MapPage()));
          },
        ),
        IconButton(
          iconSize: 30,
          icon: const Icon(
            Icons.logout,
            color: utilMainBackgroundColor,
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