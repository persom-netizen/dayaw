import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/font_provider.dart';
import 'services/api_service.dart';

class AlaalaPage extends StatefulWidget {
  final String username;
  const AlaalaPage({super.key, required this.username});

  @override
  State<AlaalaPage> createState() => _AlaalaPageState();
}

class _AlaalaPageState extends State<AlaalaPage> {
  bool _isLoading = false;
  Map<String, dynamic>? _todayTrivia;

  @override
  void initState() {
    super.initState();
    _loadTodayTrivia();
  }

  Future<void> _loadTodayTrivia() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final trivia = await ApiService.getAlaalToday();
      if (!mounted) return;
      if (trivia['success'] == true) {
        setState(() => _todayTrivia = trivia);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading trivia: $e')));
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
    if (_todayTrivia == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Walang Alaala ngayong araw',
              style: GoogleFonts.inter(fontSize: fontProvider.descriptionSize),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTodayTrivia,
              child: Text(
                'Mag-retry',
                style: GoogleFonts.inter(fontSize: fontProvider.descriptionSize),
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
              'Alam mo ba?',
              style: GoogleFonts.playfairDisplay(
                fontSize: fontProvider.titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Trivia Card (with gradient)
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
                  // Title (Large and Bold)
                  Text(
                    _todayTrivia?['alammoba'] ?? 'N/A',
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

                  // Description
                  Text(
                    _todayTrivia?['deskription'] ?? 'N/A',
                    style: GoogleFonts.inter(
                      fontSize: fontProvider.descriptionSize,
                      height: 1.8,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
