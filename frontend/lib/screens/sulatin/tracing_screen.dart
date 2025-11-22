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
  static const double _confidenceThreshold = 0.6;
  
  // Character name mappings
  static const Map<String, Map<String, dynamic>> _characterNames = {
    'A': {'tagalog': 'A', 'english': 'A', 'strokes': 3},
    'E': {'tagalog': 'E', 'english': 'E', 'strokes': 4},
    'I': {'tagalog': 'I', 'english': 'I', 'strokes': 3},
    'O': {'tagalog': 'O', 'english': 'O', 'strokes': 1},
    'U': {'tagalog': 'U', 'english': 'U', 'strokes': 1},
    '.': {'tagalog': 'Tuldok', 'english': 'Period', 'strokes': 1},
    ',': {'tagalog': 'Kuwit', 'english': 'Comma', 'strokes': 1},
  };
  
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
                       (confidence >= _confidenceThreshold);
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              _isCorrect == true ? Icons.check_circle : Icons.cancel,
              color: _isCorrect == true ? Colors.green[600] : Colors.red[600],
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isCorrect == true ? 'Tama! ✅' : 'Mali ❌',
                style: TextStyle(
                  color: _isCorrect == true ? Colors.green[700] : Colors.red[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success or Try Again message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isCorrect == true ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isCorrect == true ? Colors.green[200]! : Colors.red[200]!,
                  width: 2,
                ),
              ),
              child: Text(
                _isCorrect == true
                    ? 'Mahusay! Tama ang iyong sulat. Ipagpatuloy ang susunod na karakter.'
                    : 'Subukan muli. Sundin ang gabay at isulat nang maingat.',
                style: TextStyle(
                  fontSize: 16,
                  color: _isCorrect == true ? Colors.green[900] : Colors.red[900],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            
            // Accuracy percentage - prominently displayed
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isCorrect == true
                      ? [Colors.green[400]!, Colors.green[600]!]
                      : [Colors.orange[400]!, Colors.orange[600]!],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Tumpak (Accuracy)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(_confidence! * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Details box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    'Inaasahang karakter:',
                    widget.expectedCharacter,
                    Colors.purple[700]!,
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Nakitang karakter:',
                    _predictionResult ?? '-',
                    _isCorrect == true ? Colors.green[700]! : Colors.red[700]!,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_isCorrect != true)
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _clearCanvas();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Subukan Muli'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                side: BorderSide(color: Colors.grey[600]!, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          if (_isCorrect != true) const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              if (_isCorrect == true) {
                Navigator.pop(context, {
                  'completed': true,
                  'score': _confidence,
                });
              }
            },
            icon: Icon(_isCorrect == true ? Icons.arrow_forward : Icons.close),
            label: Text(_isCorrect == true ? 'Ipagpatuloy' : 'OK'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isCorrect == true ? Colors.green[600] : Colors.grey[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final characterInfo = _characterNames[widget.expectedCharacter];
    final tagalogName = characterInfo?['tagalog'] ?? widget.expectedCharacter;
    final englishName = characterInfo?['english'] ?? widget.expectedCharacter;
    final strokeCount = characterInfo?['strokes']?.toString() ?? '?';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonTitle),
        backgroundColor: Colors.deepPurple[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // LARGE CHARACTER REFERENCE BOX
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple[700]!, Colors.deepPurple[900]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'I-trace ang:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // LARGE CHARACTER DISPLAY
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Text(
                      widget.expectedCharacter,
                      style: TextStyle(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[800],
                        height: 1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Character names
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Ito ang titik na iyong i-trace:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$tagalogName ($englishName)',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.gesture, color: Colors.white.withOpacity(0.9), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Bilang ng stroke: $strokeCount',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // DRAWING CANVAS SECTION
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Iguhit dito:" header
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.deepPurple[700], size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Iguhit dito:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple[800],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Canvas with border
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.deepPurple[300]!, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: DrawingCanvas(
                        onStrokesChanged: _onStrokesChanged,
                        initialStrokes: _strokes,
                        strokeColor: Colors.deepPurple[700]!,
                        strokeWidth: 6.0,
                        showGuidelines: true,
                        referenceCharacter: widget.expectedCharacter,
                        height: 350,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _strokes.isEmpty ? null : _clearCanvas,
                    icon: const Icon(Icons.clear),
                    label: const Text('Burahin'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(
                        color: _strokes.isEmpty
                            ? Colors.grey[300]!
                            : Colors.grey[600]!,
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
                        : const Icon(Icons.send),
                    label: Text(_isLoading ? 'Sinusuri...' : 'Ipadala'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),

            // TIPS SECTION
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple[200]!, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.deepPurple[700], size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Mga Tip:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Sundin ang mga guhit na gabay\n'
                    '• Isulat nang mabagal at maingat\n'
                    '• Siguraduhing kumpleto ang karakter\n'
                    '• Gumamit ng wastong direksyon ng stroke',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.deepPurple[900],
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
