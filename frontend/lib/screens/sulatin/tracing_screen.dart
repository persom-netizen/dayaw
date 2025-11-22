import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/stroke_processor.dart';
import '../../services/sulatin_api.dart';
import '../../widgets/stroke_painter.dart';

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
  bool _isLoading = false;
  String? _predictionResult;
  double? _confidence;
  bool? _isCorrect;

  void _onStrokesChanged(List<Stroke> strokes) {
    setState(() {
      _strokes = strokes;
      // Reset prediction when user draws more
      if (_predictionResult != null) {
        _predictionResult = null;
        _confidence = null;
        _isCorrect = null;
      }
    });
  }

  void _clearCanvas() {
    setState(() {
      _strokes = [];
      _predictionResult = null;
      _confidence = null;
      _isCorrect = null;
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _submitDrawing() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Magsulat muna ng karakter'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Normalize strokes for prediction
      final normalizedStrokes = StrokeProcessor.normalizeStrokes(
        _strokes,
        canvasWidth: 300,
        canvasHeight: 300,
        targetSize: 256,
      );

      // Convert to JSON format
      final strokesJson = StrokeProcessor.strokesToJson(normalizedStrokes);

      // Make prediction
      final result = await SulatinApiClient.predict(strokes: strokesJson);

      if (result['success']) {
        final data = result['data'];
        final predictedLabel = data['label'];
        final confidence = data['confidence'];

        setState(() {
          _predictionResult = predictedLabel;
          _confidence = confidence;
          _isCorrect = (predictedLabel == widget.expectedCharacter) && 
                       (confidence >= 0.6);
          _isLoading = false;
        });

        // Haptic feedback based on result
        if (_isCorrect == true) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.vibrate();
        }

        // Show result dialog
        _showResultDialog();
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Nabigo ang prediction'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _isCorrect == true ? Icons.check_circle : Icons.cancel,
              color: _isCorrect == true ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              _isCorrect == true ? 'Tama!' : 'Mali',
              style: TextStyle(
                color: _isCorrect == true ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isCorrect == true) ...[
              const Text(
                'Mahusay! Tama ang iyong sulat.',
                style: TextStyle(fontSize: 16),
              ),
            ] else ...[
              const Text(
                'Subukan ulit.',
                style: TextStyle(fontSize: 16),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inaasahang karakter: ${widget.expectedCharacter}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Nakitang karakter: $_predictionResult',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Tumpak: ${(_confidence! * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_isCorrect != true)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearCanvas();
              },
              child: const Text('Subukan Muli'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_isCorrect == true) {
                Navigator.pop(context, {
                  'completed': true,
                  'score': _confidence,
                });
              }
            },
            child: Text(_isCorrect == true ? 'Ipagpatuloy' : 'OK'),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.edit,
                      size: 48,
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Sulatin ang sumusunod na karakter:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.expectedCharacter,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gamitin ang iyong daliri upang isulat ang karakter',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Drawing canvas
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple[200]!, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: DrawingCanvas(
                    onStrokesChanged: _onStrokesChanged,
                    initialStrokes: _strokes,
                    strokeColor: Colors.purple[700]!,
                    strokeWidth: 6.0,
                    showGuidelines: true,
                    referenceCharacter: widget.expectedCharacter,
                    height: 300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

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
                        color: _strokes.isEmpty
                            ? Colors.grey[300]!
                            : Colors.purple[600]!,
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
                    onPressed: _strokes.isEmpty || _isLoading
                        ? null
                        : _submitDrawing,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isLoading ? 'Sinusuri...' : 'I-submit'),
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

            // Tips section
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.purple[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Mga Tip:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Sundin ang mga guhit na gabay\n'
                    '• Isulat nang mabagal at maingat\n'
                    '• Siguraduhing kumpleto ang karakter\n'
                    '• Gumamit ng wastong direksyon ng stroke',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.purple[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
