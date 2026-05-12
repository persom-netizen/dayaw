import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/post_card.dart';
import '../models/post_model.dart';
import 'create_post_screen.dart';
import 'profile_screen.dart';

/// Bahay (Home) - Modern Community Feed Page
///
/// Design Specifications:
/// - Background: #FFF9F4
/// - Primary Yellow: #FFDF00
/// - Text Color: #554141
/// - Modern effects & animations
/// - Fade-in animation for posts
/// - Smooth transitions
class BahayPage extends StatefulWidget {
  final String username;

  const BahayPage({super.key, required this.username});

  @override
  State<BahayPage> createState() => _BahayPageState();
}

class _BahayPageState extends State<BahayPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabController;

  // Design color constants
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);
  static const Color navIconColor = Color(0xFF7B3820);

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabController.forward();

    // Load posts when page initializes
    Future.microtask(() {
      final provider = Provider.of<PostProvider>(context, listen: false);
      provider.setCurrentUsername(widget.username);
      provider.loadPosts(username: widget.username);
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _showCommentsSheet(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) =>
          _CommentsSheet(post: post, currentUsername: widget.username),
    );
  }

  @override
Widget build(BuildContext context) {
  return Consumer<ThemeProvider>(
    builder: (context, themeProvider, _) {
      final isDark = themeProvider.isDarkMode;
      final bgColor = isDark ? const Color(0xFF1F1F1F) : backgroundColor;

      return Scaffold(
        backgroundColor: bgColor,
        body: Consumer<PostProvider>(
          builder: (context, postProvider, child) {
            // LOGIC: Use filteredPosts instead of posts
            final displayedPosts = postProvider.filteredPosts;

            if (postProvider.isLoading && displayedPosts.isEmpty) {
              return _buildLoadingState();
            }

            if (postProvider.error != null && displayedPosts.isEmpty) {
              return _buildErrorState(postProvider);
            }

            if (displayedPosts.isEmpty) {
              return _buildEmptyState(postProvider);
            }

            return RefreshIndicator(
              onRefresh: () =>
                  postProvider.loadPosts(username: widget.username),
              color: primaryYellow,
              backgroundColor: isDark
                  ? const Color(0xFF2A2A2A)
                  : Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 100),
                // LOGIC: Use the length of the filtered list
                itemCount: displayedPosts.length,
                itemBuilder: (context, index) {
                  // LOGIC: Access the post from the filtered list
                  final post = displayedPosts[index];
                  return PostCard(
                    post: post,
                    showDeleteButton: post.username == widget.username,
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
                        ? () => _handleLike(postProvider, post)
                        : null,
                    onComment: post.id != null
                        ? () => _showCommentsSheet(post)
                        : null,
                    onDeleteTap:
                        post.username == widget.username && post.id != null
                        ? () => _handleDelete(postProvider, post)
                        : null,
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: ScaleTransition(
          scale: CurvedAnimation(
            parent: _fabController,
            curve: Curves.elasticOut,
          ),
          child: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreatePostScreen(username: widget.username),
                ),
              );
              if (mounted) {
                Provider.of<PostProvider>(
                  context,
                  listen: false,
                ).loadPosts(username: widget.username);
              }
            },
            backgroundColor: primaryYellow,
            elevation: 8,
            child: const Icon(Icons.add_rounded, color: textColor, size: 28),
          ),
        ),
      );
    },
  );
}
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: primaryYellow,
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Kinukuha ang mga post...',
            style: TextStyle(
              fontSize: 16,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(PostProvider postProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryYellow.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: primaryYellow,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'May error sa pagkuha ng mga post',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              postProvider.error ?? '',
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  postProvider.loadPosts(username: widget.username),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Subukan Muli'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryYellow,
                foregroundColor: textColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(PostProvider postProvider) {
    final isFiltered = postProvider.currentFilter != PostFilter.all;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryYellow.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.post_add_rounded,
                size: 64,
                color: primaryYellow,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isFiltered
                  ? 'Walang post para sa ${postProvider.currentFilter.name.toUpperCase()}'
                  : 'Walang mga post pa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Subukang pumili ng ibang filter o i-tap ang logo para makita ang lahat.'
                  : 'Maging una sa paglikha ng post! ',
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (isFiltered) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => postProvider.setFilter(PostFilter.all),
                icon: const Icon(Icons.filter_alt_off_rounded),
                label: const Text('Ipakita ang Lahat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryYellow,
                  foregroundColor: textColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleLike(PostProvider postProvider, Post post) async {
    try {
      await postProvider.toggleLike(
        postId: post.id!,
        username: widget.username,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('May error sa pag-like: $e'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(PostProvider postProvider, Post post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Tanggalin ang Post',
          style: TextStyle(color: textColor),
        ),
        content: const Text(
          'Sigurado ka bang gusto mong tanggalin ang post na ito?',
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Kanselahin',
              style: TextStyle(color: textColor.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Tanggalin'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await postProvider.deletePost(post.id!, username: widget.username);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Matagumpay na natanggal ang post'),
              backgroundColor: Colors.green.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('May error sa pagtanggal ng post: $e'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }
}

/// Bottom sheet for displaying and adding comments
class _CommentsSheet extends StatefulWidget {
  final Post post;
  final String currentUsername;

  const _CommentsSheet({required this.post, required this.currentUsername});

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
  final Map<int, List<CommentReply>> _repliesCache = {};
  final Set<int> _expandedComments = {};

  // Design color constants
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading comments: $e')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading replies: $e')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
            backgroundColor: primaryYellow.withValues(alpha: 0.3),
            child: Text(
              reply.username.isNotEmpty ? reply.username[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
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
                      '@${reply.username}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(reply.createdAt),
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  reply.content,
                  style: const TextStyle(fontSize: 13, color: textColor),
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
            backgroundColor: primaryYellow.withValues(alpha: 0.3),
            child: Text(
              comment.username.isNotEmpty
                  ? comment.username[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          title: Row(
            children: [
              Text(
                '@${comment.username}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatTimestamp(comment.createdAt),
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.5),
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
                child: Text(
                  comment.content,
                  style: const TextStyle(color: textColor),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _startReply(comment.id, comment.username),
                    icon: Icon(
                      Icons.reply_rounded,
                      size: 16,
                      color: primaryYellow,
                    ),
                    label: Text(
                      'Reply',
                      style: TextStyle(fontSize: 12, color: primaryYellow),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  if (!isExpanded)
                    TextButton(
                      onPressed: () => _loadReplies(comment.id),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'View replies',
                        style: TextStyle(fontSize: 12, color: primaryYellow),
                      ),
                    ),
                  if (isExpanded && replies.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _expandedComments.remove(comment.id);
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Hide replies (${replies.length})',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (isExpanded && replies.isNotEmpty)
          ...replies.map((reply) => _buildReplyItem(reply)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mga Komento (${_comments.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(height: 1, color: primaryYellow.withValues(alpha: 0.3)),

              // Comments list
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: primaryYellow),
                      )
                    : _comments.isEmpty
                    ? Center(
                        child: Text(
                          'Walang komento pa.Maging una! ',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.6),
                          ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: primaryYellow.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      Icon(Icons.reply_rounded, size: 16, color: primaryYellow),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Replying to @$_replyingToUsername',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: _cancelReply,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: textColor,
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
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
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
                          hintStyle: TextStyle(
                            color: textColor.withValues(alpha: 0.4),
                          ),
                          filled: true,
                          fillColor: backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        style: const TextStyle(color: textColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: primaryYellow,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryYellow.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _isSubmitting ? null : _submitComment,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: textColor,
                                ),
                              )
                            : const Icon(Icons.send_rounded, color: textColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
