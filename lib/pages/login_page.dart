import 'package:cragon/main.dart';
import 'package:cragon/pages/register_page.dart';
import 'package:flutter/material.dart';

import 'package:cragon/components/lr_text.dart';
import 'package:cragon/components/lr_button.dart';
import 'package:cragon/services/authentication_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthenticationServices authenticationServices = AuthenticationServices();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("Login"),),
      body: Container(
        decoration: BoxDecoration(color: Colors.blue[400]),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                children: [
                  LRText(controller: emailController, inHintText: "Email", inObscureText: false),
                  LRText(controller: passwordController, inHintText: "Password", inObscureText: true),
                  LRButton(inText: "Sign In", onPressed: () => {
                    authenticationServices.signInWithEmail(emailController.text, passwordController.text)
                  })
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  MyApp.navigatorKey.currentState!.pushReplacement(
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text("Sign Up"),
              ),
            )
          ],
        ),
      ),
    );
  }
}