import 'package:flutter/material.dart';

import 'package:cragon/components/lr_text.dart';
import 'package:cragon/components/lr_button.dart';
import 'package:cragon/services/authentication_services.dart';
import 'package:cragon/main.dart';
import 'package:cragon/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthenticationServices authenticationServices = AuthenticationServices();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text("Register"),),
      body: Container(
        decoration: BoxDecoration(color: Colors.blue[400]),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                children: [
                  LRText(controller: emailController, inHintText: "Email", inObscureText: false),
                  LRText(controller: passwordController, inHintText: "Password", inObscureText: true),
                  LRButton(inText: "Sign Up", onPressed: () => {
                    authenticationServices.signUpWithEmail(emailController.text, passwordController.text)
                  })
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {
                  MyApp.navigatorKey.currentState!.pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text("Sign In"),
              ),
            )
          ],
        ),
      ),
    );
  }
}