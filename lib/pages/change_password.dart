import 'package:cragon/components/header_item.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:cragon/components/form_text_item.dart';
import 'package:cragon/components/lr_button.dart';
import 'package:cragon/services/authentication_services.dart';


class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();

}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    developer.log(
      name: "ChangePasswordPage -> initState",
      "Current user has entered ChangePasswordPage");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change password')
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const HeaderItem(
            headerIcon: Icons.password_sharp,
            headerText: "Here you can change your password"
          ),
      
          Expanded(
            child: Column(
              children: [
                FormTextItem(
                  controller: currentPasswordController,
                  inLabelText: "Current password",
                  inHintText: "Your passowrd",
                  prefixIcon: null,
                  isPasswordForm: true,
                ),
                      
                const SizedBox(height: 20),
                      
                FormTextItem(
                  controller: newPasswordController,
                  inLabelText: "New passowrd",
                  inHintText: "Your new passowrd",
                  prefixIcon: null,
                  isPasswordForm: true
                ),
                      
                const SizedBox(height: 20),
                      
                FormTextItem(
                  controller: confirmPasswordController,
                  inLabelText: "Confirm new passowrd",
                  inHintText: "Confirm your new passowrd",
                  prefixIcon: null,
                  isPasswordForm: true
                ),
                      
                const SizedBox(height: 60),
                      
                LRButton(inText: "Change password", onPressed: () {
                  AuthenticationServices().changePassword(
                    currentPasswordController,
                    newPasswordController,
                    confirmPasswordController
                  );
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}