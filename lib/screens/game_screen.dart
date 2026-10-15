import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flappy_flame/game/flappy_game.dart';
import 'package:flappy_flame/models/difficulty.dart';
import 'package:flappy_flame/services/audio_service.dart';
import 'package:flappy_flame/widgets/game_overlay.dart';
import 'package:flappy_flame/widgets/music_toggle_button.dart';
import 'package:flappy_flame/workshop/game_settings.dart';

class GameScreen extends StatefulWidget {
  /// The mode picked on the home screen.
  final Difficulty difficulty;

  const GameScreen({super.key, this.difficulty = Difficulty.normal});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late FlappyGame _game;
  int _score = 0;
  int _highScore = 0;
  bool _showGameOver = false;

  @override
  void initState() {
    super.initState();
    // Tell the whole game which difficulty to use BEFORE it is created.
    WorkshopSettings.difficulty = widget.difficulty;
    _game = FlappyGame()
      ..onScoreUpdate = _updateScore
      ..onGameOverCallback = _handleGameOver;

    AudioService().playMusic(MusicTrack.game); // upbeat music while playing
  }

  @override
  void dispose() {
    // Back to the calm home-screen tune when leaving the game.
    AudioService().playMusic(MusicTrack.menu);
    super.dispose();
  }

  void _updateScore(int score, int highScore) {
    setState(() {
      _score = score;
      _highScore = highScore;
    });
  }

  void _handleGameOver() {
    setState(() => _showGameOver = true);
  }

  void _restartGame() {
    setState(() => _showGameOver = false);
    _game.resetGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          GameOverlay(
            score: _score,
            highScore: _highScore,
            isGameOver: _showGameOver,
            isPlaying: _game.gameState == GameState.playing,
            isNewBest: _game.isNewBest,
            difficulty: widget.difficulty,
            onRestart: _restartGame,
            onBack: () => Navigator.pop(context),
          ),
          // Music on/off, always reachable in the top-right corner.
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
      ),
    );
  }
}
