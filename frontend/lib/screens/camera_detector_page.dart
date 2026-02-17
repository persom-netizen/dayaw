import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';

class CameraDetectorPage extends StatefulWidget {
  const CameraDetectorPage({super.key});

  @override
  State<CameraDetectorPage> createState() => _CameraDetectorPageState();
}

class _CameraDetectorPageState extends State<CameraDetectorPage> {
  late CameraController _controller;
  late FlutterVision _vision;
  bool _isInitialized = false;
  bool _isDetecting = false;
  String _detectedLabel = "Scanning Baybayin...";

  @override
  void initState() {
    super.initState();
    _vision = FlutterVision();
    _setupDetector();
  }

  Future<void> _setupDetector() async {
    // 1. Load your model and labels
    await _vision.loadYoloModel(
      modelPath: 'assets/model.tflite',
      labels: 'assets/label.txt',
      modelVersion: "yolo11", // Specific for YOLOv11 Nano
      numThreads: 2,
      useGpu: true,
    );

    // 2. Initialize Camera
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium, enableAudio: false);
    await _controller.initialize();

    // 3. Process Stream
    _controller.startImageStream((CameraImage image) async {
      if (!_isDetecting) {
        _isDetecting = true;
        
        final results = await _vision.yoloOnFrame(
          bytesList: image.planes.map((p) => p.bytes).toList(),
          imageHeight: image.height,
          imageWidth: image.width,
          iouThreshold: 0.4,
          confThreshold: 0.10,
          classThreshold: 0.10,
        );

        if (results.isNotEmpty && mounted) {
          setState(() {
            // "tag" is the label found in your label.txt
            _detectedLabel = "Detected: ${results[0]['tag']}";
          });
        }
        _isDetecting = false;
      }
    });

    if (mounted) setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _vision.closeYoloModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _isInitialized 
            ? SizedBox.expand(child: CameraPreview(_controller))
            : const Center(child: CircularProgressIndicator(color: Color(0xFFFFDF00))),
          
          // UI Overlays
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFFFDF00), width: 2),
                ),
                child: Text(
                  _detectedLabel,
                  style: const TextStyle(
                    color: Color(0xFFFFDF00), 
                    fontSize: 22, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}