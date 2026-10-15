import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flappy_flame/theme.dart';
import 'package:flappy_flame/screens/home_screen.dart';
import 'package:flappy_flame/services/audio_service.dart';
import 'package:flappy_flame/workshop/game_settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  AudioService().initialize(); // loads sounds + the saved music setting
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: WorkshopSettings.gameTitle,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      // Browsers only allow sound after the player has tapped once.
      // This listener tells the audio service when that first tap happens.
      builder: (context, child) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => AudioService().onUserGesture(),
        child: child,
      ),
      home: const HomePage(),
    );
  }
}
