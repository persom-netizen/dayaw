import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';

// The specific categories for your app
enum PostFilter { all, paskil, kard, pod, tunog }

class PostProvider with ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;
  String? _currentUsername;

  // NEW: Track the current active filter
  PostFilter _currentFilter = PostFilter.all;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUsername => _currentUsername;
  
  // NEW: Getter for the UI to know which chip is active
  PostFilter get currentFilter => _currentFilter;

  /// NEW: The core filtering logic used by BahayPage
  List<Post> get filteredPosts {
    if (_currentFilter == PostFilter.all) {
      return _posts;
    }
    return _posts.where((post) {
      // Logic: Matches the post's category to the selected filter name
      return post.category.toLowerCase() == _currentFilter.name.toLowerCase();
    }).toList();
  }

  /// NEW: Method to update the filter and refresh UI
  void setFilter(PostFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

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

  Future<void> createPost({
    required String username,
    String? title,
    required String content,
    String? imageUrl,
    required String category, 
  }) async {
    try {
      print("[INFO] PostProvider: Creating post...");
      final newPost = await PostService.createPost(
        username: username,
        title: title,
        content: content,
        imageUrl: imageUrl,
        category: category,
      );
      _posts.insert(0, newPost);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePost(int postId, {String? username}) async {
    try {
      final user = username ?? _currentUsername;
      if (user == null || user.isEmpty) {
        throw Exception('Username is required to delete a post');
      }
      await PostService.deletePost(postId, username: user);
      _posts.removeWhere((post) => post.id == postId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleLike({required int postId, required String username}) async {
    try {
      final result = await PostService.toggleLike(postId: postId, username: username);
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].isLiked = result['liked'] ?? false;
        _posts[postIndex].likesCount = result['likes_count'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Comment>> getComments(int postId) async => await PostService.getComments(postId);

  Future<Comment> addComment({required int postId, required String username, required String content}) async {
    try {
      final comment = await PostService.addComment(postId: postId, username: username, content: content);
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].commentsCount += 1;
        notifyListeners();
      }
      return comment;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteComment({required int postId, required int commentId, String? username}) async {
    try {
      final user = username ?? _currentUsername;
      await PostService.deleteComment(postId: postId, commentId: commentId, username: user!);
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        _posts[postIndex].commentsCount -= 1;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CommentReply>> getReplies(int commentId) async => await PostService.getReplies(commentId);

  Future<CommentReply> addReply({required int commentId, required String username, required String content}) async {
    final reply = await PostService.addReply(commentId: commentId, username: username, content: content);
    return reply;
  }

  Future<void> deleteReply({required int commentId, required int replyId, String? username}) async {
    final user = username ?? _currentUsername;
    await PostService.deleteReply(commentId: commentId, replyId: replyId, username: user!);
    notifyListeners();
  }
}