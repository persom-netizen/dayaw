class Post {
  final int? id;
  final String username;
  final String? profileImage;
  final String? title;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;

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
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
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
    };
  }
}
