import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flappy_flame/game/flappy_game.dart';
import 'package:flappy_flame/workshop/game_settings.dart';
import 'package:flappy_flame/services/audio_service.dart';

class PipePair extends PositionComponent with HasGameReference<FlappyGame> {
  double get pipeWidth => WorkshopSettings.pipeWidth;
  double get gapHeight => WorkshopSettings.gapHeight;
  double get scrollSpeed => WorkshopSettings.pipeSpeed;
  
  bool scored = false;
  final AudioService _audioService = AudioService();

  PipePair({required double xPosition}) {
    position = Vector2(xPosition, 0);
  }

  @override
  Future<void> onLoad() async {
    final random = Random();
    final screenHeight = game.size.y;
    final minGapY = WorkshopSettings.minGapDistance;
    // max() keeps the gap on screen even on very short windows.
    final maxGapY = max(
      minGapY,
      screenHeight - WorkshopSettings.minGapDistance - gapHeight,
    );
    final gapY = minGapY + random.nextDouble() * (maxGapY - minGapY);

    // Top pipe
    final topPipe = Pipe(
      pipeWidth: pipeWidth,
      pipeHeight: gapY,
      isTop: true,
    );
    topPipe.position = Vector2(0, 0);
    add(topPipe);

    // Bottom pipe
    final bottomPipe = Pipe(
      pipeWidth: pipeWidth,
      pipeHeight: screenHeight - gapY - gapHeight,
      isTop: false,
    );
    bottomPipe.position = Vector2(0, gapY + gapHeight);
    add(bottomPipe);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= scrollSpeed * dt;

    // Score when bird passes pipe
    if (!scored && position.x + pipeWidth < game.bird.position.x) {
      scored = true;
      game.incrementScore();
      _audioService.playScore();
    }

    // Remove when off screen
    if (position.x < -pipeWidth) {
      removeFromParent();
    }
  }
}

class Pipe extends PositionComponent with CollisionCallbacks {
  final double pipeWidth;
  final double pipeHeight;
  final bool isTop;
  
  // Custom sprite (if using custom image)
  Sprite? _customSprite;
  bool _useCustomImage = false;

  Pipe({
    required this.pipeWidth,
    required this.pipeHeight,
    required this.isTop,
  });

  @override
  Future<void> onLoad() async {
    size = Vector2(pipeWidth, pipeHeight);
    add(RectangleHitbox());
    
    // Try to load custom image if enabled
    if (WorkshopSettings.useCustomPipeImage) {
      await _loadCustomImage();
    }
  }

  Future<void> _loadCustomImage() async {
    try {
      _customSprite = await Sprite.load(
        'workshop/images/${WorkshopSettings.pipeImageFile}',
      );
      _useCustomImage = true;
    } catch (e) {
      _useCustomImage = false;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    if (_useCustomImage && _customSprite != null) {
      _renderCustomImage(canvas);
    } else {
      // Draw based on selected design
      switch (WorkshopSettings.pipeDesign) {
        case 'modern':
          _drawModernPipe(canvas);
          break;
        case 'candy':
          _drawCandyPipe(canvas);
          break;
        case 'neon':
          _drawNeonPipe(canvas);
          break;
        case 'wood':
          _drawWoodPipe(canvas);
          break;
        case 'metal':
          _drawMetalPipe(canvas);
          break;
        case 'books':
          _drawBookPipe(canvas);
          break;
        case 'classic':
        default:
          _drawClassicPipe(canvas);
          break;
      }
    }
  }

  void _renderCustomImage(Canvas canvas) {
    if (_customSprite == null) return;
    
    const double spriteHeight = 50.0;
    final int tiles = (pipeHeight / spriteHeight).ceil();
    
    for (int i = 0; i < tiles; i++) {
      _customSprite!.render(
        canvas,
        position: Vector2(0, i * spriteHeight),
        size: Vector2(pipeWidth, spriteHeight),
      );
    }
  }

  void _drawClassicPipe(Canvas canvas) {
    final bodyPaint = Paint()..color = WorkshopSettings.pipeColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, pipeWidth, pipeHeight), bodyPaint);
    
