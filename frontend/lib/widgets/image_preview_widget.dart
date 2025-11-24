import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Cross-platform image preview widget that works on both web and mobile.
/// 
/// Uses Image.memory with XFile.readAsBytes() which works on all platforms.
/// This avoids the "Image.file is not supported on Flutter Web" error.
class ImagePreviewWidget extends StatefulWidget {
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
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget> {
  late Future<Uint8List> _imageFuture;

  @override
  void initState() {
    super.initState();
    // Cache the future to avoid re-reading the file on every rebuild
    _imageFuture = widget.imageFile.readAsBytes();
  }

  @override
  void didUpdateWidget(ImagePreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh the future if the image file changes
    // Compare both path and name for better cross-platform reliability
    if (oldWidget.imageFile.path != widget.imageFile.path ||
        oldWidget.imageFile.name != widget.imageFile.name) {
      _imageFuture = widget.imageFile.readAsBytes();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use FutureBuilder to load bytes and display with Image.memory
    // This approach works on both web and mobile platforms
    return FutureBuilder<Uint8List>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Error case - file couldn't be read
          debugPrint('[ImagePreviewWidget] Error reading image: ${snapshot.error}');
          return Container(
            height: widget.height,
            width: widget.width,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, size: 50),
            ),
          );
        } else if (snapshot.hasData) {
          // Success case - display the image
          return Image.memory(
            snapshot.data!,
            height: widget.height,
            width: widget.width,
            fit: widget.fit,
            errorBuilder: (context, error, stackTrace) {
              // Handle cases where bytes are not a valid image
              debugPrint('[ImagePreviewWidget] Error decoding image: $error');
              return Container(
                height: widget.height,
                width: widget.width,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 50),
                ),
              );
            },
          );
        } else {
          // Loading state
          return Container(
            height: widget.height,
            width: widget.width,
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
