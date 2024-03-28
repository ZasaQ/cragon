import 'package:flutter/material.dart';

class FormTextItem extends StatefulWidget {
  final TextEditingController controller;
  final String inLabelText;
  final String inHintText;
  final Widget? prefixIcon;
  final bool isPasswordForm;

  const FormTextItem({
    super.key,
    required this.controller,
    required this.inLabelText,
    required this.inHintText,
    required this.prefixIcon,
    required this.isPasswordForm
  });

  @override
  State<FormTextItem> createState() => _FormTextItemState();
}

class _FormTextItemState extends State<FormTextItem> {
  bool isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
      child: TextField(
        controller: widget.controller,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          labelText: widget.inLabelText,
          labelStyle: const TextStyle(color: Colors.black),
          hintText: widget.inHintText,
          hintStyle: const TextStyle(color: Color.fromRGBO(75, 75, 75, 1)),
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.isPasswordForm 
            ? IconButton(
                icon: isPasswordHidden
                    ? const Icon(Icons.visibility_off, color: Colors.black)
                    : const Icon(Icons.visibility, color: Colors.black),
                onPressed: () =>
                    setState(() => isPasswordHidden = !isPasswordHidden),
              )
            : widget.controller.text.isEmpty
              ? Container(width: 0)
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => widget.controller.clear(),
                ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0)
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0)
          ),
        ),
        obscureText: widget.isPasswordForm ? isPasswordHidden : false
      )
    );
  }
}

