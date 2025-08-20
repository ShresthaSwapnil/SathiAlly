import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:frontend/models/player_progress.dart';

class GamificationService {
  final Box<PlayerProgress> _progressBox = Hive.box<PlayerProgress>(
    'player_progress',
  );

  // Helper function to check if two dates are on consecutive days
  bool _isConsecutiveDay(DateTime last, DateTime now) {
    final difference = now.difference(last).inDays;
    if (difference == 1) return true;
    // Handle edge case of just before and after midnight
    if (difference == 0 && now.day != last.day) return true;
    return false;
  }

  // Helper to check if it's the same day
  bool _isSameDay(DateTime last, DateTime now) {
    return last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;
  }

  Future<void> updateProgress({required int totalScore}) async {
    final PlayerProgress progress;
    final now = DateTime.now();

    if (_progressBox.isEmpty) {
      // First session ever
      progress = PlayerProgress(
        totalXp: 0,
        streakCount: 1,
        lastSessionDate: now,
      );
    } else {
      progress = _progressBox.getAt(0)!;
    }

    // --- Calculate XP ---
    // 5 base XP for completing, plus the score
    int xpGained = 5 + totalScore;
    progress.totalXp += xpGained;

    // --- Calculate Streak ---
    if (!_isSameDay(progress.lastSessionDate, now)) {
      if (_isConsecutiveDay(progress.lastSessionDate, now)) {
        // It's the next day, increase streak!
        progress.streakCount++;
      } else {
        // Missed a day, reset streak to 1
        progress.streakCount = 1;
      }
      progress.lastSessionDate = now;
    }

    // Save the updated progress. `put(0, ...)` overwrites the entry at index 0.
    await _progressBox.put(0, progress);
  }

  PlayerProgress getProgress() {
    if (_progressBox.isEmpty) {
      // Return default values if no progress has been made yet
      return PlayerProgress(
        totalXp: 0,
        streakCount: 0,
        lastSessionDate: DateTime.now().subtract(const Duration(days: 2)),
      );
    }
    return _progressBox.getAt(0)!;
  }
}
