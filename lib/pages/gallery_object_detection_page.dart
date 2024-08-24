import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:developer' as developer;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:cragon/services/firestore_data_handler.dart';
import 'package:cragon/services/utilities.dart';


class GalleryObjectDetectionPage extends StatefulWidget {
  const GalleryObjectDetectionPage({Key? key}) : super(key: key);

  @override
  State<GalleryObjectDetectionPage> createState() => _GalleryObjectDetectionPageState();
}

class _GalleryObjectDetectionPageState extends State<GalleryObjectDetectionPage> {
  Interpreter? interpreter;
  File? _imageFile;
  double highestScore = 0.0;
  bool dragonCaught = false;
  bool wasLaunched = false;

  late List<int> inputShape;
  late List<int> outputShape;

  late TensorType inputType;
  late TensorType outputType;

  @override
  void initState() {
    super.initState();

    developer.log(
      name: "GalleryObjectDetectionPage -> initState",
      "Current user has entered GalleryObjectDetectionPage");

    loadModel();
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/models/third_detect_quant.tflite');
      interpreter!.allocateTensors();

      if (!interpreter!.isAllocated) {
        throw Exception("Interpreter hasn't allocated Tensors");
      }

      developer.log(name: "GalleryObjectDetectionPage -> loadModel", "Model loaded successfully");

      inputType = interpreter!.getInputTensor(0).type;
      developer.log(name: "GalleryObjectDetectionPage -> loadModel", "inputType: $inputType");
      inputShape = interpreter!.getInputTensor(0).shape;
      developer.log(name: "GalleryObjectDetectionPage -> loadModel", "inputShape: $inputShape");

      outputType = interpreter!.getOutputTensor(0).type;
      developer.log(name: "GalleryObjectDetectionPage -> loadModel", "outputType: $outputType");
      outputShape = interpreter!.getOutputTensor(0).shape;
      developer.log(name: "GalleryObjectDetectionPage -> loadModel", "outputShape: $outputShape");

      if (inputType.toString() != "uint8") {
        developer.log(name: "GalleryObjectDetectionPage -> loadModel -> warning", "tflite model should be quantized! (uint8 type is required)");
      }
    } catch (e) {
      developer.log(name: "GalleryObjectDetectionPage -> loadModel -> exception", "$e");
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      runModelOnImage(_imageFile!);
    }
  }

  Future<void> runModelOnImage(File imageFile) async {
    if (interpreter == null) {
      developer.log(
        name: "GalleryObjectDetectionPage -> runModelOnImage",
        "Interpreter is not initialized. Aborting inference");
      return;
    }

    try {
      final imageSize = inputShape[1];

      // Prepare input data
      final inputData = await imageToByteListUint8(imageFile, imageSize);
      if (inputData.isEmpty) {
        throw Exception("inputData is empty");
      }

      // Prepare output buffers
      var outputConfidance = List.filled(10, 0.0).reshape([1, 10]);
      var outputBoxes = List.filled(10 * 4, 0.0).reshape([1, 10, 4]);
      var numDetections = List.filled(1, 0.0).reshape([1]);
      var outputClasses = List.filled(10, 0.0).reshape([1, 10]);

      var outputs = {
        0: outputConfidance,
        1: outputBoxes,
        2: numDetections,
        3: outputClasses,
      };

      // Run inference
      interpreter!.runForMultipleInputs([inputData], outputs);

      developer.log(name: "GalleryObjectDetectionPage -> runModelOnImage",
      "0: ${outputs[0]}");
      developer.log(name: "GalleryObjectDetectionPage -> runModelOnImage",
      "3: ${outputs[1]}");

      setState(() {
        highestScore = outputs[0]![0]![0];
      });

      dragonCaught = await FirestoreDataHandler().tryCatchDragon(imageScore: highestScore);
      wasLaunched = true;
      setState(() {});
    } catch (e, stack) {
      developer.log(name: "GalleryObjectDetectionPage -> runModelOnImage -> exception",
      "$e\n$stack");
    }
  }

  Future<Uint8List> imageToByteListUint8(File imageFile, int inputSize) async {
    Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);
    img.Image resizedImage = img.copyResize(image!, width: inputSize, height: inputSize);

    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);

    int pixelIndex = 0;
    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        var pixel = resizedImage.getPixel(x, y);
        buffer[pixelIndex++] = pixel.r.toInt();
        buffer[pixelIndex++] = pixel.g.toInt();
        buffer[pixelIndex++] = pixel.b.toInt();
      }
    }
    return convertedBytes;
  }

  @override
  void dispose() {
    interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catch Dragon',
          textAlign: TextAlign.center,
          style: TextStyle(color: utilMainBackgroundColor)
        ),
        iconTheme: const IconThemeData(color: utilMainBackgroundColor),
        backgroundColor: utilMainTextColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _imageFile != null
                        ? Image.file(_imageFile!, height: 640, width: 320)
                        : const Text("No image selected"),
                    
                    if(wasLaunched)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Accuracy score: $highestScore',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Dragon has been caught: $dragonCaught",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    
                    ElevatedButton(
                      onPressed: pickImage,
                      child: const Text("Detect and Capture Dragon!"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}