import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:developer' as developer;
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';

import 'package:cragon/services/firestore_data_handler.dart';
import 'package:cragon/services/utilities.dart';


class ImageObjectDetectionPage extends StatefulWidget {
  const ImageObjectDetectionPage({Key? key}) : super(key: key);

  @override
  State<ImageObjectDetectionPage> createState() => _ImageObjectDetectionPageState();
}

class _ImageObjectDetectionPageState extends State<ImageObjectDetectionPage> {
  late List<CameraDescription> cameras;
  CameraLensDirection currentLensDirection = CameraLensDirection.back;
  CameraController? cameraController;
  int currentCameraIndex = 0;
  Interpreter? interpreter;
  late List<int> inputShape;
  late List<int> outputShape;
  late TensorType inputType;
  late TensorType outputType;
  CameraImage? latestImage;
  double highestScore = 0.0;
  bool dragonCaught = false;
  bool wasLaunched = false;

  @override
  void initState() {
    super.initState();

    developer.log(
      name: "ImageObjectDetectionPage -> initState",
      "Current user has entered ImageObjectDetectionPage");

    initializeCamera();
    loadModel();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();

    for (CameraDescription camera in cameras) {
      if (camera.lensDirection != CameraLensDirection.back) continue;

      setCamera(camera);
      return;
    }
  }

  Future<void> setCamera(CameraDescription camera) async {
    cameraController = CameraController(
      camera,
      ResolutionPreset.high,
    );
    await cameraController!.initialize();
    
    cameraController!.startImageStream((CameraImage image) {
      latestImage = image;
    });

    developer.log(
      name: "ImageObjectDetectionPage -> setCamera",
      "Camera has been changed: ${camera.name}, ${camera.lensDirection}");

    setState(() {});
  }

