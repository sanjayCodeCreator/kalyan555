import '../data/models/word_placement.dart';

/// Word validator for checking if selected path forms a valid word
class WordValidator {
  /// Validate if the selected path forms a valid word
  /// Returns the word placement if valid, null otherwise
  static WordPlacement? validateSelection({
    required List<int> selectedPath,
    required List<WordPlacement> wordPlacements,
    required List<String> gridLetters,
    required Set<int> foundWordIds,
  }) {
    if (selectedPath.isEmpty) return null;

    // Build the selected word (forward)
    final selectedWord = selectedPath.map((i) => gridLetters[i]).join();

    // Build the reverse word
    final reversedWord = selectedWord.split('').reversed.join();

    // Check against all unfound words
    for (final placement in wordPlacements) {
      // Skip already found words
      if (foundWordIds.contains(placement.wordId)) continue;

      // Check forward match
      if (placement.word == selectedWord) {
        // Verify the path matches the word's cell indices
        if (_pathMatchesPlacement(selectedPath, placement)) {
          return placement;
        }
      }

      // Check reverse match
      if (placement.word == reversedWord) {
        // Verify the reversed path matches
        final reversedPath = selectedPath.reversed.toList();
        if (_pathMatchesPlacement(reversedPath, placement)) {
          return placement;
        }
      }
    }

    return null;
  }

  /// Check if the selected path matches the word placement
  static bool _pathMatchesPlacement(
    List<int> path,
    WordPlacement placement,
  ) {
    if (path.length != placement.cellIndices.length) return false;

    for (int i = 0; i < path.length; i++) {
      if (path[i] != placement.cellIndices[i]) return false;
    }

    return true;
  }

  /// Check if the selection path is valid (continuous in one direction)
  static bool isValidSelectionPath({
    required List<int> path,
    required int gridSize,
  }) {
    if (path.length < 2) return true;

    // Calculate the direction from first two cells
    final rowDelta = (path[1] ~/ gridSize) - (path[0] ~/ gridSize);
    final colDelta = (path[1] % gridSize) - (path[0] % gridSize);

    // Validate direction is one of the allowed directions
    if (!_isValidDirection(rowDelta, colDelta)) return false;

    // Check all cells follow the same direction
    for (int i = 2; i < path.length; i++) {
      final expectedRow = (path[i - 1] ~/ gridSize) + rowDelta;
      final expectedCol = (path[i - 1] % gridSize) + colDelta;
      final actualRow = path[i] ~/ gridSize;
      final actualCol = path[i] % gridSize;

      if (actualRow != expectedRow || actualCol != expectedCol) {
        return false;
      }
    }

    return true;
  }

  /// Check if the direction is valid (horizontal, vertical, or diagonal)
  static bool _isValidDirection(int rowDelta, int colDelta) {
    // Must move exactly 0 or 1 in each direction
    if (rowDelta.abs() > 1 || colDelta.abs() > 1) return false;

    // Must move in at least one direction
    if (rowDelta == 0 && colDelta == 0) return false;

    return true;
  }

  /// Get cells between two points (for drag selection)
  static List<int> getCellsBetween({
    required int startIndex,
    required int endIndex,
    required int gridSize,
  }) {
    final startRow = startIndex ~/ gridSize;
    final startCol = startIndex % gridSize;
    final endRow = endIndex ~/ gridSize;
    final endCol = endIndex % gridSize;

    // Calculate deltas
    int rowDelta = endRow - startRow;
    int colDelta = endCol - startCol;

    // Normalize to get direction (-1, 0, or 1)
    final steps =
        [rowDelta.abs(), colDelta.abs()].reduce((a, b) => a > b ? a : b);
    if (steps == 0) return [startIndex];

    rowDelta = rowDelta ~/ steps;
    colDelta = colDelta ~/ steps;

    // Validate direction
    if (!_isValidDirection(rowDelta, colDelta)) {
      return [startIndex, endIndex];
    }

    // Build path
    final path = <int>[];
    int currentRow = startRow;
    int currentCol = startCol;

    while (true) {
      path.add(currentRow * gridSize + currentCol);

      if (currentRow == endRow && currentCol == endCol) break;

      currentRow += rowDelta;
      currentCol += colDelta;

      // Safety check
      if (path.length > gridSize) break;
    }

    return path;
  }

  /// Determine the direction of selected word
  static WordDirection? getSelectionDirection({
    required List<int> path,
    required int gridSize,
  }) {
    if (path.length < 2) return null;

    final rowDelta = (path[1] ~/ gridSize) - (path[0] ~/ gridSize);
    final colDelta = (path[1] % gridSize) - (path[0] % gridSize);

    if (rowDelta == 0 && colDelta == 1) return WordDirection.horizontal;
    if (rowDelta == 0 && colDelta == -1) return WordDirection.horizontalReverse;
    if (rowDelta == 1 && colDelta == 0) return WordDirection.vertical;
    if (rowDelta == -1 && colDelta == 0) return WordDirection.verticalReverse;
    if (rowDelta == 1 && colDelta == 1) return WordDirection.diagonalDown;
    if (rowDelta == -1 && colDelta == -1) {
      return WordDirection.diagonalDownReverse;
    }
    if (rowDelta == -1 && colDelta == 1) return WordDirection.diagonalUp;
    if (rowDelta == 1 && colDelta == -1) return WordDirection.diagonalUpReverse;

    return null;
  }
}
