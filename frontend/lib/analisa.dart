import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/font_provider.dart';
import 'providers/theme_provider.dart';

class AnalisaPage extends StatelessWidget {
  final String username;
  const AnalisaPage({super.key, required this.username});

  // Design color constants kept for brand consistency
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);

  @override
  Widget build(BuildContext context) {
    return Consumer2<FontProvider, ThemeProvider>(
      builder: (context, fontProvider, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final bgColor = isDark ? const Color(0xFF1F1F1F) : backgroundColor;
        final textColorThemed = isDark ? Colors.white : textColor;

        return Scaffold(
          backgroundColor: bgColor,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Maintenance Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryYellow.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.construction_rounded,
                      size: 80,
                      color: primaryYellow,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Main Header
                  Text(
                    'UNDER MAINTENANCE',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: primaryYellow,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subtext
                  Text(
                    'Kasalukuyan naming pinapalitan ang aming AI Bot ng isang bagong feature para mas mapaganda ang aming serbisyo para sa inyo.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: textColorThemed,
                      fontSize: fontProvider.descriptionSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Progress Indicator to show "Work in Progress"
                  const SizedBox(
                    width: 40,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.black12,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryYellow),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Abangan ang bagong Analisa!',
                    style: GoogleFonts.inter(
                      color: textColorThemed.withOpacity(0.5),
                      fontSize: fontProvider.header4Size,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}