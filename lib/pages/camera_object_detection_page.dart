import 'dart:typed_data';
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
  CameraController? _cameraController;
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
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
    );
    await _cameraController!.initialize();
    _cameraController!.startImageStream((CameraImage image) {
      if (interpreter != null) {
        runModelOnFrame(image);
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

      developer.log("Model loaded successfully");

      inputType = interpreter!.getInputTensor(0).type;
      developer.log("inputType: $inputType");
      inputShape = interpreter!.getInputTensor(0).shape;
      developer.log("inputShape: $inputShape");

      outputType = interpreter!.getOutputTensor(0).type;
      developer.log("outputType: $outputType");
      outputShape = interpreter!.getOutputTensor(0).shape;
      developer.log("outputShape: $outputShape");

      if (inputType.toString() != "uint8") {
        developer.log("tflite model should be quantized! (uint8 type is required)");
      }
    } catch (e) {
      developer.log("Error loading model: $e");
    }
  }

  Future<void> runModelOnFrame(CameraImage image) async {
    if (interpreter == null) {
      developer.log("Interpreter is not initialized. Aborting inference.");
      return;
    }

    try {
      final imageSize = inputShape[1];

      // Prepare input data
      final inputData = await imageToByteListUint8(image, imageSize, 127.5, 127.5);
      if (inputData.isEmpty) {
        throw Exception("inputData is empty");
      }

      // Prepare output buffers
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

      // Run inference
      interpreter!.runForMultipleInputs([inputData], outputs);

      setState(() {
        highestScore = outputs[0]![0]![0];
      });

      developer.log("Output confidence: ${outputs[0]}");
      developer.log("Output boxes: ${outputs[1]}");

    } catch (e, stack) {
      developer.log("Error running model on frame: $e\n$stack");
    }
  }

  Future<Uint8List> imageToByteListUint8(CameraImage image, int inputSize, double mean, double std) async {
    final img.Image imgImage = _convertYUV420ToImage(image);

    final img.Image resizedImage = img.copyResize(imgImage, width: inputSize, height: inputSize);

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

  img.Image _convertYUV420ToImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    final img.Image imgImage = img.Image(width: width, height: height);

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

        imgImage.setPixelRgba(x, y, r, g, b, 0);
      }
    }

    return imgImage;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
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
            _cameraController != null && _cameraController!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  )
                : const Text("Initializing camera..."),
            Text('Accuracy score: $highestScore'),
          ],
        ),
      ),
    );
  }
}
