import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'dart:developer' as developer;

import 'package:cragon/pages/login_page.dart';
import 'package:cragon/pages/register_page.dart';
import 'package:cragon/firebase_options.dart';
import 'package:cragon/pages/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterStatusbarcolor.setStatusBarColor(const Color.fromRGBO(128, 128, 0, 1));

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Route<dynamic>> onGeneratedInitialRoutes(String initialRouteName) {
    List<Route<dynamic>> pageStack = [];

    pageStack.add(MaterialPageRoute(builder: (_) => const CheckAuthenticationStatus()));

    return pageStack;
  }

  Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case "/home":
        return MaterialPageRoute(builder: (_) => const HomePage());
      case "/login":
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case "/register":
        return MaterialPageRoute(builder: (_) => const RegisterPage());
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cragon',
      navigatorKey: MyApp.navigatorKey,
      onGenerateInitialRoutes: onGeneratedInitialRoutes,
      onGenerateRoute: onGenerateRoute,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(128, 128, 0, 1.0),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(128, 128, 0, 1)),
        useMaterial3: true,
      ),
    );
  }
}

class CheckAuthenticationStatus extends StatefulWidget {
  const CheckAuthenticationStatus({super.key});

  @override
  State<CheckAuthenticationStatus> createState() => _CheckAuthenticationStatusState();
}

class _CheckAuthenticationStatusState extends State<CheckAuthenticationStatus> {

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        MyApp.navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );

        developer.log("Log: current user is not null, pushing HomePage");
        developer.log("Log: ${MyApp.navigatorKey.currentState}");
      } else {
        MyApp.navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );

        developer.log("Log: current user is null, pushing LoginPage");
        developer.log("Log: ${MyApp.navigatorKey.currentState}");
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}