    final borderPaint = Paint()
      ..color = WorkshopSettings.pipeBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(Rect.fromLTWH(0, 0, pipeWidth, pipeHeight), borderPaint);
    
    final highlightPaint = Paint()..color = WorkshopSettings.pipeHighlightColor;
    canvas.drawRect(Rect.fromLTWH(5, 0, 10, pipeHeight), highlightPaint);
    
    final shadowPaint = Paint()..color = WorkshopSettings.pipeShadowColor;
    canvas.drawRect(Rect.fromLTWH(pipeWidth - 15, 0, 10, pipeHeight), shadowPaint);
    
    _drawPipeCap(canvas, bodyPaint, borderPaint);
  }

  void _drawModernPipe(Canvas canvas) {
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        WorkshopSettings.pipeGradientStart,
        WorkshopSettings.pipeGradientEnd,
      ],
    );
    
    final rect = Rect.fromLTWH(0, 0, pipeWidth, pipeHeight);
    final paint = Paint()..shader = gradient.createShader(rect);
    
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, paint);
    
    final borderPaint = Paint()
      ..color = WorkshopSettings.pipeBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, borderPaint);
    
    _drawModernCap(canvas);
  }

  void _drawCandyPipe(Canvas canvas) {
    const double stripeWidth = 15.0;
    final int stripeCount = (pipeHeight / stripeWidth).ceil();
    
    for (int i = 0; i < stripeCount; i++) {
      final color = i.isEven 
          ? WorkshopSettings.candyStripe1 
          : WorkshopSettings.candyStripe2;
      
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeWidth, pipeWidth, stripeWidth),
        Paint()..color = color,
      );
    }
    
    final borderPaint = Paint()
      ..color = WorkshopSettings.candyStripe1.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(Rect.fromLTWH(0, 0, pipeWidth, pipeHeight), borderPaint);
    
    _drawCandyCap(canvas);
  }

  void _drawNeonPipe(Canvas canvas) {
    final glowPaint = Paint()
      ..color = WorkshopSettings.pipeColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);
    canvas.drawRect(Rect.fromLTWH(-5, -5, pipeWidth + 10, pipeHeight + 10), glowPaint);
    
    final bodyPaint = Paint()..color = Colors.black87;
    canvas.drawRect(Rect.fromLTWH(0, 0, pipeWidth, pipeHeight), bodyPaint);
    
    final neonPaint = Paint()
      ..color = WorkshopSettings.pipeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);
    canvas.drawRect(Rect.fromLTWH(2, 2, pipeWidth - 4, pipeHeight - 4), neonPaint);
    
    final innerGlow = Paint()
      ..color = WorkshopSettings.pipeColor.withValues(alpha: 0.5)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(pipeWidth / 2, 0),
      Offset(pipeWidth / 2, pipeHeight),
      innerGlow,
    );
  }

  void _drawWoodPipe(Canvas canvas) {
    final basePaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawRect(Rect.fromLTWH(0, 0, pipeWidth, pipeHeight), basePaint);
    
    final grainPaint = Paint()
      ..color = const Color(0xFF654321)
      ..strokeWidth = 2;
    
    for (double y = 10; y < pipeHeight; y += 20) {
      final path = Path()..moveTo(0, y);
      
      for (double x = 0; x < pipeWidth; x += 10) {
        final double waveY = y + (sin(x * 0.1) * 3).toDouble();
        path.lineTo(x, waveY);
      }
      
      canvas.drawPath(path, grainPaint);
    }
    
    final borderPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRect(Rect.fromLTWH(0, 0, pipeWidth, pipeHeight), borderPaint);
    
    _drawWoodCap(canvas);
  }

  void _drawMetalPipe(Canvas canvas) {
    final gradient = LinearGradient(
      colors: [
        Colors.grey[400]!,
        Colors.grey[600]!,
        Colors.grey[400]!,
      ],
    );
    
    final rect = Rect.fromLTWH(0, 0, pipeWidth, pipeHeight);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
    
    final rivetPaint = Paint()..color = Colors.grey[800]!;
    final rivetHighlight = Paint()..color = Colors.grey[300]!;
    
    for (double y = 20; y < pipeHeight; y += 40) {
      canvas.drawCircle(Offset(10, y), 4, rivetPaint);
      canvas.drawCircle(Offset(9, y - 1), 1.5, rivetHighlight);
      
      canvas.drawCircle(Offset(pipeWidth - 10, y), 4, rivetPaint);
      canvas.drawCircle(Offset(pipeWidth - 11, y - 1), 1.5, rivetHighlight);
    }
    
    final borderPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(rect, borderPaint);
    
    _drawMetalCap(canvas);
  }

  // ───────────────────────────────────────────────────────────────
  // 📚 BOOK STACK (EXAM WEEK ESCAPE theme)
  // The obstacle is a tall stack of textbooks. We draw one book at a
  // time in a loop, changing color, height and position a little for
  // every book (using the book number `i`), so it looks hand-stacked
  // but never flickers from frame to frame.
  // ───────────────────────────────────────────────────────────────
  static const List<Color> _bookColors = [
    Color(0xFFE74C3C), // red
    Color(0xFFF39C12), // orange
    Color(0xFF1ABC9C), // teal
    Color(0xFF3498DB), // blue
    Color(0xFFFF6B9D), // pink
    Color(0xFF2ECC71), // green
    Color(0xFFECF0F1), // white
  ];

  void _drawBookPipe(Canvas canvas) {
    final outlinePaint = Paint()
      ..color = const Color(0xFF1B1B2F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final detailPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 2;

    // Top and bottom stacks start on different colors.
    final int colorOffset = isTop ? 0 : 3;

    double y = 0;
    int i = 0;
    while (y < pipeHeight) {
      final double bookHeight = 24.0 + (i * 7 % 3) * 6; // 24, 30 or 36
      final double wobble = (i * 5 % 3) * 2.0; // 0, 2 or 4 pixels
      final double height = min(bookHeight, pipeHeight - y);
      final double left = i.isEven ? wobble : 0;
      final Rect book = Rect.fromLTWH(left, y, pipeWidth - wobble, height);

      // Book cover
      canvas.drawRect(
        book,
        Paint()..color = _bookColors[(i + colorOffset) % _bookColors.length],
      );

      // Spine band + two "title" lines (skipped on a cut-off last book)
      if (height >= 22) {
        canvas.drawRect(
          Rect.fromLTWH(left + 8, y + height * 0.2, 6, height * 0.6),
          Paint()..color = Colors.black.withValues(alpha: 0.18),
        );
        canvas.drawLine(
          Offset(left + 22, y + height * 0.38),
          Offset(left + pipeWidth * 0.6, y + height * 0.38),
          detailPaint,
        );
        canvas.drawLine(
          Offset(left + 22, y + height * 0.66),
          Offset(left + pipeWidth * 0.45, y + height * 0.66),
          detailPaint,
        );
      }

      canvas.drawRect(book, outlinePaint);
      y += bookHeight;
      i++;
    }

    _drawBookCap(canvas);
  }

  /// The big hardcover textbook at the end of every stack.
  void _drawBookCap(Canvas canvas) {
    const double capHeight = 30.0;
    const double capExtend = 8.0;
    final double capY = isTop ? pipeHeight - capHeight : 0;
    final Rect cap = Rect.fromLTWH(
      -capExtend,
      capY,
      pipeWidth + capExtend * 2,
      capHeight,
    );

    // Cover (uses the pipe color from student_code.dart)
    canvas.drawRect(cap, Paint()..color = WorkshopSettings.pipeColor);

    // Lighter strip along the spine
    canvas.drawRect(
      Rect.fromLTWH(cap.left + 4, capY + 4, 8, capHeight - 8),
      Paint()..color = WorkshopSettings.pipeHighlightColor,
    );

    // Gold bookmark ribbon
    canvas.drawRect(
      Rect.fromLTWH(pipeWidth - 14, capY, 7, capHeight),
      Paint()..color = const Color(0xFFFFD23F),
    );

    // Cream pages on the side that faces the gap
    final double pagesY = isTop ? capY + capHeight - 6 : capY;
    canvas.drawRect(
      Rect.fromLTWH(cap.left + 2, pagesY, cap.width - 4, 6),
      Paint()..color = const Color(0xFFFFF3D6),
    );

    canvas.drawRect(
      cap,
      Paint()
        ..color = const Color(0xFF1B1B2F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawPipeCap(Canvas canvas, Paint bodyPaint, Paint borderPaint) {
    const double capHeight = 30.0;
    const double capExtend = 8.0;
    
    if (isTop) {
      final capRect = Rect.fromLTWH(-capExtend, pipeHeight - capHeight, pipeWidth + capExtend * 2, capHeight);
      canvas.drawRect(capRect, bodyPaint);
      canvas.drawRect(capRect, borderPaint);
      
      final highlightPaint = Paint()..color = WorkshopSettings.pipeHighlightColor;
      canvas.drawRect(
        Rect.fromLTWH(-capExtend + 3, pipeHeight - capHeight + 3, 8, capHeight - 6),
        highlightPaint,
      );
    } else {
      final capRect = Rect.fromLTWH(-capExtend, 0, pipeWidth + capExtend * 2, capHeight);
      canvas.drawRect(capRect, bodyPaint);
      canvas.drawRect(capRect, borderPaint);
      
      final highlightPaint = Paint()..color = WorkshopSettings.pipeHighlightColor;
      canvas.drawRect(
        Rect.fromLTWH(-capExtend + 3, 3, 8, capHeight - 6),
        highlightPaint,
      );
    }
  }

  void _drawModernCap(Canvas canvas) {
    const double capHeight = 25.0;
    final double capY = isTop ? pipeHeight - capHeight : 0;
    
    final gradient = LinearGradient(
      colors: [
        WorkshopSettings.pipeGradientEnd,
        WorkshopSettings.pipeGradientStart,
      ],
    );
    
    final rect = Rect.fromLTWH(-5, capY, pipeWidth + 10, capHeight);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));
    canvas.drawRRect(rrect, Paint()..shader = gradient.createShader(rect));
  }

  void _drawCandyCap(Canvas canvas) {
    const double capHeight = 25.0;
    final double capY = isTop ? pipeHeight - capHeight : 0;
    
    canvas.drawRect(
      Rect.fromLTWH(-5, capY, pipeWidth + 10, capHeight),
      Paint()..color = WorkshopSettings.candyStripe1,
    );
    
    canvas.drawRect(
      Rect.fromLTWH(-5, capY + 8, pipeWidth + 10, 8),
      Paint()..color = WorkshopSettings.candyStripe2,
    );
  }

  void _drawWoodCap(Canvas canvas) {
    const double capHeight = 30.0;
    final double capY = isTop ? pipeHeight - capHeight : 0;
    
    final capPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawRect(
      Rect.fromLTWH(-8, capY, pipeWidth + 16, capHeight),
      capPaint,
    );
    
    final plankPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..strokeWidth = 2;
    
    canvas.drawLine(
      Offset(-8, capY + capHeight / 2),
      Offset(pipeWidth + 8, capY + capHeight / 2),
      plankPaint,
    );
  }

  void _drawMetalCap(Canvas canvas) {
    const double capHeight = 28.0;
    final double capY = isTop ? pipeHeight - capHeight : 0;
    
    final gradient = LinearGradient(
      colors: [Colors.grey[500]!, Colors.grey[700]!, Colors.grey[500]!],
    );
    
    final rect = Rect.fromLTWH(-6, capY, pipeWidth + 12, capHeight);
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
    
    final boltPaint = Paint()..color = Colors.grey[900]!;
    canvas.drawCircle(Offset(5, capY + capHeight / 2), 5, boltPaint);
    canvas.drawCircle(Offset(pipeWidth - 5, capY + capHeight / 2), 5, boltPaint);
  }
}