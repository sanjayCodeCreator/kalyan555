import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/game_state.dart';
import '../data/models/stats_model.dart';

/// Provider for stats notifier
final sudokuStatsProvider =
    StateNotifierProvider<StatsNotifier, SudokuStats>((ref) {
  return StatsNotifier();
});

/// State notifier for managing Sudoku statistics
class StatsNotifier extends StateNotifier<SudokuStats> {
  StatsNotifier() : super(const SudokuStats()) {
    _loadStats();
  }

  /// Load stats from storage
  Future<void> _loadStats() async {
    state = await SudokuStats.load();
  }

  /// Record a game completion
  Future<void> recordGame({
    required bool won,
    required Difficulty difficulty,
    required int timeSeconds,
    required int hintsUsed,
    required int mistakes,
  }) async {
    var newStats = state.copyWith(
      gamesPlayed: state.gamesPlayed + 1,
      totalHintsUsed: state.totalHintsUsed + hintsUsed,
      totalMistakes: state.totalMistakes + mistakes,
    );

    if (won) {
      newStats = newStats.copyWith(
        gamesWon: state.gamesWon + 1,
        totalTimePlayed: state.totalTimePlayed + timeSeconds,
        currentStreak: state.currentStreak + 1,
        bestStreak: (state.currentStreak + 1) > state.bestStreak
            ? state.currentStreak + 1
            : state.bestStreak,
      );

      // Update best time for difficulty
      final currentBest = state.bestTimes[difficulty];
      if (currentBest == null || timeSeconds < currentBest) {
        final newBestTimes = Map<Difficulty, int?>.from(state.bestTimes);
        newBestTimes[difficulty] = timeSeconds;
        newStats = newStats.copyWith(bestTimes: newBestTimes);
      }

      // Check for achievements
      final achievements = Set<Achievement>.from(newStats.achievements);

      // First win
      if (newStats.gamesWon == 1) {
        achievements.add(Achievement.firstWin);
      }

      // Speed demon - under 5 minutes
      if (timeSeconds < 300) {
        achievements.add(Achievement.speedster);
      }

      // Perfect game
      if (mistakes == 0) {
        achievements.add(Achievement.perfectGame);
      }

      // No hints
      if (hintsUsed == 0) {
        achievements.add(Achievement.noHints);
      }

      // Expert solver
      if (difficulty == Difficulty.expert) {
        achievements.add(Achievement.expert);
      }

      // On fire - 5 game streak
      if (newStats.currentStreak >= 5) {
        achievements.add(Achievement.streaker);
      }

      // Dedicated - 50 games
      if (newStats.gamesPlayed >= 50) {
        achievements.add(Achievement.dedicated);
      }

      newStats = newStats.copyWith(achievements: achievements);
    } else {
      // Reset streak on loss
      newStats = newStats.copyWith(currentStreak: 0);
    }

    state = newStats;
    await state.save();
  }

  /// Reset all statistics
  Future<void> resetStats() async {
    state = const SudokuStats();
    await state.save();
  }

  /// Get best time for a difficulty level
  int? getBestTime(Difficulty difficulty) {
    return state.bestTimes[difficulty];
  }
}
