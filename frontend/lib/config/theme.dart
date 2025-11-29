import 'package:flutter/material.dart';
import '../providers/font_provider.dart';

/// App Theme Configuration
/// Centralizes theme definitions and applies font preferences globally
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
        titleTextStyle: TextStyle(
          fontSize: fontProvider.header1Size,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(
            fontSize: fontProvider.descriptionSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: TextStyle(fontSize: fontProvider.descriptionSize),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(fontSize: fontProvider.descriptionSize),
        hintStyle: TextStyle(fontSize: fontProvider.descriptionSize),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: TextStyle(
          fontSize: fontProvider.descriptionSize,
          color: Colors.black87,
        ),
        subtitleTextStyle: TextStyle(
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
        titleTextStyle: TextStyle(
          fontSize: fontProvider.header1Size,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(
            fontSize: fontProvider.descriptionSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: TextStyle(fontSize: fontProvider.descriptionSize),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(fontSize: fontProvider.descriptionSize),
        hintStyle: TextStyle(fontSize: fontProvider.descriptionSize),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: TextStyle(
          fontSize: fontProvider.descriptionSize,
          color: Colors.white70,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: fontProvider.header4Size,
          color: Colors.grey[400],
        ),
      ),
      cardTheme: const CardThemeData(elevation: 2, margin: EdgeInsets.all(8)),
    );
  }

  /// Build text theme with font size preferences
  static TextTheme _buildTextTheme(
    FontProvider fontProvider,
    Brightness brightness,
  ) {
    final Color textColor = brightness == Brightness.light
        ? Colors.black87
        : Colors.white;

    return TextTheme(
      // Display styles (Titles group)
      displayLarge: TextStyle(
        fontSize: fontProvider.titleSize,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontSize: fontProvider.titleSize,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontSize: fontProvider.titleSize,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),

      // Headline styles (Header1 group)
      headlineLarge: TextStyle(
        fontSize: fontProvider.header1Size,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: fontProvider.header1Size,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontSize: fontProvider.header1Size,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),

      // Title styles (between Header1 and Description)
      titleLarge: TextStyle(
        fontSize: fontProvider.header1Size,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: fontProvider.descriptionSize + _fontSizeOffset,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontSize: fontProvider.descriptionSize,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),

      // Body styles (Description group)
      bodyLarge: TextStyle(
        fontSize: fontProvider.descriptionSize,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: fontProvider.descriptionSize,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: fontProvider.header4Size + _fontSizeOffset,
        color: textColor,
      ),

      // Label styles (Header4 group)
      labelLarge: TextStyle(
        fontSize: fontProvider.header4Size + _fontSizeOffset,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontSize: fontProvider.header4Size,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontSize: fontProvider.header4Size,
        color: textColor,
      ),
    );
  }
}
