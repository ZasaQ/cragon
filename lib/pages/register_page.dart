import 'package:cragon/components/password_textfield.dart';
import 'package:flutter/material.dart';

import 'package:cragon/components/login_textfield.dart';
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
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        top: true,
        child: Container(
          decoration: const BoxDecoration(color: Color.fromRGBO(128, 128, 0, 0.85)),
          child: Column(
            children: <Widget>[
              const Align(
                alignment: Alignment.topCenter,
                child: Image(
                  image: AssetImage('lib/images/register_icon.png'),
                  height: 100,
                  width: 100
                )
              ),

              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    const Center(
                      child: Text('Welcome! Try to Sign Up',
                        style: TextStyle(fontSize: 16)),
                    ),

                    const SizedBox(height: 60),
                    
                    LoginTextField(
                      controller: emailController,
                      inLabelText: "Email",
                      inHintText: "name@example.com"
                    ),
                    
                    const SizedBox(height: 20),
        
                    PasswordTextField(
                      controller: passwordController,
                      inLabelText: "Password",
                      inHintText: "password",
                    ),
                    
                    const SizedBox(height: 20),
        
                    PasswordTextField(
                      controller: confirmPasswordController,
                      inLabelText: "Confirm Password",
                      inHintText: "confirm password",
                    ),
                    
                    const SizedBox(height: 30),
        
                    LRButton(inText: "Sign Up", onPressed: () => {
                      authenticationServices.signUpWithEmail(
                        emailController.text,
                        passwordController.text,
                        confirmPasswordController.text
                      )
                    }),

                    const SizedBox(height: 40),

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
                          style: TextStyle(fontSize: 16),)
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
                  ]
                )
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ",
                    style: TextStyle(fontSize: 16)
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