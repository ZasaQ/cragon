import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(128, 128, 0, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(128, 128, 0, 1),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Align(
            alignment: Alignment.topCenter,
            child: Image(
              image: AssetImage('lib/images/change_password_icon.png'),
              height: 100,
              width: 100
            )
          ),

          const SizedBox(height: 20),
      
          Expanded(
            child: Column(
              children: [
                const Center(
                  child: Text('Here you can change your password!',
                    style: TextStyle(fontSize: 16)),
                ),

                const SizedBox(height: 50),

                FormTextItem(
                  controller: currentPasswordController,
                  inLabelText: "Current password",
                  inHintText: "Your passowrd",
                  prefixIcon: null,
                  isPasswordForm: true,
                ),
                      
                const SizedBox(height: 30),
                      
                FormTextItem(
                  controller: newPasswordController,
                  inLabelText: "New passowrd",
                  inHintText: "Your new passowrd",
                  prefixIcon: null,
                  isPasswordForm: true
                ),
                      
                const SizedBox(height: 30),
                      
                FormTextItem(
                  controller: confirmPasswordController,
                  inLabelText: "Confirm new passowrd",
                  inHintText: "Confirm your new passowrd",
                  prefixIcon: null,
                  isPasswordForm: true
                ),
                      
                const SizedBox(height: 30),
                      
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