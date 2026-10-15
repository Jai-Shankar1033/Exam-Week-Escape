🎮 **WORKSHOP QUICK START GUIDE**
================================

## Step 1: Find the Settings File
📁 Open: `lib/workshop/game_settings.dart`
- Use VS Code file explorer on the left
- Navigate: lib → workshop → game_settings.dart

## Step 2: Make Your First Change!

### Try This:
1. Open `lib/workshop/game_settings.dart`
2. Find this line:
   ```dart
   static const double jumpStrength = -400;
   ```
3. Change it to:
   ```dart
   static const double jumpStrength = -600;
   ```
4. Save and run the game
5. The bird jumps WAY higher! 🚀

### Try Color Changes:
1. Find:
   ```dart
   static const Color birdColor = Color(0xFFFFD700);
   ```
2. Change to:
   ```dart
   static const Color birdColor = Colors.red;
   ```
3. Run the game - red bird! 🔴

## Step 3: Try Different Modes
Open `workshop/EXAMPLES.dart` to see pre-made themes like:
- 🌙 Moon Mode (low gravity)
- 🔥 Hard Mode (super fast)
- 🌊 Underwater Mode
- 🚀 Space Mode
- 🎃 Halloween Mode

Copy any example and paste into `lib/workshop/game_settings.dart`!

## Step 4: Add Custom Images
1. Draw or find an image for your bird
2. Save it as `bird.png`
3. Put it in `workshop/assets/` folder
4. In `lib/workshop/game_settings.dart`, change:
   ```dart
   static const bool useCustomBird = true;
   ```
5. Run the game - your custom bird appears!

## Step 5: Add Sound Effects
1. Record your voice or find sound files
2. Name them: `jump.mp3`, `score.mp3`, `game_over.mp3`
3. Put them in `workshop/sounds/` folder
4. They'll play automatically!

## 🎯 Challenge Ideas
- Can you make the bird jump so high it goes off screen?
- Can you make the pipes move backwards?
- Can you make a rainbow bird?
- Can you make gravity = 0? What happens?
- Can you make 10 pipes spawn per second?

## 🆘 Help!
**Game won't run?** 
- Check for missing commas or semicolons
- Make sure colors are spelled right
- Numbers can't be negative except jumpStrength

**Want to reset everything?**
- Just copy the original values back from the comments

Have fun experimenting! 🎉
