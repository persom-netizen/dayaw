import 'salita.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'ai.dart';
import 'alaala.dart';
import 'screens/bahay_page.dart';
import 'screens/sulatin/sulatin_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_navigation.dart';
import 'providers/font_provider.dart';

/// Matuto submenu page options
enum MatutoSubPage { alaala, sulatin, salita }

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  MatutoSubPage? _selectedMatutoSubPage;

  // Design color constants
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);
  static const Color navIconColor = Color(0xFF7B3820);

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BahayPage(username: widget.username), // 0 - Bahay
      AlaalaPage(username: widget.username), // 1 - Alaala (Matuto)
      const SulatinScreen(), // 2 - Sulatin (Matuto)
      SalitaPage(username: widget.username), // 3 - Salita (Matuto)
      AiPage(username: widget.username), // 4 - Juan (AI Chatbot)
      SettingsScreen(username: widget.username), // 5 - Setting
    ];
  }

  void _onNavBarTapped(int index) {
    setState(() {
      if (index == 0) {
        _selectedIndex = 0;
        _selectedMatutoSubPage = null;
      } else if (index == 1) {
        _showMatutoMenu();
      } else if (index == 2) {
        _selectedIndex = 4;
        _selectedMatutoSubPage = null;
      } else if (index == 3) {
        _selectedIndex = 5;
        _selectedMatutoSubPage = null;
      }
    });
  }

  void _showMatutoMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _MatutoMenuSheet(
        selectedSubPage: _selectedMatutoSubPage,
        onSubPageSelected: (subPage) {
          Navigator.pop(context);
          setState(() {
            _selectedMatutoSubPage = subPage;
            switch (subPage) {
              case MatutoSubPage.alaala:
                _selectedIndex = 1;
                break;
              case MatutoSubPage.sulatin:
                _selectedIndex = 2;
                break;
              case MatutoSubPage.salita:
                _selectedIndex = 3;
                break;
            }
          });
        },
      ),
    );
  }

  int _getBottomNavIndex() {
    switch (_selectedIndex) {
      case 0:
        return 0;
      case 1:
      case 2:
      case 3:
        return 1;
      case 4:
        return 2;
      case 5:
        return 3;
      default:
        return 0;
    }
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Bahay';
      case 1:
        return 'Alaala';
      case 2:
        return 'Sulatin';
      case 3:
        return 'Salita';
      case 4:
        return 'Juan';
      case 5:
        return 'Setting';
      default:
        return 'Dayaw';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontProvider>(
      builder: (context, fontProvider, child) {
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: _buildModernAppBar(fontProvider),
          body: _pages[_selectedIndex],
          bottomNavigationBar: CustomBottomNavigation(
            currentIndex: _getBottomNavIndex(),
            onTap: _onNavBarTapped,
            onMatutoTap: _showMatutoMenu,
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildModernAppBar(FontProvider fontProvider) {
    return AppBar(
      backgroundColor: backgroundColor,
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
                    child: const Icon(
                      Icons.home_rounded,
                      color: Colors.white,
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
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = 5;
              _selectedMatutoSubPage = null;
            });
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

class _MatutoMenuSheet extends StatelessWidget {
  final MatutoSubPage? selectedSubPage;
  final Function(MatutoSubPage) onSubPageSelected;

  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);

  const _MatutoMenuSheet({
    required this.selectedSubPage,
    required this.onSubPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FontProvider>(
      builder: (context, fontProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: const BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryYellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: primaryYellow,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Matuto',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: fontProvider.titleSize,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Piliin ang gusto mong aralin',
                  style: GoogleFonts.inter(
                    fontSize: fontProvider.descriptionSize,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      primaryYellow.withValues(alpha: 0.3),
                      primaryYellow.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildMenuItem(
                context,
                icon: Icons.lightbulb_rounded,
                title: 'Alaala',
                subtitle: 'Memory/Flashcards - Mga Trivia',
                isSelected: selectedSubPage == MatutoSubPage.alaala,
                onTap: () => onSubPageSelected(MatutoSubPage.alaala),
                fontProvider: fontProvider,
              ),
              _buildMenuItem(
                context,
                icon: Icons.edit_rounded,
                title: 'Sulatin',
                subtitle: 'Writing - Baybayin Lessons',
                isSelected: selectedSubPage == MatutoSubPage.sulatin,
                onTap: () => onSubPageSelected(MatutoSubPage.sulatin),
                fontProvider: fontProvider,
              ),
              _buildMenuItem(
                context,
                icon: Icons.auto_stories_rounded,
                title: 'Salita',
                subtitle: 'Vocabulary - Salita ng Araw',
                isSelected: selectedSubPage == MatutoSubPage.salita,
                onTap: () => onSubPageSelected(MatutoSubPage.salita),
                fontProvider: fontProvider,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required FontProvider fontProvider,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: primaryYellow.withValues(alpha: 0.2),
          highlightColor: primaryYellow.withValues(alpha: 0.1),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryYellow.withValues(alpha: 0.15)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? primaryYellow
                    : textColor.withValues(alpha: 0.1),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryYellow.withValues(alpha: 0.3)
                        : primaryYellow.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? primaryYellow : textColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.bold,
                          fontSize: fontProvider.header1Size,
                          color: isSelected ? primaryYellow : textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: fontProvider.header4Size,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: isSelected
                      ? primaryYellow
                      : textColor.withValues(alpha: 0.4),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
