import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.100.168:5000";

  // ===== DATABASE ROUTES =====

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

  // ===== OPENAI / CHAT ROUTES =====

  static Future<Map<String, dynamic>> askOpenAI(
    String question, {
    String username = "anonymous",
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/ask'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'question': question, 'username': username}),
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

  static Future<Map<String, dynamic>> getChatHistory({
    String username = "anonymous",
    int limit = 50,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat-history?username=$username&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
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

  static Future<Map<String, dynamic>> deleteChat(int chatId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/chat-history/$chatId'),
        headers: {'Content-Type': 'application/json'},
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

  static Future<Map<String, dynamic>> createChatThread({
    required String title,
    String username = "anonymous",
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat-threads'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title, 'username': username}),
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

  static Future<Map<String, dynamic>> getChatThreads({
    String username = "anonymous",
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat-threads?username=$username'),
        headers: {'Content-Type': 'application/json'},
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

  static Future<Map<String, dynamic>> deleteChatThread(int threadId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/chat-threads/$threadId'),
        headers: {'Content-Type': 'application/json'},
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

  // ===== ALAALA (24-HOUR TRIVIA) ROUTES =====

  static Future<Map<String, dynamic>> getAlaalToday() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/alaala/today'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load Alaala: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Alaala: $e');
    }
  }

  static Future<Map<String, dynamic>> getAllAlaal({int limit = 100}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/alaala/all?limit=$limit'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load all Alaala: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching all Alaala: $e');
    }
  }

  // ===== SALITA (WORD OF THE DAY) ROUTES =====

  static Future<Map<String, dynamic>> getSalitaToday() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/salita/today'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load Salita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Salita: $e');
    }
  }

  static Future<Map<String, dynamic>> getAllSalita({int limit = 100}) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/salita/all?limit=$limit'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load all Salita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching all Salita: $e');
    }
  }
}
