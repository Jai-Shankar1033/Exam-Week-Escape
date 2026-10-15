import 'package:flutter/material.dart';
import 'package:flappy_flame/services/audio_service.dart';

/// Small round button that switches the background music on and off.
/// The choice is saved by [AudioService] and restored next time.
class MusicToggleButton extends StatelessWidget {
  const MusicToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = AudioService();
    return ValueListenableBuilder<bool>(
      valueListenable: audio.musicEnabled,
      builder: (context, isOn, _) {
        return Semantics(
          button: true,
          label: isOn ? 'Turn music off' : 'Turn music on',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: audio.toggleMusic,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.35),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Icon(
                isOn ? Icons.music_note_rounded : Icons.music_off_rounded,
                color: isOn ? Colors.white : Colors.white54,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}
