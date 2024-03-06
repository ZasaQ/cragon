import 'package:cragon/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cragon/firebase_options.dart';
import 'package:cragon/pages/home_page.dart';
import 'package:cragon/services/authentication_services.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String homeRoute = '/home';

  @override
  void initState() {
    super.initState();
  }

  List<Route<dynamic>> onGeneratedInitialRoutes(String initialRouteName) {
    List<Route<dynamic>> pageStack = [];

    pageStack.add(MaterialPageRoute(builder: (_) => const CheckAuthenticationStatus()));

    return pageStack;
  }

  Route<dynamic>? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case homeRoute:
      return MaterialPageRoute(builder: (_) => const HomePage());
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      )
    );
  }
}

class CheckAuthenticationStatus extends StatefulWidget {
  const CheckAuthenticationStatus({super.key});

  @override
  State<CheckAuthenticationStatus> createState() => _CheckAuthenticationStatusState();
}

class _CheckAuthenticationStatusState extends State<CheckAuthenticationStatus> {
  AuthenticationServices authenticationServices = AuthenticationServices();

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return const HomePage();
          })
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return const LoginPage();
          })
        ); //await authenticationServices.authenticateGoogleUser(context: context);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/*class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}*/


