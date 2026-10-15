import 'package:flutter/material.dart';
import 'package:flappy_flame/models/difficulty.dart';
import 'package:flappy_flame/screens/game_screen.dart';
import 'package:flappy_flame/services/audio_service.dart';
import 'package:flappy_flame/services/score_service.dart';
import 'package:flappy_flame/widgets/arcade_button.dart';
import 'package:flappy_flame/widgets/music_toggle_button.dart';
import 'package:flappy_flame/workshop/game_settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScoreService _scoreService = ScoreService();
  Difficulty _difficulty = Difficulty.normal;
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    AudioService().playMusic(MusicTrack.menu); // calm home-screen music
    _loadSavedData();
  }

  /// Loads the mode you played last and its high score.
  Future<void> _loadSavedData() async {
    final savedDifficulty = await _scoreService.getLastDifficulty();
    final score = await _scoreService.getHighScore(difficulty: savedDifficulty);
    if (!mounted) return; // the screen may be gone by now
    setState(() {
      _difficulty = savedDifficulty;
      _highScore = score;
    });
  }

  Future<void> _loadHighScore() async {
    final chosen = _difficulty;
    final score = await _scoreService.getHighScore(difficulty: chosen);
    if (!mounted || chosen != _difficulty) return;
    setState(() => _highScore = score);
  }

  void _selectDifficulty(Difficulty difficulty) {
    setState(() => _difficulty = difficulty);
    _scoreService.saveLastDifficulty(difficulty);
    _loadHighScore();
  }

  void _startGame() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GameScreen(difficulty: _difficulty)),
    ).then((_) => _loadHighScore());
  }

  /// The page itself, with the music button floating in the top-right corner.
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildPage(context),
        const Positioned(
          top: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: MusicToggleButton(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              WorkshopSettings.skyColorTop,
              WorkshopSettings.skyColorBottom,
            ],
          ),
        ),
        child: SafeArea(
          // LayoutBuilder tells us how much room we have, so the layout
          // can shrink or grow with the screen (responsive design).
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double scale =
                  (constraints.maxWidth / 400).clamp(0.8, 1.3).toDouble();

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16 * scale,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTitle(scale),
                            SizedBox(height: 22 * scale),
                            _buildDifficultySelector(scale),
                            SizedBox(height: 18 * scale),
                            SizedBox(
                              width: double.infinity,
                              child: ArcadeButton(
                                label: 'START EXAM',
                                fontSize: 20 * scale,
                                verticalPadding: 20 * scale,
                                onTap: _startGame,
                              ),
                            ),
                            SizedBox(height: 20 * scale),
                            _buildHowToPlay(scale),
                            SizedBox(height: 14 * scale),
                            _buildHighScore(scale),
                            SizedBox(height: 14 * scale),
                            Text(
                              'Created by ${WorkshopSettings.creatorName}',
                              textAlign: TextAlign.center,
                              style: pixelText(9 * scale, color: const Color(0xFFFFE9A8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(double scale) {
    return Column(
      children: [
        Text('🎓 📚 ✏️ ☕', style: TextStyle(fontSize: 26 * scale)),
        SizedBox(height: 10 * scale),
        // FittedBox shrinks the title if the screen is very narrow.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            WorkshopSettings.titleLine1,
            style: pixelText(46 * scale, shadow: true),
          ),
        ),
        SizedBox(height: 6 * scale),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            WorkshopSettings.titleLine2,
            style: pixelText(46 * scale, color: const Color(0xFFFFD23F), shadow: true),
          ),
        ),
        SizedBox(height: 14 * scale),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 10 * scale),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            WorkshopSettings.tagline,
            textAlign: TextAlign.center,
            style: pixelText(10 * scale, color: const Color(0xFFFFE9A8), height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector(double scale) {
    return Column(
      children: [
        Text(
          'CHOOSE DIFFICULTY',
          style: pixelText(11 * scale, color: Colors.white70),
        ),
        SizedBox(height: 10 * scale),
        Row(
          children: [
            // One card per difficulty. A "for" loop inside a list
            // builds the three cards for us.
            for (final difficulty in Difficulty.values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _DifficultyCard(
                    difficulty: difficulty,
                    selected: difficulty == _difficulty,
                    scale: scale,
                    onTap: () => _selectDifficulty(difficulty),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 10 * scale),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 38 * scale),
          child: Center(
            child: Text(
              '${_difficulty.modeName}\n${_difficulty.description}',
              textAlign: TextAlign.center,
              style: pixelText(9 * scale, color: Colors.white, height: 1.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHowToPlay(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW TO PLAY',
            style: pixelText(11 * scale, color: const Color(0xFFFFD23F)),
          ),
          SizedBox(height: 10 * scale),
          _HowToRow(emoji: '👆', text: 'TAP anywhere to flap up', scale: scale),
          _HowToRow(
            emoji: '📚',
            text: 'Squeeze through the gaps in the book stacks',
            scale: scale,
          ),
          _HowToRow(
            emoji: '💥',
            text: 'Hit a book, the desk or the top = game over',
            scale: scale,
          ),
          _HowToRow(
            emoji: '⭐',
            text: 'Pass a stack to score. The longer you last, the more points!',
            scale: scale,
          ),
        ],
      ),
    );
  }

  Widget _buildHighScore(double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            'BEST SCORE · ${_difficulty.label}',
            style: pixelText(10 * scale, color: _difficulty.color),
          ),
          SizedBox(height: 8 * scale),
          Text(
            '$_highScore',
            style: pixelText(30 * scale, color: const Color(0xFFD63031)),
          ),
        ],
      ),
    );
  }
}

/// One selectable difficulty button (emoji + name).
class _DifficultyCard extends StatelessWidget {
  final Difficulty difficulty;
  final bool selected;
  final double scale;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.difficulty,
    required this.selected,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: difficulty.modeName,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 4),
          decoration: BoxDecoration(
            color: selected
                ? difficulty.color
                : Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? Colors.white : Colors.white.withValues(alpha: 0.3),
              width: selected ? 3 : 2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: difficulty.color.withValues(alpha: 0.6),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(difficulty.emoji, style: TextStyle(fontSize: 26 * scale)),
              SizedBox(height: 6 * scale),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  difficulty.label,
                  style: pixelText(
                    11 * scale,
                    color: selected ? Colors.white : Colors.white70,
                    shadow: selected,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One line of the "HOW TO PLAY" card: an emoji and a sentence.
class _HowToRow extends StatelessWidget {
  final String emoji;
  final String text;
  final double scale;

  const _HowToRow({
    required this.emoji,
    required this.text,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 16 * scale)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: pixelText(9 * scale, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
