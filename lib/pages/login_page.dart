import 'package:cragon/services/utilities.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:cragon/main.dart';
import 'package:cragon/pages/register_page.dart';
import 'package:cragon/components/form_text_item.dart';
import 'package:cragon/components/lr_button.dart';
import 'package:cragon/services/authentication_services.dart';
import 'package:cragon/pages/forgot_password_page.dart';
import 'package:cragon/components/header_item.dart';


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
  void initState() {
    super.initState();

    developer.log(
      name: "LoginPage -> initState",
      "Current user has entered LoginPage");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const HeaderItem(
                headerIcon: Icons.lock_outline,
                headerText: "Welcom! Try to Sign In"
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [                                
                    FormTextItem(
                      controller: emailController,
                      inLabelText: "Email",
                      inHintText: "name@example.com",
                      prefixIcon: const Icon(Icons.email),
                      isPasswordForm: false
                    ),
                
                    const SizedBox(height: 30),
                
                    FormTextItem(
                      controller: passwordController,
                      inLabelText: "Password",
                      inHintText: 'Your Password',
                      prefixIcon: const Icon(Icons.lock),
                      isPasswordForm: true
                    ),
                
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              MyApp.navigatorKey.currentState!.push(
                                MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                              );
                            },
                            child: Text('Forgot password?',
                              style: Theme.of(context).textTheme.bodySmall
                            ),
                          )
                        ]
                      )
                    ),
                
                    const SizedBox(height: 50),
                
                    LRButton(inText: "Sign In", onPressed: () => {
                      authenticationServices.signInWithEmail(
                        emailController.text, passwordController.text)
                    }),
                
                    const SizedBox(height: 60),
                
                    const Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Divider(thickness: 2, color: utilMainTextColor)
                          ),
                        ),
                
                        Center(
                          child: Text("or continue with",
                            style: TextStyle(fontSize: 16, color: utilMainTextColor),
                          )
                        ),
                
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Divider()
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
                  ],
                ),
              ),
                
              const SizedBox(height: 30),
                
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ",
                    style: TextStyle(
                      color: utilMainTextColor,
                      fontSize: 16
                    )
                  ),
                
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        MyApp.navigatorKey.currentState!.pushReplacement(
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        "Sign Up!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: utilMainTextColor
                        ))
                    )
                  )
                ]
              )
            ],
          ),
        ),
      ),
    );
  }
}
