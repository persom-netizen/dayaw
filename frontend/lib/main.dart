import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'home.dart';


// Providers
import 'providers/post_provider.dart';
import 'providers/font_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/onboarding_provider.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Preferences
  final fontProvider = FontProvider();
  await fontProvider.loadPreferences();

  final themeProvider = ThemeProvider();
  await themeProvider.loadPreferences();

  final onboardingProvider = OnboardingProvider();
  await onboardingProvider.loadPreferences();

  // Check for Saved Session
  final prefs = await SharedPreferences.getInstance();
  final String? savedUsername = prefs.getString('username');

  runApp(MyApp(
    fontProvider: fontProvider,
    themeProvider: themeProvider,
    onboardingProvider: onboardingProvider,
    savedUsername: savedUsername,
  ));
}

class MyApp extends StatelessWidget {
  final FontProvider fontProvider;
  final ThemeProvider themeProvider;
  final OnboardingProvider onboardingProvider;
  final String? savedUsername;

  const MyApp({
    super.key,
    required this.fontProvider,
    required this.themeProvider,
    required this.onboardingProvider,
    this.savedUsername,
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
          
          // logic to decide which screen to show first
          if (!onboarding.isLoaded) {
            homeScreen = const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (savedUsername != null && savedUsername!.isNotEmpty) {
            // User is already logged in
            homeScreen = HomePage(username: savedUsername!);
          } else if (onboarding.hasCompletedOnboarding) {
            // Finished onboarding but needs to login/register (MainPage)
            homeScreen = const MainPage(); 
          } else {
            // First time opening the app
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
              '/create-post': (context) => CreatePostScreen(username: savedUsername ?? 'User'),
            },
          );
        },
      ),
    );
  }
}

