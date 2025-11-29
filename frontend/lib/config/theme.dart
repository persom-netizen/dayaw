import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/font_provider.dart';

/// App Theme Configuration
/// Centralizes theme definitions and applies font preferences globally
/// Typography:
/// - Titles: Playfair Display font family
/// - All other text: Inter font family
class AppTheme {
  /// Font size offset for intermediate text sizes
  static const double _fontSizeOffset = 2.0;

  /// Create a light theme with font size preferences applied
  static ThemeData lightTheme(FontProvider fontProvider) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      ),
      textTheme: _buildTextTheme(fontProvider, Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.inter(
          fontSize: fontProvider.header1Size,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.inter(
            fontSize: fontProvider.descriptionSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.inter(fontSize: fontProvider.descriptionSize),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: GoogleFonts.inter(fontSize: fontProvider.descriptionSize),
        hintStyle: GoogleFonts.inter(fontSize: fontProvider.descriptionSize),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: GoogleFonts.inter(
          fontSize: fontProvider.descriptionSize,
          color: Colors.black87,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: fontProvider.header4Size,
          color: Colors.grey[600],
        ),
      ),
      cardTheme: const CardThemeData(elevation: 2, margin: EdgeInsets.all(8)),
    );
  }

  /// Create a dark theme with font size preferences applied
  static ThemeData darkTheme(FontProvider fontProvider) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      textTheme: _buildTextTheme(fontProvider, Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.inter(
          fontSize: fontProvider.header1Size,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.inter(
            fontSize: fontProvider.descriptionSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.inter(fontSize: fontProvider.descriptionSize),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: GoogleFonts.inter(fontSize: fontProvider.descriptionSize),
        hintStyle: GoogleFonts.inter(fontSize: fontProvider.descriptionSize),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: GoogleFonts.inter(
          fontSize: fontProvider.descriptionSize,
          color: Colors.white70,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: fontProvider.header4Size,
          color: Colors.grey[400],
        ),
      ),
      cardTheme: const CardThemeData(elevation: 2, margin: EdgeInsets.all(8)),
    );
  }

  /// Build text theme with font size preferences
  /// Titles use Playfair Display, all other text uses Inter
  static TextTheme _buildTextTheme(
    FontProvider fontProvider,
    Brightness brightness,
  ) {
    final Color textColor = brightness == Brightness.light
        ? Colors.black87
        : Colors.white;

    return TextTheme(
      // Display styles (Titles group) - Playfair Display
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: fontProvider.titleSize,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: fontProvider.titleSize,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: fontProvider.titleSize,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),

      // Headline styles (Header1 group) - Inter
      headlineLarge: GoogleFonts.inter(
        fontSize: fontProvider.header1Size,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: fontProvider.header1Size,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: fontProvider.header1Size,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),

      // Title styles (between Header1 and Description) - Playfair Display for large, Inter for others
      titleLarge: GoogleFonts.playfairDisplay(
        fontSize: fontProvider.header1Size,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: fontProvider.descriptionSize + _fontSizeOffset,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: fontProvider.descriptionSize,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),

      // Body styles (Description group) - Inter
      bodyLarge: GoogleFonts.inter(
        fontSize: fontProvider.descriptionSize,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: fontProvider.descriptionSize,
        color: textColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: fontProvider.header4Size + _fontSizeOffset,
        color: textColor,
      ),

      // Label styles (Header4 group) - Inter
      labelLarge: GoogleFonts.inter(
        fontSize: fontProvider.header4Size + _fontSizeOffset,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: fontProvider.header4Size,
        color: textColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: fontProvider.header4Size,
        color: textColor,
      ),
    );
  }
}
