import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flappy_flame/services/audio_service.dart';
import 'package:flappy_flame/widgets/music_toggle_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AudioService().playbackDisabled = true;
  });

  testWidgets('tapping the button switches music off and on again',
      (tester) async {
    await AudioService().setMusicEnabled(true);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Center(child: MusicToggleButton()))),
    );
    expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);

    await tester.tap(find.byType(MusicToggleButton));
    await tester.pump();
    expect(AudioService().musicEnabled.value, isFalse);
    expect(find.byIcon(Icons.music_off_rounded), findsOneWidget);

    await tester.tap(find.byType(MusicToggleButton));
    await tester.pump();
    expect(AudioService().musicEnabled.value, isTrue);
    expect(find.byIcon(Icons.music_note_rounded), findsOneWidget);
  });

  test('the music choice is saved on the device', () async {
    await AudioService().setMusicEnabled(false);
    expect((await SharedPreferences.getInstance()).getBool('music_enabled'),
        isFalse);

    await AudioService().setMusicEnabled(true);
    expect((await SharedPreferences.getInstance()).getBool('music_enabled'),
        isTrue);
  });

  test('asking for the same track twice or stopping never throws', () async {
    final audio = AudioService();
    await audio.playMusic(MusicTrack.menu);
    await audio.playMusic(MusicTrack.menu);
    await audio.playMusic(MusicTrack.game);
    await audio.stopMusic();
  });
}
