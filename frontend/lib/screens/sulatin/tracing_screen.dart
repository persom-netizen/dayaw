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
  List<Stroke> _strokes = [];
  int _score = 0;
  int _attempts = 0;
  bool _isSubmitting = false;

  // Baybayin vowel mappings - only vowels
  static const Map<String, String> _characterNames = {
    'A': 'ᜀ',
    'E': 'ᜁ',
    'I': 'ᜁ',
    'O': 'ᜂ',
    'U': 'ᜂ',
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

    // For now, accept any drawing with strokes
    // In production, this would call an ML model for recognition
    final hasEnoughStrokes = _strokes.length >= 1;

    setState(() {
      _isSubmitting = false;
    });

    if (hasEnoughStrokes) {
      _score += 20;
      HapticFeedback.heavyImpact();
      _showSuccessDialog();
    } else {
      HapticFeedback.lightImpact();
      _showMessage('Subukan muli. Gumuhit ng mas malinaw.');
    }
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 32),
            const SizedBox(width: 12),
            const Text(
              'Mahusay!',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tama ang iyong pagsulat ng "$_baybayinCharacter" (${widget.expectedCharacter})!',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    '+$_score puntos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
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

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
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
                  strokeColor: Colors.purple[600]!,
                  strokeWidth: 6.0,
                  showGuidelines: true,
                  referenceCharacter: _baybayinCharacter,
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