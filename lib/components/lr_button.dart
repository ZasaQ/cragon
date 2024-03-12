import 'package:flutter/material.dart';

class LRButton extends StatelessWidget {
  final String inText;
  final Function()? onPressed;

  const LRButton({super.key, required this.inText, required this.onPressed});

  @override
  Widget build(BuildContext context) {    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 100),
      decoration: BoxDecoration(
        color: Colors.black, 
        borderRadius: BorderRadius.circular(5)
      ),
      child: TextButton(
        onPressed: onPressed, 
        child: Center(child: Text(inText,
            style: const TextStyle(
              color: Color.fromRGBO(128, 128, 0, 1),
              fontSize: 16,
              fontWeight: FontWeight.bold
            )
          ),
        )
      ),
    );
  }
}