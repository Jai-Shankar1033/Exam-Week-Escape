import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flappy_flame/main.dart';
import 'package:flappy_flame/services/audio_service.dart';
import 'package:flappy_flame/widgets/music_toggle_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AudioService().playbackDisabled = true; // never play real audio in tests
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify the app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Home screen shows the music button', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MusicToggleButton), findsOneWidget);
  });
}
