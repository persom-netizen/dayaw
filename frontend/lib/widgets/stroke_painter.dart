import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../services/stroke_processor.dart';

/// Custom painter for drawing strokes on canvas
class StrokePainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentStroke;
  final Color strokeColor;
  final double strokeWidth;
  final bool showGuidelines;
  final String? referenceCharacter;
  final bool showGuideStrokes;

  StrokePainter({
    required this.strokes,
    this.currentStroke,
    this.strokeColor = Colors.black,
    this.strokeWidth = 12.0,
    this.showGuidelines = true,
    this.referenceCharacter,
    this.showGuideStrokes = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw white background first to ensure visibility
    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    // Draw guidelines if enabled
    if (showGuidelines) {
      _drawGuidelines(canvas, size);
    }

    // Draw guide strokes if enabled
    if (showGuideStrokes && referenceCharacter != null && referenceCharacter!.isNotEmpty) {
      _drawGuideStrokes(canvas, size);
    }

    // Draw completed strokes with full opacity for high contrast
    final completedPaint = Paint()
      ..color = strokeColor.withOpacity(1.0)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (var stroke in strokes) {
      _drawStroke(canvas, stroke, completedPaint);
    }

    // Draw current stroke being drawn with full opacity for visibility
    if (currentStroke != null) {
      final currentPaint = Paint()
        ..color = strokeColor.withOpacity(1.0)
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      _drawStroke(canvas, currentStroke!, currentPaint);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke, Paint paint) {
    if (stroke.points.length < 2) {
      // Draw a single point as a circle
      if (stroke.points.isNotEmpty) {
        final point = stroke.points.first;
        canvas.drawCircle(
          Offset(point.x, point.y),
          strokeWidth / 2,
          paint,
        );
      }
      return;
    }

    final path = Path();
    path.moveTo(stroke.points.first.x, stroke.points.first.y);

    for (int i = 1; i < stroke.points.length; i++) {
      final point = stroke.points[i];
      path.lineTo(point.x, point.y);
    }

    canvas.drawPath(path, paint);
  }

  void _drawGuidelines(Canvas canvas, Size size) {
    final guidelinePaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw center cross
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      guidelinePaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      guidelinePaint,
    );

    // Draw border
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      guidelinePaint,
    );

    // Draw diagonal guidelines with lighter color
    final diagonalPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      const Offset(0, 0),
      Offset(size.width, size.height),
      diagonalPaint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      diagonalPaint,
    );
  }

  void _drawReferenceCharacter(Canvas canvas, Size size) {
    // Draw the reference character in light gray behind the drawing area
    final textPainter = TextPainter(
      text: TextSpan(
        text: referenceCharacter,
        style: TextStyle(
          fontSize: size.width * 0.6,
          color: Colors.grey.withOpacity(0.2),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Center the character
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    textPainter.paint(canvas, offset);
  }

  void _drawGuideStrokes(Canvas canvas, Size size) {
    if (referenceCharacter == null || referenceCharacter!.isEmpty) return;

    // Get guide strokes for the character
    final guideStrokes = _getBaybayinGuideStrokes(referenceCharacter!, size);
    if (guideStrokes.isEmpty) return;

    // Draw guide strokes with semi-transparent color
    final guidePaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (var stroke in guideStrokes) {
      _drawStroke(canvas, stroke, guidePaint);
    }
  }

  List<Stroke> _getBaybayinGuideStrokes(String character, Size size) {
    // Define guide strokes for each Baybayin vowel
    // Coordinates are normalized to 0-1 range and scaled to canvas size
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width * 0.4; // 40% of canvas width for character size

    switch (character) {
      case 'ᜀ': // A - vertical line with small curve at bottom
        return [
          Stroke([
            StrokePoint(x: centerX, y: centerY - scale * 0.8),
            StrokePoint(x: centerX, y: centerY + scale * 0.8),
          ]),
        ];

      case 'ᜁ': // I/E - vertical line with curve at top
        return [
          Stroke([
            StrokePoint(x: centerX - scale * 0.1, y: centerY - scale * 0.7),
            StrokePoint(x: centerX, y: centerY - scale * 0.8),
            StrokePoint(x: centerX + scale * 0.1, y: centerY - scale * 0.7),
          ]),
          Stroke([
            StrokePoint(x: centerX, y: centerY - scale * 0.7),
            StrokePoint(x: centerX, y: centerY + scale * 0.8),
          ]),
        ];

      case 'ᜂ': // U/O - vertical line with curve at bottom
        return [
          Stroke([
            StrokePoint(x: centerX, y: centerY - scale * 0.8),
            StrokePoint(x: centerX, y: centerY + scale * 0.7),
          ]),
          Stroke([
            StrokePoint(x: centerX - scale * 0.1, y: centerY + scale * 0.7),
            StrokePoint(x: centerX, y: centerY + scale * 0.8),
            StrokePoint(x: centerX + scale * 0.1, y: centerY + scale * 0.7),
          ]),
        ];

      default:
        return [];
    }
  }

  @override
  bool shouldRepaint(covariant StrokePainter oldDelegate) {
    return strokes != oldDelegate.strokes ||
        currentStroke != oldDelegate.currentStroke ||
        strokeColor != oldDelegate.strokeColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        showGuidelines != oldDelegate.showGuidelines ||
        referenceCharacter != oldDelegate.referenceCharacter ||
        showGuideStrokes != oldDelegate.showGuideStrokes;
  }
}

/// Widget that provides a drawing canvas with stroke capture
class DrawingCanvas extends StatefulWidget {
  final Function(List<Stroke>) onStrokesChanged;
  final List<Stroke> initialStrokes;
  final Color strokeColor;
  final double strokeWidth;
  final bool showGuidelines;
  final String? referenceCharacter;
  final double? height;
  final bool showGuideStrokes;

  const DrawingCanvas({
    super.key,
    required this.onStrokesChanged,
    this.initialStrokes = const [],
    this.strokeColor = Colors.black,
    this.strokeWidth = 12.0,
    this.showGuidelines = true,
    this.referenceCharacter,
    this.height,
    this.showGuideStrokes = true,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  late List<Stroke> _strokes;
  Stroke? _currentStroke;
  bool _isUsingPointerEvents = false;

  @override
  void initState() {
    super.initState();
    _strokes = List.from(widget.initialStrokes);
  }

  void _onPanStart(DragStartDetails details) {
    // Skip if already using pointer events
    if (_isUsingPointerEvents) return;
    
    setState(() {
      _currentStroke = Stroke([
        StrokePoint(
          x: details.localPosition.dx,
          y: details.localPosition.dy,
        ),
      ]);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    // Skip if already using pointer events
    if (_isUsingPointerEvents) return;
    
    setState(() {
      _currentStroke?.points.add(
        StrokePoint(
          x: details.localPosition.dx,
          y: details.localPosition.dy,
        ),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // Skip if already using pointer events
    if (_isUsingPointerEvents) return;
    
    if (_currentStroke != null && _currentStroke!.points.isNotEmpty) {
      setState(() {
        _strokes.add(_currentStroke!);
        _currentStroke = null;
      });
      widget.onStrokesChanged(_strokes);
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    // Mark that we're using pointer events to prevent duplicate handling
    _isUsingPointerEvents = true;
    
    setState(() {
      _currentStroke = Stroke([
        StrokePoint(
          x: event.localPosition.dx,
          y: event.localPosition.dy,
        ),
      ]);
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    // Only add points if we have a current stroke
    if (_currentStroke == null) return;
    
    setState(() {
      _currentStroke!.points.add(
        StrokePoint(
          x: event.localPosition.dx,
          y: event.localPosition.dy,
        ),
      );
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_currentStroke != null && _currentStroke!.points.isNotEmpty) {
      setState(() {
        _strokes.add(_currentStroke!);
        _currentStroke = null;
      });
      widget.onStrokesChanged(_strokes);
    }
    
    // Reset flag after a short delay to allow next stroke to work
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _isUsingPointerEvents = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Ensure canvas has explicit dimensions for web compatibility
            final width = constraints.maxWidth.isFinite 
                ? constraints.maxWidth 
                : MediaQuery.of(context).size.width;
            final height = widget.height ?? 300;
            
            return SizedBox(
              width: width,
              height: height,
              child: CustomPaint(
                painter: StrokePainter(
                  strokes: _strokes,
                  currentStroke: _currentStroke,
                  strokeColor: widget.strokeColor,
                  strokeWidth: widget.strokeWidth,
                  showGuidelines: widget.showGuidelines,
                  referenceCharacter: widget.referenceCharacter,
                  showGuideStrokes: widget.showGuideStrokes,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
