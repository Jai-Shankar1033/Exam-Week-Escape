import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flappy_flame/workshop/game_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The two background tracks.
enum MusicTrack { menu, game }

/// 🔊 AUDIO SERVICE
/// Manages all game sounds and background music.
///
/// SOUND EFFECTS  live in  workshop/sounds/   (names set in game_settings.dart)
/// BACKGROUND MUSIC lives in assets/audio/music/ (names set in game_settings.dart)
///
/// Every file is addressed by its FULL asset path (the audio cache prefix is
/// set to '' in [initialize]), so what you see in pubspec.yaml is exactly
/// what the game loads.
///
/// MUSIC RULES (so it never goes wrong):
///  * There is ONE music player, so two tracks can never overlap.
///  * Every music command goes through a queue and runs one at a time, so
///    quickly tapping between screens can't create duplicate music.
///  * Asking for the track that is already playing does nothing.
///  * On the web, browsers block sound until the player taps. We wait for the
///    first tap ([onUserGesture]) and then start the music that was requested.
///  * The on/off choice is saved on the device.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  static const String _sfxFolder = 'workshop/sounds/';
  static const String _musicFolder = 'assets/audio/music/';
  static const String _musicPrefKey = 'music_enabled';

  Future<void>? _initFuture;
  bool _soundEnabled = true;

  /// Tests set this to true so no real audio is ever played.
  @visibleForTesting
  bool playbackDisabled = false;

  /// True when the music is switched on. Widgets listen to this.
  final ValueNotifier<bool> musicEnabled =
      ValueNotifier<bool>(WorkshopSettings.musicEnabled);

  MusicTrack? _wantedTrack; // what SHOULD be playing
  MusicTrack? _playingTrack; // what IS playing
  bool _gestureSeen = false;
  Future<void> _musicQueue = Future<void>.value();

  /// Initialize audio system and preload sounds. Safe to call many times.
  Future<void> initialize() => _initFuture ??= _initialize();

  Future<void> _initialize() async {
    _soundEnabled = WorkshopSettings.soundEnabled;

    if (!playbackDisabled) {
      try {
        // Use full asset paths everywhere (see the note at the top).
        FlameAudio.audioCache.prefix = '';
        FlameAudio.bgm.initialize(); // also pauses music when the app is hidden
      } catch (e) {
        debugPrint('AudioService: setup failed: $e');
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      musicEnabled.value =
          prefs.getBool(_musicPrefKey) ?? WorkshopSettings.musicEnabled;
    } catch (e) {
      debugPrint('AudioService: could not read music setting: $e');
    }

    if (_soundEnabled && !playbackDisabled) {
      try {
        await FlameAudio.audioCache.loadAll([
          _sfx(WorkshopSettings.jumpSound),
          _sfx(WorkshopSettings.scoreSound),
          _sfx(WorkshopSettings.hitSound),
          _sfx(WorkshopSettings.swooshSound),
        ]);
      } catch (e) {
        // Sound files not found - the game simply stays silent.
        debugPrint('AudioService: sound effects unavailable: $e');
        _soundEnabled = false;
      }
    }
  }

  String _sfx(String file) => '$_sfxFolder$file';

  // ───────────────────────── sound effects ─────────────────────────

  void _playEffect(String file, double volume) {
    if (playbackDisabled || !_soundEnabled || !WorkshopSettings.soundEnabled) {
      return;
    }
    try {
      unawaited(
        FlameAudio.play(_sfx(file), volume: volume).then(
          (_) {},
          onError: (Object e) => debugPrint('AudioService: effect failed: $e'),
        ),
      );
    } catch (e) {
      // Sound file not available
    }
  }

  /// Play jump sound when bird flaps
  void playJump() =>
      _playEffect(WorkshopSettings.jumpSound, WorkshopSettings.jumpVolume);

  /// Play score sound when passing a pipe
  void playScore() =>
      _playEffect(WorkshopSettings.scoreSound, WorkshopSettings.scoreVolume);

  /// Play hit sound on collision
  void playHit() =>
      _playEffect(WorkshopSettings.hitSound, WorkshopSettings.hitVolume);

  /// Play swoosh sound (for menu transitions, etc.)
  void playSwoosh() =>
      _playEffect(WorkshopSettings.swooshSound, WorkshopSettings.swooshVolume);

  /// Toggle sound effects on/off
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  /// Check if sound effects are enabled
  bool get isSoundEnabled => _soundEnabled && WorkshopSettings.soundEnabled;

  // ───────────────────────── background music ─────────────────────────

  /// Ask for [track] to be playing. Calling this again with the same track
  /// is harmless.
  Future<void> playMusic(MusicTrack track) {
    _wantedTrack = track;
    return _enqueueMusicSync();
  }

  /// Stop the music (and forget which track was wanted).
  Future<void> stopMusic() {
    _wantedTrack = null;
    return _enqueueMusicSync();
  }

  /// Switch music on/off and remember the choice.
  Future<void> setMusicEnabled(bool enabled) async {
    musicEnabled.value = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_musicPrefKey, enabled);
    } catch (e) {
      debugPrint('AudioService: could not save music setting: $e');
    }
    await _enqueueMusicSync();
  }

  Future<void> toggleMusic() => setMusicEnabled(!musicEnabled.value);

  /// Call this on the player's first tap. Browsers only allow audio after
  /// a user interaction, so this is what actually starts the music on the web.
  void onUserGesture() {
    if (_gestureSeen) return;
    _gestureSeen = true;
    unawaited(_enqueueMusicSync());
  }

  Future<void> _enqueueMusicSync() {
    _musicQueue = _musicQueue.then((_) => _syncMusic()).catchError((Object e) {
      debugPrint('AudioService: music error: $e');
    });
    return _musicQueue;
  }

  /// Makes what is playing match what should be playing.
  Future<void> _syncMusic() async {
    await initialize();
    if (playbackDisabled) return;

    // Native apps may play right away; the web needs a tap first.
    final bool mayPlay = !kIsWeb || _gestureSeen;
    final MusicTrack? target =
        (mayPlay && musicEnabled.value && WorkshopSettings.soundEnabled)
            ? _wantedTrack
            : null;

    if (target == null) {
      if (_playingTrack != null) {
        _playingTrack = null;
        try {
          await FlameAudio.bgm.stop();
        } catch (e) {
          debugPrint('AudioService: could not stop music: $e');
        }
      }
      return;
    }

    if (_playingTrack == target) return; // already playing, no duplicate

    final bool isMenu = target == MusicTrack.menu;
    final String file =
        isMenu ? WorkshopSettings.menuMusic : WorkshopSettings.gameMusic;
    final double volume = isMenu
        ? WorkshopSettings.menuMusicVolume
        : WorkshopSettings.gameMusicVolume;
    try {
      // bgm.play() replaces whatever track was playing and loops the new one.
      await FlameAudio.bgm.play('$_musicFolder$file', volume: volume);
      _playingTrack = target;
    } catch (e) {
      _playingTrack = null;
      debugPrint('AudioService: could not play music: $e');
    }
  }

  /// Dispose audio resources
  void dispose() {
    unawaited(stopMusic());
    FlameAudio.audioCache.clearAll();
    _initFuture = null;
  }
}
