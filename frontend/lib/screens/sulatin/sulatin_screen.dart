import 'package:flutter/material.dart';

class SulatinScreen extends StatefulWidget {
  final String username;
  const SulatinScreen({super.key, required this.username});

  @override
  State<SulatinScreen> createState() => _SulatinScreenState();
}

class _SulatinScreenState extends State<SulatinScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Sulatin (Writing)', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Coming soon...', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
