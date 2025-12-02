import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'screens/bahay_page.dart';
import 'screens/create_post_screen.dart';
import 'screens/introduction_screen.dart';
import 'pages/main_page.dart';
import 'providers/post_provider.dart';
import 'providers/font_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/onboarding_provider.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create and initialize FontProvider and ThemeProvider
  final fontProvider = FontProvider();
  await fontProvider.loadPreferences();

  final themeProvider = ThemeProvider();
  await themeProvider.loadPreferences();

  // Create and initialize OnboardingProvider
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
        builder: (context, fontProvider, themeProvider, onboardingProvider, child) {
          // Determine which home screen to show based on onboarding completion
          // Only show MainPage if preferences are loaded and onboarding is complete
          final Widget homeScreen = onboardingProvider.isLoaded && onboardingProvider.hasCompletedOnboarding
              ? const MainPage()
              : IntroductionScreen(onboardingProvider: onboardingProvider);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(fontProvider),
            darkTheme: AppTheme.darkTheme(fontProvider),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
