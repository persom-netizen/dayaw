import 'package:flutter/material.dart';
import '../models/sulatin_models.dart';

// Design color constants - unified yellow theme
const Color _primaryYellow = Color(0xFFFFDF00);
const Color _textColor = Color(0xFF554141);

/// Widget for chapter tab selection
class ChapterTab extends StatelessWidget {
  final Chapter chapter;
  final bool isSelected;
  final VoidCallback onTap;

  const ChapterTab({
    super.key,
    required this.chapter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryYellow : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _primaryYellow : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primaryYellow.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chapter.isComingSoon)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.lock,
                  size: 16,
                  color: isSelected ? _textColor : Colors.grey[600],
                ),
              ),
            Text(
              chapter.title,
              style: TextStyle(
                color: isSelected ? _textColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying individual lesson cards
class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.onTap,
  });

  IconData _getLessonIcon() {
    switch (lesson.type) {
      case 'text':
        return Icons.description;
      case 'multiple_choice':
        return Icons.quiz;
      case 'matching':
        return Icons.extension;
      case 'tracing':
        return Icons.edit;
      case 'flipcard':
        return Icons.flip;
      default:
        return Icons.book;
    }
  }

  Color _getLessonColor() {
    if (lesson.isLocked) {
      return Colors.grey;
    }
    // Use yellow as primary with slight variations based on type
    return _primaryYellow;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: lesson.isLocked ? 2 : 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: lesson.isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getLessonColor().withValues(alpha: lesson.isLocked ? 0.1 : 0.2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: lesson.isLocked
                      ? null
                      : [
                          BoxShadow(
                            color: _primaryYellow.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Icon(
                  lesson.isLocked ? Icons.lock : _getLessonIcon(),
                  color: lesson.isLocked ? Colors.grey : _textColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: lesson.isLocked
                            ? Colors.grey[600]
                            : _textColor,
                      ),
                    ),
                    if (lesson.isLocked) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Sa susunod na version',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                lesson.isLocked ? Icons.lock_outline : Icons.arrow_forward_ios,
                color: lesson.isLocked ? Colors.grey[400] : _primaryYellow,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget for quiz options
class QuizOption extends StatelessWidget {
  final String option;
  final bool isSelected;
  final VoidCallback onTap;

  const QuizOption({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _primaryYellow.withValues(alpha: 0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryYellow : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primaryYellow.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? _primaryYellow : Colors.transparent,
                border: Border.all(
                  color: isSelected ? _primaryYellow : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: _textColor,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected ? _textColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
