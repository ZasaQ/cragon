import 'package:flutter/material.dart';

class LRText extends StatelessWidget {
  final TextEditingController controller;
  final String inHintText;
  final bool inObscureText;

  const LRText({
    super.key,
    required this.controller,
    required this.inHintText,
    required this.inObscureText
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        style: TextStyle(color:Colors.grey[700]),
        controller: controller,
        obscureText: inObscureText,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey)
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade900)
          ),
          fillColor: Colors.white,
          filled: true,
          hintText: inHintText,
          hintStyle: TextStyle(color: Colors.grey[500])
        )
      )
    );
  }
}