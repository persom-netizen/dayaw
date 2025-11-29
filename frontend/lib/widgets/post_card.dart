import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/post_model.dart';
import 'post_header.dart';
import 'post_media.dart';
import 'post_actions.dart';

/// Modern Post Card Widget
/// 
/// Displays a complete post with:
/// - Post Header (Avatar, Username, Timestamp, Delete)
/// - Post Title (Header1 style, #554141)
/// - Post Description (description style, #554141)
/// - Post Media (images with yellow border-radius)
/// - Action Buttons (Like/Star, Comment)
/// - Divider line
/// - Fade-in animation on load
/// - Soft drop shadows
class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onUserTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onDelete;
  final bool showDeleteButton;

  const PostCard({
    super.key,
    required this.post,
    this.onUserTap,
    this.onLike,
    this.onComment,
    this.onDelete,
    this.showDeleteButton = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Design color constants
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              // No background color - blends with page background (#FFF9F4)
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: PostHeader(
                      username: widget.post.username,
                      profileImage: widget.post.profileImage,
                      createdAt: widget.post.createdAt,
                      onUserTap: widget.onUserTap,
                      onDelete: widget.onDelete,
                      showDeleteButton: widget.showDeleteButton,
                    ),
                  ),

                  // Post Title
                  if (widget.post.title != null && widget.post.title!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        widget.post.title!,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.3,
                        ),
                      ),
                    ),

                  // Post Description/Content
                  if (widget.post.content.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: widget.post.title != null && widget.post.title!.isNotEmpty ? 8 : 0,
                        bottom: 12,
                      ),
                      child: Text(
                        widget.post.content,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: textColor,
                          height: 1.5,
                        ),
                      ),
                    ),

                  // Post Media (Images)
                  if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PostMedia(
                        imageUrl: widget.post.imageUrl,
                        height: 200,
                      ),
                    ),

                  // Post Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: PostActions(
                      likesCount: widget.post.likesCount,
                      commentsCount: widget.post.commentsCount,
                      isLiked: widget.post.isLiked,
                      onLike: widget.onLike,
                      onComment: widget.onComment,
                    ),
                  ),

                  // Bottom padding
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // Yellow divider at 50% opacity between posts
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: primaryYellow.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
