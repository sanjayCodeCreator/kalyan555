/// Direction of word placement in the grid
enum WordDirection {
  horizontal('→'),
  vertical('↓'),
  diagonalDown('↘'),
  diagonalUp('↗'),
  horizontalReverse('←'),
  verticalReverse('↑'),
  diagonalDownReverse('↖'),
  diagonalUpReverse('↙');

  final String symbol;
  const WordDirection(this.symbol);

  /// Check if this direction is a reverse direction
  bool get isReverse =>
      this == horizontalReverse ||
      this == verticalReverse ||
      this == diagonalDownReverse ||
      this == diagonalUpReverse;

  /// Check if this direction is diagonal
  bool get isDiagonal =>
      this == diagonalDown ||
      this == diagonalUp ||
      this == diagonalDownReverse ||
      this == diagonalUpReverse;

  /// Check if this direction is vertical
  bool get isVertical => this == vertical || this == verticalReverse;

  /// Check if this direction is horizontal
  bool get isHorizontal => this == horizontal || this == horizontalReverse;

  /// Get the row delta for this direction
  int get rowDelta {
    switch (this) {
      case horizontal:
      case horizontalReverse:
        return 0;
      case vertical:
      case diagonalDown:
        return 1;
      case verticalReverse:
      case diagonalUpReverse:
        return -1;
      case diagonalUp:
        return -1;
      case diagonalDownReverse:
        return 1;
    }
  }

  /// Get the column delta for this direction
  int get colDelta {
    switch (this) {
      case horizontal:
      case diagonalDown:
      case diagonalUp:
        return 1;
      case horizontalReverse:
      case diagonalDownReverse:
      case diagonalUpReverse:
        return -1;
      case vertical:
      case verticalReverse:
        return 0;
    }
  }
}

/// Represents a word placement in the grid
class WordPlacement {
  /// The word string
  final String word;

  /// Starting row position
  final int startRow;

  /// Starting column position
  final int startCol;

  /// Direction of the word
  final WordDirection direction;

  /// List of cell indices this word occupies
  final List<int> cellIndices;

  /// Unique ID for this word
  final int wordId;

  const WordPlacement({
    required this.word,
    required this.startRow,
    required this.startCol,
    required this.direction,
    required this.cellIndices,
    required this.wordId,
  });

  /// Get the display word (for reverse directions, show the original word)
  String get displayWord => word;

  /// Get the cell indices in the order they appear in the grid
  List<int> get orderedIndices => cellIndices;

  @override
  String toString() {
    return 'WordPlacement(word: $word, start: ($startRow, $startCol), '
        'direction: ${direction.symbol})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordPlacement &&
        other.word == word &&
        other.startRow == startRow &&
        other.startCol == startCol &&
        other.direction == direction;
  }

  @override
  int get hashCode {
    return Object.hash(word, startRow, startCol, direction);
  }
}
