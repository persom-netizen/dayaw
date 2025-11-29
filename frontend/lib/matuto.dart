import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/font_provider.dart';
import 'services/api_service.dart';
import 'screens/profile_screen.dart';
import 'screens/sulatin/sulatin_screen.dart';

/// Matuto (Learn) - Main Navigation Page
/// A sleek minimalist design unified with the existing "Bahay" structure
class MatutoPage extends StatefulWidget {
  final String username;

  const MatutoPage({super.key, required this.username});

  @override
  State<MatutoPage> createState() => _MatutoPageState();
}

class _MatutoPageState extends State<MatutoPage> {
  // Design color constants
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);
  static const Color dividerBrown = Color(0xFF592A19);

  // Loading states
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
    _loadSalita();
    _loadAlaala();
  }

  Future<void> _loadSalita() async {
    if (!mounted) return;
    setState(() => _isLoadingSalita = true);
    try {
      final word = await ApiService.getSalitaToday();
      if (!mounted) return;
      if (word['success'] == true) {
        setState(() => _salitaData = word);
      }
    } catch (e) {
      // Silently fail, show placeholder
    } finally {
      if (mounted) setState(() => _isLoadingSalita = false);
    }
  }

  Future<void> _loadAlaala() async {
    if (!mounted) return;
    setState(() => _isLoadingAlaala = true);
    try {
      final trivia = await ApiService.getAlaalToday();
      if (!mounted) return;
      if (trivia['success'] == true) {
        setState(() => _alaalaData = trivia);
      }
    } catch (e) {
      // Silently fail, show placeholder
    } finally {
      if (mounted) setState(() => _isLoadingAlaala = false);
    }
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

  void _navigateToBaybayin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SulatinScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontProvider>(
      builder: (context, fontProvider, child) {
        return Scaffold(
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: primaryYellow,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeader(fontProvider),

                    // Yellow Divider with Dropdown Shadow
                    _buildDivider(),

                    // Main Content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Salita Section (Flippable Card)
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Header with title "Matuto." and username button
  Widget _buildHeader(FontProvider fontProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            'Matuto.',
            style: GoogleFonts.playfairDisplay(
              fontSize: fontProvider.titleSize,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
          // Username Button
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

  /// Yellow divider with dropdown shadow
  Widget _buildDivider() {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: primaryYellow,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: primaryYellow.withValues(alpha: 0.6),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  /// Salita Section with flippable card design
  Widget _buildSalitaSection(FontProvider fontProvider) {
    return _SalitaFlipCard(
      salitaData: _salitaData,
      isLoading: _isLoadingSalita,
      fontProvider: fontProvider,
      onRetry: _loadSalita,
    );
  }

  /// Alaala Section with @alammoba.dayaw header
  Widget _buildAlaalaSection(FontProvider fontProvider) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: @alammoba.dayaw
          Text(
            '@alammoba.dayaw',
            style: GoogleFonts.inter(
              fontSize: fontProvider.header4Size,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),

          const SizedBox(height: 12),

          // Alammoba content
          if (_isLoadingAlaala)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: primaryYellow,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (_alaalaData != null) ...[
            Text(
              _alaalaData?['alammoba'] ?? 'Alam mo ba?',
              style: GoogleFonts.playfairDisplay(
                fontSize: fontProvider.header1Size,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 12),

            // Line divider - 3/4 screen width
            Center(
              child: Container(
                width: screenWidth * 0.75,
                height: 2,
                decoration: BoxDecoration(
                  color: dividerBrown,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Description with justified text alignment
            Text(
              _alaalaData?['deskription'] ?? '',
              style: GoogleFonts.inter(
                fontSize: fontProvider.descriptionSize,
                height: 1.6,
                color: textColor,
              ),
              textAlign: TextAlign.justify,
            ),
          ] else
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Walang alaala ngayong araw',
                    style: GoogleFonts.inter(
                      fontSize: fontProvider.descriptionSize,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Sulatin Section - Native Scripts
  Widget _buildSulatinSection(FontProvider fontProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Mga Katutubong Sulat',
            style: GoogleFonts.playfairDisplay(
              fontSize: fontProvider.header1Size,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),

        // Baybayin Container (Clickable)
        _buildSulatinItem(
          fontProvider: fontProvider,
          title: 'Baybayin',
          isActive: true,
          progress: 0.0, // TODO: Connect to actual progress
          onTap: _navigateToBaybayin,
        ),

        const SizedBox(height: 12),

        // Alibata Container (Coming Soon)
        _buildSulatinItem(
          fontProvider: fontProvider,
          title: 'Alibata',
          isActive: false,
          subtitle: 'Susunod na bersyon',
        ),

        const SizedBox(height: 12),

        // Surat Mangyan Container (Coming Soon)
        _buildSulatinItem(
          fontProvider: fontProvider,
          title: 'Surat Mangyan',
          isActive: false,
          subtitle: 'Susunod na bersyon',
        ),
      ],
    );
  }

  Widget _buildSulatinItem({
    required FontProvider fontProvider,
    required String title,
    required bool isActive,
    String? subtitle,
    double progress = 0.0,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? primaryYellow.withValues(alpha: 0.5)
                : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: primaryYellow.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Logo/Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isActive
                    ? primaryYellow.withValues(alpha: 0.15)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: isActive
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/logo_yellow.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.edit_note,
                            color: primaryYellow,
                            size: 28,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.lock_outline,
                      color: Colors.grey[400],
                      size: 28,
                    ),
            ),

            const SizedBox(width: 16),

            // Title and subtitle/progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: fontProvider.header1Size,
                      fontWeight: FontWeight.bold,
                      color: isActive ? textColor : Colors.grey[500],
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: fontProvider.header4Size,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ] else if (isActive) ...[
                    const SizedBox(height: 8),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(primaryYellow),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Arrow icon (only for active items)
            if (isActive)
              Icon(
                Icons.chevron_right_rounded,
                color: primaryYellow,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}

/// Flippable Card Widget for Salita Section
class _SalitaFlipCard extends StatefulWidget {
  final Map<String, dynamic>? salitaData;
  final bool isLoading;
  final FontProvider fontProvider;
  final VoidCallback onRetry;

  const _SalitaFlipCard({
    required this.salitaData,
    required this.isLoading,
    required this.fontProvider,
    required this.onRetry,
  });

  @override
  State<_SalitaFlipCard> createState() => _SalitaFlipCardState();
}

class _SalitaFlipCardState extends State<_SalitaFlipCard>
    with SingleTickerProviderStateMixin {
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);

  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _showFront = !_showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final isFlipped = angle > math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFlipped
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildBackSide(),
                  )
                : _buildFrontSide(),
          );
        },
      ),
    );
  }

  /// Side 1: "Salita ngayon" and "alamin!"
  Widget _buildFrontSide() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 160),
      decoration: BoxDecoration(
        // Glassmorphism effect with 1% opacity background
        color: primaryYellow.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryYellow.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: primaryYellow.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Glassmorphism background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top thick rounded line (Yellow)
                Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: primaryYellow,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // "Salita ngayon" text
                      Text(
                        'Salita ngayon',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: widget.fontProvider.titleSize,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // "alamin!" text
                      Row(
                        children: [
                          Text(
                            'alamin!',
                            style: GoogleFonts.inter(
                              fontSize: widget.fontProvider.header1Size,
                              fontWeight: FontWeight.w500,
                              color: primaryYellow,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.touch_app_outlined,
                            color: primaryYellow.withValues(alpha: 0.7),
                            size: 20,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Tap hint
                      Text(
                        'I-tap para makita ang salita',
                        style: GoogleFonts.inter(
                          fontSize: widget.fontProvider.header4Size,
                          color: textColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Side 2: Content from Salita database
  Widget _buildBackSide() {
    if (widget.isLoading) {
      return _buildCardContainer(
        child: const Center(
          child: CircularProgressIndicator(
            color: primaryYellow,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (widget.salitaData == null) {
      return _buildCardContainer(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_stories,
                size: 40,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                'Walang salita ngayong araw',
                style: GoogleFonts.inter(
                  fontSize: widget.fontProvider.descriptionSize,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: widget.onRetry,
                child: Text(
                  'Subukan muli',
                  style: GoogleFonts.inter(
                    color: primaryYellow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _buildCardContainer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The word
            Text(
              widget.salitaData?['salita'] ?? 'N/A',
              style: GoogleFonts.playfairDisplay(
                fontSize: widget.fontProvider.titleSize,
                fontWeight: FontWeight.bold,
                color: primaryYellow,
              ),
            ),

            const SizedBox(height: 12),

            // Divider
            Container(
              height: 2,
              width: 60,
              decoration: BoxDecoration(
                color: primaryYellow.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(1),
              ),
            ),

            const SizedBox(height: 16),

            // Definition
            if (widget.salitaData?['depinisyon'] != null) ...[
              _buildInfoRow('Depinisyon', widget.salitaData!['depinisyon']),
              const SizedBox(height: 12),
            ],

            // Pronunciation
            if (widget.salitaData?['bigkas'] != null) ...[
              _buildInfoRow('Bigkas', widget.salitaData!['bigkas']),
              const SizedBox(height: 12),
            ],

            // Usage
            if (widget.salitaData?['gamit'] != null)
              _buildInfoRow('Gamit', widget.salitaData!['gamit']),

            const SizedBox(height: 16),

            // Tap hint
            Center(
              child: Text(
                'I-tap para bumalik',
                style: GoogleFonts.inter(
                  fontSize: widget.fontProvider.header4Size,
                  color: textColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: widget.fontProvider.header4Size,
            fontWeight: FontWeight.w600,
            color: textColor.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: widget.fontProvider.descriptionSize,
            color: textColor,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 160),
      decoration: BoxDecoration(
        color: primaryYellow.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryYellow.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: primaryYellow.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Glassmorphism background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top thick rounded line (Yellow)
                Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: primaryYellow,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: child,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
