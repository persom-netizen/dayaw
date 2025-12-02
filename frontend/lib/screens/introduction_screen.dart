import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../login.dart';

/// Introduction/Onboarding Screen for DAYAW App
/// Displays 4 pages introducing the app in Filipino language
/// Features smooth transitions, animations, and gradient text
class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Design colors from DAYAW theme
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color darkBrown = Color(0xFF2A1F1F);
  static const Color warmCream = Color(0xFFFFF9F4);
  static const Color textColor = Color(0xFF554141);

  // Onboarding page content
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      gifAsset: 'assets/page1.gif',
      title: 'Ay ikaw pala!',
      subtitle:
          'Nagagalak ako na nandito ka. Sapagkat ito ang iyong unang pagkakataon na gamitan ang aplikasyon na ito.',
    ),
    OnboardingPage(
      gifAsset: 'assets/page2.gif',
      title: 'Hindi ka nag-iisa!',
      subtitle:
          'Ang komunidad na ito ay para sa mga taong sabik matuto sa kultura, buhay, at kaalaman na tungkol sa identidad ng mga Pilipino!',
    ),
    OnboardingPage(
      gifAsset: 'assets/page3.gif',
      title: 'Mahalagang malaman',
      subtitle:
          'Narito ka hindi para matakot sa pakikihalubilo o pagkatuto, bagkos ang bawat minuto ay nagiging masaya pag kasama si Dayaw.',
    ),
    OnboardingPage(
      gifAsset: 'assets/page4.gif',
      title: 'Buksan at mata!',
      subtitle:
          'Halina\'t samahan ang libo-libong tao na nais mapasama sa pamilya ni Dayaw.',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Initialize scale animation controller for buttons
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Start fade-in animation
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    // Restart fade animation on page change
    _fadeController.reset();
    _fadeController.forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to login page on final page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Exit on first page
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: warmCream,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at top right
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _previousPage,
                  style: TextButton.styleFrom(
                    foregroundColor: textColor,
                  ),
                  child: Text(
                    'Balikan',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // PageView for onboarding pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: WormEffect(
                  dotColor: textColor.withOpacity(0.3),
                  activeDotColor: primaryYellow,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 8,
                ),
              ),
            ),

            // Continue button at bottom
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _scaleController.forward().then((_) {
                        _scaleController.reverse();
                        _nextPage();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryYellow,
                      foregroundColor: textColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Magsimula' : 'Sunod',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // GIF image with fade-in animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: child,
                  ),
                );
              },
              child: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    page.gifAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),

            // Title with gradient and drop shadow
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [darkBrown, primaryYellow],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds),
              child: Text(
                page.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 8,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Subtitle
            Text(
              page.subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: textColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data class for onboarding page content
class OnboardingPage {
  final String gifAsset;
  final String title;
  final String subtitle;

  OnboardingPage({
    required this.gifAsset,
    required this.title,
    required this.subtitle,
  });
}
