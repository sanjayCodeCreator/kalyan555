/// Game state model for Matchstick Puzzle

import '../../domain/matchstick_models.dart';

/// Overall game status
enum GameStatus {
  initial,
  loading,
  playing,
  paused,
  completed,
  failed,
}

/// State for the matchstick puzzle game
class MatchstickGameState {
  final MatchstickPuzzle? currentPuzzle;
  final List<Matchstick> matchsticks;
  final Matchstick? selectedMatchstick;
  final Matchstick? draggingMatchstick;
  final int moveCount;
  final int hintsUsed;
  final int hintsRemaining;
  final GameStatus status;
  final List<MoveRecord> undoStack;
  final List<MoveRecord> redoStack;
  final int elapsedSeconds;
  final bool isNoteMode;
  final Set<int> highlightedMatchstickIds;
  final String? errorMessage;
  final int starsEarned;

  const MatchstickGameState({
    this.currentPuzzle,
    this.matchsticks = const [],
    this.selectedMatchstick,
    this.draggingMatchstick,
    this.moveCount = 0,
    this.hintsUsed = 0,
    this.hintsRemaining = 3,
    this.status = GameStatus.initial,
    this.undoStack = const [],
    this.redoStack = const [],
    this.elapsedSeconds = 0,
    this.isNoteMode = false,
    this.highlightedMatchstickIds = const {},
    this.errorMessage,
    this.starsEarned = 0,
  });

  /// Initial state factory
  static const initial = MatchstickGameState();

  /// Check if can undo
  bool get canUndo => undoStack.isNotEmpty;

  /// Check if can redo
  bool get canRedo => redoStack.isNotEmpty;

  /// Check if game is active
  bool get isPlaying => status == GameStatus.playing;

  /// Check if game is completed
  bool get isCompleted => status == GameStatus.completed;

  /// Check if have hints left
  bool get hasHints => hintsRemaining > 0;

  /// Check if exceeded allowed moves
  bool get exceededMoves =>
      currentPuzzle != null && moveCount > currentPuzzle!.allowedMoves * 2;

  /// Get remaining moves
  int get movesRemaining => currentPuzzle != null
      ? (currentPuzzle!.allowedMoves - moveCount).clamp(0, 99)
      : 0;

  /// Format elapsed time as mm:ss
  String get formattedTime {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Create copy with modified fields
  MatchstickGameState copyWith({
    MatchstickPuzzle? currentPuzzle,
    List<Matchstick>? matchsticks,
    Matchstick? selectedMatchstick,
    Matchstick? draggingMatchstick,
    int? moveCount,
    int? hintsUsed,
    int? hintsRemaining,
    GameStatus? status,
    List<MoveRecord>? undoStack,
    List<MoveRecord>? redoStack,
    int? elapsedSeconds,
    bool? isNoteMode,
    Set<int>? highlightedMatchstickIds,
    String? errorMessage,
    int? starsEarned,
    bool clearSelectedMatchstick = false,
    bool clearDraggingMatchstick = false,
    bool clearError = false,
  }) {
    return MatchstickGameState(
      currentPuzzle: currentPuzzle ?? this.currentPuzzle,
      matchsticks: matchsticks ?? this.matchsticks,
      selectedMatchstick: clearSelectedMatchstick
          ? null
          : (selectedMatchstick ?? this.selectedMatchstick),
      draggingMatchstick: clearDraggingMatchstick
          ? null
          : (draggingMatchstick ?? this.draggingMatchstick),
      moveCount: moveCount ?? this.moveCount,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      status: status ?? this.status,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isNoteMode: isNoteMode ?? this.isNoteMode,
      highlightedMatchstickIds:
          highlightedMatchstickIds ?? this.highlightedMatchstickIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      starsEarned: starsEarned ?? this.starsEarned,
    );
  }

  /// Serialize to JSON for persistence
  Map<String, dynamic> toJson() => {
        'puzzleId': currentPuzzle?.id,
        'matchsticks': matchsticks
            .map((m) => {
                  'id': m.id,
                  'x': m.x,
                  'y': m.y,
                  'angle': m.angle,
                  'isMovable': m.isMovable,
                })
            .toList(),
        'moveCount': moveCount,
        'hintsUsed': hintsUsed,
        'hintsRemaining': hintsRemaining,
        'elapsedSeconds': elapsedSeconds,
        'status': status.index,
      };

  /// Create from JSON (matchsticks need puzzle data to fully restore)
  factory MatchstickGameState.fromJson(Map<String, dynamic> json) {
    return MatchstickGameState(
      moveCount: json['moveCount'] as int? ?? 0,
      hintsUsed: json['hintsUsed'] as int? ?? 0,
      hintsRemaining: json['hintsRemaining'] as int? ?? 3,
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      status: GameStatus.values[json['status'] as int? ?? 0],
    );
  }
}

/// Saved game data for resume functionality
class SavedGameData {
  final int puzzleId;
  final List<Map<String, dynamic>> matchstickPositions;
  final int moveCount;
  final int hintsUsed;
  final int hintsRemaining;
  final int elapsedSeconds;
  final DateTime savedAt;

  const SavedGameData({
    required this.puzzleId,
    required this.matchstickPositions,
    required this.moveCount,
    required this.hintsUsed,
    required this.hintsRemaining,
    required this.elapsedSeconds,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'puzzleId': puzzleId,
        'matchstickPositions': matchstickPositions,
        'moveCount': moveCount,
        'hintsUsed': hintsUsed,
        'hintsRemaining': hintsRemaining,
        'elapsedSeconds': elapsedSeconds,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedGameData.fromJson(Map<String, dynamic> json) {
    return SavedGameData(
      puzzleId: json['puzzleId'] as int,
      matchstickPositions:
          (json['matchstickPositions'] as List).cast<Map<String, dynamic>>(),
      moveCount: json['moveCount'] as int,
      hintsUsed: json['hintsUsed'] as int,
      hintsRemaining: json['hintsRemaining'] as int,
      elapsedSeconds: json['elapsedSeconds'] as int,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }
}
