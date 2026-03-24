import 'package:flutter/material.dart';
import 'cell_state.dart';
import 'word_placement.dart';

/// Game difficulty levels
enum WSDifficulty {
  easy('Easy', 8, 5),
  medium('Medium', 10, 7),
  hard('Hard', 12, 10);

  final String label;
  final int gridSize;
  final int wordCount;

  const WSDifficulty(this.label, this.gridSize, this.wordCount);

  /// Get allowed directions for this difficulty
  List<WordDirection> get allowedDirections {
    switch (this) {
      case easy:
        return [WordDirection.horizontal];
      case medium:
        return [WordDirection.horizontal, WordDirection.vertical];
      case hard:
        return [
          WordDirection.horizontal,
          WordDirection.vertical,
          WordDirection.diagonalDown,
          WordDirection.diagonalUp,
          WordDirection.horizontalReverse,
          WordDirection.verticalReverse,
          WordDirection.diagonalDownReverse,
          WordDirection.diagonalUpReverse,
        ];
    }
  }
}

/// Game status
enum WSGameStatus {
  /// Game is in progress
  playing,

  /// Game is paused
  paused,

  /// Player won (all words found)
  won,
}

/// Timer mode for the game
enum WSTimerMode {
  /// Count up from zero
  countUp,

  /// Countdown from specified time
  countdown,
}

/// Main game state for Word Search
class WordSearchGameState {
  /// The letter grid
  final List<LetterCellState> grid;

  /// Grid size (e.g., 8 for 8x8)
  final int gridSize;

  /// Current difficulty level
  final WSDifficulty difficulty;

  /// Word placements in the grid
  final List<WordPlacement> wordPlacements;

  /// Set of found word IDs
  final Set<int> foundWordIds;

  /// Currently selected cell indices during drag
  final List<int> selectedPath;

  /// Current game status
  final WSGameStatus status;

  /// Timer mode
  final WSTimerMode timerMode;

  /// Elapsed time in seconds
  final int elapsedSeconds;

  /// Countdown time limit (for countdown mode)
  final int timeLimit;

  /// Current score
  final int score;

  /// Number of hints remaining
  final int hintsRemaining;

  /// Number of hints used
  final int hintsUsed;

  /// Number of mistakes made
  final int mistakes;

  /// Currently highlighted word ID (for hint)
  final int? highlightedWordId;

  /// Colors assigned to found words
  final List<Color> wordColors;

  const WordSearchGameState({
    required this.grid,
    required this.gridSize,
    required this.difficulty,
    required this.wordPlacements,
    this.foundWordIds = const {},
    this.selectedPath = const [],
    this.status = WSGameStatus.playing,
    this.timerMode = WSTimerMode.countUp,
    this.elapsedSeconds = 0,
    this.timeLimit = 300, // 5 minutes default
    this.score = 0,
    this.hintsRemaining = 3,
    this.hintsUsed = 0,
    this.mistakes = 0,
    this.highlightedWordId,
    this.wordColors = const [],
  });

  /// Create an initial empty state
  factory WordSearchGameState.initial() {
    return const WordSearchGameState(
      grid: [],
      gridSize: 8,
      difficulty: WSDifficulty.easy,
      wordPlacements: [],
    );
  }

  /// Get the list of target words
  List<String> get targetWords => wordPlacements.map((p) => p.word).toList();

  /// Get the list of found words
  List<String> get foundWords => wordPlacements
      .where((p) => foundWordIds.contains(p.wordId))
      .map((p) => p.word)
      .toList();

  /// Check if all words have been found
  bool get allWordsFound => foundWordIds.length == wordPlacements.length;

  /// Get the number of words found
  int get wordsFoundCount => foundWordIds.length;

  /// Get the total number of words
  int get totalWords => wordPlacements.length;

  /// Check if game is over
  bool get isGameOver => status == WSGameStatus.won;

  /// Get remaining time for countdown mode
  int get remainingTime => (timeLimit - elapsedSeconds).clamp(0, timeLimit);

  /// Format elapsed time as MM:SS
  String get formattedTime {
    final time =
        timerMode == WSTimerMode.countdown ? remainingTime : elapsedSeconds;
    final minutes = time ~/ 60;
    final seconds = time % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Calculate score based on time, difficulty, and hints
  int calculateFinalScore() {
    const baseScore = 1000;
    final timePenalty = elapsedSeconds ~/ 5; // -1 per 5 seconds
    final hintPenalty = hintsUsed * 100;
    final mistakePenalty = mistakes * 50;

    // Difficulty multiplier
    final multiplier = switch (difficulty) {
      WSDifficulty.easy => 1.0,
      WSDifficulty.medium => 1.5,
      WSDifficulty.hard => 2.0,
    };

    final rawScore = baseScore - timePenalty - hintPenalty - mistakePenalty;
    return (rawScore * multiplier).clamp(0, 2000).toInt();
  }

  /// Get word placement by ID
  WordPlacement? getWordById(int wordId) {
    try {
      return wordPlacements.firstWhere((p) => p.wordId == wordId);
    } catch (_) {
      return null;
    }
  }

  /// Check if a word is found by its ID
  bool isWordFound(int wordId) => foundWordIds.contains(wordId);

  /// Copy with modified fields
  WordSearchGameState copyWith({
    List<LetterCellState>? grid,
    int? gridSize,
    WSDifficulty? difficulty,
    List<WordPlacement>? wordPlacements,
    Set<int>? foundWordIds,
    List<int>? selectedPath,
    WSGameStatus? status,
    WSTimerMode? timerMode,
    int? elapsedSeconds,
    int? timeLimit,
    int? score,
    int? hintsRemaining,
    int? hintsUsed,
    int? mistakes,
    int? highlightedWordId,
    bool clearHighlight = false,
    List<Color>? wordColors,
  }) {
    return WordSearchGameState(
      grid: grid ?? this.grid,
      gridSize: gridSize ?? this.gridSize,
      difficulty: difficulty ?? this.difficulty,
      wordPlacements: wordPlacements ?? this.wordPlacements,
      foundWordIds: foundWordIds ?? this.foundWordIds,
      selectedPath: selectedPath ?? this.selectedPath,
      status: status ?? this.status,
      timerMode: timerMode ?? this.timerMode,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      timeLimit: timeLimit ?? this.timeLimit,
      score: score ?? this.score,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      mistakes: mistakes ?? this.mistakes,
      highlightedWordId:
          clearHighlight ? null : (highlightedWordId ?? this.highlightedWordId),
      wordColors: wordColors ?? this.wordColors,
    );
  }
}
