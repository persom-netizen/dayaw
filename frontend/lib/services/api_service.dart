import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000";

  // Test database connection
  static Future<Map<String, dynamic>> testDbConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/db-ping'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'ok': false, 'error': 'HTTP ${response.statusCode}'};
      }
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  // Get all users
  static Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  // Add a new user
  static Future<Map<String, dynamic>> addUser({
    required String username,
    required String email,
    required String passwordHash,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password_hash': passwordHash,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {'error': 'HTTP ${response.statusCode}: ${response.body}'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Ask OpenAI a question
  static Future<Map<String, dynamic>> askOpenAI(String question) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/ask'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'question': question}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': 'HTTP ${response.statusCode}: ${response.body}'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
