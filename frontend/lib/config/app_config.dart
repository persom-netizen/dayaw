/// Application configuration for API endpoints and environment settings
///
/// This file contains centralized configuration for connecting to the backend server.
/// Update the [apiBaseUrl] when testing on different environments:
/// - Web/Emulator: Use 'http://localhost:5000' or 'http://127.0.0.1:5000'
/// - Real Android Device: Use your machine's local network IP (e.g., 'http://192.168.1.100:5000')
///
/// To find your machine's IP address:
/// - Windows: Run `ipconfig` and look for IPv4 Address
/// - Mac/Linux: Run `ifconfig` or `ip addr` and look for inet address
/// - Make sure your device and machine are on the same network
class AppConfig {
  /// Base URL for the backend API server
  /// 
  /// ⚠️ IMPORTANT: UPDATE THIS IP ADDRESS FOR YOUR ENVIRONMENT!
  /// 
  /// Current default (192.168.100.168) is a specific development machine IP.
  /// You MUST change this to match YOUR setup:
  /// 
  /// For Android device testing:
  /// - Use your machine's local network IP (e.g., 'http://192.168.1.100:5000')
  /// - Run `ipconfig` (Windows) or `ifconfig` (Mac/Linux) to find your IP
  /// 
  /// For web/emulator testing:
  /// - Use 'http://localhost:5000' or 'http://127.0.0.1:5000'
  /// 
  /// See ANDROID_DEVICE_TESTING.md for detailed instructions
  static const String apiBaseUrl = 'http://192.168.100.168:5000';

  /// API timeout duration in seconds
  static const int apiTimeoutSeconds = 30;

  /// Environment name for debugging
  static const String environment = 'development';

  /// Whether to enable debug logging
  static const bool enableDebugLogs = true;
}
