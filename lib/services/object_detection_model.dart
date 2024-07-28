import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:typed_data';
import 'dart:developer' as developer;

class ObjectDetectionModel {
  late Interpreter interpreter;

  ObjectDetectionModel();

  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/detect.tflite');
  }

  List<Map<String, dynamic>> detectObjects(Uint8List imageBytes) {
    var input = imageBytes.buffer.asUint8List();

    // Allocate buffers for outputs
    var outputScores = List.generate(1, (index) => List.filled(10, 0.0));
    var outputBoxes = List.generate(1, (index) => List.generate(10, (index) => List.filled(4, 0.0)));
    var outputCount = List.filled(1, 0);
    var outputClasses = List.generate(1, (index) => List.filled(10, 0));

    // Run inference
    interpreter.runForMultipleInputs([input], {
      0: outputScores,
      1: outputBoxes,
      2: outputCount,
      3: outputClasses,
    });

    // Extract results and map to the desired format
    List<Map<String, dynamic>> results = [];
    int count = outputCount[0];

    for (int i = 0; i < count; i++) {
      var confidence = outputScores[0][i]; // Assuming outputScores contains confidence scores
      var box = outputBoxes[0][i];         // Bounding box
      var detectedClassIndex = outputClasses[0][i]; // Class index

      if (confidence > 0.5) { // Apply a confidence threshold
        results.add({
          "rect": {
            "x": box[0],
            "y": box[1],
            "w": box[2] - box[0],
            "h": box[3] - box[1]
          },
          "confidenceInClass": confidence,
          "detectedClass": detectedClassIndex == 1 ? "class1" : "class2"
        });
      }
    }

    return results;
  }

  void close() {
    interpreter.close();
  }
}
