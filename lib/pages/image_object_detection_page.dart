import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:developer' as developer;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImageObjectDetectionPage extends StatefulWidget {
  const ImageObjectDetectionPage({Key? key}) : super(key: key);

  @override
  State<ImageObjectDetectionPage> createState() => _ImageObjectDetectionPageState();
}

class _ImageObjectDetectionPageState extends State<ImageObjectDetectionPage> {
  Interpreter? interpreter;
  File? _imageFile;
  double highestScore = 0.0;

  late List<int> inputShape;
  late List<int> outputShape;

  late TensorType inputType;
  late TensorType outputType;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/third_detect_quant.tflite');
      interpreter!.allocateTensors();

      if (!interpreter!.isAllocated) {
        throw Exception("Interpreter hasn't allocated Tensors");
      }

      developer.log(name: "ObjectDetectionPage -> loadModel", "Model loaded successfully");

      inputType = interpreter!.getInputTensor(0).type;
      developer.log(name: "ObjectDetectionPage -> loadModel", "inputType: $inputType");
      inputShape = interpreter!.getInputTensor(0).shape;
      developer.log(name: "ObjectDetectionPage -> loadModel", "inputShape: $inputShape");

      outputType = interpreter!.getOutputTensor(0).type;
      developer.log(name: "ObjectDetectionPage -> loadModel", "outputType: $outputType");
      outputShape = interpreter!.getOutputTensor(0).shape;
      developer.log(name: "ObjectDetectionPage -> loadModel", "outputShape: $outputShape");

      if (inputType.toString() != "uint8") {
        developer.log(name: "ObjectDetectionPage -> loadModel -> warning", "tflite model should be quantized! (uint8 type is required)");
      }
    } catch (e) {
      developer.log(name: "ObjectDetectionPage -> loadModel -> exception", "$e");
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

  Future<List<String>> loadClassNames() async {
    try {
      final classFile = await rootBundle.loadString('assets/labelmap.txt');
      final lines = classFile.split('\n');
      return lines;
    } catch (e) {
      developer.log("Failed to load labelmap.txt: $e");
      return [];
    }
  }

  Future<void> runModelOnImage(File imageFile) async {
    if (interpreter == null) {
      developer.log("Interpreter is not initialized. Aborting inference.");
      return;
    }

    try {
      final imageSize = inputShape[1];

      // Prepare input data
      final inputData = await imageToByteListUint8(imageFile, imageSize, 127.5, 127.5);
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

      setState(() {
        highestScore = outputs[0]![0]![0];
      });

      developer.log(name: "ObjectDetectionPage -> runModelOnImage", "0: ${outputs[0]}");
      developer.log(name: "ObjectDetectionPage -> runModelOnImage", "3: ${outputs[1]}");

    } catch (e, stack) {
      developer.log(name: "ObjectDetectionPage -> runModelOnImage -> exception", "$e\n$stack");
    }
  }

  Future<Uint8List> imageToByteListUint8(File imageFile, int inputSize, double mean, double std) async {
    Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);
    img.Image resizedImage = img.copyResize(image!, width: inputSize, height: inputSize);

    // Initialize byte buffer for uint8 data
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
      appBar: AppBar(title: const Text('Object Detection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageFile != null
                ? Image.file(_imageFile!, height: 640, width: 320)
                : const Text("No image selected"),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image from Gallery"),
            ),
            _imageFile != null
                ? ElevatedButton(
                    onPressed: () {},
                    child: const Text("Catch Dragon!"),
                  )
                : Container(),
            Text('Accuracy score: $highestScore'), // Display detected class
          ],
        ),
      ),
    );
  }
}