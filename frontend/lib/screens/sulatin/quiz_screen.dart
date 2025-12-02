import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Design color constants - unified yellow theme
const Color _primaryYellow = Color(0xFFFFDF00);
const Color _textColor = Color(0xFF554141);
const Color _backgroundColor = Color(0xFFFFF9F4);

class QuizScreen extends StatefulWidget {
  final int lessonId;
  final String lessonTitle;
  final String question;
  final List<String>? options;
  final int? correctAnswerIndex;

  const QuizScreen({
    super.key,
    required this.lessonId,
    required this.lessonTitle,
    required this.question,
    this.options,
    this.correctAnswerIndex,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const int _pointsPerCorrectAnswer = 20;
  
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  int _score = 0;
  int _currentQuestionIndex = 0;

  // Extended quiz questions for Kabanata 1 Lesson 5
  final List<Map<String, dynamic>> _quizQuestions = [];

  @override
  void initState() {
    super.initState();
    _initializeQuestions();
  }

  void _initializeQuestions() {
    _quizQuestions.addAll([
      {
        'question': 'Saan nagmula ang salitang "baybayin"?',
        'options': [
          'Sa salitang "baybay" na nangangahulugang tabing-dagat at pagbaybay',
          'Sa pangalan ng isang bayani',
          'Sa isang lugar sa Pilipinas',
          'Wala sa nabanggit',
        ],
        'correctIndex': 0,
      },
      {
        'question': 'Ilang pangunahing karakter ang mayroon ang Baybayin?',
        'options': [
          '14',
          '17',
          '20',
          '26',
        ],
        'correctIndex': 1,
      },
      {
        'question': 'Kailan unang ginamit ang Baybayin sa Pilipinas?',
        'options': [
          'Ika-10 siglo',
          'Ika-13 siglo',
          'Ika-15 siglo',
          'Ika-16 siglo',
        ],
        'correctIndex': 1,
      },
      {
        'question': 'Ano ang uri ng alpabeto ng Baybayin?',
        'options': [
          'Alphabetic',
          'Logographic',
          'Syllabic (katinig-patinig)',
          'Pictographic',
        ],
        'correctIndex': 2,
      },
      {
        'question': 'Saan nagmula ang Baybayin script?',
        'options': [
          'Chinese script',
          'Arabic script',
          'Brahmi script ng India',
          'Latin script',
        ],
        'correctIndex': 2,
      },
    ]);
  }

  Map<String, dynamic> get _currentQuestion =>
      _currentQuestionIndex < _quizQuestions.length
          ? _quizQuestions[_currentQuestionIndex]
          : _quizQuestions.last;

  bool get _isLastQuestion =>
      _currentQuestionIndex >= _quizQuestions.length - 1;

  void _selectOption(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedOptionIndex = index;
    });
    HapticFeedback.selectionClick();
  }

  void _submitAnswer() {
    if (_selectedOptionIndex == null || _hasAnswered) return;

    final isCorrect =
        _selectedOptionIndex == _currentQuestion['correctIndex'];

    setState(() {
      _hasAnswered = true;
      if (isCorrect) {
        _score += _pointsPerCorrectAnswer;
      }
    });

    if (isCorrect) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    // Show feedback
    _showAnswerFeedback(isCorrect);
  }

