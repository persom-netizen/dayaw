class Post {
  final int? id;
  final String username;
  final String? profileImage;
  final String? title;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  int likesCount;
  int commentsCount;
  bool isLiked;

  Post({
    this.id,
    required this.username,
    this.profileImage,
    this.title,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      username: json['username'] ?? 'Anonymous',
      profileImage: json['profile_image'],
      title: json['title'],
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'profile_image': profileImage,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'is_liked': isLiked,
    };
  }

  Post copyWith({
    int? id,
    String? username,
    String? profileImage,
    String? title,
    String? content,
    String? imageUrl,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}


class Comment {
  final int id;
  final int postId;
  final String username;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.username,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['post_id'],
      username: json['username'] ?? 'Anonymous',
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'username': username,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
