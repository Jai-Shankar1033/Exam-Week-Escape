import 'package:flutter/material.dart';
import 'package:flappy_flame/models/difficulty.dart';
import 'package:flappy_flame/workshop/student_code.dart';

/// ════════════════════════════════════════════════════════════════
/// 🎮 GAME SETTINGS
/// ════════════════════════════════════════════════════════════════

class WorkshopSettings {
  
  // ═══════════════════════════════════════════════════════════════
  // 🎓 GAME IDENTITY (easy to personalize!)
  // ═══════════════════════════════════════════════════════════════
  
  /// The title is split in two lines on the home screen.
  static const String gameTitle = 'EXAM WEEK ESCAPE';
  static const String titleLine1 = 'EXAM WEEK';
  static const String titleLine2 = 'ESCAPE';
  static const String tagline = 'Survive exam week, one jump at a time!';
  
  
  // ═══════════════════════════════════════════════════════════════
  // 🎚️ DIFFICULTY (chosen on the home screen)
  // ═══════════════════════════════════════════════════════════════
  
  /// The home screen sets this before the game starts.
  /// Your own numbers from student_code.dart are multiplied by this
  /// mode's multipliers (see lib/models/difficulty.dart).
  static Difficulty difficulty = Difficulty.normal;
  
  // ═══════════════════════════════════════════════════════════════
  // 🎯 CHOOSE MODE
  // ═══════════════════════════════════════════════════════════════
  
  /// Set to TRUE: Use code from student_code.dart
  /// Set to FALSE: Use settings from this file
  static const bool useStudentCode = true;
  
  
  // ═══════════════════════════════════════════════════════════════
  // 🐦 BIRD SETTINGS
  // ═══════════════════════════════════════════════════════════════
  
  static const Color _birdColorFallback = Color(0xFFFFD700);
  static Color get birdColor => 
      useStudentCode ? StudentCode.getBirdColor() : _birdColorFallback;
  
  static const double birdSize = 40;
  static const double birdStartX = 100;
  static const Color birdEyeColor = Colors.white;
  static const Color birdPupilColor = Colors.black;
  static const Color birdBeakColor = Color(0xFFFF8C00);
  static Color get birdWingColor => birdColor.withValues(alpha: 0.8);
  static const Color birdBellyColor = Color(0xFFFFF8DC);
  
  
  // ═══════════════════════════════════════════════════════════════
  // ⚙️ PHYSICS SETTINGS
  // ═══════════════════════════════════════════════════════════════
  
  static const double _gravityFallback = 1200;
  static double get gravity =>
      useStudentCode ? StudentCode.getGravity() : _gravityFallback;
  
  static const double _jumpStrengthFallback = -400;
  static double get jumpStrength =>
      useStudentCode ? StudentCode.calculateJumpStrength(gravity) : _jumpStrengthFallback;
  
  
  // ═══════════════════════════════════════════════════════════════
  // 🚧 PIPE SETTINGS
  // ═══════════════════════════════════════════════════════════════
  
  static const double pipeWidth = 80;
  
  static const double _gapHeightFallback = 200;
  static double get gapHeight =>
      (useStudentCode ? StudentCode.getGapSize() : _gapHeightFallback) *
      difficulty.gapMultiplier;
  
  static const double _pipeSpeedFallback = 200;
  static double get pipeSpeed =>
      (useStudentCode ? StudentCode.getPipeSpeed() : _pipeSpeedFallback) *
      difficulty.speedMultiplier;
  
  /// Seconds between book stacks (depends on the difficulty).
  static double get pipeSpawnInterval => difficulty.spawnInterval;
  static const double minGapDistance = 150;
  
  static const Color _pipeColorFallback = Color(0xFF2ECC71);
  static Color get pipeColor =>
      useStudentCode ? StudentCode.getPipeColor() : _pipeColorFallback;
  
