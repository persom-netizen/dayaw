import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/font_provider.dart';
import '../services/api_service.dart';
import 'profile_screen.dart';
import 'sulatin/sulatin_screen.dart';

/// Matuto (Learn) - Navigation page with sleek, minimalist UI design
/// Combines Salita (Word), Alaala (Memory/Trivia), and Sulatin (Writing) sections
class MatutoPage extends StatefulWidget {
  final String username;

  const MatutoPage({super.key, required this.username});

  @override
  State<MatutoPage> createState() => _MatutoPageState();
}

class _MatutoPageState extends State<MatutoPage>
    with SingleTickerProviderStateMixin {
  // Design color constants matching Bahay aesthetic
  static const Color backgroundColor = Color(0xFFFFF9F4);
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color alaalaDividerColor = Color(0xFF592A19);

  // State for API data
  bool _isLoadingSalita = false;
  bool _isLoadingAlaala = false;
  Map<String, dynamic>? _salitaData;
  Map<String, dynamic>? _alaalaData;

  // State for flippable Salita card
  bool _isSalitaCardFlipped = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading Salita: $e')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading Alaala: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingAlaala = false);
    }
  }

  void _flipSalitaCard() {
    if (_isSalitaCardFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _isSalitaCardFlipped = !_isSalitaCardFlipped);
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          username: widget.username,
          currentUsername: widget.username,
        ),
      ),
    );
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
    return Consumer<FontProvider>(
      builder: (context, fontProvider, child) {
        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeader(fontProvider),
                  // Yellow Divider with drop shadow
                  _buildDivider(),
                  const SizedBox(height: 20),
                  // Salita Section - Flippable Card
                  _buildSalitaSection(fontProvider),
                  const SizedBox(height: 24),
                  // Alaala Section
                  _buildAlaalaSection(fontProvider),
                  const SizedBox(height: 24),
                  // Sulatin Section
                  _buildSulatinSection(fontProvider),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(FontProvider fontProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            'Matuto.',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          // Username chip
          GestureDetector(
            onTap: _navigateToProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: primaryYellow,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryYellow.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '@${widget.username}',
                style: GoogleFonts.inter(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: fontProvider.descriptionSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 4,
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
      child: GestureDetector(
        onTap: _flipSalitaCard,
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final angle = _flipAnimation.value * pi;
            final showFront = angle < pi / 2;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: showFront
                  ? _buildSalitaFront(fontProvider)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: _buildSalitaBack(fontProvider),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSalitaFront(FontProvider fontProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Glassmorphism effect
        color: primaryYellow.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryYellow.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorative thick rounded line at the top
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: primaryYellow,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 20),
          // "Salita ngayon" text
          Text(
            'Salita ngayon',
            style: GoogleFonts.playfairDisplay(
              fontSize: fontProvider.header1Size,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          // "iyong buksan!" text
          Row(
            children: [
              Text(
                'iyong buksan!',
                style: GoogleFonts.inter(
                  fontSize: fontProvider.descriptionSize,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.touch_app_rounded,
                color: textColor.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalitaBack(FontProvider fontProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryYellow.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryYellow.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _isLoadingSalita
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: primaryYellow),
              ),
            )
          : _salitaData == null
              ? _buildNoDataWidget('Walang Salita ngayong araw', fontProvider)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Decorative thick rounded line at the top
                    Container(
                      width: 60,
                      height: 6,
                      decoration: BoxDecoration(
                        color: primaryYellow,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Salita (Word)
                    Text(
                      'Salita',
                      style: GoogleFonts.inter(
                        fontSize: fontProvider.header4Size,
                        fontWeight: FontWeight.w600,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _salitaData?['salita'] ?? 'N/A',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: fontProvider.header1Size + 4,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Kahulugan (Meaning)
                    Text(
                      'Kahulugan',
                      style: GoogleFonts.inter(
                        fontSize: fontProvider.header4Size,
                        fontWeight: FontWeight.w600,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _salitaData?['depinisyon'] ?? 'N/A',
                      style: GoogleFonts.inter(
                        fontSize: fontProvider.descriptionSize,
                        color: textColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildNoDataWidget(String message, FontProvider fontProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 40,
              color: textColor.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: fontProvider.descriptionSize,
                color: textColor.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlaalaSection(FontProvider fontProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: @alammoba.dayaw
          Text(
            '@alammoba.dayaw',
            style: GoogleFonts.inter(
              fontSize: fontProvider.header4Size,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          // Content
          if (_isLoadingAlaala)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: primaryYellow),
              ),
            )
          else if (_alaalaData == null)
            _buildNoDataWidget('Walang Alaala ngayong araw', fontProvider)
          else ...[
            // Title from API (alammoba field)
            Text(
              _alaalaData?['alammoba'] ?? 'N/A',
              style: GoogleFonts.playfairDisplay(
                fontSize: fontProvider.header1Size,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            // Divider: line with color #592A19, 3/4 screen width
            FractionallySizedBox(
              widthFactor: 0.75,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: alaalaDividerColor,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Body: Description from API, text justified
            Text(
              _alaalaData?['deskription'] ?? 'N/A',
              style: GoogleFonts.inter(
                fontSize: fontProvider.descriptionSize,
                color: textColor,
                height: 1.6,
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ],
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
        // Horizontal scrollable list of cards
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildSulatinCard(
                title: 'Baybayin',
                isActive: true,
                fontProvider: fontProvider,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SulatinScreen()),
                  );
                },
              ),
              const SizedBox(width: 16),
              _buildSulatinCard(
                title: 'Alibata',
                isActive: false,
                fontProvider: fontProvider,
                onTap: _showComingSoonSnackbar,
              ),
              const SizedBox(width: 16),
              _buildSulatinCard(
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

  Widget _buildSulatinCard({
    required String title,
    required bool isActive,
    required FontProvider fontProvider,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? primaryYellow.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? primaryYellow.withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/logo_yellow.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: primaryYellow.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: isActive ? primaryYellow : Colors.grey,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: fontProvider.descriptionSize,
                fontWeight: FontWeight.w600,
                color: isActive ? textColor : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isActive) ...[
              const SizedBox(height: 4),
              Text(
                '(soon)',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
