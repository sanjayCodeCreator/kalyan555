import 'dart:math';

import '../data/models/cell_state.dart';

/// Mine generator with first-tap safe logic
class MineGenerator {
  static final _random = Random();

  /// Generate mines on the grid, ensuring first tap cell and neighbors are safe
  static List<CellData> generateMines({
    required int rows,
    required int cols,
    required int mineCount,
    required int firstTapIndex,
  }) {
    final totalCells = rows * cols;

    // Get cells that should be safe (first tap and its neighbors)
    final safeCells = _getSafeCells(firstTapIndex, rows, cols);

    // Collect all possible mine positions (excluding safe cells)
    final availablePositions = <int>[];
    for (int i = 0; i < totalCells; i++) {
      if (!safeCells.contains(i)) {
        availablePositions.add(i);
      }
    }

    // Shuffle and pick mine positions
    availablePositions.shuffle(_random);
    final minePositions = availablePositions.take(mineCount).toSet();

    // Place mines and calculate adjacent counts
    final updatedGrid = <CellData>[];
    for (int i = 0; i < totalCells; i++) {
      if (minePositions.contains(i)) {
        updatedGrid.add(CellData.mine());
      } else {
        final adjacentMines = _countAdjacentMines(i, rows, cols, minePositions);
        updatedGrid.add(CellData(adjacentMines: adjacentMines));
      }
    }

    return updatedGrid;
  }

  /// Get cells that should be safe (first tap and its 8 neighbors)
  static Set<int> _getSafeCells(int tapIndex, int rows, int cols) {
    final safeCells = <int>{tapIndex};
    final neighbors = getNeighborIndices(tapIndex, rows, cols);
    safeCells.addAll(neighbors);
    return safeCells;
  }

  /// Count adjacent mines for a cell
  static int _countAdjacentMines(
    int index,
    int rows,
    int cols,
    Set<int> minePositions,
  ) {
    final neighbors = getNeighborIndices(index, rows, cols);
    return neighbors.where((n) => minePositions.contains(n)).length;
  }

  /// Get all neighbor indices for a cell
  static List<int> getNeighborIndices(int index, int rows, int cols) {
    final row = index ~/ cols;
    final col = index % cols;
    final neighbors = <int>[];

    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;

        final newRow = row + dr;
        final newCol = col + dc;

        if (newRow >= 0 && newRow < rows && newCol >= 0 && newCol < cols) {
          neighbors.add(newRow * cols + newCol);
        }
      }
    }

    return neighbors;
  }

  /// Initialize empty grid without mines (before first tap)
  static List<CellData> createEmptyGrid(int rows, int cols) {
    return List<CellData>.generate(rows * cols, (_) => CellData.empty());
  }
}
