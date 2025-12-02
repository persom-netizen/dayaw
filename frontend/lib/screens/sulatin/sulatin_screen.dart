import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/sulatin_models.dart';
import '../../providers/font_provider.dart';
import '../../widgets/sulatin_widgets.dart';
import 'lesson_detail_screen.dart';

class SulatinScreen extends StatefulWidget {
  const SulatinScreen({super.key});

  @override
  State<SulatinScreen> createState() => _SulatinScreenState();
}

class _SulatinScreenState extends State<SulatinScreen>
    with SingleTickerProviderStateMixin {
  int _selectedChapterIndex = 0;
  late List<Chapter> _chapters;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Design color constants - unified yellow theme
  static const Color primaryYellow = Color(0xFFFFDF00);
  static const Color textColor = Color(0xFF554141);
  static const Color backgroundColor = Color(0xFFFFF9F4);

  @override
  void initState() {
    super.initState();
    _chapters = SulatinCurriculum.getAllChapters();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _selectChapter(int index) {
    setState(() {
      _selectedChapterIndex = index;
    });
  }

  void _openLesson(Lesson lesson) {
    if (lesson.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ang araling ito ay hindi pa available'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonDetailScreen(lesson: lesson),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedChapter = _chapters[_selectedChapterIndex];

    return Consumer<FontProvider>(
      builder: (context, fontProvider, child) {
        return Scaffold(
          backgroundColor: backgroundColor,
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header with yellow theme
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryYellow.withValues(alpha: 0.15),
                    boxShadow: [
                      BoxShadow(
                        color: primaryYellow.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sulatin',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: fontProvider.titleSize,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Matuto ng Baybayin',
                        style: GoogleFonts.inter(
                          fontSize: fontProvider.descriptionSize,
                          color: textColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Horizontal Chapter Tabs
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _chapters.length,
                    itemBuilder: (context, index) {
                      return ChapterTab(
                        chapter: _chapters[index],
                        isSelected: index == _selectedChapterIndex,
                        onTap: () => _selectChapter(index),
                      );
                    },
                  ),
                ),

                // Lessons List
                Expanded(
                  child: selectedChapter.isComingSoon
                      ? _buildComingSoonView(fontProvider)
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: selectedChapter.lessons.length,
                          itemBuilder: (context, index) {
                            final lesson = selectedChapter.lessons[index];
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 200 + (index * 100)),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: LessonCard(
                                lesson: lesson,
                                onTap: () => _openLesson(lesson),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComingSoonView(FontProvider fontProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryYellow.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline,
              size: 64,
              color: primaryYellow,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sa susunod na version',
            style: GoogleFonts.playfairDisplay(
              fontSize: fontProvider.header1Size,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ang kabanatang ito ay hindi pa available',
            style: GoogleFonts.inter(
              fontSize: fontProvider.header4Size,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
