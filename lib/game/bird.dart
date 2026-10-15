import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flappy_flame/game/flappy_game.dart';
import 'package:flappy_flame/workshop/game_settings.dart';
import 'package:flappy_flame/services/audio_service.dart';

class Bird extends PositionComponent with HasGameReference<FlappyGame>, CollisionCallbacks {
  
  // Physics
  double velocity = 0;
  bool isAlive = true;
  
  // Settings from WorkshopSettings
  double get gravity => WorkshopSettings.gravity;
  double get jumpVelocity => WorkshopSettings.jumpStrength;
  double get birdSize => WorkshopSettings.birdSize;
  
  // Audio service
  final AudioService _audioService = AudioService();
  
  // Custom image sprite (if using custom image)
  Sprite? _customSprite;
  bool _useCustomImage = false;
  
  // Animation
  double _wingAngle = 0;
  bool _wingUp = true;

  @override
  Future<void> onLoad() async {
    size = Vector2.all(birdSize);
    position = Vector2(WorkshopSettings.birdStartX, game.size.y / 2);
    anchor = Anchor.center;
    
    // Add hitbox (slightly smaller for fairness)
    add(CircleHitbox(
      radius: birdSize * 0.4,
      position: size / 2,
      anchor: Anchor.center,
    ));
    
    // Try to load custom image if enabled
    if (WorkshopSettings.useCustomBirdImage) {
      await _loadCustomImage();
    }
  }

  Future<void> _loadCustomImage() async {
    try {
      _customSprite = await Sprite.load(
        'workshop/images/${WorkshopSettings.birdImageFile}',
      );
      _useCustomImage = true;
    } catch (e) {
      _useCustomImage = false;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isAlive) return;

    // Apply gravity
    velocity += gravity * dt;
    position.y += velocity * dt;
    
    // Update rotation based on velocity
    if (WorkshopSettings.enableBirdRotation) {
      _updateRotation();
    }
    
    // Animate wings
    _animateWings(dt);

    // Check boundaries
    if (position.y > game.size.y - birdSize / 2 || position.y < birdSize / 2) {
      game.gameOver();
    }
  }

  void _updateRotation() {
    // Rotate bird based on velocity
    if (velocity < 0) {
      // Going up
      angle = WorkshopSettings.maxRotationUp * (velocity / jumpVelocity).clamp(0, 1);
    } else {
      // Falling down
      angle = WorkshopSettings.maxRotationDown * (velocity / 500).clamp(0, 1);
    }
  }

  void _animateWings(double dt) {
    // Simple wing flapping animation
    if (_wingUp) {
      _wingAngle += dt * 10;
      if (_wingAngle > 0.3) _wingUp = false;
    } else {
      _wingAngle -= dt * 10;
      if (_wingAngle < -0.3) _wingUp = true;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    if (_useCustomImage && _customSprite != null) {
      // Draw custom sprite image
      _customSprite!.render(
        canvas,
        size: size,
      );
    } else {
      // Draw based on selected design
      switch (WorkshopSettings.birdDesign) {
        case 'circle':
          _drawCircleBird(canvas);
          break;
        case 'square':
          _drawSquareBird(canvas);
          break;
        case 'triangle':
          _drawTriangleBird(canvas);
          break;
        case 'star':
          _drawStarBird(canvas);
          break;
        case 'emoji':
          _drawEmojiBird(canvas);
          break;
        case 'student':
          _drawDetailedBird(canvas);
          _drawGradCap(canvas);
          break;
        case 'detailed':
        default:
          _drawDetailedBird(canvas);
          break;
      }
    }
  }

  /// 🟡 Simple Circle Bird
  void _drawCircleBird(Canvas canvas) {
    final paint = Paint()..color = WorkshopSettings.birdColor;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), birdSize / 2, paint);
    
    // Eye
    final eyePaint = Paint()..color = WorkshopSettings.birdEyeColor;
    canvas.drawCircle(Offset(size.x / 2 + 8, size.y / 2 - 5), 5, eyePaint);
    
    // Pupil
    final pupilPaint = Paint()..color = WorkshopSettings.birdPupilColor;
    canvas.drawCircle(Offset(size.x / 2 + 10, size.y / 2 - 5), 2, pupilPaint);
    
