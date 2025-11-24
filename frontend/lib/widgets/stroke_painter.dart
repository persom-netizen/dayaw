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
            
            return CustomPaint(
              painter: StrokePainter(
                strokes: _strokes,
                currentStroke: _currentStroke,
                strokeColor: widget.strokeColor,
                strokeWidth: widget.strokeWidth,
                showGuidelines: widget.showGuidelines,
                referenceCharacter: widget.referenceCharacter,
              ),
              child: Container(
                width: width,
                height: height,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }
}
