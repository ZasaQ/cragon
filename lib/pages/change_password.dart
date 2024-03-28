import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

import 'package:cragon/components/form_text_item.dart';
import 'package:cragon/components/lr_button.dart';
import 'package:cragon/services/utilities.dart';


class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();

}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  void changePassword(TextEditingController currentPasswordController, TextEditingController newPasswordController, TextEditingController confirmPasswordController) async {
    bool isError = false;
    try {
      String currentPassword = currentPasswordController.text.toString();
      String newPassword = newPasswordController.text.toString();
      String confirmPassword = confirmPasswordController.text.toString();

      final currentUser = FirebaseAuth.instance.currentUser;
      final AuthCredential credential = EmailAuthProvider.credential(email: currentUser!.email.toString(), password: currentPassword);

      if (currentPassword.isEmpty || newPassword.isEmpty ||  confirmPassword.isEmpty) {
        showAlertMessage('Form fields can not be empty!');
        isError = true;
        return;
      }

      if (newPassword != confirmPassword) {
        showAlertMessage('New password and confirmation must be the same!');
        isError = true;
        return;
      }

      try {
        await currentUser.reauthenticateWithCredential(credential).then((value) {
          currentUser.updatePassword(newPassword);
        });
      } on FirebaseAuthException catch (e) {
        developer.log("Log: changePassword -> ${e.code}");
        showAlertMessage(e.code);
        isError = true;
      }

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      if (!isError) {
        developer.log("Log: changePassword -> Password has been changed!");
        showAlertMessage("Password has been changed!");
        return;
      }

    } on FirebaseAuthException catch (e) {
      showAlertMessage(e.code);
      return;
    }
  }


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
                  changePassword(
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