import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/memory_match_game_state.dart';
import '../data/models/memory_match_stats.dart';

/// Storage key for stats
const _statsKey = 'memory_match_stats';

/// Provider for Memory Match statistics
final memoryMatchStatsProvider =
    StateNotifierProvider<MemoryMatchStatsNotifier, MemoryMatchStats>((ref) {
      return MemoryMatchStatsNotifier();
    });

/// State notifier for managing Memory Match statistics
class MemoryMatchStatsNotifier extends StateNotifier<MemoryMatchStats> {
  MemoryMatchStatsNotifier() : super(MemoryMatchStats.initial()) {
    _loadStats();
  }

  /// Load stats from local storage
  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);
      if (statsJson != null) {
        state = MemoryMatchStats.decode(statsJson);
      }
    } catch (_) {
      // Use default stats on error
    }
  }

  /// Save stats to local storage
  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_statsKey, state.encode());
    } catch (_) {
      // Ignore save errors
    }
  }

  /// Record a completed game
  Future<void> recordGameCompletion({
    required GridSize gridSize,
    required int moves,
    required int elapsedSeconds,
    required int hintsUsed,
    required bool isWin,
  }) async {
    final newAchievements = List<String>.from(state.achievements);

    // Update basic stats
    var updatedState = state.copyWith(
      gamesPlayed: state.gamesPlayed + 1,
      gamesWon: isWin ? state.gamesWon + 1 : state.gamesWon,
      gamesLost: isWin ? state.gamesLost : state.gamesLost + 1,
      totalMoves: state.totalMoves + moves,
      totalMatchedPairs: state.totalMatchedPairs + gridSize.totalPairs,
      totalTimePlayed: state.totalTimePlayed + elapsedSeconds,
      totalHintsUsed: state.totalHintsUsed + hintsUsed,
    );

    if (isWin) {
      // Update best times
      switch (gridSize) {
        case GridSize.small:
          if (state.bestTime2x2 < 0 || elapsedSeconds < state.bestTime2x2) {
            updatedState = updatedState.copyWith(bestTime2x2: elapsedSeconds);
          }
          if (state.bestMoves2x2 < 0 || moves < state.bestMoves2x2) {
            updatedState = updatedState.copyWith(bestMoves2x2: moves);
          }
          break;
        case GridSize.medium:
          if (state.bestTime4x4 < 0 || elapsedSeconds < state.bestTime4x4) {
            updatedState = updatedState.copyWith(bestTime4x4: elapsedSeconds);
          }
          if (state.bestMoves4x4 < 0 || moves < state.bestMoves4x4) {
            updatedState = updatedState.copyWith(bestMoves4x4: moves);
          }
          break;
        case GridSize.large:
          if (state.bestTime6x6 < 0 || elapsedSeconds < state.bestTime6x6) {
            updatedState = updatedState.copyWith(bestTime6x6: elapsedSeconds);
          }
          if (state.bestMoves6x6 < 0 || moves < state.bestMoves6x6) {
            updatedState = updatedState.copyWith(bestMoves6x6: moves);
          }
          break;
      }

      // Check for perfect game
      if (moves == gridSize.totalPairs) {
        updatedState = updatedState.copyWith(
          perfectGames: state.perfectGames + 1,
        );
        if (!newAchievements.contains(MemoryMatchAchievements.perfectGame)) {
          newAchievements.add(MemoryMatchAchievements.perfectGame);
        }
      }

      // Update win streak
      final newStreak = state.currentWinStreak + 1;
      final longestStreak = newStreak > state.longestWinStreak
          ? newStreak
          : state.longestWinStreak;
      updatedState = updatedState.copyWith(
        currentWinStreak: newStreak,
        longestWinStreak: longestStreak,
      );

      // Check for first win achievement
      if (!newAchievements.contains(MemoryMatchAchievements.firstWin)) {
        newAchievements.add(MemoryMatchAchievements.firstWin);
      }

      // Check for speedster achievements
      if (gridSize == GridSize.small && elapsedSeconds < 10) {
        if (!newAchievements.contains(MemoryMatchAchievements.speedster2x2)) {
          newAchievements.add(MemoryMatchAchievements.speedster2x2);
        }
      }
      if (gridSize == GridSize.medium && elapsedSeconds < 60) {
        if (!newAchievements.contains(MemoryMatchAchievements.speedster4x4)) {
          newAchievements.add(MemoryMatchAchievements.speedster4x4);
        }
      }
      if (gridSize == GridSize.large && elapsedSeconds < 180) {
        if (!newAchievements.contains(MemoryMatchAchievements.speedster6x6)) {
          newAchievements.add(MemoryMatchAchievements.speedster6x6);
        }
      }

      // Check for hard mode achievement
      if (gridSize == GridSize.large) {
        if (!newAchievements.contains(MemoryMatchAchievements.hardMaster)) {
          newAchievements.add(MemoryMatchAchievements.hardMaster);
        }
      }

      // Check for no hints achievement
      if (hintsUsed == 0) {
        if (!newAchievements.contains(MemoryMatchAchievements.noHints)) {
          newAchievements.add(MemoryMatchAchievements.noHints);
        }
      }
    } else {
      // Reset win streak on loss
      updatedState = updatedState.copyWith(currentWinStreak: 0);
    }

    // Check for veteran achievements
    final totalGames = updatedState.gamesPlayed;
    if (totalGames >= 10 &&
        !newAchievements.contains(MemoryMatchAchievements.veteran10)) {
      newAchievements.add(MemoryMatchAchievements.veteran10);
    }
    if (totalGames >= 50 &&
        !newAchievements.contains(MemoryMatchAchievements.veteran50)) {
      newAchievements.add(MemoryMatchAchievements.veteran50);
    }
    if (totalGames >= 100 &&
        !newAchievements.contains(MemoryMatchAchievements.veteran100)) {
      newAchievements.add(MemoryMatchAchievements.veteran100);
    }

    updatedState = updatedState.copyWith(achievements: newAchievements);
    state = updatedState;
    await _saveStats();
  }

  /// Record a match (for first match achievement)
  Future<void> recordMatch({required int streak}) async {
    final newAchievements = List<String>.from(state.achievements);

    // First match achievement
    if (!newAchievements.contains(MemoryMatchAchievements.firstMatch)) {
      newAchievements.add(MemoryMatchAchievements.firstMatch);
    }

    // Streak achievements
    if (streak >= 3 &&
        !newAchievements.contains(MemoryMatchAchievements.streakMaster3)) {
      newAchievements.add(MemoryMatchAchievements.streakMaster3);
    }
    if (streak >= 5 &&
        !newAchievements.contains(MemoryMatchAchievements.streakMaster5)) {
      newAchievements.add(MemoryMatchAchievements.streakMaster5);
    }

    if (newAchievements.length != state.achievements.length) {
      state = state.copyWith(achievements: newAchievements);
      await _saveStats();
    }
  }

  /// Reset all statistics
  Future<void> resetStats() async {
    state = MemoryMatchStats.initial();
    await _saveStats();
  }
}
