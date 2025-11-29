import 'package:flutter/material.dart';
import '../../models/sulatin_models.dart';
import '../../widgets/sulatin_widgets.dart';
import 'tracing_screen.dart';
import 'matching_game_screen.dart';
import 'quiz_screen.dart';
import '../baybayin/kabanata_0.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int? _selectedOptionIndex;

  @override
  void initState() {
    super.initState();
    // For flipcard lessons, navigate directly to Kabanata0Screen
    if (widget.lesson.type == 'flipcard') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToFlipcard();
      });
    }
  }

  Future<void> _navigateToFlipcard() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Kabanata0Screen(),
      ),
    );
    if (mounted) {
      // Navigate back after flipcard is completed or closed
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while redirecting for flipcard
    if (widget.lesson.type == 'flipcard') {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.lesson.title),
          backgroundColor: Colors.teal[600],
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: Colors.blue[600],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLessonContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonContent() {
    switch (widget.lesson.type) {
      case 'text':
        return _buildTextLesson();
      case 'multiple_choice':
        return _buildMultipleChoiceLesson();
      case 'matching':
        return _buildMatchingLesson();
      case 'tracing':
        return _buildTracingLesson();
      case 'flipcard':
        return const SizedBox.shrink(); // Handled by navigation
      default:
        return _buildTextLesson();
    }
  }

  Widget _buildTextLesson() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              widget.lesson.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.8,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Ipagpatuloy',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceLesson() {
    // Check if this is a quiz-type lesson (Lesson 5 in Kabanata 1)
    if (widget.lesson.id == 5 || widget.lesson.title.contains('Pagsusulit')) {
      // Navigate to full quiz screen
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.quiz,
                    size: 64,
                    color: Colors.green[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.lesson.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Subukin ang iyong kaalaman sa Baybayin!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(
                    lessonId: widget.lesson.id,
                    lessonTitle: widget.lesson.title,
                    question: widget.lesson.content,
                    options: widget.lesson.options,
                    correctAnswerIndex: widget.lesson.correctAnswerIndex,
                  ),
                ),
              );
              if (result != null && result['completed'] == true) {
                // Lesson completed
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Magsimula ng Pagsusulit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.blue[600]!, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Bumalik',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[600],
              ),
            ),
          ),
        ],
      );
    }

    // Single question multiple choice (simple inline quiz)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              widget.lesson.content,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (widget.lesson.options != null)
          ...widget.lesson.options!.asMap().entries.map(
                (entry) => QuizOption(
                  option: entry.value,
                  isSelected: _selectedOptionIndex == entry.key,
                  onTap: () {
                    setState(() {
                      _selectedOptionIndex = entry.key;
                    });
                  },
                ),
              ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _selectedOptionIndex != null
              ? () {
                  // Show result
                  final isCorrect = _selectedOptionIndex == widget.lesson.correctAnswerIndex;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        isCorrect ? 'Tama!' : 'Mali',
                        style: TextStyle(
                          color: isCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        isCorrect
                            ? 'Mahusay! Tama ang iyong sagot.'
                            : 'Subukan muli ang pagbabasa ng aralin.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (isCorrect) {
                              Navigator.pop(context);
                            }
                          },
                          child: Text(isCorrect ? 'Ipagpatuloy' : 'OK'),
                        ),
                      ],
                    ),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[600],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'I-submit ang Sagot',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchingLesson() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.extension,
                  size: 64,
                  color: Colors.orange[400],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.lesson.content,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Itugma ang mga katinig sa kanilang tamang kombinasyon sa patinig.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchingGameScreen(
                  lessonId: widget.lesson.id,
                  lessonTitle: widget.lesson.title,
                ),
              ),
            );
            if (result != null && result['completed'] == true) {
              // Lesson completed
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange[600],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Magsimula ng Laro',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: Colors.blue[600]!, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Bumalik',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTracingLesson() {
    // Extract expected character from lesson title using pattern matching
    String expectedCharacter = 'A'; // Default
    final title = widget.lesson.title.toUpperCase();
    
    // Extract character after "PATINIG:" using regex
    final vowelPattern = RegExp(r'PATINIG:\s*([AEIOU])');
    final match = vowelPattern.firstMatch(title);
    
    if (match != null) {
      expectedCharacter = match.group(1)!;
    } else {
      // Fallback: check content for quoted character
      final content = widget.lesson.content.toLowerCase();
      final contentPattern = RegExp(r'"([aeiou])"');
      final contentMatch = contentPattern.firstMatch(content);
      
      if (contentMatch != null) {
        expectedCharacter = contentMatch.group(1)!.toUpperCase();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.edit,
                  size: 64,
                  color: Colors.purple[400],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.lesson.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.lesson.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.8,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TracingScreen(
                  lessonId: widget.lesson.id,
                  expectedCharacter: expectedCharacter,
                  lessonTitle: widget.lesson.title,
                ),
              ),
            );
            if (result != null && result['completed'] == true) {
              // Lesson completed
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[600],
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Magsimula ng Tracing',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: Colors.blue[600]!, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Bumalik',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[600],
            ),
          ),
        ),
      ],
    );
  }
}
