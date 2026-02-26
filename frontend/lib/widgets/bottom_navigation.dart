// widgets/bottom_navigation.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryYellow = Color(0xFFFFDF00);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: primaryYellow,
          borderRadius: BorderRadius.circular(35),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(0, 'assets/BAHAY.png', 'Bahay'),
            _navItem(1, 'assets/ANALISA.png', 'Analisa'),
            _navItem(2, 'assets/SULATIN.png', 'Matuto'), // Swapped to Index 2
            _navItem(3, 'assets/TIPAAN.png', 'Tipaan'),  // Swapped to Index 3
            _navItem(4, 'assets/PROFILE.png', 'Setting'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, String imagePath, String label) {
    bool active = currentIndex == index;
    const Color navColor = Color(0xFF7B3820);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: active ? 1.0 : 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 22,
                height: 22,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.broken_image, size: 22, color: navColor),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: navColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}