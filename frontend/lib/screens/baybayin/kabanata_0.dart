import 'package:flutter/material.dart';
import '../../models/baybayin_letter.dart';
import '../../widgets/baybayin_flipcard.dart';

/// Kabanata 0 - Baybayin Letters Introduction
/// Interactive flipcard system for learning all Baybayin letters
class Kabanata0Screen extends StatefulWidget {
  const Kabanata0Screen({super.key});

  @override
  State<Kabanata0Screen> createState() => _Kabanata0ScreenState();
}

class _Kabanata0ScreenState extends State<Kabanata0Screen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showingVowels = true;

  List<BaybayinLetter> get _currentLetters =>
      _showingVowels ? BaybayinLetterData.vowels : BaybayinLetterData.consonants;

  int get _totalLetters => BaybayinLetterData.totalCount;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _switchSection(bool showVowels) {
    if (_showingVowels == showVowels) return;
    setState(() {
      _showingVowels = showVowels;
      _currentIndex = 0;
    });
    _pageController.jumpToPage(0);
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentIndex < _currentLetters.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  int get _globalIndex {
    if (_showingVowels) {
      return _currentIndex + 1;
    } else {
      return BaybayinLetterData.vowels.length + _currentIndex + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kabanata 0: Mga Letra ng Baybayin'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_stories, color: Colors.blue[700], size: 24),
                const SizedBox(width: 12),
                Text(
                  '$_globalIndex / $_totalLetters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ),

          // Section tabs (Patinig / Katinig)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildSectionTab(
                    title: 'Patinig',
                    subtitle: '(Vowels)',
                    count: BaybayinLetterData.vowels.length,
                    isSelected: _showingVowels,
                    color: Colors.blue,
                    onTap: () => _switchSection(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSectionTab(
                    title: 'Katinig',
                    subtitle: '(Consonants)',
                    count: BaybayinLetterData.consonants.length,
                    isSelected: !_showingVowels,
                    color: Colors.purple,
                    onTap: () => _switchSection(false),
                  ),
                ),
              ],
            ),
          ),

          // Flipcard carousel
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _currentLetters.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 24,
                  ),
                  child: BaybayinFlipcard(
                    letter: _currentLetters[index],
                  ),
                );
              },
            ),
          ),

          // Navigation controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous button
                IconButton(
                  onPressed: _currentIndex > 0 ? _goToPrevious : null,
                  icon: const Icon(Icons.arrow_back_ios),
                  iconSize: 32,
                  color: Colors.blue[700],
                  disabledColor: Colors.grey[300],
                ),
                const SizedBox(width: 24),
                // Page dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _currentLetters.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? (_showingVowels
                                ? Colors.blue[600]
                                : Colors.purple[600])
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Next button
                IconButton(
                  onPressed: _currentIndex < _currentLetters.length - 1
                      ? _goToNext
                      : null,
                  icon: const Icon(Icons.arrow_forward_ios),
                  iconSize: 32,
                  color: Colors.blue[700],
                  disabledColor: Colors.grey[300],
                ),
              ],
            ),
          ),

          // Complete button (appears when on last card)
          if (_currentIndex == _currentLetters.length - 1 && !_showingVowels)
            Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {'completed': true});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle),
                    SizedBox(width: 8),
                    Text(
                      'Tapos na! Bumalik sa Kurso',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Instructions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'I-tap ang card para makita ang Baybayin',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTab({
    required String title,
    required String subtitle,
    required int count,
    required bool isSelected,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color[400]! : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? color[800] : Colors.grey[600],
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color[600] : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? color[200] : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count letra',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color[700] : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
