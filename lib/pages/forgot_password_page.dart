import 'package:cragon/components/header_item.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

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
  void initState() {
    super.initState();
    
    developer.log(
      name: "ForgotPasswordPage -> initState",
      "Current user has entered ForgotPasswordPage");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recover password")
      ),
      body: Column(
        children: <Widget> [
          const HeaderItem(
            headerIcon: Icons.lock_open_outlined,
            headerText: "Here you can restore your passowrd via email!"
          ),

          Expanded(
            child: Column(
              children: <Widget>[
                FormTextItem(
                  controller: emailController,
                  inLabelText: 'Email',
                  inHintText: 'name@exmaple.com',
                  prefixIcon: const Icon(Icons.email, color: utilMainTextColor),
                  isPasswordForm: false,
                ),

                const SizedBox(height: 60),

                LRButton(inText: 'Send Request', onPressed: () async {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: emailController.text).then((value) => 
                        MyApp.navigatorKey.currentState!.pop(context)
                    );
                  } on FirebaseAuthException catch (e) {
                    if (emailController.text.isEmpty) {
                      return showAlertMessageWithTimer("Email can not be empty", 2);
                    }
                    return showAlertMessageWithTimer(e.code, 2);
                  }
                })
              ],
            ), 
          )
        ]
      )
    );
  }
}