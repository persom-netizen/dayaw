import 'package:flutter/material.dart';
import '../../models/sulatin_models.dart';
import '../../widgets/sulatin_widgets.dart';
import 'lesson_detail_screen.dart';

class SulatinScreen extends StatefulWidget {
  const SulatinScreen({super.key});

  @override
  State<SulatinScreen> createState() => _SulatinScreenState();
}

class _SulatinScreenState extends State<SulatinScreen> {
  int _selectedChapterIndex = 0;
  late List<Chapter> _chapters;

  @override
  void initState() {
    super.initState();
    _chapters = SulatinCurriculum.getAllChapters();
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

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sulatin',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Matuto ng Baybayin',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[700],
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
                ? _buildComingSoonView()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: selectedChapter.lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = selectedChapter.lessons[index];
                      return LessonCard(
                        lesson: lesson,
                        onTap: () => _openLesson(lesson),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Sa susunod na version',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ang kabanatang ito ay hindi pa available',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
