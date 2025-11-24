import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/stroke_painter.dart';
import '../../services/stroke_processor.dart';

class TracingScreen extends StatefulWidget {
  final int lessonId;
  final String expectedCharacter;
  final String lessonTitle;

  const TracingScreen({
    super.key,
    required this.lessonId,
    required this.expectedCharacter,
    required this.lessonTitle,
  });

  @override
  State<TracingScreen> createState() => _TracingScreenState();
}

class _TracingScreenState extends State<TracingScreen> {
  // Scoring and validation constants
  static const int _minPointsRequired = 10;
  
  List<Stroke> _strokes = [];
  int _score = 0;
  int _attempts = 0;
  bool _isSubmitting = false;
  bool _showGuideStrokes = true;
  int _lastAccuracyScore = 0;
  String _lastFeedback = '';

  // Baybayin vowel mappings - only vowels
  // Note: In Baybayin script, E and I share the same character (ᜁ),
  // and O and U share the same character (ᜂ). This is intentional and
  // reflects the authentic Baybayin writing system where these vowel pairs
  // are not distinguished in written form.
  static const Map<String, String> _characterNames = {
    'A': 'ᜀ', // U+1700 TAGALOG LETTER A
    'E': 'ᜁ', // U+1701 TAGALOG LETTER I (also represents E)
    'I': 'ᜁ', // U+1701 TAGALOG LETTER I
    'O': 'ᜂ', // U+1702 TAGALOG LETTER U (also represents O)
    'U': 'ᜂ', // U+1702 TAGALOG LETTER U
  };

  String get _baybayinCharacter {
    return _characterNames[widget.expectedCharacter] ?? widget.expectedCharacter;
  }

  void _onStrokesChanged(List<Stroke> strokes) {
    setState(() {
      _strokes = strokes;
    });
  }

  void _clearCanvas() {
    setState(() {
      _strokes = [];
    });
    HapticFeedback.lightImpact();
  }

  void _submitDrawing() async {
    if (_strokes.isEmpty) {
      _showMessage('Gumuhit muna ng karakter!');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _attempts++;
    });

    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Basic validation: check if strokes have enough points
    int totalPoints = 0;
    for (var stroke in _strokes) {
      totalPoints += stroke.points.length;
    }
    bool hasValidStrokes = totalPoints >= _minPointsRequired;

    if (!hasValidStrokes) {
      setState(() {
        _isSubmitting = false;
      });
      HapticFeedback.lightImpact();
      _showMessage('Subukan muli. Gumuhit ng mas malinaw at mas mahabang mga stroke.');
      return;
    }

    // Calculate accuracy score (1-100) based on stroke characteristics
    // Different expected stroke counts for each character
    int expectedStrokes = 1;
    if (_baybayinCharacter == 'ᜁ' || _baybayinCharacter == 'ᜂ') {
      expectedStrokes = 2; // I/E and U/O have 2 strokes
    }

    final accuracyScore = StrokeProcessor.calculateAccuracyScore(
      _strokes,
      expectedStrokeCount: expectedStrokes,
      minTotalLength: 100.0,
      maxTotalLength: 600.0,
    );

    final feedback = StrokeProcessor.getFeedbackMessage(accuracyScore);

    setState(() {
      _isSubmitting = false;
      _lastAccuracyScore = accuracyScore;
      _lastFeedback = feedback;
      _score += accuracyScore; // Add accuracy score to total
    });

    HapticFeedback.heavyImpact();
    _showSuccessDialog();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessDialog() {
    // Determine title based on score
    String title = 'Mahusay!';
    Color titleColor = Colors.green;
    IconData titleIcon = Icons.check_circle;
    
    if (_lastAccuracyScore >= 90) {
      title = 'Perpekto!';
      titleColor = Colors.green;
      titleIcon = Icons.star;
    } else if (_lastAccuracyScore >= 71) {
      title = 'Napakagaling!';
      titleColor = Colors.green;
      titleIcon = Icons.check_circle;
    } else if (_lastAccuracyScore >= 41) {
      title = 'Maganda!';
      titleColor = Colors.blue;
      titleIcon = Icons.check_circle;
    } else if (_lastAccuracyScore >= 21) {
      title = 'Mabuti!';
      titleColor = Colors.orange;
      titleIcon = Icons.check_circle_outline;
    } else {
      title = 'Magpatuloy!';
      titleColor = Colors.orange;
      titleIcon = Icons.info_outline;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(titleIcon, color: titleColor, size: 32),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _lastFeedback,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 32),
                      const SizedBox(width: 8),
                      Text(
                        'Tumpak: $_lastAccuracyScore%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '+$_lastAccuracyScore puntos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kabuuang Puntos: $_score',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _clearCanvas();
            },
            child: const Text('Subukan Muli'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, {
                'completed': true,
                'score': _score,
                'attempts': _attempts,
              }); // Return to lesson detail
            },
            child: const Text('Ipagpatuloy'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonTitle),
        backgroundColor: Colors.purple[600],
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$_score',
                      style: TextStyle(
                        color: Colors.purple[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Character to trace
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Isulat ang sumusunod na karakter:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Show Baybayin character
                    Text(
                      _baybayinCharacter,
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Show Roman letter
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.expectedCharacter,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions and guide toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.purple[600]),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Gumuhit gamit ang iyong daliri o mouse sa ibaba',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.purple[600], size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Ipakita ang gabay',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Switch(
                        value: _showGuideStrokes,
                        onChanged: (value) {
                          setState(() {
                            _showGuideStrokes = value;
                          });
                        },
                        activeColor: Colors.purple[600],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Drawing canvas
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: DrawingCanvas(
                  onStrokesChanged: _onStrokesChanged,
                  initialStrokes: _strokes,
                  strokeColor: Colors.black,
                  strokeWidth: 12.0,
                  showGuidelines: true,
                  referenceCharacter: _baybayinCharacter,
                  showGuideStrokes: _showGuideStrokes,
                  height: 350,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _strokes.isEmpty ? null : _clearCanvas,
                    icon: const Icon(Icons.clear),
                    label: const Text('Burahin'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: Colors.purple[600]!,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitDrawing,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isSubmitting ? 'Sinusuri...' : 'I-submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('Mga Stroke', '${_strokes.length}'),
                  _buildStat('Mga Pagsubok', '$_attempts'),
                  _buildStat('Puntos', '$_score'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.purple[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}