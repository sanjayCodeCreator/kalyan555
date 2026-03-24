import 'dart:convert';

/// Player statistics for Memory Match games
class MemoryMatchStats {
  final int gamesPlayed;
  final int gamesWon;
  final int gamesLost;
  final int totalMoves;
  final int totalMatchedPairs;
  final int totalTimePlayed; // in seconds
  final int bestTime2x2; // in seconds, -1 if not achieved
  final int bestTime4x4;
  final int bestTime6x6;
  final int bestMoves2x2; // -1 if not achieved
  final int bestMoves4x4;
  final int bestMoves6x6;
  final int perfectGames; // No mistakes (moves == pairs)
  final int currentWinStreak;
  final int longestWinStreak;
  final int totalHintsUsed;
  final List<String> achievements;

  const MemoryMatchStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.totalMoves = 0,
    this.totalMatchedPairs = 0,
    this.totalTimePlayed = 0,
    this.bestTime2x2 = -1,
    this.bestTime4x4 = -1,
    this.bestTime6x6 = -1,
    this.bestMoves2x2 = -1,
    this.bestMoves4x4 = -1,
    this.bestMoves6x6 = -1,
    this.perfectGames = 0,
    this.currentWinStreak = 0,
    this.longestWinStreak = 0,
    this.totalHintsUsed = 0,
    this.achievements = const [],
  });

  /// Initial empty stats
  factory MemoryMatchStats.initial() {
    return const MemoryMatchStats();
  }

  /// Calculate win rate percentage
  double get winRate => gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0;

  /// Average moves per game
  double get averageMoves => gamesWon > 0 ? totalMoves / gamesWon : 0;

  /// Average time per game (seconds)
  double get averageTime => gamesWon > 0 ? totalTimePlayed / gamesWon : 0;

  /// Format time as MM:SS
  static String formatTime(int seconds) {
    if (seconds < 0) return '--:--';
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Check if achievement is unlocked
  bool hasAchievement(String id) => achievements.contains(id);

  /// Copy with method for immutable updates
  MemoryMatchStats copyWith({
    int? gamesPlayed,
    int? gamesWon,
    int? gamesLost,
    int? totalMoves,
    int? totalMatchedPairs,
    int? totalTimePlayed,
    int? bestTime2x2,
    int? bestTime4x4,
    int? bestTime6x6,
    int? bestMoves2x2,
    int? bestMoves4x4,
    int? bestMoves6x6,
    int? perfectGames,
    int? currentWinStreak,
    int? longestWinStreak,
    int? totalHintsUsed,
    List<String>? achievements,
  }) {
    return MemoryMatchStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesLost: gamesLost ?? this.gamesLost,
      totalMoves: totalMoves ?? this.totalMoves,
      totalMatchedPairs: totalMatchedPairs ?? this.totalMatchedPairs,
      totalTimePlayed: totalTimePlayed ?? this.totalTimePlayed,
      bestTime2x2: bestTime2x2 ?? this.bestTime2x2,
      bestTime4x4: bestTime4x4 ?? this.bestTime4x4,
      bestTime6x6: bestTime6x6 ?? this.bestTime6x6,
      bestMoves2x2: bestMoves2x2 ?? this.bestMoves2x2,
      bestMoves4x4: bestMoves4x4 ?? this.bestMoves4x4,
      bestMoves6x6: bestMoves6x6 ?? this.bestMoves6x6,
      perfectGames: perfectGames ?? this.perfectGames,
      currentWinStreak: currentWinStreak ?? this.currentWinStreak,
      longestWinStreak: longestWinStreak ?? this.longestWinStreak,
      totalHintsUsed: totalHintsUsed ?? this.totalHintsUsed,
      achievements: achievements ?? this.achievements,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'gamesLost': gamesLost,
      'totalMoves': totalMoves,
      'totalMatchedPairs': totalMatchedPairs,
      'totalTimePlayed': totalTimePlayed,
      'bestTime2x2': bestTime2x2,
      'bestTime4x4': bestTime4x4,
      'bestTime6x6': bestTime6x6,
      'bestMoves2x2': bestMoves2x2,
      'bestMoves4x4': bestMoves4x4,
      'bestMoves6x6': bestMoves6x6,
      'perfectGames': perfectGames,
      'currentWinStreak': currentWinStreak,
      'longestWinStreak': longestWinStreak,
      'totalHintsUsed': totalHintsUsed,
      'achievements': achievements,
    };
  }

  /// Create from JSON
  factory MemoryMatchStats.fromJson(Map<String, dynamic> json) {
    return MemoryMatchStats(
      gamesPlayed: json['gamesPlayed'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
      gamesLost: json['gamesLost'] ?? 0,
      totalMoves: json['totalMoves'] ?? 0,
      totalMatchedPairs: json['totalMatchedPairs'] ?? 0,
      totalTimePlayed: json['totalTimePlayed'] ?? 0,
      bestTime2x2: json['bestTime2x2'] ?? -1,
      bestTime4x4: json['bestTime4x4'] ?? -1,
      bestTime6x6: json['bestTime6x6'] ?? -1,
      bestMoves2x2: json['bestMoves2x2'] ?? -1,
      bestMoves4x4: json['bestMoves4x4'] ?? -1,
      bestMoves6x6: json['bestMoves6x6'] ?? -1,
      perfectGames: json['perfectGames'] ?? 0,
      currentWinStreak: json['currentWinStreak'] ?? 0,
      longestWinStreak: json['longestWinStreak'] ?? 0,
      totalHintsUsed: json['totalHintsUsed'] ?? 0,
      achievements: List<String>.from(json['achievements'] ?? []),
    );
  }

  /// Encode to JSON string
  String encode() => jsonEncode(toJson());

  /// Decode from JSON string
  static MemoryMatchStats decode(String json) {
    try {
      return MemoryMatchStats.fromJson(jsonDecode(json));
    } catch (_) {
      return MemoryMatchStats.initial();
    }
  }
}

