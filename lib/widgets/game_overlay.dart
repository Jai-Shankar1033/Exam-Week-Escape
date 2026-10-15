import 'package:flutter/material.dart';
import 'package:flappy_flame/models/difficulty.dart';
import 'package:flappy_flame/widgets/arcade_button.dart';
import 'package:flappy_flame/workshop/game_settings.dart';

/// Everything drawn ON TOP of the game: the live score, the
/// "tap to start" hint and the report-card game-over screen.
class GameOverlay extends StatelessWidget {
  final int score;
  final int highScore;
  final bool isGameOver;
  final bool isPlaying;
  final bool isNewBest;
  final Difficulty difficulty;
  final VoidCallback onRestart;
  final VoidCallback onBack;

  const GameOverlay({
    super.key,
    required this.score,
    required this.highScore,
    required this.isGameOver,
    required this.isPlaying,
    required this.onRestart,
    required this.onBack,
    this.isNewBest = false,
    this.difficulty = Difficulty.normal,
  });

  @override
  Widget build(BuildContext context) {
    final double scale =
        (MediaQuery.sizeOf(context).width / 400).clamp(0.8, 1.3).toDouble();
    final double topPadding = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        if (isPlaying) _buildScoreHud(scale, topPadding),
        if (!isPlaying && !isGameOver) _buildStartHint(scale),
        if (isGameOver) _buildGameOver(context, scale),
      ],
    );
  }

  /// Live score while playing.
  /// IgnorePointer = "let taps pass through me", so the player can tap
  /// anywhere on the screen to flap, even on top of the numbers.
  Widget _buildScoreHud(double scale, double topPadding) {
    return Positioned(
      top: topPadding + 16,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$score', style: pixelText(48 * scale, shadow: true)),
            SizedBox(height: 8 * scale),
            _ModeChip(difficulty: difficulty, scale: scale),
            SizedBox(height: 8 * scale),
            Text(
              'BEST $highScore',
              style: pixelText(10 * scale, color: const Color(0xFFFFE9A8), shadow: true),
            ),
          ],
        ),
      ),
    );
  }

  /// "TAP TO START" panel, placed low so the bird stays visible.
  Widget _buildStartHint(double scale) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: const Alignment(0, 0.5),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18 * scale),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('TAP TO START', style: pixelText(24 * scale, shadow: true)),
                  ),
                  SizedBox(height: 10 * scale),
                  Text(
                    'Tap to flap and dodge the books!',
                    textAlign: TextAlign.center,
                    style: pixelText(9 * scale, color: const Color(0xFFFFE9A8), height: 1.5),
                  ),
                  SizedBox(height: 14 * scale),
                  _ModeChip(difficulty: difficulty, scale: scale),
                  SizedBox(height: 14 * scale),
                  Text(
                    'Created by ${WorkshopSettings.creatorName}',
                    textAlign: TextAlign.center,
                    style: pixelText(9 * scale, color: Colors.yellow),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Game-over screen styled like a school REPORT CARD.
  Widget _buildGameOver(BuildContext context, double scale) {
    final grade = _gradeFor(score);
    const Color ink = Color(0xFF1B1B2F);

    return Positioned.fill(
      // This full-screen dark layer also stops taps from reaching the game.
      child: Container(
        color: Colors.black.withValues(alpha: 0.65),
        child: SafeArea(
          child: Center(
            // Scrolls if the screen is too short (e.g. a phone on its side).
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  padding: EdgeInsets.all(22 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7), // notebook paper
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: ink, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        offset: const Offset(0, 8),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'GAME OVER',
                          style: pixelText(28 * scale, color: const Color(0xFFD63031)),
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      Text(
                        'REPORT CARD',
                        style: pixelText(10 * scale, color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 16 * scale),

                      // Teacher-stamp style grade
                      Transform.rotate(
                        angle: -0.18,
                        child: Container(
                          width: 96 * scale,
                          height: 96 * scale,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: grade.color.withValues(alpha: 0.08),
                            border: Border.all(color: grade.color, width: 5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: FittedBox(
                              child: Text(
                                grade.letter,
                                style: pixelText(40 * scale, color: grade.color),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 14 * scale),
                      Text(
                        grade.message,
                        textAlign: TextAlign.center,
                        style: pixelText(10 * scale, color: ink, height: 1.5),
                      ),
                      SizedBox(height: 18 * scale),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatColumn(
                            label: 'SCORE',
                            value: '$score',
                            color: ink,
                            scale: scale,
                          ),
                          _StatColumn(
                            label: 'BEST',
                            value: '$highScore',
                            color: const Color(0xFFE08E0B),
                            scale: scale,
                          ),
                        ],
                      ),

                      if (isNewBest) ...[
                        SizedBox(height: 14 * scale),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12 * scale,
                            vertical: 8 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD23F),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: ink, width: 2),
                          ),
                          child: Text(
                            '★ NEW BEST! ★',
                            style: pixelText(11 * scale, color: ink),
                          ),
                        ),
                      ],

                      SizedBox(height: 16 * scale),
                      _ModeChip(difficulty: difficulty, scale: scale),
                      SizedBox(height: 10 * scale),
                      Text(
                        'By: ${WorkshopSettings.creatorName}',
                        textAlign: TextAlign.center,
                        style: pixelText(9 * scale, color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 20 * scale),

                      Row(
                        children: [
                          Expanded(
                            child: ArcadeButton(
                              label: 'MENU',
                              topColor: const Color(0xFFE74C3C),
                              bottomColor: const Color(0xFFC0392B),
                              fontSize: 14 * scale,
                              verticalPadding: 16 * scale,
                              onTap: onBack,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ArcadeButton(
                              label: 'RETRY',
                              fontSize: 14 * scale,
                              verticalPadding: 16 * scale,
                              onTap: onRestart,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 📝 GRADES
// Change the numbers to make getting an A harder or easier!
// ═══════════════════════════════════════════════════════════════

class _Grade {
  final String letter;
  final String message;
  final Color color;

  const _Grade(this.letter, this.message, this.color);
}

_Grade _gradeFor(int score) {
  if (score >= 60) {
    return const _Grade('A+', 'Top of the class!', Color(0xFF27AE60));
  }
  if (score >= 40) {
    return const _Grade('A', 'Excellent work!', Color(0xFF27AE60));
  }
  if (score >= 25) {
    return const _Grade('B', 'Solid effort!', Color(0xFF2E86DE));
  }
  if (score >= 12) {
    return const _Grade('C', 'You passed. Barely!', Color(0xFFE08E0B));
  }
  if (score >= 5) {
    return const _Grade('D', 'See you at the retake!', Color(0xFFE67E22));
  }
  return const _Grade('F', 'Time to hit the books!', Color(0xFFD63031));
}

/// Small colored pill showing the current difficulty, e.g. "😱 FINALS MODE".
class _ModeChip extends StatelessWidget {
  final Difficulty difficulty;
  final double scale;

  const _ModeChip({required this.difficulty, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        color: difficulty.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 2),
      ),
      child: Text(
        '${difficulty.emoji} ${difficulty.modeName}',
        style: pixelText(10 * scale, shadow: true),
      ),
    );
  }
}

/// A label with a big number under it (used for SCORE and BEST).
class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double scale;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: pixelText(12 * scale, color: const Color(0xFF2E86DE))),
        SizedBox(height: 8 * scale),
        Text(value, style: pixelText(30 * scale, color: color)),
      ],
    );
  }
}
