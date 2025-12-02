import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding Provider for managing onboarding/introduction screen state
/// Persists whether user has completed the initial onboarding flow
class OnboardingProvider with ChangeNotifier {
  static const String _onboardingCompleteKey = 'onboarding_completed';
  
  bool _hasCompletedOnboarding = false;
  bool _isLoaded = false;

  /// Whether user has completed the onboarding/introduction screens
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  /// Whether preferences have been loaded from storage
  bool get isLoaded => _isLoaded;

  /// Initialize and load onboarding preferences from storage
  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasCompletedOnboarding = prefs.getBool(_onboardingCompleteKey) ?? false;
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[OnboardingProvider] Error loading preferences: $e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Mark onboarding as complete and save to storage
  Future<void> markOnboardingComplete() async {
    _hasCompletedOnboarding = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompleteKey, true);
    } catch (e) {
      debugPrint('[OnboardingProvider] Error saving preference: $e');
    }
  }

  /// Reset onboarding state (useful for testing)
  Future<void> resetOnboarding() async {
    _hasCompletedOnboarding = false;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompleteKey, false);
    } catch (e) {
      debugPrint('[OnboardingProvider] Error resetting preference: $e');
    }
  }
}
