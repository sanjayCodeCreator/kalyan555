import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/game_state.dart';
import '../data/models/stats_model.dart';

/// Provider for Minesweeper statistics
final minesweeperStatsProvider =
    StateNotifierProvider<MinesweeperStatsNotifier, MinesweeperStats>((ref) {
  return MinesweeperStatsNotifier();
});

/// Stats notifier for Minesweeper game
class MinesweeperStatsNotifier extends StateNotifier<MinesweeperStats> {
  static const _statsKey = 'minesweeper_stats';

  MinesweeperStatsNotifier() : super(MinesweeperStats.initial()) {
    _loadStats();
  }

  /// Load stats from SharedPreferences
  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);

      if (statsJson != null && mounted) {
        final statsMap = jsonDecode(statsJson) as Map<String, dynamic>;
        state = MinesweeperStats.fromJson(statsMap);
      }
    } catch (e) {
      // Keep default stats on error
    }
  }

  /// Save stats to SharedPreferences
  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_statsKey, jsonEncode(state.toJson()));
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Record a game result
  Future<void> recordGame({
    required bool won,
    required Difficulty difficulty,
    required int time,
    required bool usedFlags,
    required int wrongFlags,
  }) async {
    if (!mounted) return;

    final newAchievements = Set<Achievement>.from(state.unlockedAchievements);
    var newBestTimes = Map<Difficulty, int?>.from(state.bestTimes);

    // Update basic stats
    final gamesPlayed = state.gamesPlayed + 1;
    var gamesWon = state.gamesWon;
    var gamesLost = state.gamesLost;
    var currentStreak = state.currentStreak;
    var bestStreak = state.bestStreak;

    if (won) {
      gamesWon++;
      currentStreak++;
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }

      // Update best time
      final currentBest = newBestTimes[difficulty];
      if (currentBest == null || time < currentBest) {
        newBestTimes[difficulty] = time;
      }

      // Check achievements
      _checkWinAchievements(
        newAchievements,
        gamesWon: gamesWon,
        difficulty: difficulty,
        time: time,
        usedFlags: usedFlags,
        wrongFlags: wrongFlags,
        bestTimes: newBestTimes,
      );
    } else {
      gamesLost++;
      currentStreak = 0;
    }

    // First game achievement
    if (gamesPlayed == 1 && won) {
      newAchievements.add(Achievement.firstWin);
    }

    state = state.copyWith(
      gamesPlayed: gamesPlayed,
      gamesWon: gamesWon,
      gamesLost: gamesLost,
      bestTimes: newBestTimes,
      unlockedAchievements: newAchievements,
      totalPlayTime: state.totalPlayTime + time,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      lastPlayedDate: DateTime.now(),
    );

    await _saveStats();
  }

  /// Check win-related achievements
  void _checkWinAchievements(
    Set<Achievement> achievements, {
    required int gamesWon,
    required Difficulty difficulty,
    required int time,
    required bool usedFlags,
    required int wrongFlags,
    required Map<Difficulty, int?> bestTimes,
  }) {
    // First win
    if (gamesWon == 1) {
      achievements.add(Achievement.firstWin);
    }

    // No-flag win
    if (!usedFlags) {
      achievements.add(Achievement.noFlagWin);
    }

    // Perfect game (no wrong flags)
    if (wrongFlags == 0) {
      achievements.add(Achievement.perfectGame);
    }

    // Speed achievements
    switch (difficulty) {
      case Difficulty.beginner:
        if (time < 30) achievements.add(Achievement.speedSweeperBeginner);
        break;
      case Difficulty.intermediate:
        if (time < 120) achievements.add(Achievement.speedSweeperIntermediate);
        break;
      case Difficulty.expert:
        if (time < 300) achievements.add(Achievement.speedSweeperExpert);
        break;
      case Difficulty.custom:
        break;
    }

    // Win count achievements
    if (gamesWon >= 10) achievements.add(Achievement.tenWins);
    if (gamesWon >= 50) achievements.add(Achievement.fiftyWins);
    if (gamesWon >= 100) achievements.add(Achievement.hundredWins);

    // All difficulties achievement
    if (bestTimes[Difficulty.beginner] != null &&
        bestTimes[Difficulty.intermediate] != null &&
        bestTimes[Difficulty.expert] != null) {
      achievements.add(Achievement.allDifficulties);
    }
  }

  /// Record daily challenge completion
  Future<void> recordDailyChallenge() async {
    if (!mounted) return;

    final newAchievements = Set<Achievement>.from(state.unlockedAchievements);
    newAchievements.add(Achievement.dailyChallenge);

    final completed = state.dailyChallengesCompleted + 1;
    if (completed >= 7) {
      newAchievements.add(Achievement.weeklyStreak);
    }

    state = state.copyWith(
      dailyChallengesCompleted: completed,
      unlockedAchievements: newAchievements,
    );

    await _saveStats();
  }

  /// Reset all statistics
  Future<void> resetStats() async {
    if (!mounted) return;

    state = MinesweeperStats.initial();
    await _saveStats();
  }

  /// Get best time for difficulty
  int? getBestTime(Difficulty difficulty) => state.bestTimes[difficulty];

  /// Check if achievement is unlocked
  bool hasAchievement(Achievement achievement) =>
      state.unlockedAchievements.contains(achievement);
}
