import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../models/post_model.dart';
import '../config/api_config.dart';

class PostService {
  static String get baseUrl => ApiConfig.baseUrl;
  static final Dio _dio = Dio();

  static Future<List<Post>> getPosts({String? username}) async {
    try {
      final uri = username != null && username.isNotEmpty
          ? Uri.parse('$baseUrl/api/posts?username=$username')
          : Uri.parse('$baseUrl/api/posts');
      
      final response = await http.get(
        uri,
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

  /// Toggle like on a post
  static Future<Map<String, dynamic>> toggleLike({
    required int postId,
    required String username,
  }) async {
    try {
      print("[INFO] Toggling like for post: $postId by user: $username");

      final response = await http.post(
        Uri.parse('$baseUrl/api/posts/$postId/like'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("[SUCCESS] Like toggled: ${responseData['liked']}");
        return responseData;
      } else {
        throw Exception('Failed to toggle like: ${response.statusCode}');
      }
    } catch (e) {
      print("[ERROR] Exception toggling like: $e");
      throw Exception('Error toggling like: $e');
    }
  }

  /// Get comments for a post
  static Future<List<Comment>> getComments(int postId) async {
    try {
      print("[INFO] Fetching comments for post: $postId");

      final response = await http.get(
        Uri.parse('$baseUrl/api/posts/$postId/comments'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> commentsJson = responseData['comments'] ?? [];
        return commentsJson.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      print("[ERROR] Exception fetching comments: $e");
      throw Exception('Error fetching comments: $e');
    }
  }

  /// Add a comment to a post
  static Future<Comment> addComment({
    required int postId,
    required String username,
    required String content,
  }) async {
    try {
      print("[INFO] Adding comment to post: $postId by user: $username");

      final response = await http.post(
        Uri.parse('$baseUrl/api/posts/$postId/comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print("[SUCCESS] Comment added with ID: ${responseData['comment']['id']}");
        return Comment.fromJson(responseData['comment']);
      } else {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } catch (e) {
      print("[ERROR] Exception adding comment: $e");
      throw Exception('Error adding comment: $e');
    }
  }

  /// Delete a comment
  static Future<void> deleteComment({
    required int postId,
    required int commentId,
  }) async {
    try {
      print("[INFO] Deleting comment: $commentId from post: $postId");

      final response = await http.delete(
        Uri.parse('$baseUrl/api/posts/$postId/comments/$commentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete comment: ${response.statusCode}');
      }

      print("[SUCCESS] Comment deleted: $commentId");
    } catch (e) {
      print("[ERROR] Exception deleting comment: $e");
      throw Exception('Error deleting comment: $e');
    }
  }

  /// Get replies for a comment
  static Future<List<CommentReply>> getReplies(int commentId) async {
    try {
      print("[INFO] Fetching replies for comment: $commentId");

      final response = await http.get(
        Uri.parse('$baseUrl/api/comments/$commentId/replies'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> repliesJson = responseData['replies'] ?? [];
        return repliesJson.map((json) => CommentReply.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load replies: ${response.statusCode}');
      }
    } catch (e) {
      print("[ERROR] Exception fetching replies: $e");
      throw Exception('Error fetching replies: $e');
    }
  }

  /// Add a reply to a comment
  static Future<CommentReply> addReply({
    required int commentId,
    required String username,
    required String content,
  }) async {
    try {
      print("[INFO] Adding reply to comment: $commentId by user: $username");

      final response = await http.post(
        Uri.parse('$baseUrl/api/comments/$commentId/replies'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print("[SUCCESS] Reply added with ID: ${responseData['reply']['id']}");
        return CommentReply.fromJson(responseData['reply']);
      } else {
        throw Exception('Failed to add reply: ${response.statusCode}');
      }
    } catch (e) {
      print("[ERROR] Exception adding reply: $e");
      throw Exception('Error adding reply: $e');
    }
  }

  /// Delete a reply
  static Future<void> deleteReply({
    required int commentId,
    required int replyId,
  }) async {
    try {
      print("[INFO] Deleting reply: $replyId from comment: $commentId");

      final response = await http.delete(
        Uri.parse('$baseUrl/api/comments/$commentId/replies/$replyId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete reply: ${response.statusCode}');
      }

      print("[SUCCESS] Reply deleted: $replyId");
    } catch (e) {
      print("[ERROR] Exception deleting reply: $e");
      throw Exception('Error deleting reply: $e');
    }
  }
}
