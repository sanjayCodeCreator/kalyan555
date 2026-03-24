import 'cell_state.dart';

/// Game difficulty levels
enum Difficulty {
  /// Beginner: 9×9 grid with 10 mines
  beginner(rows: 9, cols: 9, mines: 10, name: 'Beginner'),

  /// Intermediate: 16×16 grid with 40 mines
  intermediate(rows: 16, cols: 16, mines: 40, name: 'Intermediate'),

  /// Expert: 16×30 grid with 99 mines
  expert(rows: 16, cols: 30, mines: 99, name: 'Expert'),

  /// Custom difficulty
  custom(rows: 9, cols: 9, mines: 10, name: 'Custom');

  final int rows;
  final int cols;
  final int mines;
  final String name;

  const Difficulty({
    required this.rows,
    required this.cols,
    required this.mines,
    required this.name,
  });

  /// Total cells in the grid
  int get totalCells => rows * cols;
}

/// Game status states
enum GameStatus {
  /// Game not started
  idle,

  /// Game in progress
  playing,

  /// Game is paused
  paused,

  /// Player won
  won,

  /// Player lost (hit a mine)
  lost,
}

/// Complete game state for Minesweeper
class MinesweeperGameState {
  final List<CellData> grid;
  final Difficulty difficulty;
  final int customRows;
  final int customCols;
  final int customMines;
  final GameStatus status;
  final int flagsPlaced;
  final int elapsedSeconds;
  final bool flagMode;
  final int hintsRemaining;
  final int? highlightedHintCell;
  final bool isFirstMove;
  final DateTime? gameStartTime;
  final bool soundEnabled;
  final bool hapticEnabled;

  const MinesweeperGameState({
    this.grid = const [],
    this.difficulty = Difficulty.beginner,
    this.customRows = 9,
    this.customCols = 9,
    this.customMines = 10,
    this.status = GameStatus.idle,
    this.flagsPlaced = 0,
    this.elapsedSeconds = 0,
    this.flagMode = false,
    this.hintsRemaining = 3,
    this.highlightedHintCell,
    this.isFirstMove = true,
    this.gameStartTime,
    this.soundEnabled = true,
    this.hapticEnabled = true,
  });

  /// Create initial state
  factory MinesweeperGameState.initial() => const MinesweeperGameState();

  /// Get actual rows based on difficulty
  int get rows =>
      difficulty == Difficulty.custom ? customRows : difficulty.rows;

  /// Get actual cols based on difficulty
  int get cols =>
      difficulty == Difficulty.custom ? customCols : difficulty.cols;

  /// Get actual mines based on difficulty
  int get totalMines =>
      difficulty == Difficulty.custom ? customMines : difficulty.mines;

  /// Get remaining mines (total mines - flags placed)
  int get minesRemaining => totalMines - flagsPlaced;

  /// Get revealed cell count
  int get revealedCount => grid.where((cell) => cell.isRevealed).length;

  /// Get flagged cell count
  int get flaggedCount => grid.where((cell) => cell.isFlagged).length;

  /// Check if game is active
  bool get isActive => status == GameStatus.playing;

  /// Check if game is over
  bool get isGameOver => status == GameStatus.won || status == GameStatus.lost;

  /// Copy with new values
  MinesweeperGameState copyWith({
    List<CellData>? grid,
    Difficulty? difficulty,
    int? customRows,
    int? customCols,
    int? customMines,
    GameStatus? status,
    int? flagsPlaced,
    int? elapsedSeconds,
    bool? flagMode,
    int? hintsRemaining,
    int? highlightedHintCell,
    bool clearHighlightedHint = false,
    bool? isFirstMove,
    DateTime? gameStartTime,
    bool clearGameStartTime = false,
    bool? soundEnabled,
    bool? hapticEnabled,
  }) {
    return MinesweeperGameState(
      grid: grid ?? this.grid,
      difficulty: difficulty ?? this.difficulty,
      customRows: customRows ?? this.customRows,
      customCols: customCols ?? this.customCols,
      customMines: customMines ?? this.customMines,
      status: status ?? this.status,
      flagsPlaced: flagsPlaced ?? this.flagsPlaced,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      flagMode: flagMode ?? this.flagMode,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      highlightedHintCell: clearHighlightedHint
          ? null
          : (highlightedHintCell ?? this.highlightedHintCell),
      isFirstMove: isFirstMove ?? this.isFirstMove,
      gameStartTime:
          clearGameStartTime ? null : (gameStartTime ?? this.gameStartTime),
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() => {
        'grid': grid
            .map((cell) => {
                  'hasMine': cell.hasMine,
                  'adjacentMines': cell.adjacentMines,
                  'state': cell.state.index,
                })
            .toList(),
        'difficulty': difficulty.index,
        'customRows': customRows,
        'customCols': customCols,
        'customMines': customMines,
        'status': status.index,
        'flagsPlaced': flagsPlaced,
        'elapsedSeconds': elapsedSeconds,
        'flagMode': flagMode,
        'hintsRemaining': hintsRemaining,
        'isFirstMove': isFirstMove,
        'soundEnabled': soundEnabled,
        'hapticEnabled': hapticEnabled,
      };

  /// Create from JSON
  factory MinesweeperGameState.fromJson(Map<String, dynamic> json) {
    final gridData = json['grid'] as List<dynamic>? ?? [];
    return MinesweeperGameState(
      grid: gridData
          .map((cell) => CellData(
                hasMine: cell['hasMine'] as bool? ?? false,
                adjacentMines: cell['adjacentMines'] as int? ?? 0,
                state: CellState.values[cell['state'] as int? ?? 0],
              ))
          .toList(),
      difficulty: Difficulty.values[json['difficulty'] as int? ?? 0],
      customRows: json['customRows'] as int? ?? 9,
      customCols: json['customCols'] as int? ?? 9,
      customMines: json['customMines'] as int? ?? 10,
      status: GameStatus.values[json['status'] as int? ?? 0],
      flagsPlaced: json['flagsPlaced'] as int? ?? 0,
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      flagMode: json['flagMode'] as bool? ?? false,
      hintsRemaining: json['hintsRemaining'] as int? ?? 3,
      isFirstMove: json['isFirstMove'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      hapticEnabled: json['hapticEnabled'] as bool? ?? true,
    );
  }
}
