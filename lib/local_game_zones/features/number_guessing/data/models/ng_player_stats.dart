import 'ng_difficulty.dart';

/// Player statistics for tracking performance
class NGPlayerStats {
  final int totalGames;
  final int totalWins;
  final int totalLosses;
  final int currentWinStreak;
  final int bestWinStreak;
  final Map<NGDifficulty, DifficultyStats> difficultyStats;
  final List<GameHistoryEntry> recentGames;
  final List<String> unlockedAchievements;

  const NGPlayerStats({
    this.totalGames = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.currentWinStreak = 0,
    this.bestWinStreak = 0,
    this.difficultyStats = const {},
    this.recentGames = const [],
    this.unlockedAchievements = const [],
  });

  factory NGPlayerStats.initial() => const NGPlayerStats();

  /// Win rate percentage
  double get winRate {
    if (totalGames == 0) return 0;
    return (totalWins / totalGames) * 100;
  }

  /// Average attempts across all games
  double get averageAttempts {
    if (recentGames.isEmpty) return 0;
    final winningGames = recentGames.where((g) => g.won).toList();
    if (winningGames.isEmpty) return 0;
    final total = winningGames.fold<int>(0, (sum, g) => sum + g.attempts);
    return total / winningGames.length;
  }

  /// Get stats for a specific difficulty
  DifficultyStats statsForDifficulty(NGDifficulty difficulty) {
    return difficultyStats[difficulty] ?? DifficultyStats.initial();
  }

  NGPlayerStats copyWith({
    int? totalGames,
    int? totalWins,
    int? totalLosses,
    int? currentWinStreak,
    int? bestWinStreak,
    Map<NGDifficulty, DifficultyStats>? difficultyStats,
    List<GameHistoryEntry>? recentGames,
    List<String>? unlockedAchievements,
  }) {
    return NGPlayerStats(
      totalGames: totalGames ?? this.totalGames,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      currentWinStreak: currentWinStreak ?? this.currentWinStreak,
      bestWinStreak: bestWinStreak ?? this.bestWinStreak,
      difficultyStats: difficultyStats ?? this.difficultyStats,
      recentGames: recentGames ?? this.recentGames,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalGames': totalGames,
    'totalWins': totalWins,
    'totalLosses': totalLosses,
    'currentWinStreak': currentWinStreak,
    'bestWinStreak': bestWinStreak,
    'difficultyStats': difficultyStats.map(
      (k, v) => MapEntry(k.name, v.toJson()),
    ),
    'recentGames': recentGames.map((e) => e.toJson()).toList(),
    'unlockedAchievements': unlockedAchievements,
  };

  factory NGPlayerStats.fromJson(Map<String, dynamic> json) {
    return NGPlayerStats(
      totalGames: json['totalGames'] ?? 0,
      totalWins: json['totalWins'] ?? 0,
      totalLosses: json['totalLosses'] ?? 0,
      currentWinStreak: json['currentWinStreak'] ?? 0,
      bestWinStreak: json['bestWinStreak'] ?? 0,
      difficultyStats:
          (json['difficultyStats'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              NGDifficulty.values.firstWhere((d) => d.name == k),
              DifficultyStats.fromJson(v as Map<String, dynamic>),
            ),
          ) ??
          {},
      recentGames:
          (json['recentGames'] as List<dynamic>?)
              ?.map((e) => GameHistoryEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      unlockedAchievements: List<String>.from(
        json['unlockedAchievements'] ?? [],
      ),
    );
  }
}

/// Stats for a specific difficulty level
class DifficultyStats {
  final int gamesPlayed;
  final int gamesWon;
  final int? bestAttempts; // Lowest number of attempts to win
  final int? bestTimeSeconds; // Fastest win time

  const DifficultyStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.bestAttempts,
    this.bestTimeSeconds,
  });

  factory DifficultyStats.initial() => const DifficultyStats();

  double get winRate {
    if (gamesPlayed == 0) return 0;
    return (gamesWon / gamesPlayed) * 100;
  }

