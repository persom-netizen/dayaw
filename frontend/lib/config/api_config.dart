import 'package:flutter/foundation.dart' show kIsWeb;

/// API Configuration for managing base URLs across different environments.
/// 
/// This class provides a centralized way to configure the API base URL
/// for different running environments (ngrok, localhost, device IP, production).
/// 
/// Usage:
/// - For ngrok tunnel: Set [_useNgrok] = true and paste ngrok URL in [_ngrokUrl]
/// - For Chrome (web) debugging: Uses localhost automatically
/// - For real device (mobile): Uses the device IP address
/// - For production: Set [_useProduction] = true
class ApiConfig {
  // ============================================================================
  // ENVIRONMENT CONFIGURATION
  // ============================================================================
  
  /// Set to true to use ngrok tunnel for public internet access (RECOMMENDED FOR MOBILE APK TESTING)
  /// Paste your ngrok URL in [_ngrokUrl] below
  /// Generate with: ngrok http 5000
  static const bool _useNgrok = true;
  
  /// Set to true to use localhost (only works for web/Chrome debugging)
  static const bool _useLocalhost = false;
  
  /// Set to true to use production backend (for deployed apps)
  static const bool _useProduction = false;
  
  // ============================================================================
  // BACKEND URLS
  // ============================================================================
  
  /// ngrok public URL for testing mobile app with internet access
  /// 
  /// HOW TO GET THIS:
  /// 1. Download ngrok from https://ngrok.com/download
  /// 2. Sign up at https://dashboard.ngrok.com/signup
  /// 3. Get authtoken from https://dashboard.ngrok.com/get-started/your-authtoken
  /// 4. Run: ngrok config add-authtoken YOUR_AUTH_TOKEN
  /// 5. Run: ngrok http 5000
  /// 6. Copy the URL that looks like: https://xxxxxxxxxx.ngrok-free.dev
  /// 7. Paste it below (replace the example URL)
  /// 
  /// EXAMPLE: https://polyatomic-kinesically-wynell.ngrok-free.dev
  static const String _ngrokUrl = 'https://polyatomic-kinesically-wynell.ngrok-free.dev';
  
  /// The IP address of your development machine on the local network
  /// Update this to your machine's IP when debugging on a real device
  /// Find your IP: Windows (ipconfig), Mac/Linux (ifconfig)
  static const String _deviceIp = '192.168.100.168';
  
  /// The port number for the backend API server (Flask)
  static const String _port = '5000';
  
  /// Production backend URL (for deployed apps on cloud servers)
  /// Examples: Heroku, Render, AWS, Google Cloud, Azure, DigitalOcean, etc.
  /// Update this when you deploy your Flask backend to production
  static const String _productionUrl = 'https://your-production-api.com';
  
  // ============================================================================
  // BASE URL GETTER
  // ============================================================================
  
  /// Returns the appropriate base URL based on the running environment. 
  /// 
  /// Priority order:
  /// 1. If [_useProduction] = true: Returns production URL
  /// 2. If [_useNgrok] = true: Returns ngrok public URL (BEST FOR MOBILE APK)
  /// 3. If [_useLocalhost] = true or running on web (kIsWeb): Returns localhost URL
  /// 4. Otherwise: Returns device IP URL (for local network testing)
  static String get baseUrl {
    // Use production backend
    if (_useProduction) {
      return _productionUrl;
    }
    
    // Use ngrok tunnel for public internet access (RECOMMENDED FOR MOBILE APK)
    if (_useNgrok) {
      return _ngrokUrl;
    }
    
    // Always use localhost when running on web (Chrome)
    if (kIsWeb || _useLocalhost) {
      return 'http://localhost:$_port';
    }
    
    // Use device IP for real mobile devices on local network
    return 'http://$_deviceIp:$_port';
  }
}