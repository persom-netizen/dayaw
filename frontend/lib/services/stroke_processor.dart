import 'dart:math';

/// Represents a single point in a stroke
class StrokePoint {
  final double x;
  final double y;
  final DateTime timestamp;

  StrokePoint({
    required this.x,
    required this.y,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
      };
}

/// Represents a complete stroke (series of points)
class Stroke {
  final List<StrokePoint> points;

  Stroke(this.points);

  Map<String, dynamic> toJson() => points.map((p) => p.toJson()).toList();

  double get length {
    if (points.length < 2) return 0;
    double total = 0;
    for (int i = 1; i < points.length; i++) {
      total += _distance(points[i - 1], points[i]);
    }
    return total;
  }

  double _distance(StrokePoint p1, StrokePoint p2) {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
  }
}

/// Process and normalize stroke data for ML model
class StrokeProcessor {
  /// Convert list of strokes to JSON format for API
  static List<List<Map<String, dynamic>>> strokesToJson(List<Stroke> strokes) {
    return strokes.map((stroke) => stroke.toJson() as List<Map<String, dynamic>>).toList();
  }

  /// Normalize strokes to fit within a canvas size
  static List<Stroke> normalizeStrokes(
    List<Stroke> strokes, {
    required double canvasWidth,
    required double canvasHeight,
    double targetSize = 256.0,
  }) {
    if (strokes.isEmpty) return strokes;

    // Find bounding box
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (var stroke in strokes) {
      for (var point in stroke.points) {
        minX = min(minX, point.x);
        minY = min(minY, point.y);
        maxX = max(maxX, point.x);
        maxY = max(maxY, point.y);
      }
    }

    // Calculate scale to fit in target size
    double width = maxX - minX;
    double height = maxY - minY;
    if (width == 0 || height == 0) return strokes;

    double scale = min(targetSize / width, targetSize / height);

    // Center in canvas
    double offsetX = (targetSize - width * scale) / 2;
    double offsetY = (targetSize - height * scale) / 2;

    // Normalize each stroke
    return strokes.map((stroke) {
      var normalizedPoints = stroke.points.map((point) {
        return StrokePoint(
          x: (point.x - minX) * scale + offsetX,
          y: (point.y - minY) * scale + offsetY,
          timestamp: point.timestamp,
        );
      }).toList();
      return Stroke(normalizedPoints);
    }).toList();
  }

  /// Smooth strokes using simple averaging
  static List<Stroke> smoothStrokes(List<Stroke> strokes, {int windowSize = 3}) {
    return strokes.map((stroke) {
      if (stroke.points.length <= windowSize) return stroke;

      List<StrokePoint> smoothedPoints = [];
      for (int i = 0; i < stroke.points.length; i++) {
        int start = max(0, i - windowSize ~/ 2);
        int end = min(stroke.points.length, i + windowSize ~/ 2 + 1);

        double avgX = 0;
        double avgY = 0;
        int count = 0;

        for (int j = start; j < end; j++) {
          avgX += stroke.points[j].x;
          avgY += stroke.points[j].y;
          count++;
        }

        smoothedPoints.add(StrokePoint(
          x: avgX / count,
          y: avgY / count,
          timestamp: stroke.points[i].timestamp,
        ));
      }

      return Stroke(smoothedPoints);
    }).toList();
  }

  /// Resample strokes to have consistent point spacing
  static List<Stroke> resampleStrokes(List<Stroke> strokes, {double spacing = 5.0}) {
    return strokes.map((stroke) {
      if (stroke.points.length < 2) return stroke;

      List<StrokePoint> resampled = [stroke.points.first];
      double accumulatedDistance = 0;

      for (int i = 1; i < stroke.points.length; i++) {
        var p1 = stroke.points[i - 1];
        var p2 = stroke.points[i];
        double d = sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));

        accumulatedDistance += d;

        while (accumulatedDistance >= spacing) {
          double ratio = (spacing - (accumulatedDistance - d)) / d;
          resampled.add(StrokePoint(
            x: p1.x + ratio * (p2.x - p1.x),
            y: p1.y + ratio * (p2.y - p1.y),
          ));
          accumulatedDistance -= spacing;
        }
      }

      // Always include the last point
      if (resampled.last.x != stroke.points.last.x ||
          resampled.last.y != stroke.points.last.y) {
        resampled.add(stroke.points.last);
      }

      return Stroke(resampled);
    }).toList();
  }

  /// Calculate metrics for a set of strokes
  static Map<String, dynamic> calculateMetrics(List<Stroke> strokes) {
    if (strokes.isEmpty) {
      return {
        'totalLength': 0.0,
        'strokeCount': 0,
        'avgStrokeLength': 0.0,
        'totalPoints': 0,
      };
    }

    double totalLength = 0;
    int totalPoints = 0;

    for (var stroke in strokes) {
      totalLength += stroke.length;
      totalPoints += stroke.points.length;
    }

    return {
      'totalLength': totalLength,
      'strokeCount': strokes.length,
      'avgStrokeLength': totalLength / strokes.length,
      'totalPoints': totalPoints,
    };
  }
}
