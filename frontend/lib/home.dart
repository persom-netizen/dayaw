import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Imports ng iyong mga pages
import 'analisa.dart';
import 'screens/bahay_page.dart';
import 'screens/matuto_page.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/camera_detector_page.dart'; // Siguraduhing ginawa mo itong file na ito
import 'widgets/bottom_navigation.dart';

// Imports ng mga providers
import 'providers/font_provider.dart';
import 'providers/theme_provider.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BahayPage(username: widget.username),       // Index 0
      MatutoPage(username: widget.username),      // Index 1
      AnalisaPage(username: widget.username),     // Index 2 (Profile/Stats view)
      SettingsScreen(username: widget.username),   // Index 3
    ];
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Eto ang function na magbubukas ng mismong Camera Detector screen
  void _onCameraAction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraDetectorPage(),
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0: return 'Bahay';
      case 1: return 'Matuto';
      case 2: return 'Analisa';
      case 3: return 'Setting';
      default: return 'Dayaw';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FontProvider, ThemeProvider>(
      builder: (context, fontProvider, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final bgColor = isDark ? const Color(0xFF1F1F1F) : backgroundColor;
        final textColorThemed = isDark ? Colors.white : textColor;
        
        return Scaffold(
          backgroundColor: bgColor,
          appBar: _buildModernAppBar(fontProvider, isDark, bgColor, textColorThemed),
          // IndexedStack para hindi mag-reset ang state ng bawat tab
          body: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: _selectedIndex,
            onTap: _onNavBarTapped,
            onCameraTap: _onCameraAction, // Bubuksan ang CameraDetectorPage
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildModernAppBar(FontProvider font, bool isDark, Color bg, Color txt) {
    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              'assets/logo_yellow.png', 
              width: 35, 
              height: 35, 
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.star, color: primaryYellow),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _getPageTitle(),
            style: GoogleFonts.playfairDisplay(
              fontSize: font.titleSize,
              fontWeight: FontWeight.bold,
              color: txt,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (_) => ProfileScreen(
                username: widget.username, 
                currentUsername: widget.username
              ),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: primaryYellow,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Center(
              child: Text(
                '@${widget.username}', 
                style: GoogleFonts.inter(
                  color: textColor, 
                  fontWeight: FontWeight.bold, 
                  fontSize: font.descriptionSize * 0.9
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}