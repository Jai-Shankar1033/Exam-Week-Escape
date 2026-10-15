import 'package:shared_preferences/shared_preferences.dart';
import 'package:flappy_flame/models/difficulty.dart';

class ScoreService {
  static const String _lastDifficultyKey = 'last_difficulty';

  /// Every difficulty keeps its own high score, so a CHILL record
  /// doesn't hide your FINALS record.
  /// NORMAL keeps the original 'high_score' key, so scores saved
  /// before this update are not lost.
  String _highScoreKey(Difficulty difficulty) {
    if (difficulty == Difficulty.normal) return 'high_score';
    return 'high_score_${difficulty.name}';
  }

  Future<int> getHighScore({Difficulty difficulty = Difficulty.normal}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey(difficulty)) ?? 0;
  }

  Future<void> saveHighScore(
    int score, {
    Difficulty difficulty = Difficulty.normal,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHighScore = await getHighScore(difficulty: difficulty);
    if (score > currentHighScore) {
      await prefs.setInt(_highScoreKey(difficulty), score);
    }
  }

  Future<void> resetHighScore({
    Difficulty difficulty = Difficulty.normal,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_highScoreKey(difficulty));
  }

  /// Remembers which mode the player picked last.
  Future<Difficulty> getLastDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    return Difficulty.fromName(prefs.getString(_lastDifficultyKey));
  }

  Future<void> saveLastDifficulty(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastDifficultyKey, difficulty.name);
  }
}
