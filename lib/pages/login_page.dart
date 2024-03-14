import 'package:flutter/material.dart';

import 'package:cragon/main.dart';
import 'package:cragon/pages/register_page.dart';

import 'package:cragon/components/login_textfield.dart';
import 'package:cragon/components/password_textfield.dart';
import 'package:cragon/components/lr_button.dart';
import 'package:cragon/services/authentication_services.dart';
import 'package:cragon/pages/forgot_password_page.dart';

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
      body: SafeArea(
        top: true,
        child: Container(
          decoration: const BoxDecoration(color: Color.fromRGBO(128, 128, 0, 1)),
          child: Column(
            children: <Widget>[
              const Align(
                alignment: Alignment.topCenter,
                child: Image(
                  image: AssetImage('lib/images/lock_icon.png'),
                  height: 100,
                  width: 100
                )
              ),
        
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 50),

                    const Center(
                      child: Text('Welcome! Try to Sign In',
                        style: TextStyle(fontSize: 16)),
                    ),

                    const SizedBox(height: 50),
        
                    LoginTextField(
                      controller: emailController,
                      inLabelText: "Email",
                      inHintText: "name@example.com"
                    ),
        
                    const SizedBox(height: 30),
        
                    PasswordTextField(
                      controller: passwordController,
                      inLabelText: "Password",
                      inHintText: 'Your Password',
                    ),
        
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              MyApp.navigatorKey.currentState!.push(
                                MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                              );
                            },
                            child: const Text('Forgot password?',
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
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
                            child: Divider(thickness: 2, color: Colors.black)
                          ),
                        ),

                        Center(
                          child: Text("or continue with",
                            style: TextStyle(fontSize: 16),
                          )
                        ),

                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Divider(thickness: 2, color: Colors.black)
                          ),
                        ), 
                      ],
                    ),

                    const SizedBox(height: 30),

                    Center(
                      child: GestureDetector(
                        onTap: () => authenticationServices.signInWithGoogle(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color.fromRGBO(128, 128, 0, 0)
                          ),
                          child: const Image(
                            image: AssetImage('lib/images/google_icon.png'), 
                            height: 50,
                          )
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ",
                    style: TextStyle(fontSize: 16)
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        MyApp.navigatorKey.currentState!.pushReplacement(
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text("Sign Up!",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        )
                      )
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