import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'dart:developer' as developer;

class ObjectDetectionPage extends StatefulWidget {
  const ObjectDetectionPage({Key? key}) : super(key: key);

  @override
  State<ObjectDetectionPage> createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  CameraController? _cameraController;
  Interpreter? _interpreter;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      final firstCamera = cameras.first;

      _cameraController = CameraController(firstCamera, ResolutionPreset.medium);

      try {
        await _cameraController?.initialize();
      } catch (e) {
        developer.log('Camera initialization error: $e');
      }

      if (mounted) {
        setState(() {});
        _cameraController?.startImageStream((CameraImage img) {
          if (!_isDetecting) {
            _isDetecting = true;
            loadModel().then((_) => runModelOnFrame(img));
          }
        });
      }
    }
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/third_detect.tflite');
    } catch (e) {
      developer.log("Model loading error: $e", name: "Object Detection Page -> loadModel");
    }
  }

  void runModelOnFrame(CameraImage img) async {
    if (_interpreter == null) {
      developer.log("_interpreter is null", name: "Object Detection Page -> runModelOnFrame");
      return;
    }

    try {
      // Process camera image for model input
      var input = imageToByteListFloat32(img, 320, 320);

      // Define output tensor shape
      var output = List.filled(10 * 4, 0.0).reshape([1, 10, 4]);

      // Run inference
      _interpreter!.run(input, output);

      developer.log("Outputs: $output");
      _isDetecting = false;
    } catch (e) {
      developer.log("$e", name: "Object Detection Page -> runModelOnFrame -> exception");
      _isDetecting = false;
    }
  }

  // Utility function to convert CameraImage to the model's input format
  Uint8List imageToByteListFloat32(CameraImage image, int inputSize, int mean) {
    final int width = image.width;
    final int height = image.height;
    var convertedBytes = Float32List(inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        var pixel = image.planes[0].bytes[pixelIndex];
        buffer[(y * inputSize + x) * 3 + 0] = (pixel >> 16 & 0xFF) / 255.0;
        buffer[(y * inputSize + x) * 3 + 1] = (pixel >> 8 & 0xFF) / 255.0;
        buffer[(y * inputSize + x) * 3 + 2] = (pixel & 0xFF) / 255.0;
        pixelIndex++;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Object Detection')),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),
          // Add widgets here to display detection results
        ],
      ),
    );
  }
}
