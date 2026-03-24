import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/game_state.dart';
import '../data/models/stats_model.dart';

/// Key for storing Word Search stats
const _statsKey = 'word_search_stats';

/// Provider for the Word Search stats
final wordSearchStatsProvider =
    StateNotifierProvider<WordSearchStatsNotifier, WordSearchStats>((ref) {
  return WordSearchStatsNotifier();
});

/// State notifier for managing Word Search statistics
class WordSearchStatsNotifier extends StateNotifier<WordSearchStats> {
  WordSearchStatsNotifier() : super(WordSearchStats.initial()) {
    _loadStats();
  }

  /// Load stats from SharedPreferences
  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);

      if (statsJson != null) {
        state = WordSearchStats.fromJsonString(statsJson);
      }
    } catch (e) {
      // If loading fails, use initial stats
      state = WordSearchStats.initial();
    }
  }

  /// Save stats to SharedPreferences
  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_statsKey, state.toJsonString());
    } catch (e) {
      // Silently fail if saving fails
    }
  }

  /// Record a completed game
  void recordGame({
    required bool won,
    required WSDifficulty difficulty,
    required int time,
    required int wordsFound,
    required int hintsUsed,
    required int score,
  }) {
    // Update games played/won
    final newGamesPlayed = state.gamesPlayed + 1;
    final newGamesWon = won ? state.gamesWon + 1 : state.gamesWon;

    // Update streak
    int newCurrentStreak;
    int newBestStreak;
    if (won) {
      newCurrentStreak = state.currentStreak + 1;
      newBestStreak = newCurrentStreak > state.bestStreak
          ? newCurrentStreak
          : state.bestStreak;
    } else {
      newCurrentStreak = 0;
      newBestStreak = state.bestStreak;
    }

    // Update best time for difficulty
    final newBestTimes = Map<WSDifficulty, int>.from(state.bestTimes);
    if (won) {
      final currentBest = newBestTimes[difficulty];
      if (currentBest == null || time < currentBest) {
        newBestTimes[difficulty] = time;
      }
    }

    // Check for new achievements
    final newAchievements = Set<WSAchievement>.from(state.unlockedAchievements);
    _checkAchievements(
      newAchievements,
      won: won,
      difficulty: difficulty,
      time: time,
      hintsUsed: hintsUsed,
      score: score,
      gamesPlayed: newGamesPlayed,
      totalWordsFound: state.totalWordsFound + wordsFound,
      currentStreak: newCurrentStreak,
    );

    state = state.copyWith(
      gamesPlayed: newGamesPlayed,
      gamesWon: newGamesWon,
      totalWordsFound: state.totalWordsFound + wordsFound,
      totalPlayTime: state.totalPlayTime + time,
      bestTimes: newBestTimes,
      currentStreak: newCurrentStreak,
      bestStreak: newBestStreak,
      unlockedAchievements: newAchievements,
      lastPlayedDate: DateTime.now(),
    );

    _saveStats();
  }

  /// Check and unlock achievements
  void _checkAchievements(
    Set<WSAchievement> achievements, {
    required bool won,
    required WSDifficulty difficulty,
    required int time,
    required int hintsUsed,
    required int score,
    required int gamesPlayed,
    required int totalWordsFound,
    required int currentStreak,
  }) {
    // First Puzzle
    if (won && !achievements.contains(WSAchievement.firstPuzzle)) {
      achievements.add(WSAchievement.firstPuzzle);
    }

    // Speed Finder (under 2 minutes)
    if (won &&
        time < 120 &&
        !achievements.contains(WSAchievement.speedFinder)) {
      achievements.add(WSAchievement.speedFinder);
    }

    // No Hint Win
    if (won &&
        hintsUsed == 0 &&
        !achievements.contains(WSAchievement.noHintWin)) {
      achievements.add(WSAchievement.noHintWin);
    }

    // Perfect Score
    if (score >= 1000 && !achievements.contains(WSAchievement.perfectScore)) {
      achievements.add(WSAchievement.perfectScore);
    }

    // Word Master (100 total words)
    if (totalWordsFound >= 100 &&
        !achievements.contains(WSAchievement.wordMaster)) {
      achievements.add(WSAchievement.wordMaster);
    }

    // Streak Master (5 wins in a row)
    if (currentStreak >= 5 &&
        !achievements.contains(WSAchievement.streakMaster)) {
      achievements.add(WSAchievement.streakMaster);
    }

    // Hard Mode Winner
    if (won &&
        difficulty == WSDifficulty.hard &&
        !achievements.contains(WSAchievement.hardModeWinner)) {
      achievements.add(WSAchievement.hardModeWinner);
    }
  }

  /// Record daily challenge completion
  void recordDailyChallenge({required bool completed}) {
    if (completed) {
      final newCount = state.dailyChallengesCompleted + 1;
      final newAchievements =
          Set<WSAchievement>.from(state.unlockedAchievements);

      // Daily Challenger achievement
      if (!newAchievements.contains(WSAchievement.dailyChallenger)) {
        newAchievements.add(WSAchievement.dailyChallenger);
      }

      state = state.copyWith(
        dailyChallengesCompleted: newCount,
        unlockedAchievements: newAchievements,
      );

      _saveStats();
    }
  }

  /// Reset all statistics
  void resetStats() {
    state = WordSearchStats.initial();
    _saveStats();
  }
}
