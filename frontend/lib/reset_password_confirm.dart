import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config/api_config.dart';

class ResetPasswordConfirmPage extends StatefulWidget {
  const ResetPasswordConfirmPage({super.key});

  @override
  State<ResetPasswordConfirmPage> createState() => _ResetPasswordConfirmPageState();
}

class _ResetPasswordConfirmPageState extends State<ResetPasswordConfirmPage> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  static const Color brownColor = Color.fromARGB(255, 71, 61, 29);
  static const Color goldColor = Color(0xFFD4AF37);

  Future<void> _completeReset() async {
    final token = _tokenController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (token.isEmpty || password.isEmpty) {
      _showSnackBar("Paki-fill up ang lahat ng fields");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Hindi magtugma ang password");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/reset-password-complete"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "password": password,
        }),
      );

      final res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _showSnackBar("Tagumpay! Pwede ka na mag-login.");
        if (!mounted) return;
        // Go back to Login (clears the reset screens from memory)
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        _showSnackBar(res["message"] ?? "Maling token o expired na ito");
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.gif'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Bagong Password',
                          style: TextStyle(fontSize: 24, color: brownColor, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text('Ilagay ang token mula sa email at ang iyong bagong password.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: brownColor, fontSize: 14)),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _tokenController,
                          style: const TextStyle(color: brownColor),
                          decoration: _buildInputDecoration('Reset Token'),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: brownColor),
                          decoration: _buildInputDecoration(
                            'Bagong Password',
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: brownColor),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: brownColor),
                          decoration: _buildInputDecoration('I-kumpirma ang Password'),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _completeReset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: goldColor,
                              foregroundColor: brownColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isLoading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: brownColor, strokeWidth: 2)) 
                                : const Text('I-SAVE'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: brownColor),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: brownColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: goldColor, width: 2),
      ),
      suffixIcon: suffixIcon,
    );
  }
}