import 'dart:math';

import '../data/models/word_placement.dart';

/// Word placer for positioning words in the grid
class WordPlacer {
  static final _random = Random();

  /// Place a word in the grid
  /// Returns null if word cannot be placed
  static WordPlacement? placeWord({
    required String word,
    required List<String> grid,
    required int gridSize,
    required List<WordDirection> allowedDirections,
    required int wordId,
  }) {
    // Shuffle directions to randomize placement
    final directions = List<WordDirection>.from(allowedDirections)
      ..shuffle(_random);

    // Try each direction
    for (final direction in directions) {
      final placement = _tryPlaceInDirection(
        word: word,
        grid: grid,
        gridSize: gridSize,
        direction: direction,
        wordId: wordId,
      );

      if (placement != null) {
        return placement;
      }
    }

    return null;
  }

  /// Try to place word in a specific direction
  static WordPlacement? _tryPlaceInDirection({
    required String word,
    required List<String> grid,
    required int gridSize,
    required WordDirection direction,
    required int wordId,
  }) {
    // Get valid starting positions for this direction
    final validPositions = _getValidStartPositions(
      wordLength: word.length,
      gridSize: gridSize,
      direction: direction,
    );

    // Shuffle positions for randomness
    validPositions.shuffle(_random);

    // Try each position
    for (final pos in validPositions) {
      final row = pos ~/ gridSize;
      final col = pos % gridSize;

      if (_canPlaceWord(
        word: word,
        grid: grid,
        gridSize: gridSize,
        startRow: row,
        startCol: col,
        direction: direction,
      )) {
        final cellIndices = <int>[];

        // Place the word
        for (int i = 0; i < word.length; i++) {
          final r = row + (i * direction.rowDelta);
          final c = col + (i * direction.colDelta);
          final index = r * gridSize + c;
          grid[index] = word[i];
          cellIndices.add(index);
        }

        return WordPlacement(
          word: word,
          startRow: row,
          startCol: col,
          direction: direction,
          cellIndices: cellIndices,
          wordId: wordId,
        );
      }
    }

    return null;
  }

  /// Get all valid starting positions for a word in a direction
  static List<int> _getValidStartPositions({
    required int wordLength,
    required int gridSize,
    required WordDirection direction,
  }) {
    final positions = <int>[];

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        // Check if word fits from this position
        final endRow = row + ((wordLength - 1) * direction.rowDelta);
        final endCol = col + ((wordLength - 1) * direction.colDelta);

        if (endRow >= 0 &&
            endRow < gridSize &&
            endCol >= 0 &&
            endCol < gridSize) {
          positions.add(row * gridSize + col);
        }
      }
    }

    return positions;
  }

  /// Check if a word can be placed at the given position
  static bool _canPlaceWord({
    required String word,
    required List<String> grid,
    required int gridSize,
    required int startRow,
    required int startCol,
    required WordDirection direction,
  }) {
    for (int i = 0; i < word.length; i++) {
      final row = startRow + (i * direction.rowDelta);
      final col = startCol + (i * direction.colDelta);
      final index = row * gridSize + col;

      // Cell must be empty OR already contain the same letter
      if (grid[index] != '' && grid[index] != word[i]) {
        return false;
      }
    }

    return true;
  }

  /// Check if a placement would intersect with another word correctly
  static bool wouldIntersectCorrectly({
    required String word,
    required List<String> currentGrid,
    required int gridSize,
    required int startRow,
    required int startCol,
    required WordDirection direction,
  }) {
    for (int i = 0; i < word.length; i++) {
      final row = startRow + (i * direction.rowDelta);
      final col = startCol + (i * direction.colDelta);
      final index = row * gridSize + col;

      // If cell has a letter, it must match
      if (currentGrid[index] != '' && currentGrid[index] != word[i]) {
        return false;
      }
    }
    return true;
  }
}
