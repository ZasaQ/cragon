import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(child: Text("Login")));
      
  }

}