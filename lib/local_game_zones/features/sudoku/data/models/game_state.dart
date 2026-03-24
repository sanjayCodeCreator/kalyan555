import 'cell_state.dart';

/// Game difficulty levels
enum Difficulty {
  easy('Easy', 36), // ~36 clues (45 removed)
  medium('Medium', 32), // ~32 clues (49 removed)
  hard('Hard', 28), // ~28 clues (53 removed)
  expert('Expert', 24); // ~24 clues (57 removed)

  final String label;
  final int clueCount;

  const Difficulty(this.label, this.clueCount);
}

/// Game status
enum GameStatus {
  /// Game is in progress
  playing,

  /// Game is paused
  paused,

  /// Player won
  won,

  /// Player lost (too many mistakes)
  lost,
}

/// Represents a move in the game (for undo/redo)
class MoveRecord {
  final int index;
  final CellState previousState;
  final CellState newState;

  const MoveRecord({
    required this.index,
    required this.previousState,
    required this.newState,
  });
}

/// Main game state
class SudokuGameState {
  /// The 81-cell board (9x9 grid)
  final List<CellState> board;

  /// The solution for validation
  final List<int> solution;

  /// Currently selected cell index (0-80, or null if none selected)
  final int? selectedIndex;

  /// Current difficulty level
  final Difficulty difficulty;

  /// Current game status
  final GameStatus status;

  /// Number of mistakes made
  final int mistakes;

  /// Maximum mistakes allowed before game over
  final int maxMistakes;

  /// Number of hints remaining
  final int hintsRemaining;

  /// Number of hints used
  final int hintsUsed;

  /// Elapsed time in seconds
  final int elapsedSeconds;

  /// Whether note mode is active
  final bool isNoteMode;

  /// Undo stack for moves
  final List<MoveRecord> undoStack;

  /// Redo stack for moves
  final List<MoveRecord> redoStack;

  const SudokuGameState({
    required this.board,
    required this.solution,
    this.selectedIndex,
    this.difficulty = Difficulty.easy,
    this.status = GameStatus.playing,
    this.mistakes = 0,
    this.maxMistakes = 3,
    this.hintsRemaining = 3,
    this.hintsUsed = 0,
    this.elapsedSeconds = 0,
    this.isNoteMode = false,
    this.undoStack = const [],
    this.redoStack = const [],
  });

  /// Create an empty initial state
  factory SudokuGameState.initial() {
    return SudokuGameState(
      board: List.generate(81, (_) => CellState.empty()),
      solution: List.generate(81, (_) => 0),
    );
  }

  /// Check if the game is over
  bool get isGameOver => status == GameStatus.won || status == GameStatus.lost;

  /// Check if the game can be undone
  bool get canUndo => undoStack.isNotEmpty;

  /// Check if the game can be redone
  bool get canRedo => redoStack.isNotEmpty;

  /// Get the selected cell state
  CellState? get selectedCell =>
      selectedIndex != null ? board[selectedIndex!] : null;

  /// Get cells in the same row as the selected cell
  List<int> get selectedRowIndices {
    if (selectedIndex == null) return [];
    final row = selectedIndex! ~/ 9;
    return List.generate(9, (col) => row * 9 + col);
  }

  /// Get cells in the same column as the selected cell
  List<int> get selectedColIndices {
    if (selectedIndex == null) return [];
    final col = selectedIndex! % 9;
    return List.generate(9, (row) => row * 9 + col);
  }

  /// Get cells in the same 3x3 box as the selected cell
  List<int> get selectedBoxIndices {
    if (selectedIndex == null) return [];
    final row = selectedIndex! ~/ 9;
    final col = selectedIndex! % 9;
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    final indices = <int>[];
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        indices.add(r * 9 + c);
      }
    }
    return indices;
  }

  /// Get all cells with the same value as selected cell
  List<int> get sameValueIndices {
    if (selectedIndex == null) return [];
    final value = board[selectedIndex!].value;
    if (value == null) return [];
    final indices = <int>[];
    for (int i = 0; i < 81; i++) {
      if (board[i].value == value) {
        indices.add(i);
      }
    }
    return indices;
  }

  /// Count how many of each number are placed on the board
  Map<int, int> get numberCounts {
    final counts = <int, int>{};
    for (int n = 1; n <= 9; n++) {
      counts[n] = board.where((cell) => cell.value == n).length;
    }
    return counts;
  }

  /// Calculate score based on time, mistakes, and hints
  int get score {
    if (status != GameStatus.won) return 0;
    const baseScore = 1000;
    final timePenalty = elapsedSeconds ~/ 10; // -1 point per 10 seconds
    final mistakePenalty = mistakes * 50;
    final hintPenalty = hintsUsed * 100;
    return (baseScore - timePenalty - mistakePenalty - hintPenalty)
        .clamp(0, baseScore);
  }

  /// Format elapsed time as MM:SS
  String get formattedTime {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Copy with modified fields
  SudokuGameState copyWith({
    List<CellState>? board,
    List<int>? solution,
    int? selectedIndex,
    bool clearSelection = false,
    Difficulty? difficulty,
    GameStatus? status,
    int? mistakes,
    int? maxMistakes,
    int? hintsRemaining,
    int? hintsUsed,
    int? elapsedSeconds,
    bool? isNoteMode,
    List<MoveRecord>? undoStack,
    List<MoveRecord>? redoStack,
  }) {
    return SudokuGameState(
      board: board ?? this.board,
      solution: solution ?? this.solution,
      selectedIndex:
          clearSelection ? null : (selectedIndex ?? this.selectedIndex),
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      mistakes: mistakes ?? this.mistakes,
      maxMistakes: maxMistakes ?? this.maxMistakes,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isNoteMode: isNoteMode ?? this.isNoteMode,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
    );
  }
}
