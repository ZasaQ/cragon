import 'dart:async';
import 'package:cragon/services/firestore_data_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:developer' as developer;
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';

class CameraObjectDetectionPage extends StatefulWidget {
  const CameraObjectDetectionPage({Key? key}) : super(key: key);

  @override
  State<CameraObjectDetectionPage> createState() => _CameraObjectDetectionPageState();
}

class _CameraObjectDetectionPageState extends State<CameraObjectDetectionPage> {
  Interpreter? interpreter;
  CameraController? cameraController;
  double highestScore = 0.0;
  late List<int> inputShape;
  late List<int> outputShape;
  late TensorType inputType;
  late TensorType outputType;
  Timer? throttleTimer;
  CameraImage? latestImage;
  bool shouldRunModel = false;

  @override
  void initState() {
    super.initState();

    developer.log(
      name: "CameraObjectDetectionPage -> initState",
      "Current user has entered CameraObjectDetectionPage");

    initializeCamera();
    loadModel();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
    );
    await cameraController!.initialize();
    
    cameraController!.startImageStream((CameraImage image) {
      latestImage = image;
      shouldRunModel = true;
    });

    throttleTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (shouldRunModel) {
        shouldRunModel = false;
        runModelOnFrame();
      }
    });

    setState(() {});
  }

  Future<void> loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('assets/third_detect_quant.tflite');
      interpreter!.allocateTensors();

      if (!interpreter!.isAllocated) {
        throw Exception("Interpreter hasn't allocated Tensors");
      }

      developer.log(name: "CameraObjectDetectionPage -> loadModel", "Model loaded successfully");

      inputType = interpreter!.getInputTensor(0).type;
      developer.log(name: "CameraObjectDetectionPage -> loadModel", "inputType: $inputType");
      inputShape = interpreter!.getInputTensor(0).shape;
      developer.log(name: "CameraObjectDetectionPage -> loadModel", "inputShape: $inputShape");

      outputType = interpreter!.getOutputTensor(0).type;
      developer.log(name: "CameraObjectDetectionPage -> loadModel", "outputType: $outputType");
      outputShape = interpreter!.getOutputTensor(0).shape;
      developer.log(name: "CameraObjectDetectionPage -> loadModel", "outputShape: $outputShape");

      if (inputType.toString() != "uint8") {
        developer.log(
          name: "CameraObjectDetectionPage -> loadModel",
          "tflite model should be quantized! (uint8 type is required)");
      }
    } catch (e) {
      developer.log(
        name: "CameraObjectDetectionPage -> loadModel -> exception",
        "Error loading model: $e");
    }
  }

  Future<void> runModelOnFrame() async {
    if (interpreter == null) {
      developer.log(
        name: "CameraObjectDetectionPage -> _runModelOnFrame",
        "Interpreter is not initialized. Aborting inference.");
      return;
    }

    try {
      final imageSize = inputShape[1];

      final image = await getMostRecentImage();
      if (image == null) {
        developer.log(
          name: "CameraObjectDetectionPage -> _runModelOnFrame",
          "No image available for inference.");
        return;
      }

      final inputData = await imageToByteListUint8(image, imageSize);
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

      setState(() {
        highestScore = outputs[0]![0]![0] * 6;
      });

      FirestoreDataHandler().tryCatchDragon(imageScore: highestScore);

      developer.log(
        name: "CameraObjectDetectionPage -> _runModelOnFrame",
        "Output confidence: ${outputs[0]}");
      developer.log(
        name: "CameraObjectDetectionPage -> _runModelOnFrame",
        "Output boxes: ${outputs[1]}");

    } catch (e, stack) {
      developer.log(name: "CameraObjectDetectionPage -> _runModelOnFrame -> exception", "Error running model on frame: $e\n$stack");
    }
  }

  Future<CameraImage?> getMostRecentImage() async {
    return latestImage;
  }

  Future<Uint8List> imageToByteListUint8(CameraImage image, int inputSize) async {
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

  Future<void> tryCatch() async {
    if (latestImage == null) {
      developer.log(
        name: "ImageObjectDetectionPage -> captureAndDetect",
        "No camera image available to capture.");
      return;
    }

    FirestoreDataHandler().tryCatchDragon(imageScore: highestScore);
  }

  @override
  void dispose() {
    cameraController?.dispose();
    interpreter?.close();
    throttleTimer?.cancel();
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
            cameraController != null && cameraController!.value.isInitialized
              ? Expanded(child: CameraPreview(cameraController!))
              : const Text("Initializing camera..."),
            Text(
              'Accuracy score: $highestScore',
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            ElevatedButton(
              onPressed: tryCatch,
              child: const Text('Detect and Capture Dragon!'),
            ),
          ],
        ),
      ),
    );
  }
}
