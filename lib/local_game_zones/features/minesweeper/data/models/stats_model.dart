import 'game_state.dart';

/// Achievement types for Minesweeper
enum Achievement {
  /// First win
  firstWin('First Win', 'Win your first game', '🏆'),

  /// Win without using flags
  noFlagWin('No-Flag Win', 'Win without using any flags', '🚫🚩'),

  /// Speed sweeper - win beginner in under 30 seconds
  speedSweeperBeginner('Speed Sweeper', 'Win Beginner under 30 seconds', '⚡'),

  /// Speed sweeper - win intermediate in under 2 minutes
  speedSweeperIntermediate(
      'Fast Finder', 'Win Intermediate under 2 minutes', '💨'),

  /// Speed sweeper - win expert in under 5 minutes
  speedSweeperExpert('Expert Speed', 'Win Expert under 5 minutes', '🚀'),

  /// Win 10 games
  tenWins('Dedicated Player', 'Win 10 games', '🌟'),

  /// Win 50 games
  fiftyWins('Minesweeper Pro', 'Win 50 games', '👑'),

  /// Win 100 games
  hundredWins('Minesweeper Master', 'Win 100 games', '💎'),

  /// Complete daily challenge
  dailyChallenge('Daily Devotee', 'Complete a daily challenge', '📅'),

  /// Complete 7 daily challenges
  weeklyStreak('Weekly Warrior', 'Complete 7 daily challenges', '🔥'),

  /// Win on all difficulties
  allDifficulties('All-Rounder', 'Win on all difficulties', '🎯'),

  /// Perfect game - no wrong flags
  perfectGame('Perfect Game', 'Win with no wrong flags', '✨');

  final String title;
  final String description;
  final String emoji;

  const Achievement(this.title, this.description, this.emoji);
}

/// Statistics model for Minesweeper
class MinesweeperStats {
  final int gamesPlayed;
  final int gamesWon;
  final int gamesLost;
  final Map<Difficulty, int?> bestTimes;
  final Set<Achievement> unlockedAchievements;
  final int totalPlayTime;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastPlayedDate;
  final int dailyChallengesCompleted;

  const MinesweeperStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.bestTimes = const {},
    this.unlockedAchievements = const {},
    this.totalPlayTime = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastPlayedDate,
    this.dailyChallengesCompleted = 0,
  });

  /// Create initial stats
  factory MinesweeperStats.initial() => const MinesweeperStats();

  /// Win percentage
  double get winPercentage =>
      gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0;

  /// Copy with new values
  MinesweeperStats copyWith({
    int? gamesPlayed,
    int? gamesWon,
    int? gamesLost,
    Map<Difficulty, int?>? bestTimes,
    Set<Achievement>? unlockedAchievements,
    int? totalPlayTime,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastPlayedDate,
    int? dailyChallengesCompleted,
  }) {
    return MinesweeperStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesLost: gamesLost ?? this.gamesLost,
      bestTimes: bestTimes ?? this.bestTimes,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      dailyChallengesCompleted:
          dailyChallengesCompleted ?? this.dailyChallengesCompleted,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() => {
        'gamesPlayed': gamesPlayed,
        'gamesWon': gamesWon,
        'gamesLost': gamesLost,
        'bestTimes': bestTimes.map(
          (key, value) => MapEntry(key.index.toString(), value),
        ),
        'unlockedAchievements':
            unlockedAchievements.map((a) => a.index).toList(),
        'totalPlayTime': totalPlayTime,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'lastPlayedDate': lastPlayedDate?.toIso8601String(),
        'dailyChallengesCompleted': dailyChallengesCompleted,
      };

  /// Create from JSON
  factory MinesweeperStats.fromJson(Map<String, dynamic> json) {
    final bestTimesJson = json['bestTimes'] as Map<String, dynamic>? ?? {};
    final achievementsJson =
        json['unlockedAchievements'] as List<dynamic>? ?? [];

    return MinesweeperStats(
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
      gamesLost: json['gamesLost'] as int? ?? 0,
      bestTimes: bestTimesJson.map(
        (key, value) => MapEntry(
          Difficulty.values[int.parse(key)],
          value as int?,
        ),
      ),
      unlockedAchievements: achievementsJson
          .map((index) => Achievement.values[index as int])
          .toSet(),
      totalPlayTime: json['totalPlayTime'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      lastPlayedDate: json['lastPlayedDate'] != null
          ? DateTime.parse(json['lastPlayedDate'] as String)
          : null,
      dailyChallengesCompleted: json['dailyChallengesCompleted'] as int? ?? 0,
    );
  }
}
