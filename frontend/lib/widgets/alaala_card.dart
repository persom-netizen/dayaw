import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/font_provider.dart';

/// Alaala (Trivia) Card Widget
///
/// Design Specifications:
/// - Static text: "@alammoba.dayaw"
/// - Content from database (alammoba)
/// - Line divider: 3/4 of screen width, color #592A19
/// - Description text: justified alignment
/// - Unified design matching Salita section
class AlaalaCard extends StatelessWidget {
  final Map<String, dynamic>? alaalaData;
  final bool isLoading;
  final FontProvider fontProvider;

  const AlaalaCard({
    super.key,
    required this.alaalaData,
    required this.isLoading,
    required this.fontProvider,
  });

  // Design color constants
  static const Color textColor = Color(0xFF554141);
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color alaalaDividerColor = Color(0xFF592A19);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: @alammoba.dayaw
        Text(
          '@alammoba.dayaw',
          style: GoogleFonts.inter(
            fontSize: fontProvider.header4Size,
            fontWeight: FontWeight.w600,
            color: textColor.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),
        // Content
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: primaryYellow),
            ),
          )
        else if (alaalaData == null)
          _buildNoDataWidget()
        else ...[
          // Title from API (alammoba field)
          Text(
            alaalaData?['alammoba'] ?? 'N/A',
            style: GoogleFonts.playfairDisplay(
              fontSize: fontProvider.header1Size,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          // Divider: line with color #592A19, 3/4 screen width
          FractionallySizedBox(
            widthFactor: 0.75,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: alaalaDividerColor,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Body: Description from API, text justified
          Text(
            alaalaData?['deskription'] ?? 'N/A',
            style: GoogleFonts.inter(
              fontSize: fontProvider.descriptionSize,
              color: textColor,
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ],
    );
  }

  Widget _buildNoDataWidget() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 40,
              color: textColor.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              'Walang Alaala ngayong araw',
              style: GoogleFonts.inter(
                fontSize: fontProvider.descriptionSize,
                color: textColor.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
