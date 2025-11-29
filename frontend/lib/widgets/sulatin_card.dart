import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/font_provider.dart';

/// Sulatin (Indigenous Writing System) Card Widget
///
/// Design Specifications:
/// - Clickable learning containers for indigenous writing systems
/// - Available: Baybayin (with image and status bar showing progress)
/// - Placeholder: Alibata, Surat Mangyan (marked as "susunod na bersyon")
/// - Glassmorphism effect on cards
class SulatinCard extends StatelessWidget {
  final String title;
  final bool isActive;
  final FontProvider fontProvider;
  final VoidCallback onTap;
  final String? imagePath;
  final double? progress;

  const SulatinCard({
    super.key,
    required this.title,
    required this.isActive,
    required this.fontProvider,
    required this.onTap,
    this.imagePath,
    this.progress,
  });

  // Design color constants
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? primaryYellow.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? primaryYellow.withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image or placeholder
            _buildImage(),
            const SizedBox(height: 12),
            // Title
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: fontProvider.descriptionSize,
                fontWeight: FontWeight.w600,
                color: isActive ? textColor : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            // Coming soon indicator for inactive cards
            if (!isActive) ...[
              const SizedBox(height: 4),
              Text(
                '(susunod na bersyon)',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            // Progress bar for active cards
            if (isActive && progress != null) ...[
              const SizedBox(height: 8),
              _buildProgressBar(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          imagePath!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderIcon();
          },
        ),
      );
    }
    return _buildPlaceholderIcon();
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isActive
            ? primaryYellow.withValues(alpha: 0.3)
            : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.edit_rounded,
        color: isActive ? primaryYellow : Colors.grey,
        size: 30,
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress ?? 0,
        child: Container(
          decoration: BoxDecoration(
            color: primaryYellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
