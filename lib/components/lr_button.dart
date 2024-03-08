import 'package:flutter/material.dart';

class LRButton extends StatelessWidget {
  final String inText;
  final Function()? onPressed;

  const LRButton({super.key, required this.inText, required this.onPressed});

  @override
  Widget build(BuildContext context) {    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 97, 97, 97), 
        borderRadius: BorderRadius.circular(5)
      ),
      child: TextButton(
        onPressed: onPressed, 
        child: Center(child: Text(inText,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
          ),
        )
      ),
    );
  }
}