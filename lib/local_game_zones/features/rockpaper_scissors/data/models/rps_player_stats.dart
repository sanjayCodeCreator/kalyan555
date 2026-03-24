import 'rps_choice.dart';

/// Player statistics for tracking performance
class RPSPlayerStats {
  final int totalMatches;
  final int totalWins;
  final int totalLosses;
  final int totalDraws;
  final int currentWinStreak;
  final int bestWinStreak;
  final Map<RPSChoice, int> choiceFrequency;
  final List<String> unlockedAchievements;

  const RPSPlayerStats({
    this.totalMatches = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.totalDraws = 0,
    this.currentWinStreak = 0,
    this.bestWinStreak = 0,
    this.choiceFrequency = const {
      RPSChoice.rock: 0,
      RPSChoice.paper: 0,
      RPSChoice.scissors: 0,
    },
    this.unlockedAchievements = const [],
  });

  factory RPSPlayerStats.initial() => const RPSPlayerStats();

  double get winRate {
    final totalGames = totalWins + totalLosses;
    if (totalGames == 0) return 0;
    return (totalWins / totalGames) * 100;
  }

  RPSChoice? get mostUsedChoice {
    if (choiceFrequency.isEmpty) return null;
    RPSChoice? mostUsed;
    int maxCount = 0;
    choiceFrequency.forEach((choice, count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsed = choice;
      }
    });
    return mostUsed;
  }

  RPSPlayerStats copyWith({
    int? totalMatches,
    int? totalWins,
    int? totalLosses,
    int? totalDraws,
    int? currentWinStreak,
    int? bestWinStreak,
    Map<RPSChoice, int>? choiceFrequency,
    List<String>? unlockedAchievements,
  }) {
    return RPSPlayerStats(
      totalMatches: totalMatches ?? this.totalMatches,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      totalDraws: totalDraws ?? this.totalDraws,
      currentWinStreak: currentWinStreak ?? this.currentWinStreak,
      bestWinStreak: bestWinStreak ?? this.bestWinStreak,
      choiceFrequency: choiceFrequency ?? this.choiceFrequency,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalMatches': totalMatches,
    'totalWins': totalWins,
    'totalLosses': totalLosses,
    'totalDraws': totalDraws,
    'currentWinStreak': currentWinStreak,
    'bestWinStreak': bestWinStreak,
    'rockCount': choiceFrequency[RPSChoice.rock] ?? 0,
    'paperCount': choiceFrequency[RPSChoice.paper] ?? 0,
    'scissorsCount': choiceFrequency[RPSChoice.scissors] ?? 0,
    'unlockedAchievements': unlockedAchievements,
  };

  factory RPSPlayerStats.fromJson(Map<String, dynamic> json) {
    return RPSPlayerStats(
      totalMatches: json['totalMatches'] ?? 0,
      totalWins: json['totalWins'] ?? 0,
      totalLosses: json['totalLosses'] ?? 0,
      totalDraws: json['totalDraws'] ?? 0,
      currentWinStreak: json['currentWinStreak'] ?? 0,
      bestWinStreak: json['bestWinStreak'] ?? 0,
      choiceFrequency: {
        RPSChoice.rock: json['rockCount'] ?? 0,
        RPSChoice.paper: json['paperCount'] ?? 0,
        RPSChoice.scissors: json['scissorsCount'] ?? 0,
      },
      unlockedAchievements: List<String>.from(
        json['unlockedAchievements'] ?? [],
      ),
    );
  }
}

/// Achievement definitions
class RPSAchievement {
  final String id;
  final String title;
  final String description;
  final String icon;

  const RPSAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  static const List<RPSAchievement> all = [
    RPSAchievement(
      id: 'first_win',
      title: 'First Victory',
      description: 'Win your first game',
      icon: '🏆',
    ),
    RPSAchievement(
      id: 'win_streak_5',
      title: 'Hot Streak',
      description: 'Win 5 games in a row',
      icon: '🔥',
    ),
    RPSAchievement(
      id: 'win_streak_10',
      title: 'Unstoppable',
      description: 'Win 10 games in a row',
      icon: '⚡',
    ),
    RPSAchievement(
      id: 'matches_10',
      title: 'Getting Started',
      description: 'Play 10 matches',
      icon: '🎮',
    ),
    RPSAchievement(
      id: 'matches_50',
      title: 'Dedicated Player',
      description: 'Play 50 matches',
      icon: '🎯',
    ),
    RPSAchievement(
      id: 'matches_100',
      title: 'RPS Master',
      description: 'Play 100 matches',
      icon: '👑',
    ),
    RPSAchievement(
      id: 'beat_hard_ai',
      title: 'AI Slayer',
      description: 'Beat the Hard AI',
      icon: '🤖',
    ),
    RPSAchievement(
      id: 'all_choices',
      title: 'Variety Player',
      description: 'Use all three choices at least 10 times each',
      icon: '🎲',
    ),
  ];
}
