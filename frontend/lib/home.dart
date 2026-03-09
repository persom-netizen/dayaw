import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Screens
import 'screens/bahay_page.dart';
import 'screens/analisa_page.dart'; 
import 'screens/tipaan_page.dart';  
import 'screens/matuto_page.dart';
import 'screens/settings_screen.dart';
// Widgets & Providers
import 'widgets/bottom_navigation.dart';
import 'providers/font_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/post_provider.dart';

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
      case 1: return 'Analisa';
      case 2: return 'Matuto';
      case 3: return 'Tipaan';
      case 4: return 'Setting';
      default: return 'Dayaw';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<FontProvider, ThemeProvider, PostProvider>(
      builder: (context, font, theme, postProvider, child) {
        final isDark = theme.isDarkMode;
        final bgColor = isDark ? const Color(0xFF1F1F1F) : const Color(0xFFFFF9F4);
        final textColor = isDark ? Colors.white : const Color(0xFF554141);

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            toolbarHeight: 80,
            automaticallyImplyLeading: false,
            // We use a clean Row approach for perfect centering
            title: _selectedIndex == 0 
                ? _buildFilterBar(postProvider) 
                : Text(
                    _getPageTitle(),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: font.titleSize,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
            centerTitle: true,
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

  /// Fixed Alignment: Logo is centered, Chips are distributed left and right
 Widget _buildFilterBar(PostProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. LEFT GROUP
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _filterChip(provider, PostFilter.paskil, 'Paskil'),
              _filterChip(provider, PostFilter.kard, 'Kard'),
            ],
          ),

          // 2. CENTER LOGO (The "Lahat" button)
          GestureDetector(
            onTap: () => provider.setFilter(PostFilter.all),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: provider.currentFilter == PostFilter.all ? 1.0 : 0.4,
                  child: Image.asset(
                    'assets/dayawlogo.png',
                    height: 28, // Adjusted height for a cleaner look
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 2),
                // Tiny dot or line to show "Lahat" is active
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 2,
                  width: 12,
                  decoration: BoxDecoration(
                    color: provider.currentFilter == PostFilter.all 
                        ? const Color(0xFFFFDF00) 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),

          // 3. RIGHT GROUP
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _filterChip(provider, PostFilter.pod, 'Pod'),
              _filterChip(provider, PostFilter.tunog, 'Tunog'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(PostProvider provider, PostFilter filter, String label) {
    final isSelected = provider.currentFilter == filter;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2), // Tighter padding for side alignment
      child: ChoiceChip(
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10, // Small font to ensure they stay on the screen edges
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF554141),
          ),
        ),
        selected: isSelected,
        onSelected: (bool selected) {
          provider.setFilter(selected ? filter : PostFilter.all);
        },
        selectedColor: const Color(0xFFFFDF00),
        backgroundColor: Colors.transparent,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? const Color(0xFFFFDF00) : Colors.grey.withOpacity(0.1),
          ),
        ),
      ),
    );
  }
}