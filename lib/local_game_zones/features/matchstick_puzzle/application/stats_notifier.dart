/// Stats management with Riverpod for Matchstick Puzzle

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/stats_model.dart';
import '../domain/matchstick_models.dart';

/// Provider for stats notifier
final matchstickStatsProvider =
    StateNotifierProvider<MatchstickStatsNotifier, MatchstickStats>((ref) {
  return MatchstickStatsNotifier();
});

/// State notifier for player statistics
class MatchstickStatsNotifier extends StateNotifier<MatchstickStats> {
  MatchstickStatsNotifier() : super(MatchstickStats.initial) {
    _loadStats();
  }

  /// Load stats from storage
  Future<void> _loadStats() async {
    final stats = await MatchstickStatsRepository.loadStats();
    state = stats;
  }

  /// Save current stats
  Future<void> _saveStats() async {
    await MatchstickStatsRepository.saveStats(state);
  }

  /// Record a puzzle attempt
  void recordAttempt(int puzzleId) {
    final progress = state.getPuzzleProgress(puzzleId);
    final updatedProgress = progress.copyWith(
      attempts: progress.attempts + 1,
      isUnlocked: true,
    );

    final newProgressMap = Map<int, PuzzleProgress>.from(state.puzzleProgress);
    newProgressMap[puzzleId] = updatedProgress;

    state = state.copyWith(
      totalPuzzlesAttempted: state.totalPuzzlesAttempted + 1,
      puzzleProgress: newProgressMap,
      lastPlayedAt: DateTime.now(),
    );

    _saveStats();
  }

  /// Record puzzle completion
  void recordCompletion({
    required int puzzleId,
    required int moves,
    required int hints,
    required int time,
    required int stars,
  }) {
    final progress = state.getPuzzleProgress(puzzleId);
    final isFirstSolve = !progress.isCompleted;
    final isPerfect = moves <= _getAllowedMoves(puzzleId);
    final usedNoHint = hints == 0;

    // Update puzzle progress
    final updatedProgress = progress.copyWith(
      isCompleted: true,
      bestMoves: progress.bestMoves == 0 || moves < progress.bestMoves
          ? moves
          : progress.bestMoves,
      bestStars: stars > progress.bestStars ? stars : progress.bestStars,
    );

    final newProgressMap = Map<int, PuzzleProgress>.from(state.puzzleProgress);
    newProgressMap[puzzleId] = updatedProgress;

    // Unlock next puzzle
    final nextPuzzleId = puzzleId + 1;
    if (!state.isPuzzleUnlocked(nextPuzzleId)) {
      newProgressMap[nextPuzzleId] = PuzzleProgress(
        puzzleId: nextPuzzleId,
        isUnlocked: true,
      );
    }

    // Update streaks
    int newNoHintStreak = usedNoHint ? state.noHintStreak + 1 : 0;
    int newBestStreak = newNoHintStreak > state.bestNoHintStreak
        ? newNoHintStreak
        : state.bestNoHintStreak;

    // Check for new achievements
    final newAchievements =
        Set<AchievementType>.from(state.unlockedAchievements);

    if (isFirstSolve && state.totalPuzzlesSolved == 0) {
      newAchievements.add(AchievementType.firstSolve);
    }

    if (isPerfect) {
      newAchievements.add(AchievementType.perfectSolve);
    }

    if (newNoHintStreak >= 5) {
      newAchievements.add(AchievementType.noHintStreak);
    }

    if (time < 30) {
      newAchievements.add(AchievementType.speedster);
    }

    final totalStars = state.totalStars + stars;
    if (totalStars >= 50) {
      newAchievements.add(AchievementType.collector);
    }

    // Check completionist
    final solvedCount =
        newProgressMap.values.where((p) => p.isCompleted).length;
    if (solvedCount >= 20) {
      newAchievements.add(AchievementType.completionist);
    }

    state = state.copyWith(
      totalPuzzlesSolved: state.totalPuzzlesSolved + (isFirstSolve ? 1 : 0),
      totalMoves: state.totalMoves + moves,
      totalStars: totalStars,
      perfectSolves: isPerfect ? state.perfectSolves + 1 : state.perfectSolves,
      noHintStreak: newNoHintStreak,
      bestNoHintStreak: newBestStreak,
      totalTimePlayed: state.totalTimePlayed + time,
      puzzleProgress: newProgressMap,
      unlockedAchievements: newAchievements,
      lastPlayedAt: DateTime.now(),
    );

    _saveStats();
  }

  /// Record hint used
  void recordHintUsed() {
    state = state.copyWith(
      totalHintsUsed: state.totalHintsUsed + 1,
      noHintStreak: 0, // Reset streak
    );
    _saveStats();
  }

  /// Get allowed moves for a puzzle
  int _getAllowedMoves(int puzzleId) {
    // Easy: 1, Medium: 2-3, Hard: 4+
    if (puzzleId <= 7) return 1;
    if (puzzleId <= 14) return 3;
    return 5;
  }

  /// Reset all stats
  Future<void> resetStats() async {
    await MatchstickStatsRepository.clearStats();
    state = MatchstickStats.initial;
  }

  /// Get all achievements with status
  List<Achievement> getAllAchievements() {
    return [
      Achievement(
        type: AchievementType.firstSolve,
        title: 'First Steps',
        description: 'Complete your first puzzle',
        isUnlocked: state.isAchievementUnlocked(AchievementType.firstSolve),
      ),
      Achievement(
        type: AchievementType.perfectSolve,
        title: 'Perfect Move',
        description: 'Complete a puzzle with minimum moves',
        isUnlocked: state.isAchievementUnlocked(AchievementType.perfectSolve),
      ),
      Achievement(
        type: AchievementType.noHintStreak,
        title: 'Brain Power',
        description: 'Complete 5 puzzles without hints',
        isUnlocked: state.isAchievementUnlocked(AchievementType.noHintStreak),
      ),
      Achievement(
        type: AchievementType.speedster,
        title: 'Speed Solver',
        description: 'Complete a puzzle in under 30 seconds',
        isUnlocked: state.isAchievementUnlocked(AchievementType.speedster),
      ),
      Achievement(
        type: AchievementType.mathematician,
        title: 'Mathematician',
        description: 'Complete all equation puzzles',
        isUnlocked: state.isAchievementUnlocked(AchievementType.mathematician),
      ),
      Achievement(
        type: AchievementType.shapemaster,
        title: 'Shape Master',
        description: 'Complete all shape puzzles',
        isUnlocked: state.isAchievementUnlocked(AchievementType.shapemaster),
      ),
      Achievement(
        type: AchievementType.collector,
        title: 'Star Collector',
        description: 'Collect 50 total stars',
        isUnlocked: state.isAchievementUnlocked(AchievementType.collector),
      ),
      Achievement(
        type: AchievementType.completionist,
        title: 'Completionist',
        description: 'Complete all puzzles',
        isUnlocked: state.isAchievementUnlocked(AchievementType.completionist),
      ),
    ];
  }
}
