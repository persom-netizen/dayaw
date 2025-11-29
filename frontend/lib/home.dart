import 'salita.dart';
import 'package:flutter/material.dart';
import 'ai.dart';
import 'alaala.dart';
import 'bahay.dart';
import 'screens/sulatin/sulatin_screen.dart';
import 'screens/settings_screen.dart';

/// Navigation indices for the new navigation structure:
/// 0 - Bahay (Home/Feed)
/// 1 - Matuto submenu pages (Alaala, Sulatin, Salita)
///     1 - Alaala (Memory/Flashcards)
///     2 - Sulatin (Writing)
///     3 - Salita (Vocabulary)
/// 4 - Juan (AI Chat/Profile)
/// 5 - Setting (Settings)
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

  // Page indices:
  // 0 - Bahay
  // 1 - Alaala (Matuto submenu)
  // 2 - Sulatin (Matuto submenu)
  // 3 - Salita (Matuto submenu)
  // 4 - Juan
  // 5 - Setting
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BahayPage(username: widget.username),        // 0 - Bahay
      AlaalaPage(username: widget.username),       // 1 - Alaala (Matuto)
      const SulatinScreen(),                       // 2 - Sulatin (Matuto)
      SalitaPage(username: widget.username),       // 3 - Salita (Matuto)
      AiPage(username: widget.username),           // 4 - Juan
      SettingsScreen(username: widget.username),   // 5 - Setting
    ];
  }

  void _onNavBarTapped(int index) {
    if (index == 1) {
      // Matuto button - show dropdown menu
      _showMatutoMenu();
    } else {
      setState(() {
        // Map bottom nav index to page index
        // 0 -> 0 (Bahay)
        // 2 -> 4 (Juan)
        // 3 -> 5 (Setting)
        if (index == 0) {
          _selectedIndex = 0;
          _selectedMatutoSubPage = null;
        } else if (index == 2) {
          _selectedIndex = 4;
          _selectedMatutoSubPage = null;
        } else if (index == 3) {
          _selectedIndex = 5;
          _selectedMatutoSubPage = null;
        }
      });
    }
  }

  void _showMatutoMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
    // Convert page index to bottom nav index
    switch (_selectedIndex) {
      case 0:
        return 0; // Bahay
      case 1:
      case 2:
      case 3:
        return 1; // Matuto (any subpage)
      case 4:
        return 2; // Juan
      case 5:
        return 3; // Setting
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DAYAW"),
        centerTitle: true,
        backgroundColor: Colors.blue[600],
        automaticallyImplyLeading: false,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getBottomNavIndex(),
        onTap: _onNavBarTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'bahay'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'matuto'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'juan'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'setting'),
        ],
      ),
    );
  }
}

/// Bottom sheet menu for Matuto submenu options
class _MatutoMenuSheet extends StatelessWidget {
  final MatutoSubPage? selectedSubPage;
  final Function(MatutoSubPage) onSubPageSelected;

  const _MatutoMenuSheet({
    required this.selectedSubPage,
    required this.onSubPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.school, color: Colors.blue[600], size: 28),
                const SizedBox(width: 12),
                Text(
                  'Matuto',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),

          // Menu options
          _buildMenuItem(
            context,
            icon: Icons.lightbulb,
            title: 'Alaala',
            subtitle: 'Memory/Flashcards - Mga Trivia',
            isSelected: selectedSubPage == MatutoSubPage.alaala,
            onTap: () => onSubPageSelected(MatutoSubPage.alaala),
          ),
          _buildMenuItem(
            context,
            icon: Icons.edit,
            title: 'Sulatin',
            subtitle: 'Writing - Baybayin Lessons',
            isSelected: selectedSubPage == MatutoSubPage.sulatin,
            onTap: () => onSubPageSelected(MatutoSubPage.sulatin),
          ),
          _buildMenuItem(
            context,
            icon: Icons.auto_stories,
            title: 'Salita',
            subtitle: 'Vocabulary - Salita ng Araw',
            isSelected: selectedSubPage == MatutoSubPage.salita,
            onTap: () => onSubPageSelected(MatutoSubPage.salita),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.blue[600] : Colors.grey[600],
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.blue[600] : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Colors.blue[600])
          : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
