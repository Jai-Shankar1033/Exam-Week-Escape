# 🎨 WORKSHOP CHEAT SHEET

## 📂 Where to Find Things

**Main Settings File (EDIT THIS!):**
```
lib/workshop/game_settings.dart ⭐
```

**Example Themes (COPY FROM HERE):**
```
workshop/EXAMPLES.dart
```

**Add Images:**
```
workshop/assets/
  - bird.png
  - pipe.png
```

**Add Sounds:**
```
workshop/sounds/
  - jump.mp3
  - score.mp3
  - game_over.mp3
```

## ⚙️ Quick Settings Reference

### Physics Settings (in game_settings.dart)

| Setting | What It Does | Default | Try |
|---------|-------------|---------|-----|
| `birdSize` | How big is the bird | 40 | 60, 80 |
| `gravity` | How fast bird falls | 1200 | 600 (easy), 1800 (hard) |
| `jumpStrength` | How high bird jumps | -400 | -600 (higher), -300 (lower) |
| `pipeSpeed` | How fast pipes move | 200 | 300 (fast), 100 (slow) |
| `pipeWidth` | How wide are pipes | 80 | 60, 100 |
| `gapHeight` | Space between pipes | 200 | 250 (easier), 150 (harder) |
| `pipeSpawnInterval` | Time between pipes | 2.0 | 1.0 (more pipes), 3.0 (fewer) |
| `groundHeight` | How tall is ground | 100 | 80, 120 |

**💡 Pro Tip:** Change ONE thing at a time and test!

## 🎨 Color Names You Can Use

Instead of `Color(0xFF...)`, use these simple names:

```dart
Colors.red
Colors.blue
Colors.green
Colors.yellow
Colors.orange
Colors.purple
Colors.pink
Colors.black
Colors.white
Colors.grey
Colors.brown
Colors.cyan
Colors.lime
Colors.teal
Colors.indigo
```

## 🌈 Custom Colors (Hex Codes)

Format: `Color(0xFF______)`
- First FF = fully visible (opacity)
- Next 6 digits = color code

**Examples:**
```dart
Color(0xFFFF0000)  // Red
Color(0xFF00FF00)  // Green
Color(0xFF0000FF)  // Blue
Color(0xFFFFD700)  // Gold
Color(0xFFFF1493)  // Pink
Color(0xFF800080)  // Purple
Color(0xFF00FFFF)  // Cyan
Color(0xFFFFFFFF)  // White
Color(0xFF000000)  // Black
```

🔗 Find more at: https://htmlcolorcodes.com/

## 🚀 Common Customizations

### Make Game Easier
```dart
gravity: 800,           // Falls slower
jumpStrength: -450,     // Jumps higher
pipeSpeed: 150,         // Moves slower
gapHeight: 250,         // Bigger gap
pipeSpawnInterval: 3.0, // Fewer pipes
```

### Make Game Harder
```dart
gravity: 1800,          // Falls faster
jumpStrength: -350,     // Doesn't jump as high
pipeSpeed: 300,         // Moves faster
gapHeight: 150,         // Smaller gap
pipeSpawnInterval: 1.5, // More pipes
```

### Make It Look Cool
```dart
birdColor: Colors.purple,
pipeColor: Colors.orange,
skyColorTop: Color(0xFFFF69B4),    // Pink sky
skyColorBottom: Color(0xFF87CEEB), // Blue sky
```

## 🐛 Debugging Tips

**Game crashes after your change?**
1. Did you save the file?
2. Check for missing `;` at end of lines
3. Check for missing `,` between settings
4. Make sure parentheses match `()`

**Nothing changed?**
1. Make sure you edited `lib/workshop/game_settings.dart`
2. Save the file (Ctrl+S / Cmd+S)
3. Restart the game

**Want to undo?**
- Scroll down in game_settings.dart
- Find the original values in the comments
- Copy them back

## 🎮 Fun Experiments

1. **Reverse Gravity:** Try negative gravity like `-1200`
2. **Frozen Pipes:** Set `pipeSpeed: 0`
3. **Backwards Pipes:** Set `pipeSpeed: -200`
4. **Giant Bird:** Set `birdSize: 100`
5. **Invisible Clouds:** Set `cloudOpacity: 0.0`
6. **Rainbow Everything:** Make every color different!
7. **Tiny Gap:** Set `gapHeight: 50` (super hard!)
8. **Mega Jump:** Set `jumpStrength: -1000`

## 📋 Copy-Paste Template

```dart
// My custom settings!
static const double gravity = 1200;
static const double jumpStrength = -400;
static const double birdSize = 40;
static const Color birdColor = Color(0xFFFFD700);
static const double pipeSpeed = 200;
static const double gapHeight = 200;
```

---

**Remember:** There's no wrong way to experiment! Have fun! 🎉
