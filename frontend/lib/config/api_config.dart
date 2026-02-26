import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

/// API Configuration for managing base URLs across different environments.
/// 
/// This class provides a centralized way to configure the API base URL
/// for different running environments (ngrok, localhost, device IP, production).
/// 
/// **IMPORTANT**: When pasting ngrok or production URLs, ensure there are NO:
/// - Leading or trailing spaces
/// - Line breaks or tabs
/// - Zero-width or invisible characters
/// - Missing http:// or https:// scheme
/// 
/// The configuration includes automatic URL sanitization and validation to prevent
/// FormatException errors when URLs contain whitespace or invalid characters.
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
  static const bool _useNgrok = false;
  
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
  /// 5. Run: ngrok http 5000  (⚠️ IMPORTANT: Use port 5000, not port 80!)
  /// 6. Copy the URL that looks like: https://xxxxxxxxxx.ngrok-free.dev
  /// 7. Paste it below (replace the example URL)
  /// 
  /// ⚠️ CRITICAL: After pasting, verify there are NO spaces before or after the URL!
  /// Spaces or invisible characters will cause "FormatException: Scheme not starting with alphabetic character"
  /// 
  /// EXAMPLE: https://polyatomic-kinesically-wynell.ngrok-free.dev
  static const String _ngrokUrl = 'https://polyatomic-kinesically-wynell.ngrok-free.dev';
  
  /// The IP address of your development machine on the local network
  /// Update this to your machine's IP when debugging on a real device
  /// Find your IP: Windows (ipconfig), Mac/Linux (ifconfig)
  static const String _deviceIp = '192.168.254.101';
  
  /// The port number for the backend API server (Flask)
  static const String _port = '5000';
  
  /// Production backend URL (for deployed apps on cloud servers)
  /// Examples: Heroku, Render, AWS, Google Cloud, Azure, DigitalOcean, etc.
  /// Update this when you deploy your Flask backend to production
  /// 
  /// ⚠️ IMPORTANT: Ensure this URL has NO spaces and includes https://
  static const String _productionUrl = 'https://your-production-api.com';
  
  // ============================================================================
  // WARNING CONSTANTS
  // ============================================================================
  
  /// Warning message shown when ngrok URL is invalid
  static const String _invalidNgrokWarning = 
      '⚠️ WARNING: Invalid ngrok URL configuration detected! '
      'Falling back to localhost. Check _ngrokUrl for spaces or invalid characters.';
  
  /// Warning message shown when production URL is invalid
  static const String _invalidProductionWarning = 
      '⚠️ WARNING: Invalid production URL configuration detected! '
      'Falling back to safe default. Check _productionUrl for spaces or invalid characters.';
  
  // ============================================================================
  // URL VALIDATION AND NORMALIZATION
  // ============================================================================
  
  /// Regex for removing non-printable characters:
  /// - \x00-\x1F: Control characters (null, tab, newline, etc.)
  /// - \x7F-\x9F: Additional control characters (DEL, etc.)
  /// - \u200B-\u200D: Zero-width spaces (ZWSP, ZWNJ, ZWJ)
  /// - \uFEFF: Zero-width no-break space (BOM)
  static final RegExp _nonPrintableCharsRegex = RegExp(r'[\x00-\x1F\x7F-\x9F\u200B-\u200D\uFEFF]');
  
  /// Regex for removing whitespace
  static final RegExp _whitespaceRegex = RegExp(r'\s+');
  
  /// Normalizes a URL by trimming whitespace and removing non-printable characters.
  /// 
  /// This prevents FormatException when URLs are copied with accidental spaces,
  /// line breaks, tabs, or zero-width characters.
  /// 
  /// Returns the cleaned URL string, or null if the input is empty after cleaning.
  static String? _normalizeUrl(String url) {
    // Trim leading/trailing whitespace
    String cleaned = url.trim();
    
    // Remove all non-printable characters (control characters, zero-width spaces, etc.)
    // Keep only printable ASCII and common URL characters
    cleaned = cleaned.replaceAll(_nonPrintableCharsRegex, '');
    
    // Remove any remaining whitespace within the URL
    // Note: Only removes raw whitespace (space, tab, newline), not encoded %20
    cleaned = cleaned.replaceAll(_whitespaceRegex, '');
    
    return cleaned.isEmpty ? null : cleaned;
  }
  
  /// Validates if a normalized URL string is properly formed with a valid scheme.
  /// 
  /// Assumes the URL is already normalized (no need to call _normalizeUrl again).
  /// Returns true if the URL can be parsed and has http/https scheme.
  static bool _isValidUrl(String normalizedUrl) {
    if (normalizedUrl.isEmpty) return false;
    
    // Try to parse as URI and verify scheme
    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null) return false;
    
    // Verify scheme is http or https (rejects missing scheme, ftp, etc.)
    return uri.scheme == 'http' || uri.scheme == 'https';
  }
  
  /// Returns a sanitized version of the ngrok URL.
  /// If invalid, returns null and logs warning.
  static String? get _sanitizedNgrokUrl {
    final normalized = _normalizeUrl(_ngrokUrl);
    if (normalized == null || !_isValidUrl(normalized)) {
      if (kDebugMode) {
        print(_invalidNgrokWarning);
      }
      return null;
    }
    return normalized;
  }
  
  /// Returns a sanitized version of the production URL.
  /// If invalid, returns null and logs warning.
  static String? get _sanitizedProductionUrl {
    final normalized = _normalizeUrl(_productionUrl);
    if (normalized == null || !_isValidUrl(normalized)) {
      if (kDebugMode) {
        print(_invalidProductionWarning);
      }
      return null;
    }
    return normalized;
  }
  
  /// Returns the fallback URL based on the current platform.
  /// Returns localhost for web builds, device IP for mobile builds.
  static String _getFallbackUrl() {
    if (kIsWeb) {
      return 'http://localhost:$_port';
    }
    return 'http://$_deviceIp:$_port';
  }
  
  // ============================================================================
  // BASE URL GETTER
  // ============================================================================
  
  /// Returns the appropriate base URL based on the running environment. 
  /// 
  /// Priority order:
  /// 1. If [_useProduction] = true: Returns sanitized production URL (or fallback)
  /// 2. If [_useNgrok] = true: Returns sanitized ngrok URL (or fallback)
  /// 3. If [_useLocalhost] = true or running on web (kIsWeb): Returns localhost URL
  /// 4. Otherwise: Returns device IP URL (for local network testing)
  /// 
  /// **Fallback behavior:**
  /// - If production URL is invalid: Falls back to localhost or device IP
  /// - If ngrok URL is invalid: Falls back to localhost or device IP
  /// - Warnings are printed in debug mode when fallbacks occur
  static String get baseUrl {
    // Use production backend
    if (_useProduction) {
      final sanitized = _sanitizedProductionUrl;
      if (sanitized != null) {
        return sanitized;
      }
      // Fallback if production URL is invalid
      return _getFallbackUrl();
    }
    
    // Use ngrok tunnel for public internet access (RECOMMENDED FOR MOBILE APK)
    if (_useNgrok) {
      final sanitized = _sanitizedNgrokUrl;
      if (sanitized != null) {
        return sanitized;
      }
      // Fallback if ngrok URL is invalid
      return _getFallbackUrl();
    }
    
    // Always use localhost when running on web (Chrome)
    if (kIsWeb || _useLocalhost) {
      return 'http://localhost:$_port';
    }
    
    // Use device IP for real mobile devices on local network
    return 'http://$_deviceIp:$_port';
  }
}