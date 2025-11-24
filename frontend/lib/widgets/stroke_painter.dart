import 'package:flutter/material.dart';
import '../services/stroke_processor.dart';

/// Custom painter for drawing strokes on canvas
class StrokePainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? currentStroke;
  final Color strokeColor;
  final double strokeWidth;

  StrokePainter({
    required this.strokes,
    this.currentStroke,
    this.strokeColor = Colors.black,
    this.strokeWidth = 12.0,
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
        canvas.drawCircle(Offset(point.x, point.y), strokeWidth / 2, paint);
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

  @override
  bool shouldRepaint(covariant StrokePainter oldDelegate) {
    return strokes != oldDelegate.strokes ||
        currentStroke != oldDelegate.currentStroke ||
        strokeColor != oldDelegate.strokeColor ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}

/// Widget that provides a drawing canvas with stroke capture
class DrawingCanvas extends StatefulWidget {
  final Function(List<Stroke>) onStrokesChanged;
  final List<Stroke> initialStrokes;
  final Color strokeColor;
  final double strokeWidth;
  final double? height;

  const DrawingCanvas({
    super.key,
    required this.onStrokesChanged,
    this.initialStrokes = const [],
    this.strokeColor = Colors.black,
    this.strokeWidth = 12.0,
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

  @override
  void didUpdateWidget(DrawingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update internal strokes when initialStrokes changes (e.g., when cleared)
    if (widget.initialStrokes != oldWidget.initialStrokes) {
      setState(() {
        _strokes = List.from(widget.initialStrokes);
      });
    }
  }

  void _onPanStart(DragStartDetails details) {
    // Skip if already using pointer events
    if (_isUsingPointerEvents) return;

    setState(() {
      _currentStroke = Stroke([
        StrokePoint(x: details.localPosition.dx, y: details.localPosition.dy),
      ]);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    // Skip if already using pointer events
    if (_isUsingPointerEvents) return;

    setState(() {
      _currentStroke?.points.add(
        StrokePoint(x: details.localPosition.dx, y: details.localPosition.dy),
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
        StrokePoint(x: event.localPosition.dx, y: event.localPosition.dy),
      ]);
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    // Only add points if we have a current stroke
    if (_currentStroke == null) return;

    setState(() {
      _currentStroke!.points.add(
        StrokePoint(x: event.localPosition.dx, y: event.localPosition.dy),
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
