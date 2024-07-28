import 'dart:typed_data';

import 'package:cragon/services/object_detection_model.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'dart:developer' as developer;


class ObjectDetectionPage extends StatefulWidget {
  const ObjectDetectionPage({Key? key}) : super(key: key);

  @override
  _ObjectDetectionPageState createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  CameraController? _cameraController;
  Interpreter? _interpreter;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
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
            _loadModel().then((_) => _runModelOnFrame(img));
          }
        });
      }
    }
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/detect.tflite');
    } catch (e) {
      developer.log(name: "Object Detection Page -> _loadModel", "Model loading error: $e");
    }
  }

  void _runModelOnFrame(CameraImage img) async {
    if (_interpreter == null) {
      developer.log(name: "Object Detection Page -> _runModelOnFrame", "_interpreter is null");
      return;
    }

    try {
      // Example input and output
      var input0 = [1.23];  // Replace with actual input data
      var input1 = [2.43];  // Replace with actual input data
      var inputs = [input0, input1, input0, input1];  // Adjust as needed

      var output0 = List<double>.filled(1, 0);
      var output1 = List<double>.filled(1, 0);
      var outputs = {0: output0, 1: output1};

      _interpreter?.runForMultipleInputs(inputs, outputs);

      developer.log("Outputs: $outputs");
      _isDetecting = false;
    } catch (e) {
      developer.log(name: "Object Detection Page -> _runModelOnFrame", "$e");
    }

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
        ],
      ),
    );
  }
}




