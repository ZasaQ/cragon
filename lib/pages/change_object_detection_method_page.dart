import 'package:cragon/services/utilities.dart';
import 'package:flutter/material.dart';

class ChangeObjectDetectionMethodPage extends StatefulWidget {
  const ChangeObjectDetectionMethodPage({super.key});

  @override
  State<ChangeObjectDetectionMethodPage> createState() => _ChangeObjectDetectionMethodPageState();
}

class _ChangeObjectDetectionMethodPageState extends State<ChangeObjectDetectionMethodPage> {
  String selectedOption = utilchoosenObjectDetectionMethod;

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
          const Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topCenter,
                child: Icon(Icons.camera_front, size: 100,)
              ),
              Center(
                child: Text('Here you can change object detection method!',
                  style: TextStyle(color: Colors.black, fontSize: 16.0)),
              ),
            ],
          ),
          const SizedBox(height: 50),
          // Wrap ListView.builder with Expanded
          Expanded(
            child: ListView.builder(
              itemCount: objectDetectionMethods.length,
              itemBuilder: (context, index) {
                return RadioListTile<String>(
                  title: objectDetectionMethods[index] != objectDetectionMethods.last
                    ? Text(objectDetectionMethods[index])
                    : Text("${objectDetectionMethods[index]}\n(Warning! High Memory Usage)"),
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
