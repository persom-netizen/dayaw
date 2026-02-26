import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TipaanPage extends StatelessWidget {
  final String username;
  const TipaanPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F4),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.keyboard_command_key_rounded, size: 80, color: Color(0xFFFFDF00)),
            const SizedBox(height: 20),
            Text(
              'TIPAAN UNDER MAINTENANCE',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, 
                color: const Color(0xFF7B3820),
                letterSpacing: 1.2
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Text(
                'Kasalukuyan naming inihahanda ang Tipaan para sa mas magandang karanasan.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}