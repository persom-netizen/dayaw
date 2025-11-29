import 'package:flutter/material.dart';

/// Post Actions Widget
/// 
/// Displays action buttons:
/// - Star icon (outlined yellow, soft rounded)
/// - Comment icon (outlined yellow, soft rounded)
/// - Smooth icon animations (star fill on like)
/// - Ripple effect on buttons
class PostActions extends StatelessWidget {
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  // Design color constants
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);

  const PostActions({
    super.key,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    this.onLike,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Like/Star Button
        _ActionButton(
          icon: isLiked ? Icons.star_rounded : Icons.star_outline_rounded,
          label: likesCount.toString(),
          isActive: isLiked,
          onTap: onLike,
          activeColor: primaryYellow,
          inactiveColor: primaryYellow,
        ),
        const SizedBox(width: 24),
        // Comment Button
        _ActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: commentsCount.toString(),
          isActive: false,
          onTap: onComment,
          activeColor: primaryYellow,
          inactiveColor: primaryYellow,
        ),
      ],
    );
  }
}

/// Custom Action Button with animations and effects
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final Color activeColor;
  final Color inactiveColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_ActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation when liked state changes
    if (widget.isActive != oldWidget.isActive && widget.isActive) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = widget.isActive ? widget.activeColor : widget.inactiveColor;
    
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: widget.activeColor.withValues(alpha: 0.2),
          highlightColor: widget.activeColor.withValues(alpha: 0.1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? widget.activeColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isActive
                    ? widget.activeColor
                    : widget.inactiveColor.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: _isPressed
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Icon(
                        widget.icon,
                        size: 22,
                        color: iconColor,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
