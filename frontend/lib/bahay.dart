import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/create_post_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/post_provider.dart';
import 'widgets/feed_post_card.dart';
import 'models/post_model.dart';

/// Bahay (Home) - Community Feed Page
/// Displays posts from the community in a Facebook-like feed format
class BahayPage extends StatefulWidget {
  final String username;

  const BahayPage({super.key, required this.username});

  @override
  State<BahayPage> createState() => _BahayPageState();
}

class _BahayPageState extends State<BahayPage> {
  @override
  void initState() {
    super.initState();
    // Load posts when page initializes
    Future.microtask(() {
      final provider = Provider.of<PostProvider>(context, listen: false);
      provider.setCurrentUsername(widget.username);
      provider.loadPosts(username: widget.username);
    });
  }

  void _showCommentsSheet(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _CommentsSheet(
        post: post,
        currentUsername: widget.username,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          if (postProvider.isLoading && postProvider.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (postProvider.error != null && postProvider.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'May error sa pagkuha ng mga post',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    postProvider.error!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => postProvider.loadPosts(username: widget.username),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Subukan Muli'),
                  ),
                ],
              ),
            );
          }

          if (postProvider.posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.post_add, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Walang mga post pa',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Maging una sa paglikha ng post!',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => postProvider.loadPosts(username: widget.username),
            child: ListView.builder(
              itemCount: postProvider.posts.length,
              itemBuilder: (context, index) {
                final post = postProvider.posts[index];
                return FeedPostCard(
                  post: post,
                  onUserTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(
                          username: post.username,
                          currentUsername: widget.username,
                        ),
                      ),
                    );
                  },
                  onLike: post.id != null
                      ? () async {
                          try {
                            await postProvider.toggleLike(
                              postId: post.id!,
                              username: widget.username,
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('May error sa pag-like: $e'),
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  onComment: post.id != null
                      ? () => _showCommentsSheet(post)
                      : null,
                  onDelete: post.username == widget.username && post.id != null
                      ? () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Tanggalin ang Post'),
                              content: const Text(
                                'Sigurado ka bang gusto mong tanggalin ang post na ito?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Kanselahin'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Tanggalin',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            try {
                              await postProvider.deletePost(
                                post.id!,
                                username: widget.username,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Matagumpay na natanggal ang post',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'May error sa pagtanggal ng post: $e',
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        }
                      : null,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreatePostScreen(username: widget.username),
            ),
          );
          // Reload posts after returning from create screen
          if (context.mounted) {
            Provider.of<PostProvider>(context, listen: false).loadPosts(username: widget.username);
          }
        },
        backgroundColor: Colors.blue[600],
        tooltip: 'Lumikha ng post',
        child: const Icon(Icons.add),
      ),
    );
  }
}


/// Bottom sheet for displaying and adding comments
class _CommentsSheet extends StatefulWidget {
  final Post post;
  final String currentUsername;

  const _CommentsSheet({
    required this.post,
    required this.currentUsername,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  int? _replyingToCommentId;
  String? _replyingToUsername;
  Map<int, List<CommentReply>> _repliesCache = {};
  Set<int> _expandedComments = {};

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    if (widget.post.id == null) return;
    
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<PostProvider>(context, listen: false);
      final comments = await provider.getComments(widget.post.id!);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading comments: $e')),
        );
      }
    }
  }

  Future<void> _loadReplies(int commentId) async {
    try {
      final provider = Provider.of<PostProvider>(context, listen: false);
      final replies = await provider.getReplies(commentId);
      setState(() {
        _repliesCache[commentId] = replies;
        _expandedComments.add(commentId);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading replies: $e')),
        );
      }
    }
  }

  void _startReply(int commentId, String username) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToUsername = username;
    });
    _commentController.clear();
  }

  void _cancelReply() {
    setState(() {
      _replyingToCommentId = null;
      _replyingToUsername = null;
    });
    _commentController.clear();
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty || widget.post.id == null) return;

    setState(() => _isSubmitting = true);
    
    try {
      final provider = Provider.of<PostProvider>(context, listen: false);
      
      if (_replyingToCommentId != null) {
        // Adding a reply to a comment
        final newReply = await provider.addReply(
          commentId: _replyingToCommentId!,
          username: widget.currentUsername,
          content: content,
        );
        setState(() {
          if (_repliesCache.containsKey(_replyingToCommentId)) {
            _repliesCache[_replyingToCommentId]!.add(newReply);
          } else {
            _repliesCache[_replyingToCommentId!] = [newReply];
          }
          _expandedComments.add(_replyingToCommentId!);
          _replyingToCommentId = null;
          _replyingToUsername = null;
          _isSubmitting = false;
        });
      } else {
        // Adding a new comment
        final newComment = await provider.addComment(
          postId: widget.post.id!,
          username: widget.currentUsername,
          content: content,
        );
        setState(() {
          _comments.add(newComment);
          _isSubmitting = false;
        });
      }
      _commentController.clear();
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
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

  Widget _buildReplyItem(CommentReply reply) {
    return Padding(
      padding: const EdgeInsets.only(left: 48, top: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.green[200],
            child: Text(
              reply.username.isNotEmpty ? reply.username[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(reply.createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  reply.content,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    final replies = _repliesCache[comment.id] ?? [];
    final isExpanded = _expandedComments.contains(comment.id);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue[200],
            child: Text(
              comment.username.isNotEmpty
                  ? comment.username[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          title: Row(
            children: [
              Text(
                comment.username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTimestamp(comment.createdAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(comment.content),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _startReply(comment.id, comment.username),
                    icon: const Icon(Icons.reply, size: 16),
                    label: const Text('Reply', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  if (!isExpanded)
                    TextButton(
                      onPressed: () => _loadReplies(comment.id),
                      child: Text(
                        'View replies',
                        style: TextStyle(fontSize: 12, color: Colors.blue[600]),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  if (isExpanded && replies.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _expandedComments.remove(comment.id);
                        });
                      },
                      child: Text(
                        'Hide replies (${replies.length})',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        // Show replies if expanded
        if (isExpanded && replies.isNotEmpty)
          ...replies.map((reply) => _buildReplyItem(reply)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mga Komento (${_comments.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Comments list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty
                      ? const Center(
                          child: Text(
                            'Walang komento pa. Maging una!',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            return _buildCommentItem(_comments[index]);
                          },
                        ),
            ),
            
            // Reply indicator
            if (_replyingToCommentId != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.grey[100],
                child: Row(
                  children: [
                    Icon(Icons.reply, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Replying to $_replyingToUsername',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _cancelReply,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            
            // Comment input
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: _replyingToCommentId != null
                            ? 'Write a reply...'
                            : 'Mag-komento...',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSubmitting ? null : _submitComment,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.send, color: Colors.blue[600]),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
