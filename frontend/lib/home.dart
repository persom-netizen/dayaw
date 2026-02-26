// home_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'screens/bahay_page.dart';
import 'screens/analisa_page.dart'; 
import 'screens/tipaan_page.dart';  
import 'screens/matuto_page.dart';
import 'screens/settings_screen.dart';
import 'widgets/bottom_navigation.dart';
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
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Swapped the order here to match the Nav Bar
    _pages = [
      BahayPage(username: widget.username),      // Index 0
      AnalisaPage(username: widget.username),    // Index 1
      MatutoPage(username: widget.username),     // Index 2 (Now Matuto)
      TipaanPage(username: widget.username),     // Index 3 (Now Tipaan)
      SettingsScreen(username: widget.username), // Index 4
    ];
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0: return 'Bahay';
      case 1: return 'Analisa';
      case 2: return 'Matuto'; // Updated to match Index 2
      case 3: return 'Tipaan'; // Updated to match Index 3
      case 4: return 'Setting';
      default: return 'Dayaw';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FontProvider, ThemeProvider>(
      builder: (context, font, theme, child) {
        final isDark = theme.isDarkMode;
        final bgColor = isDark ? const Color(0xFF1F1F1F) : const Color(0xFFFFF9F4);
        final textColor = isDark ? Colors.white : const Color(0xFF554141);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              _getPageTitle(),
              style: GoogleFonts.playfairDisplay(
                fontSize: font.titleSize,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: _selectedIndex,
            onTap: _onNavBarTapped,
          ),
        );
      },
    );
  }
}