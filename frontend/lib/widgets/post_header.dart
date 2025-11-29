import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Post Header Widget
/// 
/// Displays:
/// - User avatar (circular profile picture)
/// - Username (@yulbi_seif format)
/// - Timestamp: "{X days ago | HH:MM}" (50% opacity text)
/// - Delete button (trash icon, outlined yellow, drop shadow)
class PostHeader extends StatelessWidget {
  final String username;
  final String? profileImage;
  final DateTime createdAt;
  final VoidCallback? onUserTap;
  final VoidCallback? onDelete;
  final bool showDeleteButton;

  // Design color constants
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);

  const PostHeader({
    super.key,
    required this.username,
    this.profileImage,
    required this.createdAt,
    this.onUserTap,
    this.onDelete,
    this.showDeleteButton = false,
  });

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      // Format: "X days ago | HH:MM"
      final hours = dateTime.hour.toString().padLeft(2, '0');
      final minutes = dateTime.minute.toString().padLeft(2, '0');
      return '${difference.inDays} araw nakalipas | $hours:$minutes';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} oras nakalipas';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto nakalipas';
    } else {
      return 'Ngayon lang';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // User Avatar with tap animation
        GestureDetector(
          onTap: onUserTap,
          child: Hero(
            tag: 'avatar_$username',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryYellow,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryYellow.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: primaryYellow.withValues(alpha: 0.2),
                backgroundImage: profileImage != null
                    ? NetworkImage(profileImage!)
                    : null,
                child: profileImage == null
                    ? Text(
                        username.isNotEmpty ? username[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Username and Timestamp
        Expanded(
          child: GestureDetector(
            onTap: onUserTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@$username',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(createdAt),
                  style: GoogleFonts.inter(
                    color: textColor.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Delete Button
        if (showDeleteButton && onDelete != null)
          _DeleteButton(onTap: onDelete!),
      ],
    );
  }
}

/// Custom Delete Button with outlined yellow style and drop shadow
class _DeleteButton extends StatefulWidget {
  final VoidCallback onTap;

  const _DeleteButton({required this.onTap});

  @override
  State<_DeleteButton> createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<_DeleteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent, // No fill color
                border: Border.all(
                  color: PostHeader.primaryYellow, // Yellow outline only
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                // No shadow/grey effect
              ),
              child: Icon(
                Icons.delete_outline_rounded, // Outline icon
                color: PostHeader.primaryYellow, // Yellow color
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }
}
