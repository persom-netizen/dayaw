import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Cross-platform image preview widget that works on both web and mobile.
/// 
/// Uses Image.memory with XFile.readAsBytes() which works on all platforms.
/// This avoids the "Image.file is not supported on Flutter Web" error.
class ImagePreviewWidget extends StatelessWidget {
  final XFile imageFile;
  final double? height;
  final double? width;
  final BoxFit fit;

  const ImagePreviewWidget({
    super.key,
    required this.imageFile,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // Use FutureBuilder to load bytes and display with Image.memory
    // This approach works on both web and mobile platforms
    return FutureBuilder<Uint8List>(
      future: imageFile.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Error case - file couldn't be read
          return Container(
            height: height,
            width: width,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, size: 50),
            ),
          );
        } else if (snapshot.hasData) {
          // Success case - display the image
          return Image.memory(
            snapshot.data!,
            height: height,
            width: width,
            fit: fit,
          );
        } else {
          // Loading state
          return Container(
            height: height,
            width: width,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
