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

  List<Map<String, dynamic>> toJson() => points.map((p) => p.toJson()).toList();

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
    return strokes.map((stroke) => stroke.toJson()).toList();
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

    // Safe division - we've already checked strokes is not empty
    final avgLength = strokes.isNotEmpty ? totalLength / strokes.length : 0.0;

    return {
      'totalLength': totalLength,
      'strokeCount': strokes.length,
      'avgStrokeLength': avgLength,
      'totalPoints': totalPoints,
    };
  }

  /// Calculate accuracy score from 1-100 based on stroke characteristics
  /// More lenient scoring that considers coverage, smoothness, and basic shape matching
  static int calculateAccuracyScore(List<Stroke> strokes, {
    int expectedStrokeCount = 1,
    double minTotalLength = 50.0,
    double maxTotalLength = 500.0,
  }) {
    if (strokes.isEmpty) return 0;

    int score = 50; // Start with base score

    // 1. Stroke count similarity (±20 points)
    final strokeCountDiff = (strokes.length - expectedStrokeCount).abs();
    if (strokeCountDiff == 0) {
      score += 20; // Perfect match
    } else if (strokeCountDiff == 1) {
      score += 10; // Close
    } else if (strokeCountDiff <= 2) {
      score += 5; // Acceptable
    } else {
      score -= 10; // Too many or too few strokes
    }

    // 2. Total length assessment (±15 points)
    double totalLength = 0;
    for (var stroke in strokes) {
      totalLength += stroke.length;
    }
    
    if (totalLength >= minTotalLength && totalLength <= maxTotalLength) {
      score += 15; // Good length
    } else if (totalLength > maxTotalLength * 1.5) {
      score -= 10; // Way too long
    } else if (totalLength < minTotalLength * 0.5) {
      score -= 15; // Way too short
    }

    // 3. Stroke smoothness (±10 points)
    // Check if strokes have reasonable point density
    for (var stroke in strokes) {
      if (stroke.points.length >= 5 && stroke.length > 30) {
        score += 3; // Smooth stroke
      } else if (stroke.points.length < 2) {
        score -= 5; // Too short/jerky
      }
    }

    // 4. Coverage bonus (±5 points)
    // Reward having sufficient points
    int totalPoints = 0;
    for (var stroke in strokes) {
      totalPoints += stroke.points.length;
    }
    if (totalPoints >= 20) {
      score += 5; // Good coverage
    }

    // Clamp score to 1-100 range
    return score.clamp(1, 100);
  }

  /// Get Filipino feedback message based on accuracy score
  static String getFeedbackMessage(int score) {
    if (score >= 90) {
      return "Ika'y napakagaling! Ipagpatuloy mo pa!";
    } else if (score >= 71) {
      return "Hmm! Masyado mo namang ginagalingan, ngunit konting sanay pa.";
    } else if (score >= 41) {
      return "Nagagalak akong maganda ang naging resulta! Ipagpatuloy mo pa!";
    } else if (score >= 21) {
      return "Ayos! Ngunit, kailangan mo pa ng kaunting pag sasanay.";
    } else {
      return "Ok lang yan! Matuturo kapa. Ulitin muli hanggang sa masanay ka sa bawat kurba.";
    }
  }
}
