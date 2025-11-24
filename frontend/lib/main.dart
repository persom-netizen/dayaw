import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'sign_up.dart';
import 'providers/post_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const MainPage(),
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
          const Image(image: AssetImage('assets/try2.jpg'), fit: BoxFit.cover),

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
