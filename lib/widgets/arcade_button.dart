import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 🔤 One place for our pixel-style text, so every screen matches.
/// `shadow: true` adds the dark "arcade" drop shadow behind the letters.
TextStyle pixelText(
  double size, {
  Color color = Colors.white,
  bool shadow = false,
  double? height,
}) {
  return GoogleFonts.pressStart2p(
    fontSize: size,
    color: color,
    height: height,
    shadows: shadow
        ? [
            Shadow(
              color: const Color(0xFF0B1030),
              offset: Offset(size / 12 + 1, size / 12 + 1),
              blurRadius: 0,
            ),
          ]
        : null,
  );
}

/// 🕹️ A chunky arcade button. Used on the home screen AND the
/// game-over screen, so we only had to design it once.
///
/// The two colors make the gradient; the darker "ledge" under the
/// button is drawn with a BoxShadow that sits a few pixels lower.
class ArcadeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color topColor;
  final Color bottomColor;
  final double fontSize;
  final double verticalPadding;

  const ArcadeButton({
    super.key,
    required this.label,
    required this.onTap,
    this.topColor = const Color(0xFF2ECC71),
    this.bottomColor = const Color(0xFF27AE60),
    this.fontSize = 18,
    this.verticalPadding = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: verticalPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [topColor, bottomColor],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
            boxShadow: [
              BoxShadow(
                color: Color.lerp(bottomColor, Colors.black, 0.45) ?? bottomColor,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 9),
                blurRadius: 10,
              ),
            ],
          ),
          // FittedBox shrinks the text if the button is too narrow,
          // so the label can never overflow on small screens.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: pixelText(fontSize, shadow: true)),
          ),
        ),
      ),
    );
  }
}
