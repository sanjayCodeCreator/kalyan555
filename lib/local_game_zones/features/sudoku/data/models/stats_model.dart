import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'game_state.dart';

/// Statistics for Sudoku gameplay
class SudokuStats {
  /// Total games played
  final int gamesPlayed;

  /// Total games won
  final int gamesWon;

  /// Best times per difficulty (in seconds)
  final Map<Difficulty, int?> bestTimes;

  /// Total time played (in seconds)
  final int totalTimePlayed;

  /// Total hints used
  final int totalHintsUsed;

  /// Total mistakes made
  final int totalMistakes;

  /// Current win streak
  final int currentStreak;

  /// Best win streak
  final int bestStreak;

  /// Achievements unlocked
  final Set<Achievement> achievements;

  const SudokuStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.bestTimes = const {},
    this.totalTimePlayed = 0,
    this.totalHintsUsed = 0,
    this.totalMistakes = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.achievements = const {},
  });

  /// Win rate percentage
  double get winRate => gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0.0;

  /// Average solve time (for won games)
  int get averageSolveTime => gamesWon > 0 ? totalTimePlayed ~/ gamesWon : 0;

  /// Format time as MM:SS
  static String formatTime(int? seconds) {
    if (seconds == null) return '--:--';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Copy with modified fields
  SudokuStats copyWith({
    int? gamesPlayed,
    int? gamesWon,
    Map<Difficulty, int?>? bestTimes,
    int? totalTimePlayed,
    int? totalHintsUsed,
    int? totalMistakes,
    int? currentStreak,
    int? bestStreak,
    Set<Achievement>? achievements,
  }) {
    return SudokuStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      bestTimes: bestTimes ?? this.bestTimes,
      totalTimePlayed: totalTimePlayed ?? this.totalTimePlayed,
      totalHintsUsed: totalHintsUsed ?? this.totalHintsUsed,
      totalMistakes: totalMistakes ?? this.totalMistakes,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      achievements: achievements ?? this.achievements,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'bestTimes': bestTimes.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'totalTimePlayed': totalTimePlayed,
      'totalHintsUsed': totalHintsUsed,
      'totalMistakes': totalMistakes,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'achievements': achievements.map((a) => a.name).toList(),
    };
  }

  /// Create from JSON
  factory SudokuStats.fromJson(Map<String, dynamic> json) {
    return SudokuStats(
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
      bestTimes: (json['bestTimes'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              Difficulty.values.firstWhere((d) => d.name == key),
              value as int?,
            ),
          ) ??
          {},
      totalTimePlayed: json['totalTimePlayed'] as int? ?? 0,
      totalHintsUsed: json['totalHintsUsed'] as int? ?? 0,
      totalMistakes: json['totalMistakes'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((name) => Achievement.values.firstWhere(
                    (a) => a.name == name,
                    orElse: () => Achievement.firstWin,
                  ))
              .toSet() ??
          {},
    );
  }

  /// Save to SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sudoku_stats', jsonEncode(toJson()));
  }

  /// Load from SharedPreferences
  static Future<SudokuStats> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('sudoku_stats');
    if (json == null) return const SudokuStats();
    try {
      return SudokuStats.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      return const SudokuStats();
    }
  }
}

/// Available achievements
enum Achievement {
  firstWin('First Victory', 'Complete your first Sudoku puzzle', '🏆'),
  speedster('Speed Demon', 'Complete a puzzle in under 5 minutes', '⚡'),
  perfectGame('Perfectionist', 'Complete a puzzle with no mistakes', '✨'),
  expert('Expert Solver', 'Complete an Expert difficulty puzzle', '🧠'),
  streaker('On Fire', 'Win 5 games in a row', '🔥'),
  noHints('Pure Skill', 'Complete a puzzle without using hints', '💪'),
  dedicated('Dedicated', 'Play 50 games', '🎮'),
  masterMind('Master Mind', 'Complete 10 Expert puzzles', '👑');

  final String title;
  final String description;
  final String icon;

  const Achievement(this.title, this.description, this.icon);
}
