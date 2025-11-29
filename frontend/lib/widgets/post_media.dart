import 'package:flutter/material.dart';

/// Post Media Widget
/// 
/// Displays images/media with:
/// - Sleek, consistent height regardless of original aspect ratio
/// - Images adjust width to fit, don't touch container edges
/// - Yellow (#FFDF00) border-radius
/// - Centered within post
/// - Appropriate padding
/// - Horizontal scroll for multiple images
class PostMedia extends StatelessWidget {
  final String? imageUrl;
  final List<String>? imageUrls;
  final double height;

  // Design color constants
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const double defaultHeight = 200.0;

  const PostMedia({
    super.key,
    this.imageUrl,
    this.imageUrls,
    this.height = defaultHeight,
  });

  @override
  Widget build(BuildContext context) {
    // If multiple images, show horizontal scroll
    if (imageUrls != null && imageUrls!.isNotEmpty) {
      return _buildImageGallery();
    }

    // Single image
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return _buildSingleImage(imageUrl!);
    }

    return const SizedBox.shrink();
  }

  Widget _buildSingleImage(String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: Container(
          height: height,
          constraints: const BoxConstraints(maxWidth: double.infinity),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryYellow,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryYellow.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: height,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return _FadeInImage(child: child);
                }
                return Container(
                  color: primaryYellow.withValues(alpha: 0.1),
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: primaryYellow,
                      strokeWidth: 3,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorPlaceholder();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    return SizedBox(
      height: height + 16,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: imageUrls!.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < imageUrls!.length - 1 ? 12 : 0,
            ),
            child: _buildGalleryImage(imageUrls![index]),
          );
        },
      ),
    );
  }

  Widget _buildGalleryImage(String url) {
    return Container(
      width: 280,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryYellow,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryYellow.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return _FadeInImage(child: child);
            }
            return Container(
              color: primaryYellow.withValues(alpha: 0.1),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  color: primaryYellow,
                  strokeWidth: 3,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorPlaceholder();
          },
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: primaryYellow.withValues(alpha: 0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_rounded,
              size: 48,
              color: primaryYellow.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Hindi makuha ang larawan',
              style: TextStyle(
                color: primaryYellow.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fade-in animation for loaded images
class _FadeInImage extends StatefulWidget {
  final Widget child;

  const _FadeInImage({required this.child});

  @override
  State<_FadeInImage> createState() => _FadeInImageState();
}

class _FadeInImageState extends State<_FadeInImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
