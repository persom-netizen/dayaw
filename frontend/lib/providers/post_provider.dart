import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print("[INFO] Loading posts...");
      _posts = await PostService.getPosts();
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      print("[SUCCESS] Posts loaded: ${_posts.length}");
    } catch (e) {
      _error = e.toString();
      print("[ERROR] Error loading posts: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upload image to backend
  Future<String> uploadImage(XFile imageFile) async {
    try {
      print("[INFO] PostProvider: Uploading image...");
      final imageUrl = await PostService.uploadImage(imageFile);
      print("[SUCCESS] PostProvider: Image uploaded successfully");
      return imageUrl;
    } catch (e) {
      print("[ERROR] PostProvider: Error uploading image: $e");
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Create post
  Future<void> createPost({
    required String username,
    String? title,
    required String content,
    String? imageUrl,
  }) async {
    try {
      print("[INFO] PostProvider: Creating post...");
      final newPost = await PostService.createPost(
        username: username,
        title: title,
        content: content,
        imageUrl: imageUrl,
      );
      _posts.insert(0, newPost);
      _error = null;
      notifyListeners();
      print("[SUCCESS] PostProvider: Post created successfully");
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print("[ERROR] PostProvider: Error creating post: $e");
      rethrow;
    }
  }

  /// Delete post
  Future<void> deletePost(int postId) async {
    try {
      print("[INFO] PostProvider: Deleting post: $postId");
      await PostService.deletePost(postId);
      _posts.removeWhere((post) => post.id == postId);
      _error = null;
      notifyListeners();
      print("[SUCCESS] PostProvider: Post deleted successfully");
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print("[ERROR] PostProvider: Error deleting post: $e");
      rethrow;
    }
  }
}
