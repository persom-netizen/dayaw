import 'package:flutter/foundation.dart' show kIsWeb;

/// API Configuration for managing base URLs across different environments.
/// 
/// This class provides a centralized way to configure the API base URL
/// for different running environments (Chrome web, real device, etc.).
/// 
/// Usage:
/// - For Chrome (web) debugging: Uses localhost automatically
/// - For real device (mobile): Uses the device IP address
/// 
/// To switch environments manually, change the [_useLocalhost] constant below.
class ApiConfig {
  // ============================================================================
  // CONFIGURATION SECTION
  // ============================================================================
  
  /// Set to true for Chrome web debugging (localhost)
  /// Set to false for real device debugging (uses device IP)
  /// 
  /// Note: When running on web (kIsWeb), localhost is automatically used
  /// regardless of this setting.
  static const bool _useLocalhost = true;
  
  /// The IP address of your development machine on the local network.
  /// Update this to your machine's IP when debugging on a real device.
  static const String _deviceIp = '192.168.100.168';
  
  /// The port number for the backend API server.
  static const String _port = '5000';
  
  // ============================================================================
  // BASE URL GETTER
  // ============================================================================
  
  /// Returns the appropriate base URL based on the running environment.
  /// 
  /// - On web (Chrome): Always returns localhost URL
  /// - On mobile with [_useLocalhost] = true: Returns localhost URL
  /// - On mobile with [_useLocalhost] = false: Returns device IP URL
  static String get baseUrl {
    // Always use localhost when running on web (Chrome)
    if (kIsWeb || _useLocalhost) {
      return 'http://localhost:$_port';
    }
    // Use device IP for real mobile devices
    return 'http://$_deviceIp:$_port';
  }
}
