import 'package:flutter/material.dart';
import '../providers/font_provider.dart';

/// Centralized text style definitions that respect font preferences
/// 
/// Text Hierarchy:
/// - Titles: Page titles, Section headers, Headlines (Largest)
/// - Header1: Card titles, Main headers (Large)
/// - Description: Body text, Content descriptions, Regular paragraphs (Medium)
/// - Header4: Tiny details, Helper text, Captions, Footer text (Smallest)
class AppTextStyles {
  final FontProvider fontProvider;

  AppTextStyles(this.fontProvider);

  // ============================================
  // Text Group A - Titles (Largest in group)
  // ============================================

  /// Page title style
  TextStyle get pageTitle => TextStyle(
        fontSize: fontProvider.titleSize,
        fontWeight: FontWeight.bold,
      );

  /// Section header style
  TextStyle get sectionHeader => TextStyle(
        fontSize: fontProvider.titleSize,
        fontWeight: FontWeight.bold,
      );

  /// Headline style
  TextStyle get headline => TextStyle(
        fontSize: fontProvider.titleSize,
        fontWeight: FontWeight.bold,
      );

  /// Title with custom color
  TextStyle pageTitleWithColor(Color color) => TextStyle(
        fontSize: fontProvider.titleSize,
        fontWeight: FontWeight.bold,
        color: color,
      );

  // ============================================
  // Text Group B - Header1 (Large)
  // ============================================

  /// Card title style
  TextStyle get cardTitle => TextStyle(
        fontSize: fontProvider.header1Size,
        fontWeight: FontWeight.bold,
      );

  /// Main header style
  TextStyle get mainHeader => TextStyle(
        fontSize: fontProvider.header1Size,
        fontWeight: FontWeight.bold,
      );

  /// Header1 with custom color
  TextStyle header1WithColor(Color color) => TextStyle(
        fontSize: fontProvider.header1Size,
        fontWeight: FontWeight.bold,
        color: color,
      );

  /// Header1 with normal weight
  TextStyle get header1Normal => TextStyle(
        fontSize: fontProvider.header1Size,
        fontWeight: FontWeight.normal,
      );

  // ============================================
  // Text Group C - Description (Medium)
  // ============================================

  /// Body text style
  TextStyle get bodyText => TextStyle(
        fontSize: fontProvider.descriptionSize,
      );

  /// Content description style
  TextStyle get contentDescription => TextStyle(
        fontSize: fontProvider.descriptionSize,
      );

  /// Regular paragraph style
  TextStyle get paragraph => TextStyle(
        fontSize: fontProvider.descriptionSize,
      );

  /// Description with custom color
  TextStyle descriptionWithColor(Color color) => TextStyle(
        fontSize: fontProvider.descriptionSize,
        color: color,
      );

  /// Description with bold weight
  TextStyle get descriptionBold => TextStyle(
        fontSize: fontProvider.descriptionSize,
        fontWeight: FontWeight.bold,
      );

  // ============================================
  // Text Group D - Header4 (Smallest)
  // ============================================

  /// Caption style
  TextStyle get caption => TextStyle(
        fontSize: fontProvider.header4Size,
      );

  /// Helper text style
  TextStyle get helperText => TextStyle(
        fontSize: fontProvider.header4Size,
        color: Colors.grey[600],
      );

  /// Footer text style
  TextStyle get footerText => TextStyle(
        fontSize: fontProvider.header4Size,
      );

  /// Tiny details style
  TextStyle get tinyDetails => TextStyle(
        fontSize: fontProvider.header4Size,
        color: Colors.grey[500],
      );

  /// Header4 with custom color
  TextStyle header4WithColor(Color color) => TextStyle(
        fontSize: fontProvider.header4Size,
        color: color,
      );

  /// Header4 with bold weight
  TextStyle get header4Bold => TextStyle(
        fontSize: fontProvider.header4Size,
        fontWeight: FontWeight.bold,
      );
}

/// Extension to get text styles from BuildContext
extension TextStylesExtension on BuildContext {
  /// Get AppTextStyles from the nearest FontProvider
  AppTextStyles getTextStyles(FontProvider fontProvider) {
    return AppTextStyles(fontProvider);
  }
}
