# Changelog

## Unreleased

### Added
- **Background music.** A calm lo-fi track on the home screen (`assets/audio/music/menu.wav`)
  and an upbeat chiptune track while playing (`assets/audio/music/game.wav`).
  Both are original and loop seamlessly.
- **Music on/off button** on the home and game screens. The choice is saved on the device.
- Music settings in `lib/workshop/game_settings.dart` (file names, volumes, first-launch default).
- Web support for music: playback starts after the player's first tap (browser autoplay rules).
- The four sound effects the game already referenced (`workshop/sounds/jump|score|hit|swoosh.wav`).
- Tests: music toggle and saved preference, and a guard that every audio file named in the
  settings exists on disk and is bundled by `pubspec.yaml`.
- `tools/build_vercel_site.ps1` and `.sh` to build the web game into `vercel-site/`.
- `tools/generate_audio.py` to regenerate the music and sound effects.

### Fixed
- Sound effects could never play: the code looked for `workshop/sounds/...` under Flame's default
  `assets/audio/` prefix. All audio is now addressed by its full asset path.
- `workshop/sounds/README.md` listed file names the game does not use.

### Removed
- Build output and caches (`build/`, `.dart_tool/`, `.flutter-plugins-dependencies`).
- Generated or machine-specific files (`android/.gradle`, `android/local.properties`, iOS/macOS/Windows/Linux
  `ephemeral` folders, iOS and Android plugin-registrant files). Flutter recreates them automatically.
- `.github/modernize/` (unrelated Java-upgrade tooling).
- `lib/services/workshop_assets.dart` and `lib/models/game_state.dart`: unreferenced code
  (no imports anywhere; the first also pointed at asset paths that don't exist).

### Unchanged
- Gameplay, controls, scoring, collisions, difficulty modes, navigation, theme,
  `lib/workshop/student_code.dart`, and `pubspec.lock`.
