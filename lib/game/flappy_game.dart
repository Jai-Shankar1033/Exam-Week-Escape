import 'dart:async';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flappy_flame/game/bird.dart';
import 'package:flappy_flame/game/pipe.dart';
import 'package:flappy_flame/game/ground.dart';
import 'package:flappy_flame/game/background.dart';
import 'package:flappy_flame/services/score_service.dart';
import 'package:flappy_flame/services/audio_service.dart';
import 'package:flappy_flame/workshop/game_settings.dart';

enum GameState { menu, playing, gameOver }

class FlappyGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  late Bird bird;
  late Ground ground;
  late GameBackground background;

  GameState gameState = GameState.menu;
  int score = 0;
  int highScore = 0;

  /// The best score before this round started, used to detect a NEW BEST.
  int _bestAtStart = 0;
  bool isNewBest = false;

  final ScoreService scoreService = ScoreService();
  final AudioService audioService = AudioService();
  Timer? pipeSpawnTimer;

  Function(int, int)? onScoreUpdate;
  Function()? onGameOverCallback;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await audioService.initialize();
    // Every difficulty mode has its own high score.
    highScore = await scoreService.getHighScore(
      difficulty: WorkshopSettings.difficulty,
    );

    background = GameBackground();
    add(background);

    bird = Bird();
    add(bird);

    ground = Ground();
    add(ground);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameState == GameState.playing) {
      pipeSpawnTimer?.update(dt);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameState == GameState.playing) {
      bird.jump();
    } else if (gameState == GameState.menu) {
      startGame();
    }
  }

  void startGame() {
    gameState = GameState.playing;
    score = 0;
    isNewBest = false;
    _bestAtStart = highScore;
    bird.reset();

    children.whereType<PipePair>().forEach((pipe) => pipe.removeFromParent());

    pipeSpawnTimer = Timer(
      WorkshopSettings.pipeSpawnInterval,
      repeat: true,
      onTick: spawnPipe,
    );

    audioService.playSwoosh();
    onScoreUpdate?.call(score, highScore);
  }

  void spawnPipe() {
    final pipe = PipePair(xPosition: size.x);
    add(pipe);
  }

  void incrementScore() {
    // 🎓 Using student's calculatePoints function!
    int points = WorkshopSettings.getPoints(score);
    score += points;

    if (score > highScore) {
      highScore = score;
    }
    onScoreUpdate?.call(score, highScore);
  }

  void gameOver() {
    if (gameState == GameState.gameOver) return;

    gameState = GameState.gameOver;
    bird.isAlive = false;
    pipeSpawnTimer?.stop();

    // A "new best" means we beat the record from before this round.
    isNewBest = score > 0 && score > _bestAtStart;

    audioService.playHit();
    scoreService.saveHighScore(score, difficulty: WorkshopSettings.difficulty);

    onGameOverCallback?.call();
  }

  void resetGame() {
    gameState = GameState.menu;
    score = 0;
    isNewBest = false;
    bird.reset();
    children.whereType<PipePair>().forEach((pipe) => pipe.removeFromParent());
    pipeSpawnTimer?.stop();
    onScoreUpdate?.call(score, highScore);
  }
}
