import 'package:flutter/material.dart';

class AnalisaPage extends StatelessWidget {
  // ✅ Add this line to receive the username
  final String username; 

  // ✅ Update the constructor to include username
  const AnalisaPage({super.key, required this.username}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. THE CAMERA VIEW (Placeholder)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, color: Colors.white, size: 50),
                const SizedBox(height: 10),
                Text(
                  "Handa ka na ba, $username?", // Using the username here!
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),

          // 2. CLOSE BUTTON
          // Note: If this is a tab in IndexedStack, pop might close the whole app.
          // You might want to remove this button if it's strictly a bottom-nav tab.
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),

          // 3. INTERNAL PAGE NAVIGATION
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _internalAction(Icons.photo_library, "Gallery", () {
                    print("Open Gallery");
                  }),

                  // MIDDLE: Main Capture
                  GestureDetector(
                    onTap: () => print("Captured!"),
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      ),
                    ),
                  ),

                  _internalAction(Icons.flip_camera_ios, "Flip", () {
                    print("Camera Flipped");
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _internalAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}