/// Achievement definitions
class MemoryMatchAchievements {
  static const String firstMatch = 'first_match';
  static const String firstWin = 'first_win';
  static const String perfectGame = 'perfect_game';
  static const String speedster2x2 = 'speedster_2x2'; // Under 10 seconds
  static const String speedster4x4 = 'speedster_4x4'; // Under 60 seconds
  static const String speedster6x6 = 'speedster_6x6'; // Under 180 seconds
  static const String streakMaster3 = 'streak_master_3'; // 3 matches in a row
  static const String streakMaster5 = 'streak_master_5'; // 5 matches in a row
  static const String veteran10 = 'veteran_10'; // 10 games
  static const String veteran50 = 'veteran_50'; // 50 games
  static const String veteran100 = 'veteran_100'; // 100 games
  static const String noHints = 'no_hints'; // Won without hints
  static const String hardMaster = 'hard_master'; // Complete 6x6

  static String getName(String id) {
    switch (id) {
      case firstMatch:
        return 'First Match';
      case firstWin:
        return 'First Victory';
      case perfectGame:
        return 'Perfect Memory';
      case speedster2x2:
        return 'Lightning Fast (2×2)';
      case speedster4x4:
        return 'Speed Demon (4×4)';
      case speedster6x6:
        return 'Time Master (6×6)';
      case streakMaster3:
        return 'Hot Streak';
      case streakMaster5:
        return 'On Fire';
      case veteran10:
        return 'Getting Started';
      case veteran50:
        return 'Dedicated Player';
      case veteran100:
        return 'Memory Master';
      case noHints:
        return 'Pure Memory';
      case hardMaster:
        return 'Hard Mode Champion';
      default:
        return id;
    }
  }

  static String getDescription(String id) {
    switch (id) {
      case firstMatch:
        return 'Make your first match';
      case firstWin:
        return 'Complete your first game';
      case perfectGame:
        return 'Complete a game with no mistakes';
      case speedster2x2:
        return 'Complete 2×2 in under 10 seconds';
      case speedster4x4:
        return 'Complete 4×4 in under 60 seconds';
      case speedster6x6:
        return 'Complete 6×6 in under 3 minutes';
      case streakMaster3:
        return 'Match 3 pairs in a row';
      case streakMaster5:
        return 'Match 5 pairs in a row';
      case veteran10:
        return 'Play 10 games';
      case veteran50:
        return 'Play 50 games';
      case veteran100:
        return 'Play 100 games';
      case noHints:
        return 'Win a game without using hints';
      case hardMaster:
        return 'Complete a 6×6 game';
      default:
        return '';
    }
  }
}
