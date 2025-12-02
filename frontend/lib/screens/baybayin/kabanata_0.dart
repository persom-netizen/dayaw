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
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;
  bool _showingVowels = true;

  // Design color constants - unified yellow theme
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);

  List<BaybayinLetter> get _currentLetters =>
      _showingVowels ? BaybayinLetterData.vowels : BaybayinLetterData.consonants;

  int get _totalLetters => BaybayinLetterData.totalCount;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _switchSection(bool showVowels) {
    if (_showingVowels == showVowels) return;
    _fadeController.reset();
    setState(() {
      _showingVowels = showVowels;
      _currentIndex = 0;
    });
    _pageController.jumpToPage(0);
    _fadeController.forward();
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

  /// Returns true when the user has completed viewing all letters.
  /// This occurs when viewing the last consonant (last card in the consonants section).
  bool _shouldShowCompleteButton() {
    return _currentIndex == _currentLetters.length - 1 && !_showingVowels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Kabanata 0: Mga Letra ng Baybayin'),
        backgroundColor: primaryYellow,
        foregroundColor: textColor,
        elevation: 2,
        shadowColor: primaryYellow.withValues(alpha: 0.5),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryYellow.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: primaryYellow.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_stories, color: textColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    '$_globalIndex / $_totalLetters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
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
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 24,
                      ),
                      child: BaybayinFlipcard(
                        letter: _currentLetters[index],
                      ),
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
                    color: textColor,
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
                              ? primaryYellow
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: _currentIndex == index
                              ? [
                                  BoxShadow(
                                    color: primaryYellow.withValues(alpha: 0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
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
                    color: textColor,
                    disabledColor: Colors.grey[300],
                  ),
                ],
              ),
            ),

            // Complete button - shows only when viewing the last consonant,
            // indicating all letters (vowels + consonants) have been reviewed
            if (_shouldShowCompleteButton())
              Padding(
                padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {'completed': true});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryYellow,
                      foregroundColor: textColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                      elevation: 4,
                      shadowColor: primaryYellow.withValues(alpha: 0.5),
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
              ),

            // Instructions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: primaryYellow.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 18, color: textColor.withValues(alpha: 0.7)),
                  const SizedBox(width: 8),
                  Text(
                    'I-tap ang card para makita ang Baybayin',
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTab({
    required String title,
    required String subtitle,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryYellow.withValues(alpha: 0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryYellow : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryYellow.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? textColor : Colors.grey[600],
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? textColor.withValues(alpha: 0.7) : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? primaryYellow.withValues(alpha: 0.3) : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count letra',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? textColor : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
