import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // IMPORTANT
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home.dart';
import 'sign_up.dart';
import 'config/api_config.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  static const Color brownColor = Color.fromARGB(255, 71, 61, 29);
  static const Color goldColor = Color(0xFFD4AF37);

  // --- LOGIC: SAVING THE SESSION ---
  Future<void> _saveSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  // --- HANDLER: GOOGLE SIGN IN ---
  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser != null) {
        final response = await http.post(
          Uri.parse("${ApiConfig.baseUrl}/api/google-login"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "email": googleUser.email,
            "displayName": googleUser.displayName,
          }),
        );

        final res = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          String username = res["username"];
          await _saveSession(username); // Save to local storage

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomePage(username: username)),
          );
        } else {
          _showErrorSnackBar(res["message"] ?? "Google Login failed");
        }
      }
    } catch (error) {
      _showErrorSnackBar("Google Sign-In Error: $error");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HANDLER: MANUAL LOGIN ---
  Future<void> _login() async {
    if (_isLoading) return;

    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showErrorSnackBar("Pakisulat ang lahat ng detalye");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _usernameController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text,
        }),
      );

      final res = jsonDecode(response.body);

      if (response.statusCode == 200 && res["success"] == true) {
        String username = res["username"];
        await _saveSession(username); // Save to local storage

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(username: username)),
        );
      } else {
        _showErrorSnackBar(res["message"] ?? "Mali ang impormasyon");
      }
    } catch (e) {
      _showErrorSnackBar("Network error: Check your connection");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  // --- UI COMPONENTS (KEEPING YOUR DESIGN) ---

  InputDecoration _buildInputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: brownColor, fontWeight: FontWeight.w500),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: brownColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: goldColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.white.withOpacity(0.3),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/bg.gif'), fit: BoxFit.cover),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Image.asset('assets/logo_blue.png', height: 120, width: 120),
                const SizedBox(height: 40),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: goldColor, width: 2.5),
                      ),
                      child: Column(
                        children: [
                          const Text('Pasukin', style: TextStyle(fontFamily: 'Fortalesia', fontSize: 40, color: brownColor, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 24),
                          TextField(controller: _usernameController, decoration: _buildInputDecoration('Username')),
                          const SizedBox(height: 14),
                          TextField(controller: _emailController, decoration: _buildInputDecoration('Email')),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: _buildInputDecoration(
                              'Password',
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: brownColor),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: goldColor,
                                foregroundColor: brownColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _isLoading 
                                ? const CircularProgressIndicator(color: brownColor) 
                                : const Text('SIGE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDivider(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _socialButton(label: 'Google', icon: Icons.login, onPressed: _handleGoogleSignIn)),
                              const SizedBox(width: 12),
                              Expanded(child: _socialButton(label: 'Facebook', icon: Icons.group, onPressed: () {})),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignUpPage())),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(color: brownColor, fontSize: 14),
                                children: [
                                  TextSpan(text: 'Wala pang account?  '),
                                  TextSpan(text: 'Rehistro', style: TextStyle(color: goldColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildDivider() => Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("O")), Expanded(child: Divider())]);
  
  Widget _socialButton({required String label, required IconData icon, required VoidCallback onPressed}) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(foregroundColor: brownColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      icon: Icon(icon, size: 20),
      label: Text(label),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}