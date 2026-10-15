# 🎮 Flappy Game Workshop

Welcome to your game workshop! This is where you can customize your Flappy Bird game. **You only need to edit files in this folder!**

```
workshop/
├── 📖 README.md (you are here!)
├── 🚀 QUICKSTART.md (start here!)
├── 🎨 EXAMPLES.dart (cool pre-made themes)
├── ⚙️ game_settings.dart (MAIN FILE - change game here!)
├── 🖼️ assets/ (put your custom images here)
│   ├── bird.png or bird.svg
│   ├── pipe.png or pipe.svg
│   └── README.md
└── 🎵 sounds/ (put your sound effects here)
    ├── jump.mp3
    ├── score.mp3
    ├── game_over.mp3
    └── README.md
```

## 🎯 What Can You Change?

### 1. **Game Physics** (`game_settings.dart`)
- How fast the bird falls (gravity)
- How high the bird jumps
- How fast pipes move
- Gap size between pipes
- Colors of everything!

### 2. **Custom Images** (`assets/` folder)
- **Bird**: Replace with any image you want! (SVG or PNG)
- **Pipes/Obstacles**: Change to rockets, trees, buildings... anything!
- **Background**: Add your own sky, space, underwater scene

### 3. **Sound Effects** (`sounds/` folder)
- **Jump sound**: When bird flaps
- **Score sound**: When you pass a pipe
- **Game over sound**: When you crash

## 🚀 Quick Start (3 Minutes!)

### ⚡ Make Your First Change Now!

1. **Open** `game_settings.dart`

2. **Find this line** (around line 21):
   ```dart
   static const double jumpStrength = -400;
   ```

3. **Change it to**:
   ```dart
   static const double jumpStrength = -600;
   ```

4. **Save** the file

5. **Run the game** - The bird jumps super high! 🚀

### 🎨 Change a Color!

1. **Find** (around line 26):
   ```dart
   static const Color birdColor = Color(0xFFFFD700);
   ```

2. **Change to**:
   ```dart
   static const Color birdColor = Colors.red;
   ```

3. **Run the game** - Red bird! 🔴

**That's it!** You're now customizing games! 🎉

## 📚 Learn More

- **QUICKSTART.md** - Step-by-step beginner guide
- **EXAMPLES.dart** - Copy-paste ready themes (Space, Underwater, Hard Mode, etc.)
- **game_settings.dart** - The main file with all settings explained

## 💡 Cool Things to Try

### Easy Experiments:
- Make gravity = 600 (floaty moon bird!)
- Make gap bigger = 300 (super easy mode)
- Make pipes move backwards: pipeSpeed = -200
- Change ALL the colors!

### Medium Challenges:
- Make the bird huge (birdSize = 80)
- Make pipes spawn every 0.5 seconds (chaos mode!)
- Create your own color theme
- Try the example modes from EXAMPLES.dart

### Advanced Ideas:
- Draw your own bird and use it (see assets/README.md)
- Record your own sound effects (see sounds/README.md)
- Mix settings from multiple example modes
- Make the game impossible, then make it playable again

## 🎨 Example Themes (from EXAMPLES.dart)

Just open EXAMPLES.dart, copy any theme, and paste into game_settings.dart:

- 🌙 **Moon Mode** - Super low gravity, floaty
- 🔥 **Hard Mode** - Fast and challenging
- 👶 **Easy Mode** - Perfect for beginners
- 🌊 **Underwater Mode** - Slow motion
- 🚀 **Space Mode** - Black space background
- 🎃 **Halloween Mode** - Spooky colors
- 🎄 **Winter Mode** - Snowy theme
- 🏜️ **Desert Mode** - Sandy colors

## 🆘 Help & Troubleshooting

**Game won't run after changing settings?**
- Check you didn't delete any semicolons `;`
- Check you didn't delete any commas `,`
- Make sure colors are written correctly
- Copy the original value back from comments

**Want to reset everything?**
- Look for the original values in comments
- Or ask someone to help restore defaults

**Can't find a file?**
- All files are in the `workshop/` folder
- Use VS Code's file explorer on the left

## 🎯 Workshop Goals

By using this workshop, you'll learn:
- ✅ How game physics work (gravity, speed, forces)
- ✅ How to customize software without breaking it
- ✅ How to experiment and iterate
- ✅ Basic programming concepts
- ✅ Creative problem solving

Most importantly: **Have fun experimenting!** 🎉

There's no wrong way to do this - try things, break things, fix things, and make something cool!

---

**Need help?** Ask an adult, friend, or teacher to help you read `game_settings.dart`
