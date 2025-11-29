import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/font_provider.dart';

/// Flippable card widget for displaying Word of the Day (Salita ngayon)
///
/// Design Specifications:
/// - Soft rounded corners with drop shadow
/// - Background color: FFDF00 with glassmorphism effect
/// - Front: "Salita ngayon" + "alamin!" with tap indicator
/// - Back: Complete word details (salita, depinisyon, etc.)
/// - Flippable card animation on tap
class SalitaCardFlip extends StatefulWidget {
  final Map<String, dynamic>? salitaData;
  final bool isLoading;
  final FontProvider fontProvider;
  final VoidCallback? onLongPress;

  const SalitaCardFlip({
    super.key,
    required this.salitaData,
    required this.isLoading,
    required this.fontProvider,
    this.onLongPress,
  });

  @override
  State<SalitaCardFlip> createState() => _SalitaCardFlipState();
}

class _SalitaCardFlipState extends State<SalitaCardFlip>
    with SingleTickerProviderStateMixin {
  // Design color constants
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);

  bool _isFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * pi;
          final showFront = angle < pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showFront
                ? _buildFrontCard()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildBackCard(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFrontCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Glassmorphism effect
        color: primaryYellow.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryYellow.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative thick rounded line at the top
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: primaryYellow,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 20),
          // "Salita ngayon" text
          Text(
            'Salita ngayon',
            style: GoogleFonts.playfairDisplay(
              fontSize: widget.fontProvider.header1Size,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          // "iyong buksan!" text with tap indicator
          Row(
            children: [
              Text(
                'iyong buksan!',
                style: GoogleFonts.inter(
                  fontSize: widget.fontProvider.descriptionSize,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.touch_app_rounded,
                color: textColor.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryYellow.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryYellow.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: widget.isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: primaryYellow),
              ),
            )
          : widget.salitaData == null
              ? _buildNoDataWidget()
              : _buildSalitaDetails(),
    );
  }

  Widget _buildNoDataWidget() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 40,
              color: textColor.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              'Walang Salita ngayong araw',
              style: GoogleFonts.inter(
                fontSize: widget.fontProvider.descriptionSize,
                color: textColor.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalitaDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Decorative thick rounded line at the top
        Container(
          width: 60,
          height: 6,
          decoration: BoxDecoration(
            color: primaryYellow,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 16),
        // Salita (Word)
        Text(
          'Salita',
          style: GoogleFonts.inter(
            fontSize: widget.fontProvider.header4Size,
            fontWeight: FontWeight.w600,
            color: textColor.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.salitaData?['salita'] ?? 'N/A',
          style: GoogleFonts.playfairDisplay(
            fontSize: widget.fontProvider.header1Size + 4,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        // Kahulugan (Meaning)
        Text(
          'Kahulugan',
          style: GoogleFonts.inter(
            fontSize: widget.fontProvider.header4Size,
            fontWeight: FontWeight.w600,
            color: textColor.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.salitaData?['depinisyon'] ?? 'N/A',
          style: GoogleFonts.inter(
            fontSize: widget.fontProvider.descriptionSize,
            color: textColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