    // Beak
    _drawBeak(canvas);
  }

  /// 🟨 Square/Pixel Bird
  void _drawSquareBird(Canvas canvas) {
    final paint = Paint()..color = WorkshopSettings.birdColor;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y / 2),
        width: birdSize * 0.9,
        height: birdSize * 0.9,
      ),
      paint,
    );
    
    // Pixel eye
    final eyePaint = Paint()..color = WorkshopSettings.birdPupilColor;
    canvas.drawRect(
      Rect.fromLTWH(size.x / 2 + 5, size.y / 2 - 8, 6, 6),
      eyePaint,
    );
    
    // Pixel beak
    final beakPaint = Paint()..color = WorkshopSettings.birdBeakColor;
    canvas.drawRect(
      Rect.fromLTWH(size.x / 2 + 15, size.y / 2 - 2, 8, 6),
      beakPaint,
    );
  }

  /// 🔺 Triangle Bird
  void _drawTriangleBird(Canvas canvas) {
    final paint = Paint()..color = WorkshopSettings.birdColor;
    final path = Path()
      ..moveTo(size.x / 2 + birdSize / 2, size.y / 2)
      ..lineTo(size.x / 2 - birdSize / 2, size.y / 2 - birdSize / 2)
      ..lineTo(size.x / 2 - birdSize / 2, size.y / 2 + birdSize / 2)
      ..close();
    canvas.drawPath(path, paint);
    
    // Eye
    final eyePaint = Paint()..color = WorkshopSettings.birdPupilColor;
    canvas.drawCircle(Offset(size.x / 2 - 5, size.y / 2 - 5), 3, eyePaint);
  }

  /// ⭐ Star Bird
  void _drawStarBird(Canvas canvas) {
    final paint = Paint()..color = WorkshopSettings.birdColor;
    final path = _createStarPath(
      Offset(size.x / 2, size.y / 2),
      birdSize / 2,
      birdSize / 4,
      5,
    );
    canvas.drawPath(path, paint);
    
    // Eye in center
    final eyePaint = Paint()..color = WorkshopSettings.birdPupilColor;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2 - 3), 4, eyePaint);
  }

  Path _createStarPath(Offset center, double outerRadius, double innerRadius, int points) {
    final path = Path();
    final angle = pi / points;
    
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + radius * cos(i * angle - pi / 2);
      final y = center.dy + radius * sin(i * angle - pi / 2);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  /// 😊 Emoji Bird
  void _drawEmojiBird(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: WorkshopSettings.birdEmoji,
        style: TextStyle(fontSize: birdSize * 0.9),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
  }

  /// 🐦 Detailed Bird (Default)
  void _drawDetailedBird(Canvas canvas) {
    final centerX = size.x / 2;
    final centerY = size.y / 2;
    
    // Body
    final bodyPaint = Paint()..color = WorkshopSettings.birdColor;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: birdSize,
        height: birdSize * 0.8,
      ),
      bodyPaint,
    );
    
    // Belly
    final bellyPaint = Paint()..color = WorkshopSettings.birdBellyColor;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - 2, centerY + 3),
        width: birdSize * 0.5,
        height: birdSize * 0.4,
      ),
      bellyPaint,
    );
    
    // Wing
    canvas.save();
    canvas.translate(centerX - 5, centerY);
    canvas.rotate(_wingAngle);
    final wingPaint = Paint()..color = WorkshopSettings.birdWingColor;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: birdSize * 0.4,
        height: birdSize * 0.25,
      ),
      wingPaint,
    );
    canvas.restore();
    
    // Eye white
    final eyeWhitePaint = Paint()..color = WorkshopSettings.birdEyeColor;
    canvas.drawCircle(
      Offset(centerX + 8, centerY - 5),
      6,
      eyeWhitePaint,
    );
    
    // Pupil
    final pupilPaint = Paint()..color = WorkshopSettings.birdPupilColor;
    canvas.drawCircle(
      Offset(centerX + 10, centerY - 5),
      3,
      pupilPaint,
    );
    
    // Eye shine
    final shinePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(centerX + 9, centerY - 7),
      1.5,
      shinePaint,
    );
    
    // Beak
    _drawBeak(canvas);
    
    // Tail feathers
    final tailPaint = Paint()..color = WorkshopSettings.birdWingColor;
    final tailPath = Path()
      ..moveTo(centerX - birdSize / 2, centerY - 3)
      ..lineTo(centerX - birdSize / 2 - 8, centerY - 8)
      ..lineTo(centerX - birdSize / 2 - 6, centerY)
      ..lineTo(centerX - birdSize / 2 - 10, centerY + 5)
      ..lineTo(centerX - birdSize / 2, centerY + 3)
      ..close();
    canvas.drawPath(tailPath, tailPaint);
  }

  /// 🎓 Graduation cap drawn on top of the detailed bird.
  /// Everything is multiplied by `k` so the cap grows and shrinks
  /// together with the bird if you change birdSize.
  void _drawGradCap(Canvas canvas) {
    final double k = birdSize / 40;
    final double cx = size.x / 2 + 3 * k;
    final double cy = size.y / 2 - 14 * k;
    const Color capColor = Color(0xFF1F2A44);
    const Color goldColor = Color(0xFFFFC93C);

    // Rounded base that sits on the head
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 3 * k), width: 15 * k, height: 8 * k),
        Radius.circular(2 * k),
      ),
      Paint()..color = capColor,
    );

    // Flat diamond-shaped board
    final board = Path()
      ..moveTo(cx - 17 * k, cy)
      ..lineTo(cx, cy - 6 * k)
      ..lineTo(cx + 17 * k, cy)
      ..lineTo(cx, cy + 6 * k)
      ..close();
    canvas.drawPath(board, Paint()..color = capColor);
    canvas.drawPath(
      board,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Gold button and hanging tassel
    final goldPaint = Paint()
      ..color = goldColor
      ..strokeWidth = 1.5 * k;
    canvas.drawCircle(Offset(cx, cy), 2 * k, goldPaint);
    canvas.drawLine(Offset(cx, cy), Offset(cx + 14 * k, cy + 1 * k), goldPaint);
    canvas.drawLine(
      Offset(cx + 14 * k, cy + 1 * k),
      Offset(cx + 14 * k, cy + 9 * k),
      goldPaint,
    );
    canvas.drawCircle(Offset(cx + 14 * k, cy + 10 * k), 2 * k, goldPaint);
  }

  void _drawBeak(Canvas canvas) {
    final beakPaint = Paint()..color = WorkshopSettings.birdBeakColor;
    final beakPath = Path()
      ..moveTo(size.x / 2 + birdSize / 2 - 5, size.y / 2 - 2)
      ..lineTo(size.x / 2 + birdSize / 2 + 8, size.y / 2 + 2)
      ..lineTo(size.x / 2 + birdSize / 2 - 5, size.y / 2 + 5)
      ..close();
    canvas.drawPath(beakPath, beakPaint);
  }

  void jump() {
    if (isAlive) {
      velocity = jumpVelocity;
      _audioService.playJump();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (isAlive) {
      game.gameOver();
    }
  }

  void reset() {
    position = Vector2(WorkshopSettings.birdStartX, game.size.y / 2);
    velocity = 0;
    angle = 0;
    isAlive = true;
  }
}