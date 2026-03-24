import 'memory_match_card.dart';

/// Represents the current phase of the game
enum GamePhase {
  idle, // Not started, on home screen
  playing, // Game in progress
  paused, // Game paused
  completed, // All pairs matched
  failed, // Failed (ran out of time/moves)
}

/// Grid size options
enum GridSize {
  small(2, 'Easy', '2×2'),
  medium(4, 'Medium', '4×4'),
  large(6, 'Hard', '6×6');

  final int size;
  final String difficulty;
  final String label;

  const GridSize(this.size, this.difficulty, this.label);

  /// Total number of cards
  int get totalCards => size * size;

  /// Number of pairs needed
  int get totalPairs => totalCards ~/ 2;

  /// Default hints for this grid size
  int get defaultHints {
    switch (this) {
      case GridSize.small:
        return 1;
      case GridSize.medium:
        return 2;
      case GridSize.large:
        return 3;
    }
  }

  /// Default time limit for timed mode (seconds)
  int get defaultTimeLimit {
    switch (this) {
      case GridSize.small:
        return 30;
      case GridSize.medium:
        return 120;
      case GridSize.large:
        return 300;
    }
  }

  /// Default move limit for limited moves mode
  int get defaultMoveLimit {
    switch (this) {
      case GridSize.small:
        return 6;
      case GridSize.medium:
        return 24;
      case GridSize.large:
        return 54;
    }
  }
}

/// Game mode options
enum GameMode {
  classic('Classic', 'Match all pairs at your own pace'),
  timed('Timed', 'Race against the clock'),
  limitedMoves('Limited Moves', 'Complete within move limit'),
  training('Training', 'Memory training with preview');

  final String name;
  final String description;

  const GameMode(this.name, this.description);
}

/// Main game state for Memory Match
class MemoryMatchGameState {
  final GamePhase phase;
  final GridSize gridSize;
  final GameMode mode;
  final List<MemoryMatchCard> cards;
  final int? firstFlippedIndex;
  final int? secondFlippedIndex;
  final int moves;
  final int matchedPairs;
  final int elapsedSeconds;
  final int? remainingTime; // For timed mode (seconds)
  final int? remainingMoves; // For limited moves mode
  final int hintsRemaining;
  final int hintsUsed;
  final int streak; // Consecutive matches
  final int maxStreak; // Best streak this game
  final int score;
  final bool soundEnabled;
  final bool hapticEnabled;
  final bool isKidsMode;
  final bool isInputLocked;
  final bool showingHint; // Currently showing hint
  final bool trainingPreview; // Training mode preview phase

  const MemoryMatchGameState({
    this.phase = GamePhase.idle,
    this.gridSize = GridSize.medium,
    this.mode = GameMode.classic,
    this.cards = const [],
    this.firstFlippedIndex,
    this.secondFlippedIndex,
    this.moves = 0,
    this.matchedPairs = 0,
    this.elapsedSeconds = 0,
    this.remainingTime,
    this.remainingMoves,
    this.hintsRemaining = 3,
    this.hintsUsed = 0,
    this.streak = 0,
    this.maxStreak = 0,
    this.score = 0,
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.isKidsMode = false,
    this.isInputLocked = false,
    this.showingHint = false,
    this.trainingPreview = false,
  });

  /// Initial state factory
  factory MemoryMatchGameState.initial() {
    return const MemoryMatchGameState();
  }

  /// Check if game is complete
  bool get isComplete => matchedPairs >= gridSize.totalPairs;

  /// Check if game has failed (timed out or moves exhausted)
  bool get hasFailed {
    if (mode == GameMode.timed &&
        remainingTime != null &&
        remainingTime! <= 0) {
      return true;
    }
    if (mode == GameMode.limitedMoves &&
        remainingMoves != null &&
        remainingMoves! <= 0 &&
        !isComplete) {
      return true;
    }
    return false;
  }

  /// Check if a card is currently flipped (for comparison)
  bool get hasFirstCard => firstFlippedIndex != null;
  bool get hasBothCards =>
      firstFlippedIndex != null && secondFlippedIndex != null;

  /// Get the first flipped card
  MemoryMatchCard? get firstCard =>
      firstFlippedIndex != null ? cards[firstFlippedIndex!] : null;

  /// Get the second flipped card
  MemoryMatchCard? get secondCard =>
      secondFlippedIndex != null ? cards[secondFlippedIndex!] : null;

  /// Progress percentage (0.0 to 1.0)
  double get progress =>
      gridSize.totalPairs > 0 ? matchedPairs / gridSize.totalPairs : 0.0;

  /// Copy with method for immutable updates
  MemoryMatchGameState copyWith({
    GamePhase? phase,
    GridSize? gridSize,
    GameMode? mode,
    List<MemoryMatchCard>? cards,
    int? firstFlippedIndex,
    int? secondFlippedIndex,
    int? moves,
    int? matchedPairs,
    int? elapsedSeconds,
    int? remainingTime,
    int? remainingMoves,
    int? hintsRemaining,
    int? hintsUsed,
    int? streak,
    int? maxStreak,
    int? score,
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? isKidsMode,
    bool? isInputLocked,
    bool? showingHint,
    bool? trainingPreview,
    bool clearFirstFlipped = false,
    bool clearSecondFlipped = false,
    bool clearRemainingTime = false,
    bool clearRemainingMoves = false,
  }) {
    return MemoryMatchGameState(
      phase: phase ?? this.phase,
      gridSize: gridSize ?? this.gridSize,
      mode: mode ?? this.mode,
      cards: cards ?? this.cards,
      firstFlippedIndex: clearFirstFlipped
          ? null
          : (firstFlippedIndex ?? this.firstFlippedIndex),
      secondFlippedIndex: clearSecondFlipped
          ? null
          : (secondFlippedIndex ?? this.secondFlippedIndex),
      moves: moves ?? this.moves,
      matchedPairs: matchedPairs ?? this.matchedPairs,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      remainingTime: clearRemainingTime
          ? null
          : (remainingTime ?? this.remainingTime),
      remainingMoves: clearRemainingMoves
          ? null
          : (remainingMoves ?? this.remainingMoves),
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      streak: streak ?? this.streak,
      maxStreak: maxStreak ?? this.maxStreak,
      score: score ?? this.score,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      isKidsMode: isKidsMode ?? this.isKidsMode,
      isInputLocked: isInputLocked ?? this.isInputLocked,
      showingHint: showingHint ?? this.showingHint,
      trainingPreview: trainingPreview ?? this.trainingPreview,
    );
  }
}
