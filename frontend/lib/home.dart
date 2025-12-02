import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'ai.dart';
import 'screens/bahay_page.dart';
import 'screens/matuto_page.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
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

  // Design color constants
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BahayPage(username: widget.username), // 0 - Bahay
      MatutoPage(username: widget.username), // 1 - Matuto (unified page)
      AiPage(username: widget.username), // 2 - Juan (AI Chatbot)
      SettingsScreen(username: widget.username), // 3 - Setting
    ];
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Bahay';
      case 1:
        return 'Matuto';
      case 2:
        return 'Juan';
      case 3:
        return 'Setting';
      default:
        return 'Dayaw';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FontProvider, ThemeProvider>(
      builder: (context, fontProvider, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final bgColor = isDark ? const Color(0xFF1F1F1F) : backgroundColor;
        final appBarBgColor = isDark ? const Color(0xFF1F1F1F) : backgroundColor;
        final textColorThemed = isDark ? Colors.white : textColor;
        
        return Scaffold(
          backgroundColor: bgColor,
          appBar: _buildModernAppBar(fontProvider, isDark, appBarBgColor, textColorThemed),
          body: _pages[_selectedIndex],
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: _selectedIndex,
            onTap: _onNavBarTapped,
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildModernAppBar(
    FontProvider fontProvider,
    bool isDark,
    Color appBarBgColor,
    Color textColorThemed,
  ) {
    return AppBar(
      backgroundColor: appBarBgColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primaryYellow.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/logo_yellow.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: primaryYellow,
                    child: Icon(
                      Icons.home_rounded,
                      color: isDark ? textColor : Colors.white,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _getPageTitle(),
            style: GoogleFonts.playfairDisplay(
              fontSize: fontProvider.titleSize,
              fontWeight: FontWeight.bold,
              color: textColorThemed,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {
            // Navigate to user profile
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  username: widget.username,
                  currentUsername: widget.username,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: primaryYellow,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryYellow.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '@${widget.username}',
              style: GoogleFonts.inter(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: fontProvider.descriptionSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