  void _showAnswerFeedback(bool isCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: AlertDialog(
          backgroundColor: _backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.red,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                isCorrect ? 'Tama!' : 'Mali',
                style: TextStyle(
                  color: isCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            isCorrect
                ? 'Mahusay! Tama ang iyong sagot.'
                : 'Subukan muli ang pagbabasa ng aralin.',
            style: TextStyle(fontSize: 16, color: _textColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (_isLastQuestion) {
                  _showFinalScore();
                } else {
                  _nextQuestion();
                }
              },
              child: Text(
                _isLastQuestion ? 'Tingnan ang Iskor' : 'Sunod',
                style: TextStyle(color: _textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _selectedOptionIndex = null;
      _hasAnswered = false;
    });
  }

  void _showFinalScore() {
    final totalQuestions = _quizQuestions.length;
    final maxScore = totalQuestions * _pointsPerCorrectAnswer;
    final percentage = (_score / maxScore * 100).round();

    String message;
    IconData icon;
    Color color;

    if (percentage >= 80) {
      message = 'Napakahusay! Mahusay ang iyong kaalaman sa Baybayin!';
      icon = Icons.emoji_events;
      color = Colors.amber;
    } else if (percentage >= 60) {
      message = 'Mabuti! May alam ka na tungkol sa Baybayin.';
      icon = Icons.thumb_up;
      color = _primaryYellow;
    } else {
      message = 'Kailangan mo pang mag-aral ng higit pa tungkol sa Baybayin.';
      icon = Icons.school;
      color = _primaryYellow;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: AlertDialog(
          backgroundColor: _backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 12),
              Text(
                'Natapos ang Quiz!',
                style: TextStyle(fontWeight: FontWeight.bold, color: _textColor),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: TextStyle(fontSize: 16, color: _textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _primaryYellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_score / $maxScore',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tama: ${_score ~/ _pointsPerCorrectAnswer} sa $totalQuestions',
                      style: TextStyle(fontSize: 14, color: _textColor.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _restartQuiz();
              },
              child: Text('Subukan Muli', style: TextStyle(color: _textColor)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, {
                  'completed': true,
                  'score': _score,
                  'maxScore': maxScore,
                  'percentage': percentage,
                });
              },
              child: Text('Ipagpatuloy', style: TextStyle(color: _textColor)),
            ),
          ],
        ),
      ),
    );
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _hasAnswered = false;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(widget.lessonTitle),
        backgroundColor: _primaryYellow,
        foregroundColor: _textColor,
        elevation: 2,
        shadowColor: _primaryYellow.withValues(alpha: 0.5),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryYellow.withValues(alpha: 0.15),
              border: Border(
                bottom: BorderSide(color: _primaryYellow.withValues(alpha: 0.3), width: 2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tanong ${_currentQuestionIndex + 1} ng ${_quizQuestions.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryYellow,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryYellow.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$_score',
                            style: TextStyle(
                              color: _textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _quizQuestions.length,
                  backgroundColor: _primaryYellow.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(_primaryYellow),
                ),
              ],
            ),
          ),

          // Question and options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question card
                  Card(
                    elevation: 4,
                    shadowColor: _primaryYellow.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        _currentQuestion['question'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                          color: _textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Options
                  ...(_currentQuestion['options'] as List<String>)
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    final isSelected = _selectedOptionIndex == index;
                    final isCorrect =
                        index == _currentQuestion['correctIndex'];
                    final showCorrect = _hasAnswered && isCorrect;
                    final showIncorrect =
                        _hasAnswered && isSelected && !isCorrect;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOptionCard(
                        option,
                        isSelected,
                        showCorrect,
                        showIncorrect,
                        () => _selectOption(index),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Submit button
                  ElevatedButton(
                    onPressed:
                        _selectedOptionIndex != null && !_hasAnswered
                            ? _submitAnswer
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryYellow,
                      foregroundColor: _textColor,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      shadowColor: _primaryYellow.withValues(alpha: 0.5),
                    ),
                    child: const Text(
                      'I-submit ang Sagot',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildOptionCard(
    String option,
    bool isSelected,
    bool showCorrect,
    bool showIncorrect,
    VoidCallback onTap,
  ) {
    Color backgroundColor = Colors.grey[100]!;
    Color borderColor = Colors.grey[300]!;
    Widget? leadingIcon;

    if (showCorrect) {
      backgroundColor = Colors.green[50]!;
      borderColor = Colors.green[600]!;
      leadingIcon = Icon(Icons.check_circle, color: Colors.green[600]);
    } else if (showIncorrect) {
      backgroundColor = Colors.red[50]!;
      borderColor = Colors.red[600]!;
      leadingIcon = Icon(Icons.cancel, color: Colors.red[600]);
    } else if (isSelected) {
      backgroundColor = _primaryYellow.withValues(alpha: 0.2);
      borderColor = _primaryYellow;
    }

    return GestureDetector(
      onTap: _hasAnswered ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: isSelected && !_hasAnswered
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
            if (leadingIcon != null) ...[
              leadingIcon,
              const SizedBox(width: 12),
            ] else ...[
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
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: _textColor,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 15,
                  color: showIncorrect ? Colors.red[900] : _textColor,
                  fontWeight: (isSelected || showCorrect || showIncorrect)
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
