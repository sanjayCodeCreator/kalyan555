import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/ng_difficulty.dart';
import '../data/models/ng_player_stats.dart';

/// Provider for player stats
final ngStatsProvider = StateNotifierProvider<NGStatsNotifier, NGPlayerStats>((
  ref,
) {
  return NGStatsNotifier();
});

/// State notifier for tracking player statistics
class NGStatsNotifier extends StateNotifier<NGPlayerStats> {
  NGStatsNotifier() : super(NGPlayerStats.initial()) {
    _loadStats();
  }

  static const String _storageKey = 'ng_player_stats';
  static const int _maxRecentGames = 20;

  /// Load stats from SharedPreferences
  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        state = NGPlayerStats.fromJson(json);
      }
    } catch (_) {
      // If loading fails, use default state
    }
  }

  /// Save stats to SharedPreferences
  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    } catch (_) {
      // Fail silently
    }
  }

  /// Record a game result
  void recordResult({
    required NGDifficulty difficulty,
    required bool won,
    required int attempts,
    required int targetNumber,
    int? timeSeconds,
    required int hintsUsed,
  }) {
    // Update streaks
    int newWinStreak = state.currentWinStreak;
    int newBestStreak = state.bestWinStreak;

    if (won) {
      newWinStreak++;
      if (newWinStreak > newBestStreak) {
        newBestStreak = newWinStreak;
      }
    } else {
      newWinStreak = 0;
    }

    // Update difficulty stats
    final currentDiffStats = state.statsForDifficulty(difficulty);
    DifficultyStats newDiffStats;

    if (won) {
      int? newBestAttempts = currentDiffStats.bestAttempts;
      if (newBestAttempts == null || attempts < newBestAttempts) {
        newBestAttempts = attempts;
      }

      int? newBestTime = currentDiffStats.bestTimeSeconds;
      if (timeSeconds != null) {
        if (newBestTime == null || timeSeconds < newBestTime) {
          newBestTime = timeSeconds;
        }
      }

      newDiffStats = currentDiffStats.copyWith(
        gamesPlayed: currentDiffStats.gamesPlayed + 1,
        gamesWon: currentDiffStats.gamesWon + 1,
        bestAttempts: newBestAttempts,
        bestTimeSeconds: newBestTime,
      );
    } else {
      newDiffStats = currentDiffStats.copyWith(
        gamesPlayed: currentDiffStats.gamesPlayed + 1,
      );
    }

    final newDifficultyStats = Map<NGDifficulty, DifficultyStats>.from(
      state.difficultyStats,
    );
    newDifficultyStats[difficulty] = newDiffStats;

    // Add to recent games
    final newEntry = GameHistoryEntry(
      timestamp: DateTime.now(),
      difficulty: difficulty,
      won: won,
      attempts: attempts,
      targetNumber: targetNumber,
      timeSeconds: timeSeconds,
    );

    final newRecentGames = [newEntry, ...state.recentGames];
    if (newRecentGames.length > _maxRecentGames) {
      newRecentGames.removeLast();
    }

    state = state.copyWith(
      totalGames: state.totalGames + 1,
      totalWins: won ? state.totalWins + 1 : state.totalWins,
      totalLosses: won ? state.totalLosses : state.totalLosses + 1,
      currentWinStreak: newWinStreak,
      bestWinStreak: newBestStreak,
      difficultyStats: newDifficultyStats,
      recentGames: newRecentGames,
    );

    // Check for new achievements
    _checkAchievements(
      won: won,
      attempts: attempts,
      difficulty: difficulty,
      timeSeconds: timeSeconds,
      hintsUsed: hintsUsed,
    );

    _saveStats();
  }

  /// Check and unlock new achievements
  void _checkAchievements({
    required bool won,
    required int attempts,
    required NGDifficulty difficulty,
    int? timeSeconds,
    required int hintsUsed,
  }) {
    final newAchievements = List<String>.from(state.unlockedAchievements);
    bool updated = false;

    // First win
    if (won && state.totalWins == 1 && !newAchievements.contains('first_win')) {
      newAchievements.add('first_win');
      updated = true;
    }

    // Lucky guess (first attempt)
    if (won && attempts == 1 && !newAchievements.contains('lucky_guess')) {
      newAchievements.add('lucky_guess');
      updated = true;
    }

    // Two attempts
    if (won && attempts == 2 && !newAchievements.contains('two_attempts')) {
      newAchievements.add('two_attempts');
      updated = true;
    }

    // Win streaks
    if (state.currentWinStreak >= 3 &&
        !newAchievements.contains('win_streak_3')) {
      newAchievements.add('win_streak_3');
      updated = true;
    }
    if (state.currentWinStreak >= 5 &&
        !newAchievements.contains('win_streak_5')) {
      newAchievements.add('win_streak_5');
      updated = true;
    }
    if (state.currentWinStreak >= 10 &&
        !newAchievements.contains('win_streak_10')) {
      newAchievements.add('win_streak_10');
      updated = true;
    }

    // Games played
    if (state.totalGames >= 10 && !newAchievements.contains('games_10')) {
      newAchievements.add('games_10');
      updated = true;
    }
    if (state.totalGames >= 50 && !newAchievements.contains('games_50')) {
      newAchievements.add('games_50');
      updated = true;
    }
    if (state.totalGames >= 100 && !newAchievements.contains('games_100')) {
      newAchievements.add('games_100');
      updated = true;
    }

    // Beat hard
    if (won &&
        difficulty == NGDifficulty.hard &&
        !newAchievements.contains('beat_hard')) {
      newAchievements.add('beat_hard');
      updated = true;
    }

    // Speed demon
    if (won &&
        timeSeconds != null &&
        timeSeconds < 30 &&
        !newAchievements.contains('speed_demon')) {
      newAchievements.add('speed_demon');
      updated = true;
    }

    // No hints
    if (won && hintsUsed == 0 && !newAchievements.contains('no_hints')) {
      newAchievements.add('no_hints');
      updated = true;
    }

    // All difficulties
    final hasEasyWin = state.statsForDifficulty(NGDifficulty.easy).gamesWon > 0;
    final hasMediumWin =
        state.statsForDifficulty(NGDifficulty.medium).gamesWon > 0;
    final hasHardWin =
        state.statsForDifficulty(NGDifficulty.hard).gamesWon > 0 ||
        (won && difficulty == NGDifficulty.hard);
    if (hasEasyWin &&
        hasMediumWin &&
        hasHardWin &&
        !newAchievements.contains('all_difficulties')) {
      newAchievements.add('all_difficulties');
      updated = true;
    }

    if (updated) {
      state = state.copyWith(unlockedAchievements: newAchievements);
    }
  }

  /// Reset all stats
  void resetStats() {
    state = NGPlayerStats.initial();
    _saveStats();
  }
}
