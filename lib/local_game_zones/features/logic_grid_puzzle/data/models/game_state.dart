import '../../domain/puzzle_models.dart';
import '../../domain/puzzle_generator.dart';

/// Game status enum
enum GameStatus {
  initial, // Not started
  playing, // In progress
  paused, // Paused
  won, // Puzzle solved correctly
  failed, // Puzzle failed (strict mode)
}

/// State for the Logic Grid Puzzle game
class LogicGridGameState {
  final Puzzle? puzzle;
  final Difficulty difficulty;
  final Map<String, GridCell> grid;
  final String? selectedCell;
  final int? highlightedClueId;
  final Set<String> highlightedCells;
  final List<GridAction> undoStack;
  final List<GridAction> redoStack;
  final int elapsedSeconds;
  final int hintsRemaining;
  final int hintsUsed;
  final int mistakesCount;
  final bool isNoteMode;
  final bool strictMode;
  final GameStatus status;
  final Set<String> conflictCells;

  const LogicGridGameState({
    this.puzzle,
    this.difficulty = Difficulty.easy,
    this.grid = const {},
    this.selectedCell,
    this.highlightedClueId,
    this.highlightedCells = const {},
    this.undoStack = const [],
    this.redoStack = const [],
    this.elapsedSeconds = 0,
    this.hintsRemaining = 5,
    this.hintsUsed = 0,
    this.mistakesCount = 0,
    this.isNoteMode = false,
    this.strictMode = false,
    this.status = GameStatus.initial,
    this.conflictCells = const {},
  });

  /// Initial empty state
  factory LogicGridGameState.initial() {
    return const LogicGridGameState();
  }

  /// Check if game is active
  bool get isPlaying => status == GameStatus.playing;

  /// Check if game is paused
  bool get isPaused => status == GameStatus.paused;

  /// Check if game is finished
  bool get isFinished =>
      status == GameStatus.won || status == GameStatus.failed;

  /// Format elapsed time as mm:ss
  String get formattedTime {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Calculate completion percentage
  double get completionPercentage {
    if (puzzle == null || grid.isEmpty) return 0.0;

    int yesCount = 0;
    int totalRequired = 0;

    // Count required "yes" cells (one per row per section)
    for (int cat1 = 0; cat1 < puzzle!.categoryCount - 1; cat1++) {
      for (int cat2 = cat1 + 1; cat2 < puzzle!.categoryCount; cat2++) {
        totalRequired += puzzle!.gridSize;
      }
    }

    for (final cell in grid.values) {
      if (cell.mark == CellMark.yes) yesCount++;
    }

    return totalRequired > 0 ? (yesCount / totalRequired) * 100 : 0.0;
  }

  LogicGridGameState copyWith({
    Puzzle? puzzle,
    Difficulty? difficulty,
    Map<String, GridCell>? grid,
    String? selectedCell,
    bool clearSelectedCell = false,
    int? highlightedClueId,
    bool clearHighlightedClue = false,
    Set<String>? highlightedCells,
    List<GridAction>? undoStack,
    List<GridAction>? redoStack,
    int? elapsedSeconds,
    int? hintsRemaining,
    int? hintsUsed,
    int? mistakesCount,
    bool? isNoteMode,
    bool? strictMode,
    GameStatus? status,
    Set<String>? conflictCells,
  }) {
    return LogicGridGameState(
      puzzle: puzzle ?? this.puzzle,
      difficulty: difficulty ?? this.difficulty,
      grid: grid ?? this.grid,
      selectedCell:
          clearSelectedCell ? null : (selectedCell ?? this.selectedCell),
      highlightedClueId: clearHighlightedClue
          ? null
          : (highlightedClueId ?? this.highlightedClueId),
      highlightedCells: highlightedCells ?? this.highlightedCells,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      mistakesCount: mistakesCount ?? this.mistakesCount,
      isNoteMode: isNoteMode ?? this.isNoteMode,
      strictMode: strictMode ?? this.strictMode,
      status: status ?? this.status,
      conflictCells: conflictCells ?? this.conflictCells,
    );
  }
}
