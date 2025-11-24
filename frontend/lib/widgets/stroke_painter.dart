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

  StrokePainter({
    required this.strokes,
    this.currentStroke,
    this.strokeColor = Colors.black,
    this.strokeWidth = 4.0,
    this.showGuidelines = true,
    this.referenceCharacter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw guidelines if enabled
    if (showGuidelines) {
      _drawGuidelines(canvas, size);
    }

    // Draw reference character if provided
    if (referenceCharacter != null && referenceCharacter!.isNotEmpty) {
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

  @override
  bool shouldRepaint(covariant StrokePainter oldDelegate) {
    return strokes != oldDelegate.strokes ||
        currentStroke != oldDelegate.currentStroke ||
        strokeColor != oldDelegate.strokeColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        showGuidelines != oldDelegate.showGuidelines ||
        referenceCharacter != oldDelegate.referenceCharacter;
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

  const DrawingCanvas({
    super.key,
    required this.onStrokesChanged,
    this.initialStrokes = const [],
    this.strokeColor = Colors.black,
    this.strokeWidth = 4.0,
    this.showGuidelines = true,
    this.referenceCharacter,
    this.height,
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
    if (_currentStroke != null) {
      setState(() {
        _currentStroke!.points.add(
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
    // This provides more direct access to pointer events and works well on both platforms
    return Listener(
      onPointerDown: (event) => _handlePointerDown(event.localPosition),
      onPointerMove: (event) => _handlePointerMove(event.localPosition),
      onPointerUp: (event) => _handlePointerUp(),
      onPointerCancel: (event) => _handlePointerUp(),
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        painter: StrokePainter(
          strokes: _strokes,
          currentStroke: _currentStroke,
          strokeColor: widget.strokeColor,
          strokeWidth: widget.strokeWidth,
          showGuidelines: widget.showGuidelines,
          referenceCharacter: widget.referenceCharacter,
        ),
        child: Container(
          height: widget.height,
          color: Colors.white,
        ),
      ),
    );
  }
}
