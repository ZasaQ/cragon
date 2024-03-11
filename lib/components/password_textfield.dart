import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String inLabelText;
  final String inHintText;

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.inLabelText,
    required this.inHintText,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: widget.controller,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          labelText: widget.inLabelText,
          labelStyle: const TextStyle(color: Colors.black),
          hintText: widget.inHintText,
          hintStyle: const TextStyle(color: Color.fromRGBO(75, 75, 75, 1)),
          prefixIcon: const Icon(
            Icons.lock,
            color: Colors.black,
          ),
          suffixIcon: IconButton(
            icon: isPasswordHidden
                ? const Icon(Icons.visibility_off, color: Colors.black)
                : const Icon(Icons.visibility, color: Colors.black),
            onPressed: () =>
                setState(() => isPasswordHidden = !isPasswordHidden),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0)
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0)
          ),
        ),
        obscureText: isPasswordHidden,
      )
    );
  }
}

