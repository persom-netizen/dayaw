// frontend/lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  // ✅ DB Connection Test
  static Future<Map<String, dynamic>> testDbConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/db-ping'));
      return json.decode(response.body);
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  // ✅ Get Users
  static Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/login'));
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  // ✅ Ask OpenAI (Original)
  static Future<Map<String, dynamic>> askOpenAI(String question) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ask-openai'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'prompt': question}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'answer': 'Error: $e'};
    }
  }

  // ✅ CHAT: Create new session
  static Future<Map<String, dynamic>> createChatSession(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/sessions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ✅ CHAT: Get all sessions
  static Future<List<dynamic>> getChatSessions(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/sessions?username=$username'),
      );
      final data = json.decode(response.body);
      return data['sessions'] ?? [];
    } catch (e) {
      throw Exception('Failed to load chat sessions: $e');
    }
  }

  // ✅ CHAT: Get messages from session
  static Future<List<dynamic>> getChatMessages(int sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/messages/$sessionId'),
      );
      final data = json.decode(response.body);
      return data['messages'] ?? [];
    } catch (e) {
      throw Exception('Failed to load chat messages: $e');
    }
  }

  // ✅ CHAT: Send message and get AI response
  static Future<Map<String, dynamic>> sendChatMessage(
    int sessionId,
    String message,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'session_id': sessionId, 'message': message}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ✅ CHAT: Delete session
  static Future<Map<String, dynamic>> deleteChatSession(int sessionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/chat/sessions/$sessionId'),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
