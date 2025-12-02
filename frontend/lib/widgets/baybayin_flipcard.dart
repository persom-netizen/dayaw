import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/baybayin_letter.dart';

// Design color constants - unified yellow theme
const Color _primaryYellow = Color(0xFFFFDF00);
const Color _textColor = Color(0xFF554141);
const Color _backgroundColor = Color(0xFFFFF9F4);

/// A reusable flipcard widget for displaying Baybayin letters
/// Shows romanized letter on front, Baybayin character on back
class BaybayinFlipcard extends StatefulWidget {
  /// The Baybayin letter to display
  final BaybayinLetter letter;

  /// Optional callback when card is flipped
  final VoidCallback? onFlip;

  /// Whether the card starts flipped (showing Baybayin side)
  final bool initiallyFlipped;

  const BaybayinFlipcard({
    super.key,
    required this.letter,
    this.onFlip,
    this.initiallyFlipped = false,
  });

  @override
  State<BaybayinFlipcard> createState() => _BaybayinFlipcardState();
}

class _BaybayinFlipcardState extends State<BaybayinFlipcard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _isFlipped = widget.initiallyFlipped;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (_isFlipped) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
    widget.onFlip?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final showFront = _animation.value < 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showFront
                ? _buildFront()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  /// Build the front side of the card (Romanized letter)
  Widget _buildFront() {
    return Card(
      elevation: 8,
      shadowColor: _primaryYellow.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: _primaryYellow, width: 3),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _primaryYellow.withValues(alpha: 0.15),
              Colors.white,
              _primaryYellow.withValues(alpha: 0.15),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Letter type label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _primaryYellow.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.letter.type == 'vowel' ? 'Patinig' : 'Katinig',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Romanized letter
            Text(
              widget.letter.romanized,
              style: TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.bold,
                color: _textColor,
                shadows: [
                  Shadow(
                    color: _primaryYellow.withValues(alpha: 0.5),
                    offset: const Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Hint to flip
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, size: 18, color: _textColor.withValues(alpha: 0.5)),
                const SizedBox(width: 8),
                Text(
                  'I-tap para makita ang Baybayin',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build the back side of the card (Baybayin character)
  Widget _buildBack() {
    return Card(
      elevation: 8,
      shadowColor: _primaryYellow.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: _primaryYellow, width: 3),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _primaryYellow,
              _primaryYellow.withValues(alpha: 0.8),
              _primaryYellow,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Letter type label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.letter.description ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Baybayin character
            Text(
              widget.letter.baybayin,
              style: TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                color: _textColor,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Romanized equivalent
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.letter.romanized,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Hint to flip back
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, size: 18, color: _textColor.withValues(alpha: 0.7)),
                const SizedBox(width: 8),
                Text(
                  'I-tap para bumalik',
                  style: TextStyle(
                    fontSize: 12,
                    color: _textColor.withValues(alpha: 0.8),
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
