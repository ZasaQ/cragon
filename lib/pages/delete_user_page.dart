import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:cragon/components/form_text_item.dart';
import 'package:cragon/components/lr_button.dart';
import 'package:cragon/services/authentication_services.dart';
import 'package:cragon/services/utilities.dart';


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
      backgroundColor: const Color.fromRGBO(128, 128, 0, 1),
      appBar: AppBar(backgroundColor: const Color.fromRGBO(128, 128, 0, 1),),
      body: Column(
        children: <Widget>[
          const Align(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Image(
                  image: AssetImage('lib/images/delete_account_icon.png'),
                  height: 100.0,
                  width: 100.0,
                ),
                Center(
                child: Text('Here you can delete your account', 
                  style: TextStyle(color: Colors.black, fontSize: 16.0)
                  ),
                ),
              ]
            )
          ),

          const SizedBox(height: 50.0),

          Expanded(
            child: Column(
              children: <Widget>[
                FormTextItem(
                  controller: passwordController,
                  inLabelText: "Password",
                  inHintText: "Your password",
                  prefixIcon: const Icon(Icons.lock, color: Colors.black),
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