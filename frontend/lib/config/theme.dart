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

  // Light mode colors
  static const Color lightBackground = Color(0xFFFFF9F4);
  static const Color lightTextColor = Color(0xFF554141);
  static const Color primaryYellow = Color(0xFFFFDF00);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF1F1F1F);
  static const Color darkCardBackground = Color(0xFF2A2A2A);
  static const Color darkTextColor = Color(0xFFFFFFFF);
  static const Color darkSecondaryText = Color(0xFFBDBDBD);
  static const Color darkBorder = Color(0xFF404040);

  /// Create a light theme with font size preferences applied
  static ThemeData lightTheme(FontProvider fontProvider) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryYellow,
        brightness: Brightness.light,
        primary: primaryYellow,
        surface: Colors.white,
      ),
      textTheme: _buildTextTheme(fontProvider, Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightTextColor,
        elevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: fontProvider.titleSize,
          fontWeight: FontWeight.bold,
          color: lightTextColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: lightTextColor,
          textStyle: GoogleFonts.inter(
            fontSize: fontProvider.descriptionSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightTextColor,
          textStyle: GoogleFonts.inter(fontSize: fontProvider.descriptionSize),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: GoogleFonts.inter(
          fontSize: fontProvider.descriptionSize,
          color: lightTextColor,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: fontProvider.descriptionSize,
          color: lightTextColor.withValues(alpha: 0.5),
        ),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: GoogleFonts.inter(
          fontSize: fontProvider.descriptionSize,
          color: lightTextColor,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: fontProvider.header4Size,
          color: lightTextColor.withValues(alpha: 0.6),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: primaryYellow, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: primaryYellow.withValues(alpha: 0.5),
        thickness: 1,
      ),
    );
  }

  /// Create a dark theme with font size preferences applied
  static ThemeData darkTheme(FontProvider fontProvider) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryYellow,
        brightness: Brightness.dark,
        primary: primaryYellow,
        surface: darkCardBackground,
      ),
      textTheme: _buildTextTheme(fontProvider, Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkTextColor,
        elevation: 0,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: fontProvider.titleSize,
          fontWeight: FontWeight.bold,
          color: darkTextColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: lightTextColor,
          textStyle: GoogleFonts.inter(
            fontSize: fontProvider.descriptionSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkTextColor,
          textStyle: GoogleFonts.inter(fontSize: fontProvider.descriptionSize),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardBackground,
        labelStyle: GoogleFonts.inter(
          fontSize: fontProvider.descriptionSize,
          color: darkTextColor,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: fontProvider.descriptionSize,
          color: darkSecondaryText,
        ),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: GoogleFonts.inter(
          fontSize: fontProvider.descriptionSize,
          color: darkTextColor,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: fontProvider.header4Size,
          color: darkSecondaryText,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardBackground,
        elevation: 2,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: primaryYellow, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: primaryYellow.withValues(alpha: 0.5),
        thickness: 1,
      ),
    );
  }

  /// Build text theme with font size preferences
  /// Titles use Playfair Display, all other text uses Inter
  static TextTheme _buildTextTheme(
    FontProvider fontProvider,
    Brightness brightness,
  ) {
    final Color textColor = brightness == Brightness.light
        ? lightTextColor
        : darkTextColor;

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
