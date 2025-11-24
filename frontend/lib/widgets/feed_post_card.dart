import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post_model.dart';

class FeedPostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onDelete;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const FeedPostCard({
    super.key,
    required this.post,
    this.onDelete,
    this.onLike,
    this.onComment,
  });

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with profile image, username, and timestamp
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue[200],
                  backgroundImage: post.profileImage != null
                      ? NetworkImage(post.profileImage!)
                      : null,
                  child: post.profileImage == null
                      ? Text(
                          post.username.isNotEmpty
                              ? post.username[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatTimestamp(post.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    color: Colors.grey[600],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Title (if present)
            if (post.title != null && post.title!.isNotEmpty) ...[
              Text(
                post.title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // Content
            Text(
              post.content,
              style: const TextStyle(fontSize: 15),
            ),
            
            // Image (if present)
            if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            // Interaction elements (likes, comments)
            const SizedBox(height: 12),
            Row(
              children: [
                // Like button
                InkWell(
                  onTap: onLike,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          post.isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: post.isLiked ? Colors.red : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.likesCount}',
                          style: TextStyle(
                            color: post.isLiked ? Colors.red : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Comment button
                InkWell(
                  onTap: onComment,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.comment_outlined, size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${post.commentsCount}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
