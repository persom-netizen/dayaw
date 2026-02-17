import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onCameraTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryYellow = Color(0xFFFFDF00);
    const Color navColor = Color(0xFF7B3820);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: primaryYellow,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(0, Icons.home_rounded, 'Bahay'),
            _navItem(1, Icons.school_rounded, 'Matuto'),
            
            // Middle Action Button
            GestureDetector(
              onTap: onCameraTap,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: navColor, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, color: primaryYellow),
              ),
            ),

            _navItem(2, Icons.person_rounded, 'Analisa'),
            _navItem(3, Icons.settings_rounded, 'Setting'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    bool active = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Opacity(
        opacity: active ? 1.0 : 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF7B3820), size: 24),
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF7B3820))),
          ],
        ),
      ),
    );
  }
}