import 'salita.dart';
import 'package:flutter/material.dart';
import 'ai.dart';
import 'alaala.dart';
import 'bahay.dart';
import 'screens/sulatin/sulatin_screen.dart';

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
      AiPage(username: widget.username),
      SalitaPage(username: widget.username),
      AlaalaPage(username: widget.username),
      const SulatinScreen(),
    ];
  }

  void _onNavBarTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DAYAW"),
        centerTitle: true,
        backgroundColor: Colors.blue[600],
        automaticallyImplyLeading: false, // ✅ REMOVES BACK ARROW
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Bahay'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Juan'),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories),
            label: 'Salita',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Alaala'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Sulatin'),
        ],
      ),
    );
  }
}
