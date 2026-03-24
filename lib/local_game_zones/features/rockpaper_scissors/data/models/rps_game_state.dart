import 'rps_choice.dart';

/// Represents the current phase of the game
enum GamePhase {
  idle, // Waiting for player to make a choice
  selecting, // Player is selecting (used for timer mode)
  revealing, // Revealing both choices with animation
  result, // Showing result
  matchEnd, // Match has ended (for Best of X mode)
}

/// Main game state for Rock Paper Scissors
class RPSGameState {
  final GamePhase phase;
  final RPSChoice? playerChoice;
  final RPSChoice? computerChoice;
  final RPSResult? result;
  final int playerScore;
  final int computerScore;
  final int drawCount;
  final int currentRound;
  final List<RPSChoice> playerHistory;
  final AIDifficulty difficulty;
  final GameRoundsMode roundsMode;
  final bool timerEnabled;
  final int timerDuration;
  final int? remainingTime;
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool isInputLocked;
  final String? matchWinner; // 'player' or 'computer' when match ends

  const RPSGameState({
    this.phase = GamePhase.idle,
    this.playerChoice,
    this.computerChoice,
    this.result,
    this.playerScore = 0,
    this.computerScore = 0,
    this.drawCount = 0,
    this.currentRound = 1,
    this.playerHistory = const [],
    this.difficulty = AIDifficulty.easy,
    this.roundsMode = GameRoundsMode.infinite,
    this.timerEnabled = false,
    this.timerDuration = 3,
    this.remainingTime,
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.isInputLocked = false,
    this.matchWinner,
  });

  /// Initial state factory
  factory RPSGameState.initial() {
    return const RPSGameState();
  }

  /// Copy with method for immutable updates
  RPSGameState copyWith({
    GamePhase? phase,
    RPSChoice? playerChoice,
    RPSChoice? computerChoice,
    RPSResult? result,
    int? playerScore,
    int? computerScore,
    int? drawCount,
    int? currentRound,
    List<RPSChoice>? playerHistory,
    AIDifficulty? difficulty,
    GameRoundsMode? roundsMode,
    bool? timerEnabled,
    int? timerDuration,
    int? remainingTime,
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? isInputLocked,
    String? matchWinner,
    bool clearPlayerChoice = false,
    bool clearComputerChoice = false,
    bool clearResult = false,
    bool clearRemainingTime = false,
    bool clearMatchWinner = false,
  }) {
    return RPSGameState(
      phase: phase ?? this.phase,
      playerChoice: clearPlayerChoice
          ? null
          : (playerChoice ?? this.playerChoice),
      computerChoice: clearComputerChoice
          ? null
          : (computerChoice ?? this.computerChoice),
      result: clearResult ? null : (result ?? this.result),
      playerScore: playerScore ?? this.playerScore,
      computerScore: computerScore ?? this.computerScore,
      drawCount: drawCount ?? this.drawCount,
      currentRound: currentRound ?? this.currentRound,
      playerHistory: playerHistory ?? this.playerHistory,
      difficulty: difficulty ?? this.difficulty,
      roundsMode: roundsMode ?? this.roundsMode,
      timerEnabled: timerEnabled ?? this.timerEnabled,
      timerDuration: timerDuration ?? this.timerDuration,
      remainingTime: clearRemainingTime
          ? null
          : (remainingTime ?? this.remainingTime),
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      isInputLocked: isInputLocked ?? this.isInputLocked,
      matchWinner: clearMatchWinner ? null : (matchWinner ?? this.matchWinner),
    );
  }

  /// Check if match is over (for Best of X mode)
  bool get isMatchOver {
    if (roundsMode == GameRoundsMode.infinite) return false;
    final targetWins = roundsMode.targetWins!;
    return playerScore >= targetWins || computerScore >= targetWins;
  }

  /// Get the current match winner
  String? get currentMatchWinner {
    if (!isMatchOver) return null;
    final targetWins = roundsMode.targetWins!;
    if (playerScore >= targetWins) return 'player';
    if (computerScore >= targetWins) return 'computer';
    return null;
  }
}
