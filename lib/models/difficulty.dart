import 'package:flutter/material.dart';

/// ════════════════════════════════════════════════════════════════
/// 🎚️ DIFFICULTY MODES
/// ════════════════════════════════════════════════════════════════
///
/// An `enum` is a fixed list of choices. Ours has exactly three:
/// chill, normal and finals.
///
/// Each choice carries its own settings (a "multiplier" is a number we
/// multiply by). NORMAL uses 1.0 everywhere, which means NORMAL is
/// exactly the values you wrote in student_code.dart.
///
///   CHILL  → gap x1.2 (wider),   speed x0.8 (slower)
///   NORMAL → gap x1.0,           speed x1.0
///   FINALS → gap x0.82 (tighter), speed x1.3 (faster)
///
/// Want to tune a mode? Just change the numbers below!
enum Difficulty {
  chill(
    label: 'CHILL',
    modeName: 'CHILL MODE',
    emoji: '😎',
    description: 'Wider gaps, slower books. Perfect for warming up!',
    gapMultiplier: 1.2,
    speedMultiplier: 0.8,
    spawnInterval: 2.2,
    color: Color(0xFF27AE60),
  ),
  normal(
    label: 'NORMAL',
    modeName: 'NORMAL MODE',
    emoji: '📖',
    description: 'A balanced week of studying. The classic challenge!',
    gapMultiplier: 1.0,
    speedMultiplier: 1.0,
    spawnInterval: 2.0,
    color: Color(0xFF2E86DE),
  ),
  finals(
    label: 'FINALS',
    modeName: 'FINALS MODE',
    emoji: '😱',
    description: 'Faster books, tighter gaps. Only the best survive!',
    gapMultiplier: 0.82,
    speedMultiplier: 1.3,
    spawnInterval: 1.7,
    color: Color(0xFFD63031),
  );

  const Difficulty({
    required this.label,
    required this.modeName,
    required this.emoji,
    required this.description,
    required this.gapMultiplier,
    required this.speedMultiplier,
    required this.spawnInterval,
    required this.color,
  });

  /// Short name shown on the selector button, e.g. "CHILL".
  final String label;

  /// Full name shown in titles and badges, e.g. "CHILL MODE".
  final String modeName;

  /// Emoji shown on the selector button.
  final String emoji;

  /// One-line explanation shown under the selector.
  final String description;

  /// Multiplies the gap between the book stacks (bigger = easier).
  final double gapMultiplier;

  /// Multiplies how fast the book stacks move (bigger = harder).
  final double speedMultiplier;

  /// Seconds between new book stacks. Faster modes spawn them a bit sooner.
  final double spawnInterval;

  /// Accent color of the mode.
  final Color color;

  /// Turns a saved name like "finals" back into Difficulty.finals.
  /// Falls back to NORMAL if the saved value is missing or unknown.
  static Difficulty fromName(String? name) {
    for (final difficulty in Difficulty.values) {
      if (difficulty.name == name) return difficulty;
    }
    return Difficulty.normal;
  }
}
