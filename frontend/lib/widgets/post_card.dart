import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/post_model.dart';
import '../providers/font_provider.dart';
import 'post_media.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final bool showDeleteButton;
  final VoidCallback? onUserTap;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onCommentsTap;

  const PostCard({
    super.key,
    required this.post,
    this.showDeleteButton = false,
    this.onUserTap,
    this.onDeleteTap,
    this.onCommentsTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);

  @override
  Widget build(BuildContext context) {
    return Consumer<FontProvider>(
      builder: (context, fontProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onUserTap,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryYellow,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            widget.post.username.isNotEmpty
                                ? widget.post.username[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: fontProvider.header1Size,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: widget.onUserTap,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '@${widget.post.username}',
                              style: GoogleFonts.inter(
                                fontSize: fontProvider.descriptionSize,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            Text(
                              '${widget.post.daysAgo} days ago | ${widget.post.time}',
                              style: GoogleFonts.inter(
                                fontSize: fontProvider.header4Size,
                                color: textColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.showDeleteButton)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: primaryYellow,
                          size: 20,
                        ),
                        onPressed: widget.onDeleteTap,
                      )
                    else
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: primaryYellow, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.bookmark_border,
                          color: primaryYellow,
                        ),
                      ),
                  ],
                ),
              ),
              // Post Title
              if (widget.post.title != null && widget.post.title!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.post.title!,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: fontProvider.titleSize,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      height: 1.3,
                    ),
                  ),
                ),
              // Post Content
              if (widget.post.content.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top:
                        widget.post.title != null &&
                            widget.post.title!.isNotEmpty
                        ? 8
                        : 0,
                    bottom: 12,
                  ),
                  child: Text(
                    widget.post.content,
                    style: GoogleFonts.inter(
                      fontSize: fontProvider.descriptionSize,
                      color: textColor,
                      height: 1.5,
                    ),
                  ),
                ),
              // Post Media
              if (widget.post.imageUrl != null &&
                  widget.post.imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PostMedia(imageUrl: widget.post.imageUrl, height: 200),
                ),
              // Post Actions
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(Icons.star_outline, color: primaryYellow, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.post.likesCount}',
                      style: GoogleFonts.inter(
                        fontSize: fontProvider.descriptionSize,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.chat_bubble_outline,
                      color: primaryYellow,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.post.commentsCount}',
                      style: GoogleFonts.inter(
                        fontSize: fontProvider.descriptionSize,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Divider(
                  color: primaryYellow.withValues(alpha: 0.5),
                  thickness: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
