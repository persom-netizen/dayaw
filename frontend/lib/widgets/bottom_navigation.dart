import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom Bottom Navigation Bar with Modern Design
///
/// Design Specifications:
/// - Container: Yellow (#FFDF00), pill-shaped (border-radius: 100)
/// - Buttons: Soft rounded, drop shadow (down), inside shadow (up)
/// - Icons & Text: #7B3820 color
/// - Active State: Full opacity
/// - Inactive State: 50% opacity
class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  // Design color constants
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color navIconColor = Color(0xFF7B3820);
  static const Color backgroundColor = Color(0xFFFFF9F4);

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          color: primaryYellow,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'Bahay',
              isActive: currentIndex == 0,
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.school_rounded,
              label: 'Matuto',
              isActive: currentIndex == 1,
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.person_rounded,
              label: 'Juan',
              isActive: currentIndex == 2,
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.settings_rounded,
              label: 'Setting',
              isActive: currentIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    final double opacity = isActive ? 1.0 : 0.5;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          boxShadow: isActive
              ? [
                  // Outer shadow (down)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                  // Inner shadow effect (simulated with gradient)
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.3),
                    blurRadius: 0,
                    offset: const Offset(0, -1),
                  ),
                ]
              : null,
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: opacity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: navIconColor, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: navIconColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
