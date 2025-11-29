import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/font_provider.dart';
import '../services/api_service.dart';
import '../screens/settings_screen.dart';
import 'sulatin/sulatin_screen.dart';

/// Matuto (Learn) - Main Learning Navigation Screen
/// 
/// Design Specifications (matching Bahay theme):
/// - Background: #FFF9F4
/// - Primary Yellow: #FFDF00
/// - Text Color: #554141
/// - Brown accent: #592A19
/// - Glassmorphism effects & drop shadows
class MatutoScreen extends StatefulWidget {
  final String username;

  const MatutoScreen({super.key, required this.username});

  @override
  State<MatutoScreen> createState() => _MatutoScreenState();
}

class _MatutoScreenState extends State<MatutoScreen> {
  // Design color constants (consistent with Bahay theme)
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);
  static const Color brownAccent = Color(0xFF592A19);

  // Data loading states
  bool _isLoadingSalita = false;
  bool _isLoadingAlaala = false;
  Map<String, dynamic>? _todaySalita;
  Map<String, dynamic>? _todayAlaala;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadTodaySalita(),
      _loadTodayAlaala(),
    ]);
  }

  Future<void> _loadTodaySalita() async {
    if (!mounted) return;
    setState(() => _isLoadingSalita = true);
    try {
      final salita = await ApiService.getSalitaToday();
      if (!mounted) return;
      if (salita['success'] == true) {
        setState(() => _todaySalita = salita);
      }
    } catch (e) {
      // Silently handle error, UI will show fallback state
    } finally {
      if (mounted) setState(() => _isLoadingSalita = false);
    }
  }

  Future<void> _loadTodayAlaala() async {
    if (!mounted) return;
    setState(() => _isLoadingAlaala = true);
    try {
      final alaala = await ApiService.getAlaalToday();
      if (!mounted) return;
      if (alaala['success'] == true) {
        setState(() => _todayAlaala = alaala);
      }
    } catch (e) {
      // Silently handle error, UI will show fallback state
    } finally {
      if (mounted) setState(() => _isLoadingAlaala = false);
    }
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(username: widget.username),
      ),
    );
  }

  void _navigateToSulatin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SulatinScreen(),
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
            child: RefreshIndicator(
              onRefresh: _loadData,
              color: primaryYellow,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeader(fontProvider),
                    
                    // Yellow Divider with Drop Shadow
                    _buildDivider(),
                    
                    const SizedBox(height: 20),
                    
                    // Section 1: Salita (Word of the Day) - Flippable Card
                    _buildSalitaSection(fontProvider),
                    
                    const SizedBox(height: 24),
                    
                    // Section 2: Alaala (Trivia/Memory)
                    _buildAlaalaSection(fontProvider),
                    
                    const SizedBox(height: 24),
                    
                    // Section 3: Sulatin (Indigenous Writing)
                    _buildSulatinSection(fontProvider),
                    
                    const SizedBox(height: 100), // Bottom padding for navigation
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Header with "Matuto." title and clickable username
  Widget _buildHeader(FontProvider fontProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title: "Matuto."
          Text(
            'Matuto.',
            style: GoogleFonts.playfairDisplay(
              fontSize: fontProvider.titleSize,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
          // Clickable username → redirects to profile/settings (akin)
          GestureDetector(
            onTap: _navigateToSettings,
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

  /// Horizontal divider with #FFDF00 color and drop shadow
  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 3,
      decoration: BoxDecoration(
        color: primaryYellow,
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: primaryYellow.withValues(alpha: 0.5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  /// Section 1: Salita (Word of the Day) - Flippable Card
  Widget _buildSalitaSection(FontProvider fontProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _SalitaFlipCard(
        salitaData: _todaySalita,
        isLoading: _isLoadingSalita,
        fontProvider: fontProvider,
      ),
    );
  }

  /// Section 2: Alaala (Trivia/Memory)
  Widget _buildAlaalaSection(FontProvider fontProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Static text "@alammoba.dayaw"
          Text(
            '@alammoba.dayaw',
            style: GoogleFonts.inter(
              fontSize: fontProvider.header4Size,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          
          // Title from database
          if (_isLoadingAlaala)
            _buildLoadingPlaceholder()
          else if (_todayAlaala != null)
            Text(
              _todayAlaala!['alammoba'] ?? 'Alam mo ba?',
              style: GoogleFonts.playfairDisplay(
                fontSize: fontProvider.header1Size,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            )
          else
            Text(
              'Walang Alaala ngayong araw',
              style: GoogleFonts.playfairDisplay(
                fontSize: fontProvider.header1Size,
                fontWeight: FontWeight.bold,
                color: textColor.withValues(alpha: 0.5),
              ),
            ),
          
          const SizedBox(height: 8),
          
          // Divider: 3/4 width, color #592A19
          FractionallySizedBox(
            widthFactor: 0.75,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: brownAccent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Body: Content/description from database (justified text)
          if (_isLoadingAlaala)
            _buildLoadingPlaceholder(height: 60)
          else if (_todayAlaala != null && _todayAlaala!['deskription'] != null)
            Text(
              _todayAlaala!['deskription'],
              textAlign: TextAlign.justify,
              style: GoogleFonts.inter(
                fontSize: fontProvider.descriptionSize,
                height: 1.6,
                color: textColor,
              ),
            )
          else
            Text(
              'Walang detalye para sa araw na ito.',
              textAlign: TextAlign.justify,
              style: GoogleFonts.inter(
                fontSize: fontProvider.descriptionSize,
                height: 1.6,
                color: textColor.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }

  /// Section 3: Sulatin (Indigenous Writing)
  Widget _buildSulatinSection(FontProvider fontProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title: "Mga Katutubong Sulat"
          Text(
            'Mga Katutubong Sulat',
            style: GoogleFonts.playfairDisplay(
              fontSize: fontProvider.header1Size,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // Grid of Writing Systems
          _buildWritingSystemsGrid(fontProvider),
        ],
      ),
    );
  }

  /// Grid of indigenous writing systems
  Widget _buildWritingSystemsGrid(FontProvider fontProvider) {
    return Column(
      children: [
        // Row 1: Baybayin (enabled)
        _buildWritingSystemCard(
          label: 'Baybayin',
          isEnabled: true,
          hasProgress: true,
          progressValue: 0.0, // TODO: Calculate from actual chapter completion
          onTap: _navigateToSulatin,
          fontProvider: fontProvider,
        ),
        const SizedBox(height: 12),
        
        // Row 2: Alibata (disabled - coming soon)
        _buildWritingSystemCard(
          label: 'Alibata',
          isEnabled: false,
          hasProgress: false,
          onTap: null,
          fontProvider: fontProvider,
        ),
        const SizedBox(height: 12),
        
        // Row 3: Surat Mangyan (disabled - coming soon)
        _buildWritingSystemCard(
          label: 'Surat Mangyan',
          isEnabled: false,
          hasProgress: false,
          onTap: null,
          fontProvider: fontProvider,
        ),
      ],
    );
  }

  /// Individual writing system card
  Widget _buildWritingSystemCard({
    required String label,
    required bool isEnabled,
    required bool hasProgress,
    double progressValue = 0.0,
    VoidCallback? onTap,
    required FontProvider fontProvider,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Stack(
        children: [
          // Main card container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEnabled 
                  ? Colors.white 
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isEnabled 
                    ? primaryYellow 
                    : Colors.grey[300]!,
                width: 2,
              ),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Logo/Icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isEnabled 
                        ? primaryYellow.withValues(alpha: 0.2)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: label == 'Baybayin'
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/logo_yellow.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.edit_rounded,
                                color: isEnabled ? primaryYellow : Colors.grey,
                                size: 28,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.edit_rounded,
                          color: isEnabled ? primaryYellow : Colors.grey,
                          size: 28,
                        ),
                ),
                const SizedBox(width: 16),
                
                // Label and progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: fontProvider.descriptionSize,
                          fontWeight: FontWeight.bold,
                          color: isEnabled ? textColor : Colors.grey[500],
                        ),
                      ),
                      if (hasProgress && isEnabled) ...[
                        const SizedBox(height: 8),
                        // Progress bar
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: primaryYellow.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progressValue.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: primaryYellow,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Arrow or lock icon
                Icon(
                  isEnabled ? Icons.arrow_forward_ios_rounded : Icons.lock_outline_rounded,
                  color: isEnabled ? textColor.withValues(alpha: 0.5) : Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
          
          // "Susunod na bersyon" overlay for disabled cards
          if (!isEnabled)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'susunod na bersyon',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Loading placeholder widget
  Widget _buildLoadingPlaceholder({double height = 20}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

/// Salita (Word of the Day) Flippable Card Widget
class _SalitaFlipCard extends StatefulWidget {
  final Map<String, dynamic>? salitaData;
  final bool isLoading;
  final FontProvider fontProvider;

  const _SalitaFlipCard({
    required this.salitaData,
    required this.isLoading,
    required this.fontProvider,
  });

  @override
  State<_SalitaFlipCard> createState() => _SalitaFlipCardState();
}

class _SalitaFlipCardState extends State<_SalitaFlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipped = false;

  // Design color constants
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);

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

  void _flip() {
    if (_isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingCard();
    }

    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final showFront = _animation.value < 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: showFront
                ? _buildFrontSide()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildBackSide(),
                  ),
          );
        },
      ),
    );
  }

  /// Loading state card
  Widget _buildLoadingCard() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: primaryYellow,
        ),
      ),
    );
  }

  /// Front side of the flip card
  Widget _buildFrontSide() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        // Glassmorphism: #FFDF00 with 1% opacity background
        color: primaryYellow.withValues(alpha: 0.01),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryYellow.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          // Glass effect with white overlay
          color: Colors.white.withValues(alpha: 0.9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top decoration: Rounded thick line (color #FFDF00)
              Container(
                margin: const EdgeInsets.only(top: 16),
                width: 60,
                height: 6,
                decoration: BoxDecoration(
                  color: primaryYellow,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              
              // Text: "Salita ngayon" (Playfair Display)
              Text(
                'Salita ngayon',
                style: GoogleFonts.playfairDisplay(
                  fontSize: widget.fontProvider.header1Size,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              
              // Text: "alamin!" (Inter)
              Text(
                'alamin!',
                style: GoogleFonts.inter(
                  fontSize: widget.fontProvider.descriptionSize,
                  fontWeight: FontWeight.w500,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              
              // Tap hint
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: 16,
                    color: textColor.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'I-tap para makita',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: textColor.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Back side of the flip card - displays salita data from database
  Widget _buildBackSide() {
    final hasData = widget.salitaData != null;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        color: primaryYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryYellow,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryYellow.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: Colors.white.withValues(alpha: 0.95),
          padding: const EdgeInsets.all(20),
          child: hasData
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Word (Salita)
                    Center(
                      child: Text(
                        widget.salitaData!['salita'] ?? 'N/A',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: widget.fontProvider.titleSize,
                          fontWeight: FontWeight.bold,
                          color: primaryYellow.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Divider
                    Container(
                      height: 2,
                      color: primaryYellow.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    
                    // Definition (Depinisyon)
                    if (widget.salitaData!['depinisyon'] != null) ...[
                      Text(
                        'Depinisyon:',
                        style: GoogleFonts.inter(
                          fontSize: widget.fontProvider.header4Size,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.salitaData!['depinisyon'],
                        style: GoogleFonts.inter(
                          fontSize: widget.fontProvider.header4Size,
                          color: textColor.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Pronunciation (Bigkas)
                    if (widget.salitaData!['bigkas'] != null) ...[
                      Row(
                        children: [
                          Text(
                            'Bigkas: ',
                            style: GoogleFonts.inter(
                              fontSize: widget.fontProvider.header4Size,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            widget.salitaData!['bigkas'],
                            style: GoogleFonts.inter(
                              fontSize: widget.fontProvider.header4Size,
                              fontStyle: FontStyle.italic,
                              color: textColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Tap hint to flip back
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 14,
                            color: textColor.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'I-tap para bumalik',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: textColor.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        size: 48,
                        color: textColor.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Walang Salita ngayong araw',
                        style: GoogleFonts.inter(
                          fontSize: widget.fontProvider.descriptionSize,
                          color: textColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
