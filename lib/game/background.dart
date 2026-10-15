import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flappy_flame/game/flappy_game.dart';
import 'package:flappy_flame/workshop/game_settings.dart';

/// 🌙 Late-night campus background for EXAM WEEK ESCAPE.
///
/// From back to front we draw:
///   1. the sky gradient (colors come from student_code.dart)
///   2. stars and a crescent moon
///   3. floating sticky notes (study reminders!)
///   4. dorm buildings where lots of windows are still lit,
///      because everybody is up studying
///
/// Every position is a FRACTION of the screen size (0.0 to 1.0), so the
/// scene stretches to any screen instead of being stuck at one size.
class GameBackground extends PositionComponent with HasGameReference<FlappyGame> {
  // x fraction, y fraction, radius
  static const List<List<double>> _stars = [
    [0.07, 0.05, 1.6], [0.19, 0.12, 1.2], [0.31, 0.04, 1.4],
    [0.42, 0.16, 1.0], [0.55, 0.07, 1.6], [0.66, 0.14, 1.2],
    [0.74, 0.03, 1.0], [0.90, 0.17, 1.4], [0.12, 0.24, 1.0],
    [0.48, 0.27, 1.2], [0.83, 0.30, 1.0], [0.26, 0.33, 1.4],
  ];

  // x fraction, y fraction, rotation in radians, color
  static const List<List<Object>> _notes = [
    [0.14, 0.40, -0.25, Color(0xFFFFE066)],
    [0.80, 0.46, 0.20, Color(0xFFFF9CC2)],
    [0.50, 0.58, -0.12, Color(0xFF9BE7FF)],
  ];

  // Height of each dorm building (in pixels, at an 800px tall screen)
  static const List<double> _buildingHeights = [
    110, 170, 130, 200, 120, 160, 100,
  ];

  /// The smaller of width and height (used to size the moon and notes).
  double get _shortestSide => size.x < size.y ? size.x : size.y;

  @override
  Future<void> onLoad() async {
    size = game.size;
    position = Vector2.zero();
  }

  /// Called by Flame when the screen/window size changes.
  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize.clone();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // 1. Sky
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        WorkshopSettings.skyColorTop,
        WorkshopSettings.skyColorBottom,
      ],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    _drawStars(canvas);
    _drawMoon(canvas);
    _drawStickyNotes(canvas);
    _drawDorms(canvas);
  }

  void _drawStars(Canvas canvas) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    for (final star in _stars) {
      canvas.drawCircle(Offset(size.x * star[0], size.y * star[1]), star[2], paint);
    }
  }

  void _drawMoon(Canvas canvas) {
    final double radius = (_shortestSide * 0.07).clamp(18.0, 40.0).toDouble();
    final Offset center = Offset(size.x * 0.82, size.y * 0.1);

    // A crescent = a circle with a smaller circle cut out of it.
    final moon = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
      Path()
        ..addOval(Rect.fromCircle(
          center: center.translate(radius * 0.55, -radius * 0.2),
          radius: radius * 0.85,
        )),
    );
    canvas.drawPath(moon, Paint()..color = const Color(0xFFFFF3C4));
  }

  void _drawStickyNotes(Canvas canvas) {
    final double noteSize = (_shortestSide * 0.12).clamp(34.0, 70.0).toDouble();
    for (final note in _notes) {
      canvas.save();
      canvas.translate(size.x * (note[0] as double), size.y * (note[1] as double));
      canvas.rotate(note[2] as double);

      final body = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: noteSize, height: noteSize),
        const Radius.circular(4),
      );
      canvas.drawRRect(body, Paint()..color = (note[3] as Color).withValues(alpha: 0.28));

      // Two scribbled "text" lines
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(-noteSize * 0.3, -noteSize * 0.1),
        Offset(noteSize * 0.3, -noteSize * 0.1),
        linePaint,
      );
      canvas.drawLine(
        Offset(-noteSize * 0.3, noteSize * 0.12),
        Offset(noteSize * 0.1, noteSize * 0.12),
        linePaint,
      );
      canvas.restore();
    }
  }

  void _drawDorms(Canvas canvas) {
    final double baseY = size.y - WorkshopSettings.groundHeight;
    final double scale = (size.y / 800).clamp(0.6, 1.4).toDouble();
    final double buildingWidth = size.x / 5; // wider screen = wider buildings
    final int count = (size.x / buildingWidth).ceil() + 1;

    final wallPaint = Paint()..color = const Color(0xFF0F1538);
    final litPaint = Paint()..color = const Color(0xFFFFE08A).withValues(alpha: 0.85);
    final darkPaint = Paint()..color = Colors.white.withValues(alpha: 0.08);

    for (int b = 0; b < count; b++) {
      final double height = _buildingHeights[b % _buildingHeights.length] * scale;
      final double left = b * buildingWidth;
      canvas.drawRect(
        Rect.fromLTWH(left, baseY - height, buildingWidth - 4, height),
        wallPaint,
      );

      // Windows: a grid where some are lit (a repeatable pattern, so
      // the lights never flicker between frames).
      final double step = 16 * scale;
      final double windowW = 7 * scale;
      final double windowH = 9 * scale;
      int row = 0;
      for (double y = baseY - height + step; y < baseY - step; y += step * 1.4) {
        int col = 0;
        for (double x = left + step * 0.6; x < left + buildingWidth - step; x += step) {
          final bool lit = (b * 7 + row * 3 + col * 5) % 4 == 0;
          canvas.drawRect(
            Rect.fromLTWH(x, y, windowW, windowH),
            lit ? litPaint : darkPaint,
          );
          col++;
        }
        row++;
      }
    }
  }
}
