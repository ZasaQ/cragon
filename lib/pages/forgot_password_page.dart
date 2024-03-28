import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cragon/main.dart';
import 'package:cragon/components/form_text_item.dart';
import 'package:cragon/components/lr_button.dart';
import 'package:cragon/services/utilities.dart';


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(128, 128, 0, 1),
      appBar: AppBar(backgroundColor: const Color.fromRGBO(128, 128, 0, 1)),
      body: Column(
        children: <Widget> [          
          Align(
            alignment: Alignment.center,
            child: Expanded(
              child: Column(
                children: [
                   const Center(
                    child: Text('Please type your email to receive password reset request', 
                      style: TextStyle(color: Colors.black)
                    ),
                  ),
              
                  const SizedBox(height: 20),
              
                  // Email text field
                  FormTextItem(
                    controller: emailController,
                    inLabelText: 'Email',
                    inHintText: 'Email',
                    prefixIcon: const Icon(Icons.email, color: Colors.black),
                    isPasswordForm: false,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  LRButton(inText: 'Send Request', onPressed: () async {
                    try {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: emailController.text).then((value) => 
                          MyApp.navigatorKey.currentState!.pop(context)
                      );
                    } on FirebaseAuthException catch (excep) {
                      if (emailController.text.isEmpty) {
                        return showAlertMessage("Email can not be empty");
                      }
                      return showAlertMessage(excep.code);
                    }
                  })
                ],
              )
            ),
          ),
        ]
      )
    );
  }
}