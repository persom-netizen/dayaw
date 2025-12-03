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
      // Should contain either localhost, an IP address, or a domain
      final hasValidHost = url.contains('localhost') ||
          RegExp(r'\d+\.\d+\.\d+\.\d+').hasMatch(url) ||
          url.contains('.dev') ||
          url.contains('.com');
      expect(hasValidHost, isTrue,
          reason: 'URL should contain a valid host (localhost, IP, or domain)');
    });
  });
}
