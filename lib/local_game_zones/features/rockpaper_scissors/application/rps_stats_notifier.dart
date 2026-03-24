import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/rps_choice.dart';
import '../data/models/rps_player_stats.dart';

/// Provider for player stats
final rpsStatsProvider =
    StateNotifierProvider<RPSStatsNotifier, RPSPlayerStats>((ref) {
      return RPSStatsNotifier();
    });

/// State notifier for tracking player statistics
class RPSStatsNotifier extends StateNotifier<RPSPlayerStats> {
  RPSStatsNotifier() : super(RPSPlayerStats.initial()) {
    _loadStats();
  }

  static const String _storageKey = 'rps_player_stats';

  /// Load stats from SharedPreferences
  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        state = RPSPlayerStats.fromJson(json);
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
    required RPSChoice playerChoice,
    required bool isWin,
    required bool isLoss,
    required bool isDraw,
    required AIDifficulty difficulty,
  }) {
    final newFrequency = Map<RPSChoice, int>.from(state.choiceFrequency);
    newFrequency[playerChoice] = (newFrequency[playerChoice] ?? 0) + 1;

    int newWinStreak = state.currentWinStreak;
    int newBestStreak = state.bestWinStreak;

    if (isWin) {
      newWinStreak++;
      if (newWinStreak > newBestStreak) {
        newBestStreak = newWinStreak;
      }
    } else if (isLoss) {
      newWinStreak = 0;
    }

    state = state.copyWith(
      totalMatches: state.totalMatches + 1,
      totalWins: isWin ? state.totalWins + 1 : state.totalWins,
      totalLosses: isLoss ? state.totalLosses + 1 : state.totalLosses,
      totalDraws: isDraw ? state.totalDraws + 1 : state.totalDraws,
      currentWinStreak: newWinStreak,
      bestWinStreak: newBestStreak,
      choiceFrequency: newFrequency,
    );

    // Check for new achievements
    _checkAchievements(isWin: isWin, difficulty: difficulty);

    _saveStats();
  }

  /// Check and unlock new achievements
  void _checkAchievements({
    required bool isWin,
    required AIDifficulty difficulty,
  }) {
    final newAchievements = List<String>.from(state.unlockedAchievements);
    bool updated = false;

    // First win
    if (isWin &&
        state.totalWins == 1 &&
        !newAchievements.contains('first_win')) {
      newAchievements.add('first_win');
      updated = true;
    }

    // Win streak 5
    if (state.currentWinStreak >= 5 &&
        !newAchievements.contains('win_streak_5')) {
      newAchievements.add('win_streak_5');
      updated = true;
    }

    // Win streak 10
    if (state.currentWinStreak >= 10 &&
        !newAchievements.contains('win_streak_10')) {
      newAchievements.add('win_streak_10');
      updated = true;
    }

    // Matches count
    if (state.totalMatches >= 10 && !newAchievements.contains('matches_10')) {
      newAchievements.add('matches_10');
      updated = true;
    }
    if (state.totalMatches >= 50 && !newAchievements.contains('matches_50')) {
      newAchievements.add('matches_50');
      updated = true;
    }
    if (state.totalMatches >= 100 && !newAchievements.contains('matches_100')) {
      newAchievements.add('matches_100');
      updated = true;
    }

    // Beat hard AI
    if (isWin &&
        difficulty == AIDifficulty.hard &&
        !newAchievements.contains('beat_hard_ai')) {
      newAchievements.add('beat_hard_ai');
      updated = true;
    }

    // Variety player
    final freq = state.choiceFrequency;
    if ((freq[RPSChoice.rock] ?? 0) >= 10 &&
        (freq[RPSChoice.paper] ?? 0) >= 10 &&
        (freq[RPSChoice.scissors] ?? 0) >= 10 &&
        !newAchievements.contains('all_choices')) {
      newAchievements.add('all_choices');
      updated = true;
    }

    if (updated) {
      state = state.copyWith(unlockedAchievements: newAchievements);
    }
  }

  /// Reset all stats
  void resetStats() {
    state = RPSPlayerStats.initial();
    _saveStats();
  }
}
