import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/font_preference.dart';

/// Font Provider for managing font size preferences
/// Uses SharedPreferences for persistence across app sessions
class FontProvider with ChangeNotifier {
  static const String _fontLevelKey = 'font_size_level';

  FontPreference _preference = FontPreference.defaultPreference();
  bool _isLoaded = false;

  /// Current font preference
  FontPreference get preference => _preference;

  /// Current font size level
  FontSizeLevel get level => _preference.level;

  /// Current font size configuration
  FontSizeConfig get config => _preference.config;

  /// Whether preferences have been loaded from storage
  bool get isLoaded => _isLoaded;

  /// Initialize and load font preferences from storage
  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLevel = prefs.getInt(_fontLevelKey);

      if (savedLevel != null) {
        final fontLevel = FontSizeLevel.fromValue(savedLevel);
        _preference = _preference.copyWith(level: fontLevel);
      }

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[FontProvider] Error loading preferences: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Set font size level and save to storage
  Future<void> setFontLevel(FontSizeLevel level) async {
    if (_preference.level == level) return;

    _preference = _preference.copyWith(level: level);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_fontLevelKey, level.value);
    } catch (e) {
      debugPrint('[FontProvider] Error saving preference: $e');
    }
  }

  /// Set font size level by integer value (1-5)
  Future<void> setFontLevelByValue(int value) async {
    final clampedValue = value.clamp(1, 5);
    final level = FontSizeLevel.fromValue(clampedValue);
    await setFontLevel(level);
  }

  /// Reset to default font level (Level 3 - Medium)
  Future<void> resetToDefault() async {
    await setFontLevel(FontSizeLevel.level3);
  }

  // Convenience getters for individual font sizes
  double get titleSize => _preference.config.titles;
  double get header1Size => _preference.config.header1;
  double get descriptionSize => _preference.config.description;
  double get header4Size => _preference.config.header4;
}