  Future<void> switchCamera() async {
    await cameraController!.dispose();

    currentLensDirection = (currentLensDirection == CameraLensDirection.back) 
        ? CameraLensDirection.front : CameraLensDirection.back;

    for (CameraDescription camera in cameras) {
      if (camera.lensDirection != currentLensDirection) continue;

      await setCamera(camera);
      break;
    }

    setState(() {});
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/models/third_detect_quant.tflite');
      interpreter!.allocateTensors();

      if (!interpreter!.isAllocated) {
        throw Exception("Interpreter hasn't allocated Tensors");
      }

      developer.log(name: "ImageObjectDetectionPage -> loadModel", "Model loaded successfully");

      inputType = interpreter!.getInputTensor(0).type;
      developer.log(name: "ImageObjectDetectionPage -> loadModel", "inputType: $inputType");
      inputShape = interpreter!.getInputTensor(0).shape;
      developer.log(name: "ImageObjectDetectionPage -> loadModel", "inputShape: $inputShape");

      outputType = interpreter!.getOutputTensor(0).type;
      developer.log(name: "ImageObjectDetectionPage -> loadModel", "outputType: $outputType");
      outputShape = interpreter!.getOutputTensor(0).shape;
      developer.log(name: "ImageObjectDetectionPage -> loadModel", "outputShape: $outputShape");

      if (inputType.toString() != "uint8") {
        developer.log(
          name: "ImageObjectDetectionPage -> loadModel",
          "tflite model should be quantized! (uint8 type is required)");
      }
    } catch (e) {
      developer.log(
        name: "ImageObjectDetectionPage -> loadModel -> exception",
        "Error loading model: $e");
    }
  }

  Future<void> runModelOnFrame(CameraImage image) async {
    if (interpreter == null) {
      developer.log(
        name: "ImageObjectDetectionPage -> _runModelOnFrame",
        "Interpreter is not initialized. Aborting inference.");
      return;
    }

    try {
      final imageSize = inputShape[1];

      final inputData = await imageToByteListUint8(image, imageSize, 127.5, 127.5);
      if (inputData.isEmpty) {
        throw Exception("inputData is empty");
      }

      var outputConfidence = List.filled(10, 0.0).reshape([1, 10]);
      var outputBoxes = List.filled(10 * 4, 0.0).reshape([1, 10, 4]);
      var numDetections = List.filled(1, 0.0).reshape([1]);
      var outputClasses = List.filled(10, 0.0).reshape([1, 10]);

      var outputs = {
        0: outputConfidence,
        1: outputBoxes,
        2: numDetections,
        3: outputClasses,
      };

      interpreter!.runForMultipleInputs([inputData], outputs);

      highestScore = outputs[0]![0]![0];

      dragonCaught = await FirestoreDataHandler().tryCatchDragon(imageScore: highestScore);

      setState(() => wasLaunched = true);

      developer.log(
        name: "ImageObjectDetectionPage -> runModelOnFrame",
        "Output confidence: ${outputs[0]}");
      developer.log(
        name: "ImageObjectDetectionPage -> runModelOnFrame",
        "Output boxes: ${outputs[1]}");

    } catch (e, stack) {
      developer.log(
        name: "ImageObjectDetectionPage -> runModelOnFrame -> exception",
        "Error running model on frame: $e\n$stack");
    }
  }

  Future<Uint8List> imageToByteListUint8(CameraImage image, int inputSize, double mean, double std) async {
    final img.Image? imgImage = await convertYUV420toImageColor(image);

    final img.Image resizedImage = img.copyResize(imgImage!, width: inputSize, height: inputSize);

    final Uint8List convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);

    int pixelIndex = 0;
    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        buffer[pixelIndex++] = pixel.r.toInt();
        buffer[pixelIndex++] = pixel.g.toInt();
        buffer[pixelIndex++] = pixel.b.toInt();
      }
    }
    return convertedBytes;
  }

  Future<img.Image?> convertYUV420toImageColor(CameraImage image) async {
    try {
      final int width = image.width;
      final int height = image.height;
      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel!;

      var convertedImage = img.Image(width: width, height: height);

      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int uvIndex = uvPixelStride * (x >> 1) + uvRowStride * (y >> 1);
          final int index = y * width + x;

          final yp = image.planes[0].bytes[index];
          final up = image.planes[1].bytes[uvIndex];
          final vp = image.planes[2].bytes[uvIndex];

          int r = (yp + vp * 1.402 - 179).round().clamp(0, 255);
          int g = (yp - up * 0.34414 - vp * 0.71414 + 135.45984).round().clamp(0, 255);
          int b = (yp + up * 1.772 - 226.816).round().clamp(0, 255);

          convertedImage.setPixelRgb(x, y, r, g, b);
        }
      }

      return convertedImage;
    } catch (e) {
      developer.log(
        name: "convertYUV420toImageColor -> exception",
        "$e");
    }
    return null;
  }

  Future<void> captureAndDetect() async {
    if (latestImage == null) {
      developer.log(
        name: "ImageObjectDetectionPage -> captureAndDetect",
        "No camera image available to capture.");
      return;
    }

    runModelOnFrame(latestImage!);
  }

  @override
  void dispose() {
    cameraController?.dispose();
    interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catch Dragon!')
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (cameraController != null && cameraController!.value.isInitialized)
            CameraPreview(cameraController!)
          else
            const Center(child: Text("Initializing camera...")),

          if (wasLaunched)
            Positioned(
              top: 5.0,
              left: 5.0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: utilMainBackgroundColor,
                      ),
                      child: Text(
                        "Previous accuracy score: $highestScore",
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: utilMainBackgroundColor,
                      ),
                      child: Text(
                        "Dragon has been caught: $dragonCaught",
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              heroTag: "switchCamera",
              onPressed: switchCamera,
              child: const Icon(Icons.switch_camera),
            ),
          ),

          Positioned(
            bottom: 16.0,
            left: MediaQuery.of(context).size.width / 2 - 28.0,
            child: FloatingActionButton(
              heroTag: "captureAndDetect",
              onPressed: captureAndDetect,
              child: const Icon(Icons.photo_camera),
            ),
          ),
        ],
      ),
    );
  }
}
