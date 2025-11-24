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
      _posts = await PostService.getPosts();
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost({
    required String username,
    String? title,
    required String content,
    String? imageUrl,
    XFile? imageFile,
  }) async {
    try {
      String? uploadedImageUrl;

      // If image file is selected, upload it
      if (imageFile != null) {
        uploadedImageUrl = await PostService.uploadImage(imageFile);
      } else if (imageUrl != null && imageUrl.isNotEmpty) {
        uploadedImageUrl = imageUrl;
      }

      final newPost = await PostService.createPost(
        username: username,
        title: title,
        content: content,
        imageUrl: uploadedImageUrl,
      );

      _posts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      await PostService.deletePost(postId);
      _posts.removeWhere((post) => post.id == postId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
