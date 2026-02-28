import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'screens/bahay_page.dart';
import 'screens/analisa_page.dart'; 
import 'screens/tipaan_page.dart';  
import 'screens/matuto_page.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart'; // Ensure this is imported for the chip
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
    // Order matches your latest Home Dart: Bahay, Analisa, Matuto, Tipaan, Settings
    _pages = [
      BahayPage(username: widget.username),
      AnalisaPage(username: widget.username),
      MatutoPage(username: widget.username), 
      TipaanPage(username: widget.username), 
      SettingsScreen(username: widget.username),
    ];
  }

  void _onNavBarTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0: return 'Bahay';
      case 1: return 'Analisa';
      case 2: return 'Matuto';
      case 3: return 'Tipaan';
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
            title: Row(
              children: [
                Image.asset('assets/logo_yellow.png', width: 35, height: 35, 
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.star, color: Colors.amber)),
                const SizedBox(width: 10),
                Text(
                  _getPageTitle(),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: font.titleSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            // --- THE UPPER USER NAV (RESTORING THIS) ---
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ActionChip(
                  backgroundColor: const Color(0xFFFFDF00),
                  label: Text(
                    '@${widget.username}', 
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, 
                      color: const Color(0xFF554141)
                    )
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ProfileScreen(
                        username: widget.username, 
                        currentUsername: widget.username
                      )
                    ));
                  },
                ),
              ),
            ],
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