  DifficultyStats copyWith({
    int? gamesPlayed,
    int? gamesWon,
    int? bestAttempts,
    int? bestTimeSeconds,
    bool clearBestAttempts = false,
    bool clearBestTimeSeconds = false,
  }) {
    return DifficultyStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      bestAttempts: clearBestAttempts
          ? null
          : (bestAttempts ?? this.bestAttempts),
      bestTimeSeconds: clearBestTimeSeconds
          ? null
          : (bestTimeSeconds ?? this.bestTimeSeconds),
    );
  }

  Map<String, dynamic> toJson() => {
    'gamesPlayed': gamesPlayed,
    'gamesWon': gamesWon,
    'bestAttempts': bestAttempts,
    'bestTimeSeconds': bestTimeSeconds,
  };

  factory DifficultyStats.fromJson(Map<String, dynamic> json) {
    return DifficultyStats(
      gamesPlayed: json['gamesPlayed'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
      bestAttempts: json['bestAttempts'],
      bestTimeSeconds: json['bestTimeSeconds'],
    );
  }
}

/// A single game history entry
class GameHistoryEntry {
  final DateTime timestamp;
  final NGDifficulty difficulty;
  final bool won;
  final int attempts;
  final int? targetNumber;
  final int? timeSeconds;

  const GameHistoryEntry({
    required this.timestamp,
    required this.difficulty,
    required this.won,
    required this.attempts,
    this.targetNumber,
    this.timeSeconds,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'difficulty': difficulty.name,
    'won': won,
    'attempts': attempts,
    'targetNumber': targetNumber,
    'timeSeconds': timeSeconds,
  };

  factory GameHistoryEntry.fromJson(Map<String, dynamic> json) {
    return GameHistoryEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      difficulty: NGDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
      ),
      won: json['won'] as bool,
      attempts: json['attempts'] as int,
      targetNumber: json['targetNumber'] as int?,
      timeSeconds: json['timeSeconds'] as int?,
    );
  }
}

/// Achievement definitions for Number Guessing
class NGAchievement {
  final String id;
  final String title;
  final String description;
  final String icon;

  const NGAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  static const List<NGAchievement> all = [
    NGAchievement(
      id: 'first_win',
      title: 'First Victory',
      description: 'Win your first game',
      icon: '🏆',
    ),
    NGAchievement(
      id: 'lucky_guess',
      title: 'Lucky Guess',
      description: 'Win on your first attempt',
      icon: '🍀',
    ),
    NGAchievement(
      id: 'two_attempts',
      title: 'Sharp Mind',
      description: 'Win with only 2 attempts',
      icon: '🧠',
    ),
    NGAchievement(
      id: 'win_streak_3',
      title: 'Hot Streak',
      description: 'Win 3 games in a row',
      icon: '🔥',
    ),
    NGAchievement(
      id: 'win_streak_5',
      title: 'On Fire',
      description: 'Win 5 games in a row',
      icon: '⚡',
    ),
    NGAchievement(
      id: 'win_streak_10',
      title: 'Unstoppable',
      description: 'Win 10 games in a row',
      icon: '💫',
    ),
    NGAchievement(
      id: 'games_10',
      title: 'Getting Started',
      description: 'Play 10 games',
      icon: '🎮',
    ),
    NGAchievement(
      id: 'games_50',
      title: 'Dedicated Player',
      description: 'Play 50 games',
      icon: '🎯',
    ),
    NGAchievement(
      id: 'games_100',
      title: 'Number Master',
      description: 'Play 100 games',
      icon: '👑',
    ),
    NGAchievement(
      id: 'beat_hard',
      title: 'Hard Mode Hero',
      description: 'Win on Hard difficulty',
      icon: '🦸',
    ),
    NGAchievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      description: 'Win in under 30 seconds',
      icon: '⏱️',
    ),
    NGAchievement(
      id: 'no_hints',
      title: 'No Help Needed',
      description: 'Win without using any hints',
      icon: '💪',
    ),
    NGAchievement(
      id: 'all_difficulties',
      title: 'Well Rounded',
      description: 'Win on all difficulty levels',
      icon: '🌟',
    ),
  ];
}
