import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:developer' as developer;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

class ObjectDetectionPage extends StatefulWidget {
  const ObjectDetectionPage({Key? key}) : super(key: key);

  @override
  State<ObjectDetectionPage> createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  Interpreter? interpreter;
  IsolateInterpreter? isolateInterpreter;
  File? _imageFile;
  String _detectedClass = ''; // State variable to hold the detected class

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
      interpreter = await Interpreter.fromAsset('assets/third_detect.tflite');
      interpreter!.allocateTensors();

      isolateInterpreter = await IsolateInterpreter.create(address: interpreter!.address);

      if (!interpreter!.isAllocated) {
        throw Exception("Interpreter hasn't allocated Tensors");
      }

      developer.log(name: "ObjectDetecionPage -> loadModel", "Model loaded successfully");

      inputType = interpreter!.getInputTensor(0).type;
      developer.log("inputType: $inputType");
      inputShape = interpreter!.getInputTensor(0).shape;
      developer.log("inputShape: $inputShape");

      outputType = interpreter!.getOutputTensor(0).type;
      developer.log("outputType: $outputType");
      outputShape = interpreter!.getOutputTensor(0).shape;
      developer.log("outputShape: $outputShape");

      /*String? res = await Tflite.loadModel(
        model: "assets/third_detect.tflite",
        labels: "assets/labelmap.txt",
        numThreads: 1, // defaults to 1
        isAsset: true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate: false // defaults to false, set to true to use GPU delegate
      );*/
    } catch (e) {
      developer.log(name: "ObjectDetecionPage -> loadModel -> exception", "$e");
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

  void runModel(File imageFile) async {
    dynamic recognitions;
    try {
       recognitions = await Tflite.runModelOnImage(
        path: imageFile.path,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 10,
        threshold: 0.2,
        asynch: true
      );
    } catch (e) {
      developer.log(name: "ObjectDetectionPage -> runModel -> exception", "$e");
    }

    developer.log("$recognitions");
  }

  void runModelOnImage(File imageFile) async {
    if (interpreter == null) {
      developer.log("Interpreter is not initialized. Aborting inference.");
      return;
    }

    try {
      final height = inputShape[1];
      const inputMean = 127.5;
      const inputStd = 127.5;

      final inputData = await imageToByteListFloat32(imageFile, height, inputMean, inputStd);
      if (inputData.isEmpty) {
        throw Exception("inputData is null");
      }
      
      final outputData = List.filled(1*10, 0).reshape([1,10]);

      isolateInterpreter!.run(inputData, outputData);

      //interpreter!.run(inputData, outputData);

      final result = outputData.first;

      developer.log("Results: $result");
    } catch (e, stack) {
      developer.log("Error during model inference: $e\n$stack");
    }
  }

  /*Future<List<double>> normalizeImage(img.Image image, int inputSize) async {
    const inputMean = 127.5;
    const inputStd = 127.5;

    img.Image resizedImage = img.copyResize(image, width: inputSize, height: inputSize);

    List<double> normalizedImageData = [];
    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        img.Pixel pixel = resizedImage.getPixel(x, y);

        normalizedImageData.add((pixel.r.toDouble() - inputMean) / inputStd);
        normalizedImageData.add((pixel.g.toDouble() - inputMean) / inputStd);
        normalizedImageData.add((pixel.b.toDouble() - inputMean) / inputStd);
      }
    }

    return normalizedImageData;
  }*/

  Future<Uint8List> imageToByteListFloat32(File imageFile, int inputSize, double mean, double std) async {
    Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);
    img.Image resizedImage = img.copyResize(image!, width: inputSize, height: inputSize);
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);

    if (!resizedImage.isValid || resizedImage.isEmpty) {
      developer.log("resizedImage is incorrect");
      throw Exception("resizedImage is incorrect");
    }

    int pixelIndex = 0;
    for (var x = 0; x < inputSize; x++) {
      for (var y = 0; y < inputSize; y++) {
        var pixel = resizedImage.getPixel(y, x);
        buffer[pixelIndex++] = (pixel.r - mean).toDouble() / std;
        buffer[pixelIndex++] = (pixel.g - mean).toDouble() / std;
        buffer[pixelIndex++] = (pixel.b - mean).toDouble() / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  /*Future<List<List<List<List<double>>>>> processImage(String imagePath, int width, int height) async {
    // Mean and standard deviation for normalization
    const double inputMean = 127.5;
    const double inputStd = 127.5;

    // Read the image file
    File imageFile = File(imagePath);
    Uint8List imageBytes = await imageFile.readAsBytes();

    // Decode the image
    img.Image? image = img.decodeImage(imageBytes);

    // Resize the image
    img.Image resizedImage = img.copyResize(image!, width: width, height: height);

    // Normalize pixel values and add to a 4D list
    List<List<List<List<double>>>> inputData = List.generate(1, (batch) {
      return List.generate(height, (y) {
        return List.generate(width, (x) {
          img.Pixel pixel = resizedImage.getPixel(x, y);

          final r = (pixel.r.toDouble() - inputMean) / inputStd;
          final g = (pixel.g.toDouble() - inputMean) / inputStd;
          final b = (pixel.b.toDouble() - inputMean) / inputStd;

          return [r, g, b];
        });
      });
    });

    return inputData;
  }*/

  @override
  void dispose() {
    interpreter!.close();
    isolateInterpreter!.close();
    Tflite.close();
    super.dispose();

    developer.log("Closed!");
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
            Text('Detected Class: $_detectedClass'), // Display detected class
          ],
        ),
      ),
    );
  }
}