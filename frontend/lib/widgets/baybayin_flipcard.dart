import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/baybayin_letter.dart';

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
    final isVowel = widget.letter.type == 'vowel';
    final primaryColor = isVowel ? Colors.blue : Colors.purple;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: primaryColor[300]!, width: 3),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor[50]!,
              Colors.white,
              primaryColor[50]!,
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
                color: primaryColor[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isVowel ? 'Patinig' : 'Katinig',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor[800],
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
                color: primaryColor[700],
                shadows: [
                  Shadow(
                    color: primaryColor[200]!,
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
                Icon(Icons.touch_app, size: 18, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Text(
                  'I-tap para makita ang Baybayin',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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
    final isVowel = widget.letter.type == 'vowel';
    final primaryColor = isVowel ? Colors.blue : Colors.purple;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: primaryColor[600]!, width: 3),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor[600]!,
              primaryColor[400]!,
              primaryColor[600]!,
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
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.letter.description ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Baybayin character
            Text(
              widget.letter.baybayin,
              style: const TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
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
              ),
              child: Text(
                widget.letter.romanized,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor[700],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Hint to flip back
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.touch_app, size: 18, color: Colors.white70),
                const SizedBox(width: 8),
                const Text(
                  'I-tap para bumalik',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
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
