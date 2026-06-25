import 'package:flutter_test/flutter_test.dart';
import 'package:dayaw_frontend/config/api_config.dart';

void main() {
  group('ApiConfig', () {
    test('baseUrl should return a valid URL', () {
      final url = ApiConfig.baseUrl;
      expect(url, isNotEmpty);
      expect(url, isNotNull);
    });

    test('baseUrl should start with http:// or https://', () {
      final url = ApiConfig.baseUrl;
      expect(url.startsWith('http://') || url.startsWith('https://'), isTrue,
          reason: 'URL should start with http:// or https://');
    });

    test('baseUrl should not end with a slash', () {
      final url = ApiConfig.baseUrl;
      expect(url.endsWith('/'), isFalse,
          reason: 'Base URL should not end with a slash to allow clean path concatenation');
    });

    test('baseUrl should be a complete URL', () {
      final url = ApiConfig.baseUrl;
      // Should contain either localhost, a valid IP address, or a domain name
      final hasLocalhost = url.contains('localhost');
      final hasValidIp = RegExp(
              r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')
          .hasMatch(url);
      final hasDomain = RegExp(r'[a-zA-Z0-9-]+\.[a-zA-Z]{2,}').hasMatch(url);
      
      expect(hasLocalhost || hasValidIp || hasDomain, isTrue,
          reason: 'URL should contain a valid host (localhost, valid IP address, or domain name)');
    });
  });
}
