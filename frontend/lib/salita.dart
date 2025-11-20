import 'package:flutter/material.dart';
import 'services/api_service.dart';

class SalitaPage extends StatefulWidget {
  final String username;
  const SalitaPage({super.key, required this.username});

  @override
  State<SalitaPage> createState() => _SalitaPageState();
}

class _SalitaPageState extends State<SalitaPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _todayWord;

  @override
  void initState() {
    super.initState();
    _loadTodayWord();
  }

  Future<void> _loadTodayWord() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final word =
          await ApiService.getSalitaToday(); // ✅ FIXED: Changed from getAlaalToday()

      if (!mounted) return;

      if (word['success'] == true) {
        setState(() => _todayWord = word);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading word: $e')));
    } finally {
      if (!mounted) return;

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTodayView(),
    );
  }

  Widget _buildTodayView() {
    if (_todayWord == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Walang Salita ngayong araw',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTodayWord,
              child: const Text('Mag-retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Center(
            child: Text(
              'Salita ng Araw',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Word Card (with gradient)
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue[50]!, Colors.blue[100]!],
                ),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Salita (The Word - Large and Bold)
                  Text(
                    _todayWord?['salita'] ?? 'N/A',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Container(height: 2, color: Colors.blue[300]),
                  const SizedBox(height: 20),

                  // Depinisyon (Definition)
                  _buildField('Depinisyon:', _todayWord?['depinisyon']),
                  const SizedBox(height: 16),

                  // Bigkas (Pronunciation)
                  _buildField('Bigkas:', _todayWord?['bigkas']),
                  const SizedBox(height: 16),

                  // Etimolohiya (Etymology)
                  _buildField('Etimolohiya:', _todayWord?['etimolohiya']),
                  const SizedBox(height: 16),

                  // Gamit (Usage)
                  _buildField('Gamit:', _todayWord?['gamit']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
