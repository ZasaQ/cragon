import 'dart:async';
import 'dart:typed_data';
import 'package:cragon/services/firestore_data_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:developer' as developer;
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';

class ImageObjectDetectionPage extends StatefulWidget {
  const ImageObjectDetectionPage({Key? key}) : super(key: key);

  @override
  State<ImageObjectDetectionPage> createState() => _ImageObjectDetectionPageState();
}

class _ImageObjectDetectionPageState extends State<ImageObjectDetectionPage> {
  Interpreter? interpreter;
  CameraController? cameraController;
  CameraImage? latestImage;
  double highestScore = 0.0;
  late List<int> inputShape;
  late List<int> outputShape;
  late TensorType inputType;
  late TensorType outputType;

  @override
  void initState() {
    super.initState();
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

  Future<void> _runModelOnFrame(CameraImage image) async {
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

      setState(() {
        highestScore = outputs[0]![0]![0];
      });

      developer.log(
        name: "ImageObjectDetectionPage -> _runModelOnFrame",
        "Output confidence: ${outputs[0]}");
      developer.log(
        name: "ImageObjectDetectionPage -> _runModelOnFrame",
        "Output boxes: ${outputs[1]}");

    } catch (e, stack) {
      developer.log(name: "ImageObjectDetectionPage -> _runModelOnFrame -> exception", "Error running model on frame: $e\n$stack");
    }
  }

  Future<Uint8List> imageToByteListUint8(CameraImage image, int inputSize, double mean, double std) async {
    final img.Image? imgImage = await convertYUV420toImageColor(image);

    final img.Image resizedImage = img.copyResize(imgImage!, width: inputSize, height: inputSize);

    final Uint8List convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    final buffer = ByteData.view(convertedBytes.buffer);

    int pixelIndex = 0;
    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixel = resizedImage.getPixel(x, y);
        buffer.setUint8(pixelIndex++, (pixel.r - mean) ~/ std);
        buffer.setUint8(pixelIndex++, (pixel.g - mean) ~/ std);
        buffer.setUint8(pixelIndex++, (pixel.b - mean) ~/ std);
      }
    }
    return convertedBytes;
  }

  Future<img.Image?> convertYUV420toImageColor(CameraImage image) async {
  try {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int? uvPixelStride = image.planes[1].bytesPerPixel;

    developer.log("uvRowStride: $uvRowStride");
    developer.log("uvPixelStride: $uvPixelStride");

    var convertedImage = img.Image(width: width, height: height);

    // Fill image buffer with plane[0] from YUV420_888
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = uvPixelStride! * (x >> 1) + uvRowStride * (y >> 1);
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];

        // Calculate pixel color
        int r = (yp + vp * 1.402 - 179).round().clamp(0, 255);
        int g = (yp - up * 0.34414 - vp * 0.71414 + 135.45984).round().clamp(0, 255);
        int b = (yp + up * 1.772 - 226.816).round().clamp(0, 255);

        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        convertedImage.setPixelRgb(x, y, r, g, b);
      }
    }

    return convertedImage;
  } catch (e) {
    developer.log(">>>>>>>>>>>> ERROR: $e");
  }
  return null;
}


  img.Image convertYUV420ToImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    final img.Image convertImage = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = (y >> 1) * uvRowStride + (x >> 1) * uvPixelStride;

        final int index = y * width + x;
        final int yp = image.planes[0].bytes[index];
        final int up = image.planes[1].bytes[uvIndex];
        final int vp = image.planes[2].bytes[uvIndex];

        int r = (yp + vp * 1.402 - 179.456).clamp(0, 255).toInt();
        int g = (yp - up * 0.34414 - vp * 0.71414 + 135.45984).clamp(0, 255).toInt();
        int b = (yp + up * 1.772 - 226.816).clamp(0, 255).toInt();

        convertImage.setPixelRgba(x, y, r, g, b, 0);
      }
    }

    return convertImage;
  }

  Future<void> captureAndDetect() async {
    if (latestImage == null) {
      developer.log(
        name: "ImageObjectDetectionPage -> captureAndDetect",
        "No camera image available to capture.");
      return;
    }

    await _runModelOnFrame(latestImage!);
    FirestoreDataHandler().tryCatchDragon(imageScore: highestScore);
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
      appBar: AppBar(title: const Text('Object Detection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            cameraController != null && cameraController!.value.isInitialized
                ? Expanded(child: CameraPreview(cameraController!))
                : const Text("Initializing camera..."),
            Text('Accuracy score: $highestScore'),
            ElevatedButton(
              onPressed: captureAndDetect,
              child: const Text('Capture and Detect'),
            ),
          ],
        ),
      ),
    );
  }
}
