import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUsername;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUsername => _currentUsername;

  void setCurrentUsername(String username) {
    _currentUsername = username;
  }

  Future<void> loadPosts({String? username}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print("[INFO] Loading posts...");
      _posts = await PostService.getPosts(username: username ?? _currentUsername);
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

  /// Toggle like on a post
  Future<void> toggleLike({
    required int postId,
    required String username,
  }) async {
    try {
      print("[INFO] PostProvider: Toggling like for post: $postId");
      final result = await PostService.toggleLike(
        postId: postId,
        username: username,
      );
      
      // Update the post in the list
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].isLiked = result['liked'] ?? false;
        _posts[postIndex].likesCount = result['likes_count'] ?? 0;
        notifyListeners();
      }
      
      _error = null;
      print("[SUCCESS] PostProvider: Like toggled successfully");
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print("[ERROR] PostProvider: Error toggling like: $e");
      rethrow;
    }
  }

  /// Get comments for a post
  Future<List<Comment>> getComments(int postId) async {
    try {
      print("[INFO] PostProvider: Getting comments for post: $postId");
      final comments = await PostService.getComments(postId);
      print("[SUCCESS] PostProvider: Got ${comments.length} comments");
      return comments;
    } catch (e) {
      print("[ERROR] PostProvider: Error getting comments: $e");
      rethrow;
    }
  }

  /// Add a comment to a post
  Future<Comment> addComment({
    required int postId,
    required String username,
    required String content,
  }) async {
    try {
      print("[INFO] PostProvider: Adding comment to post: $postId");
      final comment = await PostService.addComment(
        postId: postId,
        username: username,
        content: content,
      );
      
      // Update the post's comments count
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].commentsCount += 1;
        notifyListeners();
      }
      
      _error = null;
      print("[SUCCESS] PostProvider: Comment added successfully");
      return comment;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print("[ERROR] PostProvider: Error adding comment: $e");
      rethrow;
    }
  }

  /// Delete a comment
  Future<void> deleteComment({
    required int postId,
    required int commentId,
  }) async {
    try {
      print("[INFO] PostProvider: Deleting comment: $commentId");
      await PostService.deleteComment(
        postId: postId,
        commentId: commentId,
      );
      
      // Update the post's comments count
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final currentCount = _posts[postIndex].commentsCount;
        _posts[postIndex].commentsCount = currentCount > 0 ? currentCount - 1 : 0;
        notifyListeners();
      }
      
      _error = null;
      print("[SUCCESS] PostProvider: Comment deleted successfully");
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print("[ERROR] PostProvider: Error deleting comment: $e");
      rethrow;
    }
  }
}
