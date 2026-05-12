import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/font_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../widgets/salita_card_flip.dart';
import '../widgets/alaala_card.dart';
import '../widgets/sulatin_card.dart';
import 'sulatin/sulatin_screen.dart';

/// Matuto (Learn) - Unified Navigation page with sleek, minimalist UI design
/// Combines Salita (Word), Alaala (Memory/Trivia), and Sulatin (Writing) sections
///
/// Design Specifications:
/// - Yellow divider (FFDF00) with drop shadow below header
/// - Salita Section: Flippable card for Word of the Day
/// - Alaala Section: Today's trivia with @alammoba.dayaw
/// - Sulatin Section: Indigenous writing system learning cards
/// - Consistent design matching Bahay screen aesthetic
class MatutoPage extends StatefulWidget {
  final String username;

  const MatutoPage({super.key, required this.username});

  @override
  State<MatutoPage> createState() => _MatutoPageState();
}

class _MatutoPageState extends State<MatutoPage> {
  // Design color constants matching Bahay aesthetic
  static const Color backgroundColor = Color(0xFFFFF9F4);
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);

  // State for API data
  bool _isLoadingSalita = false;
  bool _isLoadingAlaala = false;
  Map<String, dynamic>? _salitaData;
  Map<String, dynamic>? _alaalaData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadSalitaData(), _loadAlaalaData()]);
  }

  Future<void> _loadSalitaData() async {
    if (!mounted) return;
    setState(() => _isLoadingSalita = true);

    try {
      final data = await ApiService.getSalitaToday();
      if (!mounted) return;
      if (data['success'] == true) {
        setState(() => _salitaData = data);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading Salita: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingSalita = false);
    }
  }

  Future<void> _loadAlaalaData() async {
    if (!mounted) return;
    setState(() => _isLoadingAlaala = true);

    try {
      final data = await ApiService.getAlaalToday();
      if (!mounted) return;
      if (data['success'] == true) {
        setState(() => _alaalaData = data);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading Alaala: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingAlaala = false);
    }
  }

  void _showComingSoonSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('susunod na bersyon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FontProvider, ThemeProvider>(
      builder: (context, fontProvider, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final bgColor = isDark ? const Color(0xFF1F1F1F) : backgroundColor;
        
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: primaryYellow,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Yellow Divider with drop shadow
                    _buildDivider(),
                    const SizedBox(height: 20),
                    // Salita Section - Flippable Card (using reusable widget)
                    _buildSalitaSection(fontProvider),
                    const SizedBox(height: 24),
                    // Alaala Section (using reusable widget)
                    _buildAlaalaSection(fontProvider),
                    const SizedBox(height: 24),
                    // Sulatin Section (using reusable widget)
                    _buildSulatinSection(fontProvider),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 2,
      decoration: BoxDecoration(
        color: primaryYellow,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: primaryYellow.withValues(alpha: 0.5),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }

  Widget _buildSalitaSection(FontProvider fontProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SalitaCardFlip(
        salitaData: _salitaData,
        isLoading: _isLoadingSalita,
        fontProvider: fontProvider,
        onLongPress: () {
          // Long press hint for revealing information
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pindutin para makita ang salita'),
              duration: Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlaalaSection(FontProvider fontProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AlaalaCard(
        alaalaData: _alaalaData,
        isLoading: _isLoadingAlaala,
        fontProvider: fontProvider,
      ),
    );
  }

  Widget _buildSulatinSection(FontProvider fontProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Mga Katutubong Sulat',
            style: GoogleFonts.playfairDisplay(
              fontSize: fontProvider.header1Size,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Horizontal scrollable list of cards (using reusable widget)
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              SulatinCard(
                title: 'Baybayin',
                isActive: true,
                fontProvider: fontProvider,
                imagePath: 'assets/logo_yellow.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SulatinScreen()),
                  );
                },
              ),
              const SizedBox(width: 16),
              SulatinCard(
                title: 'Alibata',
                isActive: false,
                fontProvider: fontProvider,
                onTap: _showComingSoonSnackbar,
              ),
              const SizedBox(width: 16),
              SulatinCard(
                title: 'Surat Mangyan',
                isActive: false,
                fontProvider: fontProvider,
                onTap: _showComingSoonSnackbar,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
