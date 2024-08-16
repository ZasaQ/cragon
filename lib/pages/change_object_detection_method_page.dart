import 'package:cragon/components/header_item.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:cragon/services/utilities.dart';


class ChangeObjectDetectionMethodPage extends StatefulWidget {
  const ChangeObjectDetectionMethodPage({super.key});

  @override
  State<ChangeObjectDetectionMethodPage> createState() => _ChangeObjectDetectionMethodPageState();
}

class _ChangeObjectDetectionMethodPageState extends State<ChangeObjectDetectionMethodPage> {
  String selectedOption = utilchoosenObjectDetectionMethod;

  @override
  void initState() {
    super.initState();

    developer.log(
      name: "ChangeObjectDetectionMethodPage -> initState",
      "Current user has entered ChangeObjectDetectionMethodPage");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Method"),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const HeaderItem(
            headerIcon: Icons.camera_front,
            headerText: "Here you can change object detection method!",
            headerPadding: EdgeInsets.only(bottom: 20, top: 20),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: objectDetectionMethods.length,
              itemBuilder: (context, index) {
                return RadioListTile<String>(
                  title: objectDetectionMethods[index] != objectDetectionMethods.last
                    ? Text(
                      objectDetectionMethods[index],
                      style: Theme.of(context).textTheme.bodyMedium
                    )
                    : Text(
                      "${objectDetectionMethods[index]}\n(Warning! High Memory Usage)",
                      style: Theme.of(context).textTheme.bodyMedium
                    ),
                  value: objectDetectionMethods[index],
                  groupValue: selectedOption,
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value!;
                      utilchoosenObjectDetectionMethod = value;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
