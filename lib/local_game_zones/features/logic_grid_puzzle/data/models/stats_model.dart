import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/puzzle_generator.dart';

/// Statistics model for Logic Grid Puzzle
class LogicGridStats {
  final int gamesPlayed;
  final int gamesWon;
  final Map<Difficulty, int> gamesPlayedByDifficulty;
  final Map<Difficulty, int> gamesWonByDifficulty;
  final Map<Difficulty, int> bestTimes; // seconds
  final Map<Difficulty, int> totalTime; // seconds
  final int currentStreak;
  final int bestStreak;
  final int totalHintsUsed;
  final int puzzlesSolvedWithoutHints;
  final DateTime? lastPlayedDate;

  const LogicGridStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.gamesPlayedByDifficulty = const {},
    this.gamesWonByDifficulty = const {},
    this.bestTimes = const {},
    this.totalTime = const {},
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalHintsUsed = 0,
    this.puzzlesSolvedWithoutHints = 0,
    this.lastPlayedDate,
  });

  /// Win rate percentage
  double get winRate {
    if (gamesPlayed == 0) return 0.0;
    return (gamesWon / gamesPlayed) * 100;
  }

  /// Average solve time in seconds
  int getAverageTime(Difficulty difficulty) {
    final won = gamesWonByDifficulty[difficulty] ?? 0;
    final total = totalTime[difficulty] ?? 0;
    if (won == 0) return 0;
    return total ~/ won;
  }

  /// Format time as mm:ss
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Check achievements
  bool get hasFirstWin => gamesWon >= 1;
  bool get hasNoHintWin => puzzlesSolvedWithoutHints >= 1;
  bool get hasSpeedSolver => bestTimes.values.any((t) => t < 120); // < 2 min
  bool get hasMaster => gamesWon >= 50;
  bool get hasStreakMaster => bestStreak >= 10;

  LogicGridStats copyWith({
    int? gamesPlayed,
    int? gamesWon,
    Map<Difficulty, int>? gamesPlayedByDifficulty,
    Map<Difficulty, int>? gamesWonByDifficulty,
    Map<Difficulty, int>? bestTimes,
    Map<Difficulty, int>? totalTime,
    int? currentStreak,
    int? bestStreak,
    int? totalHintsUsed,
    int? puzzlesSolvedWithoutHints,
    DateTime? lastPlayedDate,
  }) {
    return LogicGridStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesPlayedByDifficulty:
          gamesPlayedByDifficulty ?? this.gamesPlayedByDifficulty,
      gamesWonByDifficulty: gamesWonByDifficulty ?? this.gamesWonByDifficulty,
      bestTimes: bestTimes ?? this.bestTimes,
      totalTime: totalTime ?? this.totalTime,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalHintsUsed: totalHintsUsed ?? this.totalHintsUsed,
      puzzlesSolvedWithoutHints:
          puzzlesSolvedWithoutHints ?? this.puzzlesSolvedWithoutHints,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'gamesPlayedByDifficulty': gamesPlayedByDifficulty.map(
        (k, v) => MapEntry(k.index.toString(), v),
      ),
      'gamesWonByDifficulty': gamesWonByDifficulty.map(
        (k, v) => MapEntry(k.index.toString(), v),
      ),
      'bestTimes': bestTimes.map(
        (k, v) => MapEntry(k.index.toString(), v),
      ),
      'totalTime': totalTime.map(
        (k, v) => MapEntry(k.index.toString(), v),
      ),
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'totalHintsUsed': totalHintsUsed,
      'puzzlesSolvedWithoutHints': puzzlesSolvedWithoutHints,
      'lastPlayedDate': lastPlayedDate?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory LogicGridStats.fromJson(Map<String, dynamic> json) {
    return LogicGridStats(
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
      gamesPlayedByDifficulty:
          (json['gamesPlayedByDifficulty'] as Map<String, dynamic>?)?.map(
                (k, v) => MapEntry(Difficulty.values[int.parse(k)], v as int),
              ) ??
              {},
      gamesWonByDifficulty:
          (json['gamesWonByDifficulty'] as Map<String, dynamic>?)?.map(
                (k, v) => MapEntry(Difficulty.values[int.parse(k)], v as int),
              ) ??
              {},
      bestTimes: (json['bestTimes'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(Difficulty.values[int.parse(k)], v as int),
          ) ??
          {},
      totalTime: (json['totalTime'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(Difficulty.values[int.parse(k)], v as int),
          ) ??
          {},
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalHintsUsed: json['totalHintsUsed'] as int? ?? 0,
      puzzlesSolvedWithoutHints: json['puzzlesSolvedWithoutHints'] as int? ?? 0,
      lastPlayedDate: json['lastPlayedDate'] != null
          ? DateTime.parse(json['lastPlayedDate'] as String)
          : null,
    );
  }

  /// Load from SharedPreferences
  static Future<LogicGridStats> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('logic_grid_stats');
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return LogicGridStats.fromJson(json);
      } catch (e) {
        return const LogicGridStats();
      }
    }
    return const LogicGridStats();
  }

  /// Save to SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logic_grid_stats', jsonEncode(toJson()));
  }
}
