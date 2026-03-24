/// Cell states for Minesweeper game
enum CellState {
  /// Cell is hidden (not yet revealed)
  hidden,

  /// Cell has been revealed
  revealed,

  /// Cell is flagged as potential mine
  flagged,

  /// Cell is marked with question mark (optional)
  questionMark,
}

/// Represents a single cell in the Minesweeper grid
class CellData {
  final bool hasMine;
  final int adjacentMines;
  final CellState state;

  const CellData({
    this.hasMine = false,
    this.adjacentMines = 0,
    this.state = CellState.hidden,
  });

  /// Create an empty hidden cell
  factory CellData.empty() => const CellData();

  /// Create a cell with a mine
  factory CellData.mine() => const CellData(hasMine: true);

  /// Copy with new values
  CellData copyWith({
    bool? hasMine,
    int? adjacentMines,
    CellState? state,
  }) {
    return CellData(
      hasMine: hasMine ?? this.hasMine,
      adjacentMines: adjacentMines ?? this.adjacentMines,
      state: state ?? this.state,
    );
  }

  /// Check if cell is hidden
  bool get isHidden => state == CellState.hidden;

  /// Check if cell is revealed
  bool get isRevealed => state == CellState.revealed;

  /// Check if cell is flagged
  bool get isFlagged => state == CellState.flagged;

  /// Check if cell has question mark
  bool get isQuestionMark => state == CellState.questionMark;

  /// Check if cell is empty (no mine and no adjacent mines)
  bool get isEmpty => !hasMine && adjacentMines == 0;

  /// Get the standard Minesweeper color for the number
  static const List<int> numberColors = [
    0xFF0000FF, // 1 - Blue
    0xFF008000, // 2 - Green
    0xFFFF0000, // 3 - Red
    0xFF000080, // 4 - Dark Blue
    0xFF800000, // 5 - Maroon
    0xFF008080, // 6 - Teal
    0xFF000000, // 7 - Black
    0xFF808080, // 8 - Gray
  ];

  @override
  String toString() =>
      'CellData(hasMine: $hasMine, adjacentMines: $adjacentMines, state: $state)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CellData &&
        other.hasMine == hasMine &&
        other.adjacentMines == adjacentMines &&
        other.state == state;
  }

  @override
  int get hashCode => Object.hash(hasMine, adjacentMines, state);
}
