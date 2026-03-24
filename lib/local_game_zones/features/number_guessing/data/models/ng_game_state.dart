import 'ng_difficulty.dart';

/// Represents the current phase of the game
enum NGGamePhase {
  /// Initial state, ready to start
  idle,

  /// Game is in progress
  playing,

  /// Player guessed correctly
  won,

  /// Player ran out of attempts or time
  lost,
}

/// Represents a single guess entry in history
class GuessEntry {
  final int guess;
  final GuessResult result;
  final DateTime timestamp;

  const GuessEntry({
    required this.guess,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'guess': guess,
    'result': result.name,
    'timestamp': timestamp.toIso8601String(),
  };

  factory GuessEntry.fromJson(Map<String, dynamic> json) {
    return GuessEntry(
      guess: json['guess'] as int,
      result: GuessResult.values.firstWhere((e) => e.name == json['result']),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Active hint that has been revealed
class ActiveHint {
  final HintType type;
  final String message;

  const ActiveHint({required this.type, required this.message});
}

/// Main game state for Number Guessing Game
class NGGameState {
  final NGGamePhase phase;
  final NGDifficulty difficulty;
  final int? targetNumber;
  final List<GuessEntry> guessHistory;
  final List<ActiveHint> activeHints;
  final int attemptsUsed;
  final int hintsRemaining;
  final GuessResult? lastResult;
  final String? feedbackMessage;

  // Timer state
  final bool timerEnabled;
  final int timerDurationSeconds;
  final int? remainingTimeSeconds;
  final DateTime? gameStartTime;

  // Settings
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool aiAssistEnabled;

  // Input state
  final bool isInputLocked;
  final String? inputError;

  const NGGameState({
    this.phase = NGGamePhase.idle,
    this.difficulty = NGDifficulty.easy,
    this.targetNumber,
    this.guessHistory = const [],
    this.activeHints = const [],
    this.attemptsUsed = 0,
    this.hintsRemaining = 3,
    this.lastResult,
    this.feedbackMessage,
    this.timerEnabled = false,
    this.timerDurationSeconds = 60,
    this.remainingTimeSeconds,
    this.gameStartTime,
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.aiAssistEnabled = true,
    this.isInputLocked = false,
    this.inputError,
  });

  /// Initial state factory
  factory NGGameState.initial() => const NGGameState();

  /// Get list of raw guesses for logic operations
  List<int> get rawGuesses => guessHistory.map((e) => e.guess).toList();

  /// Remaining attempts for limited modes
  int? get remainingAttempts {
    final max = difficulty.maxAttempts;
    if (max == null) return null;
    return max - attemptsUsed;
  }

  /// Check if game is over
  bool get isGameOver => phase == NGGamePhase.won || phase == NGGamePhase.lost;

  /// Duration played so far
  Duration? get durationPlayed {
    if (gameStartTime == null) return null;
    final endTime = isGameOver ? DateTime.now() : DateTime.now();
    return endTime.difference(gameStartTime!);
  }

  /// Copy with method for immutable updates
  NGGameState copyWith({
    NGGamePhase? phase,
    NGDifficulty? difficulty,
    int? targetNumber,
    List<GuessEntry>? guessHistory,
    List<ActiveHint>? activeHints,
    int? attemptsUsed,
    int? hintsRemaining,
    GuessResult? lastResult,
    String? feedbackMessage,
    bool? timerEnabled,
    int? timerDurationSeconds,
    int? remainingTimeSeconds,
    DateTime? gameStartTime,
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? aiAssistEnabled,
    bool? isInputLocked,
    String? inputError,
    bool clearTargetNumber = false,
    bool clearLastResult = false,
    bool clearFeedbackMessage = false,
    bool clearRemainingTime = false,
    bool clearGameStartTime = false,
    bool clearInputError = false,
  }) {
    return NGGameState(
      phase: phase ?? this.phase,
      difficulty: difficulty ?? this.difficulty,
      targetNumber: clearTargetNumber
          ? null
          : (targetNumber ?? this.targetNumber),
      guessHistory: guessHistory ?? this.guessHistory,
      activeHints: activeHints ?? this.activeHints,
      attemptsUsed: attemptsUsed ?? this.attemptsUsed,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      lastResult: clearLastResult ? null : (lastResult ?? this.lastResult),
      feedbackMessage: clearFeedbackMessage
          ? null
          : (feedbackMessage ?? this.feedbackMessage),
      timerEnabled: timerEnabled ?? this.timerEnabled,
      timerDurationSeconds: timerDurationSeconds ?? this.timerDurationSeconds,
      remainingTimeSeconds: clearRemainingTime
          ? null
          : (remainingTimeSeconds ?? this.remainingTimeSeconds),
      gameStartTime: clearGameStartTime
          ? null
          : (gameStartTime ?? this.gameStartTime),
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      aiAssistEnabled: aiAssistEnabled ?? this.aiAssistEnabled,
      isInputLocked: isInputLocked ?? this.isInputLocked,
      inputError: clearInputError ? null : (inputError ?? this.inputError),
    );
  }
}
