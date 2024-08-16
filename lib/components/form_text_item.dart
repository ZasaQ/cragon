import 'package:flutter/material.dart';
import 'package:cragon/services/utilities.dart';


class FormTextItem extends StatefulWidget {
  final TextEditingController controller;
  final Color cursorColor = utilMainTextColor;
  final enableBorder = const OutlineInputBorder(
            borderSide: BorderSide(color: utilMainTextColor, width: 2.0));
  final focusedBorder = const OutlineInputBorder(
            borderSide: BorderSide(color: utilMainTextColor, width: 2.0));
  final String inLabelText;
  final TextStyle labelTextStyle = const TextStyle(color: utilMainTextColor);
  final String inHintText;
  final TextStyle hintTextStyle = const TextStyle(color: Color.fromRGBO(75, 75, 75, 1), fontSize: 16.0);
  final Widget? prefixIcon;
  final Color iconColor = utilMainTextColor;
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
        cursorColor: widget.cursorColor,
        decoration: InputDecoration(
          labelText: widget.inLabelText,
          labelStyle: widget.labelTextStyle,
          hintText: widget.inHintText,
          hintStyle: widget.hintTextStyle,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.isPasswordForm 
            ? IconButton(
                icon: isPasswordHidden
                    ? Icon(Icons.visibility_off, color: widget.iconColor)
                    : Icon(Icons.visibility, color: widget.iconColor),
                onPressed: () =>
                    setState(() => isPasswordHidden = !isPasswordHidden),
              )
            : widget.controller.text.isEmpty
              ? Container(width: 0)
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => widget.controller.clear(),
                ),
          enabledBorder: widget.enableBorder,
          focusedBorder: widget.focusedBorder
        ),
        obscureText: widget.isPasswordForm ? isPasswordHidden : false
      )
    );
  }
}

