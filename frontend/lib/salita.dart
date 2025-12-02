import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/font_provider.dart';
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
    return Consumer<FontProvider>(
      builder: (context, fontProvider, child) {
        return Scaffold(
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildTodayView(fontProvider),
        );
      },
    );
  }

  Widget _buildTodayView(FontProvider fontProvider) {
    if (_todayWord == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Walang Salita ngayong araw',
              style: GoogleFonts.inter(fontSize: fontProvider.descriptionSize),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTodayWord,
              child: Text(
                'Mag-retry',
                style: GoogleFonts.inter(
                  fontSize: fontProvider.descriptionSize,
                ),
              ),
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
              style: GoogleFonts.playfairDisplay(
                fontSize: fontProvider.titleSize,
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
                    style: GoogleFonts.playfairDisplay(
                      fontSize: fontProvider.header1Size,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Container(height: 2, color: Colors.blue[300]),
                  const SizedBox(height: 20),

                  // Depinisyon (Definition)
                  _buildField(
                    'Depinisyon:',
                    _todayWord?['depinisyon'],
                    fontProvider,
                  ),
                  const SizedBox(height: 16),

                  // Bigkas (Pronunciation)
                  _buildField('Bigkas:', _todayWord?['bigkas'], fontProvider),
                  const SizedBox(height: 16),

                  // Etimolohiya (Etymology)
                  _buildField(
                    'Etimolohiya:',
                    _todayWord?['etimolohiya'],
                    fontProvider,
                  ),
                  const SizedBox(height: 16),

                  // Gamit (Usage)
                  _buildField('Gamit:', _todayWord?['gamit'], fontProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, dynamic value, FontProvider fontProvider) {
    if (value == null || value.toString().isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: fontProvider.header4Size,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: GoogleFonts.inter(
            fontSize: fontProvider.descriptionSize,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
