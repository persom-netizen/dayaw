import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../models/post_model.dart';

class PostService {
  static const String baseUrl = "http://192.168.100.168:5000";
  static final Dio _dio = Dio();

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

  /// Upload image using Dio (better file handling)
  static Future<String> uploadImage(XFile imageFile) async {
    try {
      print("[INFO] Starting image upload: ${imageFile.name}");

      // Read file as bytes
      final bytes = await imageFile.readAsBytes();

      // Create FormData
      FormData formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: imageFile.name),
      });

      print("[INFO] Sending request to: $baseUrl/api/upload");

      // Upload using Dio
      final response = await _dio.post(
        '$baseUrl/api/upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Accept': 'application/json'},
        ),
      );

      print("[INFO] Upload response: ${response.statusCode}");
      print("[INFO] Response data: ${response.data}");

      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        if (jsonResponse['success'] == true) {
          final imageUrl = jsonResponse['image_url'] ?? '';
          print("[SUCCESS] Image uploaded. URL: $imageUrl");
          return imageUrl;
        } else {
          throw Exception('Upload failed: ${jsonResponse['error']}');
        }
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("[ERROR] DioException: ${e.message}");
      print("[ERROR] Response: ${e.response?.data}");
      throw Exception('Error uploading image: ${e.message}');
    } catch (e) {
      print("[ERROR] Exception: $e");
      throw Exception('Error uploading image: $e');
    }
  }

  /// Create post with optional image
  static Future<Post> createPost({
    required String username,
    String? title,
    required String content,
    String? imageUrl,
  }) async {
    try {
      print("[INFO] Creating post for user: $username");

      final payload = {
        'username': username,
        'title': title,
        'content': content,
        'image_url': imageUrl,
        'profile_image': null,
      };

      print("[INFO] Payload: $payload");

      final response = await http.post(
        Uri.parse('$baseUrl/api/posts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      print("[INFO] Create post response: ${response.statusCode}");
      print("[INFO] Response body: ${response.body}");

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print("[SUCCESS] Post created with ID: ${responseData['id']}");
        return Post.fromJson(responseData);
      } else {
        print("[ERROR] Failed to create post: ${response.statusCode}");
        print("[ERROR] Response: ${response.body}");
        throw Exception(
          'Failed to create post: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print("[ERROR] Exception creating post: $e");
      throw Exception('Error creating post: $e');
    }
  }

  /// Delete post
  static Future<void> deletePost(int postId) async {
    try {
      print("[INFO] Deleting post: $postId");

      final response = await http.delete(
        Uri.parse('$baseUrl/api/posts/$postId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete post: ${response.statusCode}');
      }

      print("[SUCCESS] Post deleted: $postId");
    } catch (e) {
      print("[ERROR] Exception deleting post: $e");
      throw Exception('Error deleting post: $e');
    }
  }
}
