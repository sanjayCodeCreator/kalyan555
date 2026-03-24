import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/stats_model.dart';
import '../domain/puzzle_generator.dart';

/// Provider for Logic Grid Puzzle stats
final logicGridStatsProvider =
    StateNotifierProvider<LogicGridStatsNotifier, LogicGridStats>((ref) {
  return LogicGridStatsNotifier();
});

/// State notifier for managing Logic Grid Puzzle stats
class LogicGridStatsNotifier extends StateNotifier<LogicGridStats> {
  LogicGridStatsNotifier() : super(const LogicGridStats()) {
    _loadStats();
  }

  /// Load stats from storage
  Future<void> _loadStats() async {
    final stats = await LogicGridStats.load();
    state = stats;
  }

  /// Record a game result
  Future<void> recordGame({
    required Difficulty difficulty,
    required bool won,
    required int timeSeconds,
    required int hintsUsed,
  }) async {
    final playedByDiff =
        Map<Difficulty, int>.from(state.gamesPlayedByDifficulty);
    playedByDiff[difficulty] = (playedByDiff[difficulty] ?? 0) + 1;

    final wonByDiff = Map<Difficulty, int>.from(state.gamesWonByDifficulty);
    final bestTimes = Map<Difficulty, int>.from(state.bestTimes);
    final totalTime = Map<Difficulty, int>.from(state.totalTime);

    int currentStreak = state.currentStreak;
    int bestStreak = state.bestStreak;
    int puzzlesSolvedWithoutHints = state.puzzlesSolvedWithoutHints;

    if (won) {
      wonByDiff[difficulty] = (wonByDiff[difficulty] ?? 0) + 1;
      totalTime[difficulty] = (totalTime[difficulty] ?? 0) + timeSeconds;

      // Update best time
      final currentBest = bestTimes[difficulty];
      if (currentBest == null || timeSeconds < currentBest) {
        bestTimes[difficulty] = timeSeconds;
      }

      // Update streak
      currentStreak++;
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }

      // Track no-hint wins
      if (hintsUsed == 0) {
        puzzlesSolvedWithoutHints++;
      }
    } else {
      currentStreak = 0;
    }

    state = state.copyWith(
      gamesPlayed: state.gamesPlayed + 1,
      gamesWon: state.gamesWon + (won ? 1 : 0),
      gamesPlayedByDifficulty: playedByDiff,
      gamesWonByDifficulty: wonByDiff,
      bestTimes: bestTimes,
      totalTime: totalTime,
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      totalHintsUsed: state.totalHintsUsed + hintsUsed,
      puzzlesSolvedWithoutHints: puzzlesSolvedWithoutHints,
      lastPlayedDate: DateTime.now(),
    );

    await state.save();
  }

  /// Reset all stats
  Future<void> resetStats() async {
    state = const LogicGridStats();
    await state.save();
  }
}
