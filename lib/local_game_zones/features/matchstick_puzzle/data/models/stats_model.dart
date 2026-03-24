/// Statistics model for Matchstick Puzzle with persistence

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/matchstick_models.dart';

/// Player statistics for matchstick puzzle
class MatchstickStats {
  final int totalPuzzlesSolved;
  final int totalPuzzlesAttempted;
  final int totalMoves;
  final int totalHintsUsed;
  final int totalStars;
  final int perfectSolves; // Solved with minimum moves
  final int noHintStreak; // Current streak without hints
  final int bestNoHintStreak;
  final int totalTimePlayed; // In seconds
  final Map<int, PuzzleProgress> puzzleProgress;
  final Set<AchievementType> unlockedAchievements;
  final DateTime? lastPlayedAt;

  const MatchstickStats({
    this.totalPuzzlesSolved = 0,
    this.totalPuzzlesAttempted = 0,
    this.totalMoves = 0,
    this.totalHintsUsed = 0,
    this.totalStars = 0,
    this.perfectSolves = 0,
    this.noHintStreak = 0,
    this.bestNoHintStreak = 0,
    this.totalTimePlayed = 0,
    this.puzzleProgress = const {},
    this.unlockedAchievements = const {},
    this.lastPlayedAt,
  });

  /// Initial empty stats
  static const initial = MatchstickStats();

  /// Get progress for a specific puzzle
  PuzzleProgress getPuzzleProgress(int puzzleId) {
    return puzzleProgress[puzzleId] ??
        PuzzleProgress(puzzleId: puzzleId, isUnlocked: puzzleId == 1);
  }

  /// Check if puzzle is unlocked
  bool isPuzzleUnlocked(int puzzleId) {
    if (puzzleId == 1) return true; // First puzzle always unlocked
    return puzzleProgress[puzzleId]?.isUnlocked ?? false;
  }

  /// Check if achievement is unlocked
  bool isAchievementUnlocked(AchievementType type) {
    return unlockedAchievements.contains(type);
  }

  /// Get completion percentage
  double get completionPercentage {
    if (puzzleProgress.isEmpty) return 0;
    final completed = puzzleProgress.values.where((p) => p.isCompleted).length;
    return (completed / 20) * 100; // Assuming 20 total puzzles
  }

  /// Average moves per puzzle
  double get averageMoves {
    if (totalPuzzlesSolved == 0) return 0;
    return totalMoves / totalPuzzlesSolved;
  }

