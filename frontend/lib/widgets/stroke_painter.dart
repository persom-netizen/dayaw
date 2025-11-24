import 'package:flutter/material.dart';
import '../services/stroke_processor.dart';

/// Custom painter for drawing strokes on canvas
class StrokePainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentStroke;
  final Color strokeColor;
  final double strokeWidth;
  final bool showGuidelines;
  final String? referenceCharacter;
  final bool showTracingGuide;

  StrokePainter({
    required this.strokes,
    this.currentStroke,
    this.strokeColor = Colors.black,
    this.strokeWidth = 4.0,
    this.showGuidelines = true,
    this.referenceCharacter,
    this.showTracingGuide = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw guidelines if enabled
    if (showGuidelines) {
      _drawGuidelines(canvas, size);
    }

    // Draw reference character if provided
    if (referenceCharacter != null && referenceCharacter!.isNotEmpty && showTracingGuide) {
      _drawReferenceCharacter(canvas, size);
    }

    // Draw completed strokes
    final completedPaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (var stroke in strokes) {
      _drawStroke(canvas, stroke, completedPaint);
    }

    // Draw current stroke being drawn with slightly lighter color
    if (currentStroke != null) {
      final currentPaint = Paint()
        ..color = strokeColor.withOpacity(0.8)
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
    // Draw the reference character as a tracing guide
    // First draw a lighter filled version for context
    final backgroundTextPainter = TextPainter(
      text: TextSpan(
        text: referenceCharacter,
        style: TextStyle(
          fontSize: size.width * 0.6,
          color: Colors.grey.withOpacity(0.15),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    backgroundTextPainter.layout();

    // Center the character
    final offset = Offset(
      (size.width - backgroundTextPainter.width) / 2,
      (size.height - backgroundTextPainter.height) / 2,
    );

    backgroundTextPainter.paint(canvas, offset);
    
    // Draw the outline/stroke version for tracing
    final outlineTextPainter = TextPainter(
      text: TextSpan(
        text: referenceCharacter,
        style: TextStyle(
          fontSize: size.width * 0.6,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.0
            ..color = Colors.deepPurple.withOpacity(0.4),
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    outlineTextPainter.layout();
    outlineTextPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant StrokePainter oldDelegate) {
    return strokes != oldDelegate.strokes ||
        currentStroke != oldDelegate.currentStroke ||
        strokeColor != oldDelegate.strokeColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        showGuidelines != oldDelegate.showGuidelines ||
        referenceCharacter != oldDelegate.referenceCharacter ||
        showTracingGuide != oldDelegate.showTracingGuide;
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
  final bool showTracingGuide;

  const DrawingCanvas({
    super.key,
    required this.onStrokesChanged,
    this.initialStrokes = const [],
    this.strokeColor = Colors.black,
    this.strokeWidth = 4.0,
    this.showGuidelines = true,
    this.referenceCharacter,
    this.height,
    this.showTracingGuide = true,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  late List<Stroke> _strokes;
  Stroke? _currentStroke;

  @override
  void initState() {
    super.initState();
    _strokes = List.from(widget.initialStrokes);
  }

  void _handlePointerDown(Offset position) {
    setState(() {
      _currentStroke = Stroke([
        StrokePoint(
          x: position.dx,
          y: position.dy,
        ),
      ]);
    });
  }

  void _handlePointerMove(Offset position) {
    final currentStroke = _currentStroke;
    if (currentStroke != null) {
      setState(() {
        currentStroke.points.add(
          StrokePoint(
            x: position.dx,
            y: position.dy,
          ),
        );
      });
    }
  }

  void _handlePointerUp() {
    if (_currentStroke != null && _currentStroke!.points.isNotEmpty) {
      setState(() {
        _strokes.add(_currentStroke!);
        _currentStroke = null;
      });
      widget.onStrokesChanged(_strokes);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Listener for better pointer event handling across web and mobile
    // Listener provides direct access to pointer events and works consistently across:
    // - Web: Handles mouse, touch, and stylus input reliably
    // - Mobile: Better touch tracking with precise pointer coordinates
    // - Improved over GestureDetector which can miss rapid pointer movements
    return Listener(
      onPointerDown: (event) => _handlePointerDown(event.localPosition),
      onPointerMove: (event) => _handlePointerMove(event.localPosition),
      onPointerUp: (event) => _handlePointerUp(),
      onPointerCancel: (event) => _handlePointerUp(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: widget.height,
        color: Colors.white,
        child: CustomPaint(
          foregroundPainter: StrokePainter(
            strokes: _strokes,
            currentStroke: _currentStroke,
            strokeColor: widget.strokeColor,
            strokeWidth: widget.strokeWidth,
            showGuidelines: widget.showGuidelines,
            referenceCharacter: widget.referenceCharacter,
            showTracingGuide: widget.showTracingGuide,
          ),
          child: Container(),
        ),
      ),
    );
  }
}
