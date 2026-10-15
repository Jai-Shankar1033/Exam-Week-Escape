import 'package:flutter/material.dart';
import 'dart:math';

/// ════════════════════════════════════════════════════════════════
/// 🎓 STUDENT CODE FILE
/// ════════════════════════════════════════════════════════════════
/// 
/// Welcome! This is where YOU write code!
/// 
/// HOW THIS WORKS:
/// 1. Each section below has a TASK
/// 2. Read the instructions
/// 3. Write your code where it says "YOUR CODE HERE"
/// 4. Save and hot reload (press 'r')
/// 5. See your changes!
/// 
/// 📚 THEME: "EXAM WEEK ESCAPE"
/// A student-bird with a graduation cap flies through the night sky of
/// a late-night study session and has to squeeze between towering
/// stacks of textbooks. The longer you survive, the more every book
/// stack you pass is worth!
///
/// 🎚️ These numbers are the NORMAL mode. CHILL and FINALS multiply
/// them (see lib/models/difficulty.dart).
/// 
/// ════════════════════════════════════════════════════════════════

class StudentCode {
  
  // ═══════════════════════════════════════════════════════════════
  // ✏️ TASK 1: Choose Your Bird Color
  // ═══════════════════════════════════════════════════════════════
  
  static Color getBirdColor() {
    // 🐥 Sunny yellow: easy to spot against the dark night sky.
    return const Color(0xFFFFD23F);
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ✏️ TASK 2: Set the Gravity
  // ═══════════════════════════════════════════════════════════════
  
  static double getGravity() {
    // A slightly floaty bird is easier to control.
    // Lower = easier (try 800), higher = harder (try 1500)
    // (Original: 1200)
    return 1100;
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ✏️ TASK 3: Set the Gap Size
  // ═══════════════════════════════════════════════════════════════
  
  static double getGapSize() {
    // NORMAL mode gap. CHILL makes it wider, FINALS makes it tighter.
    // (Original: 200)
    return 215;
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ✏️ TASK 4: Set the Pipe Speed
  // ═══════════════════════════════════════════════════════════════
  
  static double getPipeSpeed() {
    // NORMAL mode speed. CHILL is slower, FINALS is faster.
    // (Original: 200)
    return 210;
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ✏️ TASK 5: Calculate Jump Strength
  // ═══════════════════════════════════════════════════════════════
  
  static double calculateJumpStrength(double gravity) {
    // 🧠 Smart version: the jump is tied to gravity, so if you change
    // gravity in Task 2 the bird always still feels right!
    // With gravity 1100 this gives -396 (almost the same as -400).
    // The clamp stops the jump from ever becoming absurdly weak/strong.
    final double jump = gravity * -0.36;
    return jump.clamp(-700.0, -250.0).toDouble();
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ✏️ TASK 6: Choose Pipe Color
  // ═══════════════════════════════════════════════════════════════
  
  static Color getPipeColor() {
    // 📕 The cover color of the big textbook at the end of each stack.
    // (The books below it use their own rainbow of colors.)
    return const Color(0xFFB03A2E);
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ✏️ TASK 7: Choose Sky Colors
  // ═══════════════════════════════════════════════════════════════
  
  static Color getSkyTopColor() {
    return const Color(0xFF141E4D);  // Midnight navy
  }
  
  static Color getSkyBottomColor() {
    return const Color(0xFF7B4FD6);  // Late-night violet
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ✏️ TASK 8: Calculate Points
  // ═══════════════════════════════════════════════════════════════
  
  static int calculatePoints(int currentScore) {
    // 📈 STUDY LEVELS: the longer you survive, the more every book
    // stack you pass is worth!
    //
    //   score  0 - 9   → 1 point per stack
    //   score 10 - 19  → 2 points per stack
    //   score 20 - 39  → 3 points per stack
    //   score 40+      → 5 points per stack
    int points = 1;
    
    if (currentScore >= 40) {
      points = 5;
    } else if (currentScore >= 20) {
      points = 3;
    } else if (currentScore >= 10) {
      points = 2;
    }
    
    // Safety cap so the score can never run away (uses dart:math).
    return min(points, 5);
  }
  
  // ═══════════════════════════════════════════════════════════════
  // ✏️ TASK 9: Write Your Name!
  // ═══════════════════════════════════════════════════════════════
  
  static String getCreatorName() {
    return "Jai Shankar";  // 👈 Put your name here! Shown on the home screen.
  }
}
