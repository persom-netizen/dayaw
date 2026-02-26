import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Your existing imports
import 'screens/bahay_page.dart';
import 'screens/matuto_page.dart';
import 'screens/settings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/introduction_screen.dart';
import 'pages/main_page.dart';
import 'widgets/bottom_navigation.dart';
import 'screens/analisa_page.dart';
import 'screens/tipaan_page.dart';

// Providers
import 'providers/post_provider.dart';
import 'providers/font_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/onboarding_provider.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final fontProvider = FontProvider();
  await fontProvider.loadPreferences();

  final themeProvider = ThemeProvider();
  await themeProvider.loadPreferences();

  final onboardingProvider = OnboardingProvider();
  await onboardingProvider.loadPreferences();

  runApp(MyApp(
    fontProvider: fontProvider,
    themeProvider: themeProvider,
    onboardingProvider: onboardingProvider,
  ));
}

class MyApp extends StatelessWidget {
  final FontProvider fontProvider;
  final ThemeProvider themeProvider;
  final OnboardingProvider onboardingProvider;

  const MyApp({
    super.key,
    required this.fontProvider,
    required this.themeProvider,
    required this.onboardingProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider.value(value: fontProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: onboardingProvider),
      ],
      child: Consumer3<FontProvider, ThemeProvider, OnboardingProvider>(
        builder: (context, font, theme, onboarding, child) {
          Widget homeScreen;
          
          if (!onboarding.isLoaded) {
            homeScreen = const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (onboarding.hasCompletedOnboarding) {
            homeScreen = const HomePage(username: 'User'); 
          } else {
            homeScreen = IntroductionScreen(onboardingProvider: onboarding);
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(font),
            darkTheme: AppTheme.darkTheme(font),
            themeMode: theme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: homeScreen,
            routes: {
              '/main': (context) => const MainPage(),
              '/home': (context) => const HomePage(username: ''),
              '/bahay': (context) => const BahayPage(username: ''),
              '/create-post': (context) => const CreatePostScreen(username: ''),
            },
          );
        },
      ),
    );
  }
}

// --- HOME PAGE LOGIC (Updated for 5 Tabs) ---

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Order matches the Bottom Navigation Bar Icons
    _pages = [
      BahayPage(username: widget.username),       // Index 0
      AnalisaPage(username: widget.username),     // Index 1 (Camera)
      TipaanPage(username: widget.username),      // Index 2 (Maintenance)
      MatutoPage(username: widget.username),      // Index 3
      SettingsScreen(username: widget.username),  // Index 4
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
      case 2: return 'Tipaan';
      case 3: return 'Matuto';
      case 4: return 'Setting';
      default: return 'Dayaw';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FontProvider, ThemeProvider>(
      builder: (context, fontProvider, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final bgColor = isDark ? const Color(0xFF1F1F1F) : backgroundColor;
        final textColorThemed = isDark ? Colors.white : textColor;
        
        return Scaffold(
          backgroundColor: bgColor,
          appBar: _buildModernAppBar(fontProvider, isDark, bgColor, textColorThemed),
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

  PreferredSizeWidget _buildModernAppBar(FontProvider font, bool isDark, Color bg, Color txt) {
    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Image.asset('assets/logo_yellow.png', width: 40, height: 40, 
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.star, color: primaryYellow)),
          const SizedBox(width: 12),
          Text(_getPageTitle(), style: GoogleFonts.playfairDisplay(fontSize: font.titleSize, fontWeight: FontWeight.bold, color: txt)),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(username: widget.username, currentUsername: widget.username))),
          child: Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: primaryYellow, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text('@${widget.username}', style: GoogleFonts.inter(color: textColor, fontWeight: FontWeight.bold))),
          ),
        ),
      ],
    );
  }
}