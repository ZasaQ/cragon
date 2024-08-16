import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:cragon/components/form_text_item.dart';
import 'package:cragon/components/lr_button.dart';
import 'package:cragon/services/authentication_services.dart';
import 'package:cragon/services/utilities.dart';
import 'package:cragon/components/header_item.dart';


class DeleteUserPage extends StatefulWidget {
  const DeleteUserPage({super.key});

  @override
  State<DeleteUserPage> createState() => _DeleteUserPageState();
}

class _DeleteUserPageState extends State<DeleteUserPage> {
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    developer.log(
      name: "DeleteUserPage -> initState",
      "Current user has entered DeleteUserPage");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete account"),
      ),
      body: Column(
        children: <Widget>[
          const HeaderItem(
            headerIcon: Icons.person_remove,
            headerText: "Here you can delete your account!",
            headerPadding: EdgeInsets.only(bottom: 60, top: 20),
          ),

          Expanded(
            child: Column(
              children: <Widget>[
                FormTextItem(
                  controller: passwordController,
                  inLabelText: "Password",
                  inHintText: "Your password",
                  prefixIcon: const Icon(Icons.lock, color: utilMainTextColor),
                  isPasswordForm: true
                ),

                const SizedBox(height: 20.0),
          
                LRButton(inText: "Delete Account", onPressed: () {
                  String password = passwordController.text.toString();
            
                  AuthenticationServices().reauthenticateCurrentUser(password: password).then(
                    (bool isReauthenticated) {
                      if (isReauthenticated) {
                        AuthenticationServices().deleteCurrentUser();
                      } else {
                        showAlertMessageWithTimer("Wrong password!", 2);
                        developer.log(name: "DeleteUserPage -> reauthenticateCurrentUser", "Wrong password");
                      }
                    }
                  );
                })
              ]
            )
          ),
        ],
      ),
    );
  }
}