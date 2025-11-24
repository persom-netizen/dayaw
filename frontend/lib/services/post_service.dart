import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/post_model.dart';

class PostService {
  static const String baseUrl = "http://192.168.100.168:5000";

  static Future<List<Post>> getPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/posts'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

  static Future<String> uploadImage(XFile imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/api/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add file to request
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        return jsonResponse['image_url'] ?? '';
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  static Future<Post> createPost({
    required String username,
    String? title,
    required String content,
    String? imageUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'title': title,
          'content': content,
          'image_url': imageUrl,
          'profile_image': null, // Backend will handle default
        }),
      );

      print('Post Response: ${response.statusCode}');
      print('Post Body: ${response.body}');

      if (response.statusCode == 201) {
        return Post.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to create post: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error creating post: $e');
    }
  }

  static Future<void> deletePost(int postId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/posts/$postId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete post: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting post: $e');
    }
  }
}
