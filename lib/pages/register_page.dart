import 'package:cragon/services/utilities.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:cragon/components/form_text_item.dart';
import 'package:cragon/components/lr_button.dart';
import 'package:cragon/services/authentication_services.dart';
import 'package:cragon/main.dart';
import 'package:cragon/pages/login_page.dart';
import 'package:cragon/components/header_item.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthenticationServices authenticationServices = AuthenticationServices();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    developer.log(
      name: "RegisterPage -> initState",
      "Current user has entered RegisterPage");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: <Widget>[
                const HeaderItem(headerIcon: Icons.book, headerText: "Welcome! Try to Sign Up"),
        
                FormTextItem(
                  controller: emailController,
                  inLabelText: "Email",
                  inHintText: "name@example.com",
                  prefixIcon: const Icon(Icons.email),
                  isPasswordForm: false,
                ),
        
                const SizedBox(height: 20),
        
                FormTextItem(
                  controller: passwordController,
                  inLabelText: "Password",
                  inHintText: "password",
                  prefixIcon: const Icon(Icons.lock),
                  isPasswordForm: true,
                ),
        
                const SizedBox(height: 20),
        
                FormTextItem(
                  controller: confirmPasswordController,
                  inLabelText: "Confirm Password",
                  inHintText: "confirm password",
                  prefixIcon: const Icon(Icons.lock),
                  isPasswordForm: true,
                ),
        
                const SizedBox(height: 30),
        
                LRButton(inText: "Sign Up", onPressed: () => {
                  authenticationServices.signUpWithEmail(
                      emailController.text,
                      passwordController.text,
                      confirmPasswordController.text)
                }),
        
                const SizedBox(height: 40),
        
                Row(
                  children: [
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(),
                      ),
                    ),
        
                    Center(
                      child: Text("or continue with",
                        style: Theme.of(context).textTheme.bodyMedium),
                    ),
        
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(),
                      ),
                    ),
                  ],
                ),
        
                const SizedBox(height: 30),
        
                SizedBox(
                  width: 70,
                  height: 70,
                  child: FittedBox(
                    child: FloatingActionButton(
                      onPressed: () => authenticationServices.authenticateGoogleUser(context: context),
                      child: const Image(
                        image: AssetImage('lib/images/google_icon.png'),
                        height: 40,
                      ),
                    ),
                  ),
                ),
        
                const SizedBox(height: 30),
        
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium
                    ),
        
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () {
                          MyApp.navigatorKey.currentState!.pushReplacement(
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        child: const Text("Sign In",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: utilMainTextColor
                          )
                        )
                      )
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
