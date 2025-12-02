import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'sign_up.dart';
import 'home.dart';
import 'screens/bahay_page.dart';
import 'screens/create_post_screen.dart';
import 'providers/post_provider.dart';
import 'providers/font_provider.dart';
import 'providers/theme_provider.dart';
import 'config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create and initialize FontProvider and ThemeProvider
  final fontProvider = FontProvider();
  await fontProvider.loadPreferences();

  final themeProvider = ThemeProvider();
  await themeProvider.loadPreferences();

  runApp(MyApp(
    fontProvider: fontProvider,
    themeProvider: themeProvider,
  ));
}

class MyApp extends StatelessWidget {
  final FontProvider fontProvider;
  final ThemeProvider themeProvider;

  const MyApp({
    super.key,
    required this.fontProvider,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider.value(value: fontProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: Consumer2<FontProvider, ThemeProvider>(
        builder: (context, fontProvider, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(fontProvider),
            darkTheme: AppTheme.darkTheme(fontProvider),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MainPage(),
            routes: {
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

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.white, // ✅ White background
      foregroundColor: const Color(0xFF000000), // ✅ Gold text
      side: const BorderSide(
        color: Color(0xFFEFBF04),
        width: 2,
      ), // ✅ Gold border
      shape: const StadiumBorder(), // ✅ Rounded / pill shape
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🌄 Background image
          const Image(
            image: AssetImage('assets/rehistro.png'),
            fit: BoxFit.cover,
          ),

          // 🌟 Centered content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title text with custom font
                const Text(
                  'Dayaw',
                  style: TextStyle(
                    fontFamily: 'Fortalesia',
                    fontSize: 100,
                    color: Colors.white, // ✅ White title text
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Row for side-by-side buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: buttonStyle,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      child: const Text("Login"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: buttonStyle,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      ),
                      child: const Text("Sign Up"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
