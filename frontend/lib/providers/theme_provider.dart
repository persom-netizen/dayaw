import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Provider for managing dark mode state
/// Persists theme preference using SharedPreferences
class ThemeProvider with ChangeNotifier {
  static const String _darkModeKey = 'dark_mode_enabled';
  
  bool _isDarkMode = false;
  bool _isLoaded = false;

  /// Whether dark mode is enabled
  bool get isDarkMode => _isDarkMode;

  /// Whether preferences have been loaded from storage
  bool get isLoaded => _isLoaded;

  /// Initialize and load theme preferences from storage
  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[ThemeProvider] Error loading preferences: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Toggle dark mode and save to storage
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, _isDarkMode);
    } catch (e) {
      debugPrint('[ThemeProvider] Error saving preference: $e');
    }
  }

  /// Set dark mode state and save to storage
  Future<void> setDarkMode(bool enabled) async {
    if (_isDarkMode == enabled) return;

    _isDarkMode = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, enabled);
    } catch (e) {
      debugPrint('[ThemeProvider] Error saving preference: $e');
    }
  }
}
