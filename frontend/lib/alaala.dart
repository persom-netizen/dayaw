// ...existing code...
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AlaalaPage extends StatefulWidget {
  const AlaalaPage({super.key});

  @override
  State<AlaalaPage> createState() => _AlaalaPageState();
}

class _AlaalaPageState extends State<AlaalaPage> {
  Map<String, dynamic>? trivia;
  bool loading = true;
  String? errorMessage; // <-- added

  @override
  void initState() {
    super.initState();
    loadTrivia();
  }

  Future<void> loadTrivia() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTime = prefs.getString('lastTriviaTime');
    final cachedTrivia = prefs.getString('cachedTrivia');
    final now = DateTime.now();

    if (lastTime != null &&
        now.difference(DateTime.parse(lastTime)).inHours < 24 &&
        cachedTrivia != null) {
      try {
        setState(() {
          trivia = jsonDecode(cachedTrivia);
          loading = false;
          errorMessage = null;
        });
        return;
      } catch (e) {
        // fall through to fetch if cached JSON is corrupted
      }
    }

    await fetchTrivia();
  }

  Future<void> fetchTrivia() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      // NOTE: keep 10.0.2.2 for emulator. For a real device use PC LAN IP, e.g. http://192.168.x.y:5000
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/trivia'),
      );

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('cachedTrivia', response.body);
          prefs.setString('lastTriviaTime', DateTime.now().toString());

          setState(() {
            trivia = data;
            loading = false;
            errorMessage = null;
          });
        } catch (e) {
          setState(() {
            loading = false;
            errorMessage = 'Invalid JSON from server';
          });
        }
      } else {
        setState(() {
          loading = false;
          errorMessage = 'Server returned ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = 'Network error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always return a Scaffold so page chrome is consistent
    return Scaffold(
      appBar: AppBar(title: const Text("Alaala (Trivia)")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Builder(
          builder: (_) {
            if (loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (errorMessage != null) {
              return Center(
                child: Text(errorMessage!, textAlign: TextAlign.center),
              );
            }
            if (trivia == null) {
              return const Center(child: Text("Walang trivia ngayon."));
            }
            return ListView(
              children: [
                Text(
                  trivia!['salita'] ?? '',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text("Depinisyon: ${trivia!['depinisyon'] ?? '—'}"),
                const SizedBox(height: 8),
                Text("Bigkas: ${trivia!['bigkas'] ?? '—'}"),
                const SizedBox(height: 8),
                Text("Etimolohiya: ${trivia!['etimolohiya'] ?? '—'}"),
                const SizedBox(height: 8),
                Text("Gamit: ${trivia!['gamit'] ?? '—'}"),
                const SizedBox(height: 8),
                Text("Konteksto: ${trivia!['kontekstong_kultural'] ?? '—'}"),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchTrivia,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
// ...existing code...