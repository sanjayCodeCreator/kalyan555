import 'dart:convert';

import 'game_state.dart';

/// Achievement types for Word Search
enum WSAchievement {
  firstPuzzle('First Puzzle', 'Complete your first word search', '🎯'),
  speedFinder('Speed Finder', 'Complete a puzzle in under 2 minutes', '⚡'),
  noHintWin('No Hint Win', 'Complete a puzzle without using hints', '🧠'),
  perfectScore('Perfect Score', 'Score 1000+ points in a game', '🏆'),
  wordMaster('Word Master', 'Find 100 total words', '📚'),
  streakMaster('Streak Master', 'Win 5 games in a row', '🔥'),
  hardModeWinner('Hard Mode Winner', 'Complete a hard mode puzzle', '💪'),
  dailyChallenger('Daily Challenger', 'Complete a daily challenge', '📅');

  final String title;
  final String description;
  final String icon;

  const WSAchievement(this.title, this.description, this.icon);
}

/// Statistics model for Word Search
class WordSearchStats {
  /// Number of games played
  final int gamesPlayed;

  /// Number of games won
  final int gamesWon;

  /// Total words found across all games
  final int totalWordsFound;

  /// Total time spent playing (in seconds)
  final int totalPlayTime;

  /// Best times by difficulty (in seconds)
  final Map<WSDifficulty, int> bestTimes;

  /// Current winning streak
  final int currentStreak;

  /// Best winning streak
  final int bestStreak;

  /// Unlocked achievements
  final Set<WSAchievement> unlockedAchievements;

  /// Last played date (for daily challenge)
  final DateTime? lastPlayedDate;

  /// Daily challenges completed
  final int dailyChallengesCompleted;

  const WordSearchStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.totalWordsFound = 0,
    this.totalPlayTime = 0,
    this.bestTimes = const {},
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.unlockedAchievements = const {},
    this.lastPlayedDate,
    this.dailyChallengesCompleted = 0,
  });

  /// Create initial empty stats
  factory WordSearchStats.initial() {
    return const WordSearchStats();
  }

  /// Get win rate percentage
  double get winRate => gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0.0;

  /// Get average solve time in seconds
  int get averageSolveTime => gamesWon > 0 ? totalPlayTime ~/ gamesWon : 0;

  /// Format a time in seconds as MM:SS
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Copy with modified fields
  WordSearchStats copyWith({
    int? gamesPlayed,
    int? gamesWon,
    int? totalWordsFound,
    int? totalPlayTime,
    Map<WSDifficulty, int>? bestTimes,
    int? currentStreak,
    int? bestStreak,
    Set<WSAchievement>? unlockedAchievements,
    DateTime? lastPlayedDate,
    int? dailyChallengesCompleted,
  }) {
    return WordSearchStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      totalWordsFound: totalWordsFound ?? this.totalWordsFound,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      bestTimes: bestTimes ?? this.bestTimes,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      dailyChallengesCompleted:
          dailyChallengesCompleted ?? this.dailyChallengesCompleted,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'totalWordsFound': totalWordsFound,
      'totalPlayTime': totalPlayTime,
      'bestTimes': bestTimes.map((k, v) => MapEntry(k.name, v)),
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'unlockedAchievements': unlockedAchievements.map((a) => a.name).toList(),
      'lastPlayedDate': lastPlayedDate?.toIso8601String(),
      'dailyChallengesCompleted': dailyChallengesCompleted,
    };
  }

  /// Create from JSON
  factory WordSearchStats.fromJson(Map<String, dynamic> json) {
    return WordSearchStats(
      gamesPlayed: json['gamesPlayed'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
      totalWordsFound: json['totalWordsFound'] ?? 0,
      totalPlayTime: json['totalPlayTime'] ?? 0,
      bestTimes: (json['bestTimes'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              WSDifficulty.values.firstWhere((d) => d.name == k),
              v as int,
            ),
          ) ??
          {},
      currentStreak: json['currentStreak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      unlockedAchievements: (json['unlockedAchievements'] as List?)
              ?.map((name) =>
                  WSAchievement.values.firstWhere((a) => a.name == name))
              .toSet() ??
          {},
      lastPlayedDate: json['lastPlayedDate'] != null
          ? DateTime.parse(json['lastPlayedDate'])
          : null,
      dailyChallengesCompleted: json['dailyChallengesCompleted'] ?? 0,
    );
  }

  /// Convert to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Create from JSON string
  factory WordSearchStats.fromJsonString(String jsonString) {
    return WordSearchStats.fromJson(jsonDecode(jsonString));
  }
}
