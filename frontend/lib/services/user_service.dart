import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../config/api_config.dart';

class UserService {
  static String get baseUrl => ApiConfig.baseUrl;

  /// Get user profile info and their posts
  static Future<Map<String, dynamic>> getUserProfile(String username) async {
    try {
      print("[INFO] Fetching user profile for: $username");

      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$username'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final user = User.fromJson(responseData['user']);
          final List<dynamic> postsJson = responseData['posts'] ?? [];
          final posts = postsJson.map((p) => Post.fromJson(p)).toList();
          final postCount = responseData['post_count'] ?? posts.length;
          
          print("[SUCCESS] User profile fetched: ${user.username}");
          return {
            'success': true,
            'user': user,
            'posts': posts,
            'postCount': postCount,
          };
        } else {
          throw Exception(responseData['message'] ?? 'Failed to get user profile');
        }
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to get user profile: ${response.statusCode}');
      }
    } catch (e) {
      print("[ERROR] Exception fetching user profile: $e");
      throw Exception('Error fetching user profile: $e');
    }
  }

  /// Update user profile (pangalan and mongkahe)
  static Future<User> updateUserProfile({
    required String username,
    required String pangalan,
    required String mongkahe,
  }) async {
    try {
      print("[INFO] Updating user profile for: $username");

      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$username/profile'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'pangalan': pangalan,
          'mongkahe': mongkahe,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final user = User.fromJson(responseData['user']);
          print("[SUCCESS] User profile updated: ${user.username}");
          return user;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to update profile');
        }
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print("[ERROR] Exception updating user profile: $e");
      throw Exception('Error updating user profile: $e');
    }
  }
}
