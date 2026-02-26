import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Added this
import '../providers/font_provider.dart';
import '../providers/theme_provider.dart';

class AnalisaPage extends StatefulWidget {
  final String username;
  const AnalisaPage({super.key, required this.username});

  @override
  State<AnalisaPage> createState() => _AnalisaPageState();
}

class _AnalisaPageState extends State<AnalisaPage> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker(); // Initialize Picker

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false, // Set to false if you don't need audio
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  // --- FUNCTION 1: Pick from Gallery ---
  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      debugPrint("Image selected: ${image.path}");
      // TODO: Navigate to a result page or show the image
    }
  }

  // --- FUNCTION 2: Capture Photo ---
  Future<void> _takePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile photo = await _controller!.takePicture();
      debugPrint("Photo saved to: ${photo.path}");
      // TODO: Navigate to a result page or show the image
    } catch (e) {
      debugPrint("Error taking photo: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FontProvider, ThemeProvider>(
      builder: (context, fontProvider, themeProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Camera Preview
              _isCameraInitialized
                  ? CameraPreview(_controller!)
                  : const Center(child: CircularProgressIndicator(color: Color(0xFFFFDF00))),

              // 2. Navigation Overlay
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // FUNCTION 1: Gallery
                      _cameraNavItem(
                        icon: Icons.photo_library_rounded,
                        label: "Gallery",
                        onTap: _pickFromGallery,
                      ),

                      // CENTER: Capture Button
                      GestureDetector(
                        onTap: _takePhoto,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),

                      // FUNCTION 2: Flip Camera (Optional but useful)
                      _cameraNavItem(
                        icon: Icons.flip_camera_ios_rounded,
                        label: "Flip",
                        onTap: () {
                          // Logic to toggle between front/back camera
                          debugPrint("Flip camera tapped");
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _cameraNavItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}