  static Color get pipeBorderColor => pipeColor.withValues(alpha: 0.8);
  static Color get pipeHighlightColor => 
      Color.lerp(pipeColor, Colors.white, 0.3) ?? pipeColor;
  static Color get pipeShadowColor =>
      Color.lerp(pipeColor, Colors.black, 0.3) ?? pipeColor;
  
  
  // ═══════════════════════════════════════════════════════════════
  // 🌤️ SKY/BACKGROUND
  // ═══════════════════════════════════════════════════════════════
  
  static const Color _skyColorTopFallback = Color(0xFF87CEEB);
  static const Color _skyColorBottomFallback = Color(0xFF4A90E2);
  
  static Color get skyColorTop =>
      useStudentCode ? StudentCode.getSkyTopColor() : _skyColorTopFallback;
  static Color get skyColorBottom =>
      useStudentCode ? StudentCode.getSkyBottomColor() : _skyColorBottomFallback;
  
  static const Color cloudColor = Colors.white;
  static const double cloudOpacity = 0.6;
  
  
  // ═══════════════════════════════════════════════════════════════
  // 🌍 GROUND
  // ═══════════════════════════════════════════════════════════════
  
  static const double groundHeight = 100;
  static const Color groundColor = Color(0xFF7A4A2B); // desk wood
  static const Color grassColor = Color(0xFFC98B4F); // desk edge
  static const Color groundLineColor = Color(0xFF5A3620); // wood grain
  
  
  // ═══════════════════════════════════════════════════════════════
  // 🏆 SCORING
  // ═══════════════════════════════════════════════════════════════
  
  static int getPoints(int currentScore) =>
      useStudentCode ? StudentCode.calculatePoints(currentScore) : 1;
  
  static String get creatorName =>
      useStudentCode ? StudentCode.getCreatorName() : "Workshop Participant";
  
  
  // ═══════════════════════════════════════════════════════════════
  // ✨ VISUAL EFFECTS
  // ═══════════════════════════════════════════════════════════════
  
  static const bool enableBirdRotation = true;
  static const double maxRotationUp = -0.5;
  static const double maxRotationDown = 0.8;
  static const bool enableBirdTrail = false;
  static const Color trailColor = Color(0xFFFFD700);
  static const double trailOpacity = 0.3;
  
  
  // ═══════════════════════════════════════════════════════════════
  // 🔊 SOUND
  // ═══════════════════════════════════════════════════════════════
  
  static const bool soundEnabled = true;
  static const String jumpSound = 'jump.wav';
  static const String scoreSound = 'score.wav';
  static const String hitSound = 'hit.wav';
  static const String swooshSound = 'swoosh.wav';

  // 🎵 BACKGROUND MUSIC (files live in assets/audio/music/)
  // Players switch music on/off with the 🎵 button and the game remembers it.
  // `musicEnabled` is only the starting value the very first time the game opens.
  // (If `soundEnabled` above is false, ALL audio - music too - stays off.)
  static const bool musicEnabled = true;
  static const String menuMusic = 'menu.wav'; // calm tune on the home screen
  static const String gameMusic = 'game.wav'; // upbeat tune while playing
  static const double menuMusicVolume = 0.35; // 0.0 (silent) to 1.0 (loud)
  static const double gameMusicVolume = 0.30;
  static const double jumpVolume = 0.5;
  static const double scoreVolume = 0.7;
  static const double hitVolume = 0.8;
  static const double swooshVolume = 0.4;
  static const double masterVolume = 1.0;
  
  
  // ═══════════════════════════════════════════════════════════════
  // 🖼️ CUSTOM IMAGES
  // ═══════════════════════════════════════════════════════════════
  
  static const bool useCustomBirdImage = false;
  static const bool useCustomPipeImage = false;
  static const String birdImageFile = 'bird.png';
  static const String pipeImageFile = 'pipe.png';
  static const String birdDesign = 'student'; // detailed bird + graduation cap
  static const String birdEmoji = '🐤';
  static const String pipeDesign = 'books'; // stacks of textbooks
  static const Color pipeGradientStart = Color(0xFF2ECC71);
  static const Color pipeGradientEnd = Color(0xFF27AE60);
  static const Color candyStripe1 = Color(0xFFFF69B4);
  static const Color candyStripe2 = Colors.white;
}