import 'package:flutter/material.dart';

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String inLabelText;
  final String inHintText;

  const LoginTextField({
    super.key,
    required this.controller,
    required this.inLabelText,
    required this.inHintText
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        cursorColor: Colors.black,
        style: const TextStyle(color:Colors.black),
        decoration: InputDecoration(
          labelText: inLabelText,
          labelStyle: const TextStyle(color: Colors.black),
          hintText: inHintText,
          hintStyle: const TextStyle(color: Color.fromRGBO(75, 75, 75, 1)),
          prefixIcon: const Icon(
            Icons.mail,
            color: Colors.black
          ),
          suffixIcon: controller.text.isEmpty
              ? Container(width: 0)
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => controller.clear(),
                ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0)
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0)
          ),
        ),
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
      )
    );
  }
}

