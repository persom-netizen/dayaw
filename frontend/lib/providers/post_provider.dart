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
  Future<void> deletePost(int postId, {String? username}) async {
    try {
      final user = username ?? _currentUsername;
      if (user == null || user.isEmpty) {
        throw Exception('Username is required to delete a post');
      }
      print("[INFO] PostProvider: Deleting post: $postId by user: $user");
      await PostService.deletePost(postId, username: user);
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
    String? username,
  }) async {
    try {
      final user = username ?? _currentUsername;
      if (user == null || user.isEmpty) {
        throw Exception('Username is required to delete a comment');
      }
      print("[INFO] PostProvider: Deleting comment: $commentId by user: $user");
      await PostService.deleteComment(
        postId: postId,
        commentId: commentId,
        username: user,
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

  /// Get replies for a comment
  Future<List<CommentReply>> getReplies(int commentId) async {
    try {
      print("[INFO] PostProvider: Getting replies for comment: $commentId");
      final replies = await PostService.getReplies(commentId);
      print("[SUCCESS] PostProvider: Got ${replies.length} replies");
      return replies;
    } catch (e) {
      print("[ERROR] PostProvider: Error getting replies: $e");
      rethrow;
    }
  }

  /// Add a reply to a comment
  Future<CommentReply> addReply({
    required int commentId,
    required String username,
    required String content,
  }) async {
    try {
      print("[INFO] PostProvider: Adding reply to comment: $commentId");
      final reply = await PostService.addReply(
        commentId: commentId,
        username: username,
        content: content,
      );
      
      _error = null;
      print("[SUCCESS] PostProvider: Reply added successfully");
      return reply;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print("[ERROR] PostProvider: Error adding reply: $e");
      rethrow;
    }
  }

  /// Delete a reply
  Future<void> deleteReply({
    required int commentId,
    required int replyId,
    String? username,
  }) async {
    try {
      final user = username ?? _currentUsername;
      if (user == null || user.isEmpty) {
        throw Exception('Username is required to delete a reply');
      }
      print("[INFO] PostProvider: Deleting reply: $replyId by user: $user");
      await PostService.deleteReply(
        commentId: commentId,
        replyId: replyId,
        username: user,
      );
      
      _error = null;
      print("[SUCCESS] PostProvider: Reply deleted successfully");
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      print("[ERROR] PostProvider: Error deleting reply: $e");
      rethrow;
    }
  }
}
