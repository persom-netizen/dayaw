import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class SulatinApiClient {
  // Uses centralized API configuration from ApiConfig
  static String get baseUrl => '${ApiConfig.baseUrl}/api';

  /// Fetch lessons from backend
  static Future<Map<String, dynamic>> fetchLessons() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sulatin/lessons'));

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Failed to load lessons: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error fetching lessons: $e'};
    }
  }

  /// Save training drawing samples
  static Future<Map<String, dynamic>> saveSample({
    required String character,
    required List<Map<String, dynamic>> strokes,
    required String username,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sulatin/save-sample'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'character': character,
          'strokes': strokes,
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Failed to save sample: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error saving sample: $e'};
    }
  }

  /// Make predictions on strokes
  static Future<Map<String, dynamic>> predict({
    required List<List<Map<String, dynamic>>> strokes,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/sulatin/predict'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'strokes': strokes}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'Failed to predict: ${response.statusCode}',
        };
      }
    } on http.ClientException catch (e) {
      // Log technical details for debugging
      print('Network error in predict: $e');
      return {
        'success': false,
        'error': 'Hindi makakonekta sa server. Pakisubukan muli.',
      };
    } catch (e) {
      // Log technical details for debugging
      print('Error making prediction: $e');
      return {
        'success': false,
        'error': 'May naganap na error. Pakisubukan muli.',
      };
    }
  }

  /// Check database connection
  static Future<Map<String, dynamic>> checkDbConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/test-db'));

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {
          'success': false,
          'error': 'DB connection failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Error checking DB connection: $e'};
    }
  }
}