  /// Format total time played
  String get formattedTimePlayed {
    final hours = totalTimePlayed ~/ 3600;
    final minutes = (totalTimePlayed % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  MatchstickStats copyWith({
    int? totalPuzzlesSolved,
    int? totalPuzzlesAttempted,
    int? totalMoves,
    int? totalHintsUsed,
    int? totalStars,
    int? perfectSolves,
    int? noHintStreak,
    int? bestNoHintStreak,
    int? totalTimePlayed,
    Map<int, PuzzleProgress>? puzzleProgress,
    Set<AchievementType>? unlockedAchievements,
    DateTime? lastPlayedAt,
  }) {
    return MatchstickStats(
      totalPuzzlesSolved: totalPuzzlesSolved ?? this.totalPuzzlesSolved,
      totalPuzzlesAttempted:
          totalPuzzlesAttempted ?? this.totalPuzzlesAttempted,
      totalMoves: totalMoves ?? this.totalMoves,
      totalHintsUsed: totalHintsUsed ?? this.totalHintsUsed,
      totalStars: totalStars ?? this.totalStars,
      perfectSolves: perfectSolves ?? this.perfectSolves,
      noHintStreak: noHintStreak ?? this.noHintStreak,
      bestNoHintStreak: bestNoHintStreak ?? this.bestNoHintStreak,
      totalTimePlayed: totalTimePlayed ?? this.totalTimePlayed,
      puzzleProgress: puzzleProgress ?? this.puzzleProgress,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
        'totalPuzzlesSolved': totalPuzzlesSolved,
        'totalPuzzlesAttempted': totalPuzzlesAttempted,
        'totalMoves': totalMoves,
        'totalHintsUsed': totalHintsUsed,
        'totalStars': totalStars,
        'perfectSolves': perfectSolves,
        'noHintStreak': noHintStreak,
        'bestNoHintStreak': bestNoHintStreak,
        'totalTimePlayed': totalTimePlayed,
        'puzzleProgress': puzzleProgress.map(
          (key, value) => MapEntry(key.toString(), value.toJson()),
        ),
        'unlockedAchievements':
            unlockedAchievements.map((a) => a.index).toList(),
        'lastPlayedAt': lastPlayedAt?.toIso8601String(),
      };

  /// Deserialize from JSON
  factory MatchstickStats.fromJson(Map<String, dynamic> json) {
    final progressMap = <int, PuzzleProgress>{};
    final jsonProgress = json['puzzleProgress'] as Map<String, dynamic>?;
    if (jsonProgress != null) {
      for (final entry in jsonProgress.entries) {
        final id = int.tryParse(entry.key);
        if (id != null) {
          progressMap[id] =
              PuzzleProgress.fromJson(entry.value as Map<String, dynamic>);
        }
      }
    }

    final achievementsList = json['unlockedAchievements'] as List?;
    final achievements = <AchievementType>{};
    if (achievementsList != null) {
      for (final index in achievementsList) {
        if (index is int && index < AchievementType.values.length) {
          achievements.add(AchievementType.values[index]);
        }
      }
    }

    return MatchstickStats(
      totalPuzzlesSolved: json['totalPuzzlesSolved'] as int? ?? 0,
      totalPuzzlesAttempted: json['totalPuzzlesAttempted'] as int? ?? 0,
      totalMoves: json['totalMoves'] as int? ?? 0,
      totalHintsUsed: json['totalHintsUsed'] as int? ?? 0,
      totalStars: json['totalStars'] as int? ?? 0,
      perfectSolves: json['perfectSolves'] as int? ?? 0,
      noHintStreak: json['noHintStreak'] as int? ?? 0,
      bestNoHintStreak: json['bestNoHintStreak'] as int? ?? 0,
      totalTimePlayed: json['totalTimePlayed'] as int? ?? 0,
      puzzleProgress: progressMap,
      unlockedAchievements: achievements,
      lastPlayedAt: json['lastPlayedAt'] != null
          ? DateTime.parse(json['lastPlayedAt'] as String)
          : null,
    );
  }
}

/// Repository for stats persistence
class MatchstickStatsRepository {
  static const _statsKey = 'matchstick_puzzle_stats';
  static const _savedGameKey = 'matchstick_puzzle_saved_game';

  /// Load stats from SharedPreferences
  static Future<MatchstickStats> loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_statsKey);
      if (jsonString == null) return MatchstickStats.initial;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return MatchstickStats.fromJson(json);
    } catch (e) {
      print('Error loading matchstick stats: $e');
      return MatchstickStats.initial;
    }
  }

  /// Save stats to SharedPreferences
  static Future<void> saveStats(MatchstickStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(stats.toJson());
      await prefs.setString(_statsKey, jsonString);
    } catch (e) {
      print('Error saving matchstick stats: $e');
    }
  }

  /// Clear all stats
  static Future<void> clearStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_statsKey);
      await prefs.remove(_savedGameKey);
    } catch (e) {
      print('Error clearing matchstick stats: $e');
    }
  }

  /// Save current game for resume
  static Future<void> saveGame(Map<String, dynamic> gameData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(gameData);
      await prefs.setString(_savedGameKey, jsonString);
    } catch (e) {
      print('Error saving game: $e');
    }
  }

  /// Load saved game
  static Future<Map<String, dynamic>?> loadSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_savedGameKey);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error loading saved game: $e');
      return null;
    }
  }

  /// Clear saved game
  static Future<void> clearSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedGameKey);
    } catch (e) {
      print('Error clearing saved game: $e');
    }
  }
}
