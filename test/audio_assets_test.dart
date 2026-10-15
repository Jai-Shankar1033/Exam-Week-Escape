import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flappy_flame/workshop/game_settings.dart';

/// Guards against the classic "file name changed but the asset is missing"
/// bug: every sound named in game_settings.dart must exist on disk AND sit in
/// a folder that pubspec.yaml bundles into the app (and the web build).
void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();

  final sounds = <String>[
    WorkshopSettings.jumpSound,
    WorkshopSettings.scoreSound,
    WorkshopSettings.hitSound,
    WorkshopSettings.swooshSound,
  ];
  final music = <String>[
    WorkshopSettings.menuMusic,
    WorkshopSettings.gameMusic,
  ];

  test('sound effect files exist and their folder is bundled', () {
    expect(pubspec, contains('workshop/sounds/'));
    for (final name in sounds) {
      expect(File('workshop/sounds/$name').existsSync(), isTrue,
          reason: 'missing workshop/sounds/$name');
    }
  });

  test('music files exist and their folder is bundled', () {
    expect(pubspec, contains('assets/audio/music/'));
    for (final name in music) {
      expect(File('assets/audio/music/$name').existsSync(), isTrue,
          reason: 'missing assets/audio/music/$name');
    }
  });

  test('music files are a reasonable size for a web game (under 4 MB each)',
      () {
    for (final name in music) {
      final bytes = File('assets/audio/music/$name').lengthSync();
      expect(bytes, lessThan(4 * 1024 * 1024), reason: '$name is too large');
    }
  });
}
