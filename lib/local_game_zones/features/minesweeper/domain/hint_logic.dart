import 'dart:math';

import '../data/models/cell_state.dart';
import 'mine_generator.dart';

/// Hint logic for Minesweeper
class HintLogic {
  static final _random = Random();

  /// Find a random safe cell that is hidden
  static int? getSafeCell(List<CellData> grid, int rows, int cols) {
    final safeCells = <int>[];

    for (int i = 0; i < grid.length; i++) {
      final cell = grid[i];
      if (cell.isHidden && !cell.hasMine) {
        safeCells.add(i);
      }
    }

    if (safeCells.isEmpty) return null;

    // Prioritize cells adjacent to revealed cells for better hints
    final adjacentSafeCells = <int>[];
    for (final index in safeCells) {
      final neighbors = MineGenerator.getNeighborIndices(index, rows, cols);
      final hasRevealedNeighbor = neighbors.any((n) => grid[n].isRevealed);
      if (hasRevealedNeighbor) {
        adjacentSafeCells.add(index);
      }
    }

    final candidates =
        adjacentSafeCells.isNotEmpty ? adjacentSafeCells : safeCells;
    return candidates[_random.nextInt(candidates.length)];
  }

  /// Find a cell that is definitely a mine based on revealed numbers
  static int? getObviousMine(List<CellData> grid, int rows, int cols) {
    for (int i = 0; i < grid.length; i++) {
      final cell = grid[i];
      if (!cell.isRevealed || cell.adjacentMines == 0) continue;

      final neighbors = MineGenerator.getNeighborIndices(i, rows, cols);
      final hiddenNeighbors = <int>[];
      int flaggedCount = 0;

      for (final n in neighbors) {
        if (grid[n].isFlagged) flaggedCount++;
        if (grid[n].isHidden) hiddenNeighbors.add(n);
      }

      // If hidden neighbors count + flagged count == adjacent mines,
      // all hidden neighbors are mines
      if (hiddenNeighbors.length + flaggedCount == cell.adjacentMines &&
          hiddenNeighbors.isNotEmpty) {
        // Return first unflagged hidden neighbor that's a mine
        for (final n in hiddenNeighbors) {
          if (!grid[n].isFlagged) {
            return n;
          }
        }
      }
    }

    return null;
  }

  /// Get cells that can be safely revealed based on flagged mines
  static List<int> getSafeReveals(List<CellData> grid, int rows, int cols) {
    final safeReveals = <int>[];

    for (int i = 0; i < grid.length; i++) {
      final cell = grid[i];
      if (!cell.isRevealed || cell.adjacentMines == 0) continue;

      final neighbors = MineGenerator.getNeighborIndices(i, rows, cols);
      int flaggedCount = 0;
      final hiddenNeighbors = <int>[];

      for (final n in neighbors) {
        if (grid[n].isFlagged) flaggedCount++;
        if (grid[n].isHidden) hiddenNeighbors.add(n);
      }

      // If flagged count == adjacent mines, all hidden neighbors are safe
      if (flaggedCount == cell.adjacentMines && hiddenNeighbors.isNotEmpty) {
        safeReveals.addAll(hiddenNeighbors);
      }
    }

    return safeReveals.toSet().toList(); // Remove duplicates
  }

  /// Analyze the board and provide hint type
  static HintResult analyzeBoard(List<CellData> grid, int rows, int cols) {
    // First, try to find an obvious mine to flag
    final obviousMine = getObviousMine(grid, rows, cols);
    if (obviousMine != null) {
      return HintResult(
        type: HintType.flagMine,
        cellIndex: obviousMine,
        message: 'This cell is definitely a mine!',
      );
    }

    // Then, try to find safe reveals
    final safeReveals = getSafeReveals(grid, rows, cols);
    if (safeReveals.isNotEmpty) {
      return HintResult(
        type: HintType.safeReveal,
        cellIndex: safeReveals[_random.nextInt(safeReveals.length)],
        message: 'This cell is safe to reveal!',
      );
    }

    // Finally, provide a random safe cell
    final safeCell = getSafeCell(grid, rows, cols);
    if (safeCell != null) {
      return HintResult(
        type: HintType.safeCell,
        cellIndex: safeCell,
        message: 'Try this cell - it\'s safe!',
      );
    }

    return const HintResult(
      type: HintType.noHint,
      cellIndex: null,
      message: 'No hints available.',
    );
  }
}

/// Type of hint provided
enum HintType {
  /// A cell that should be flagged as mine
  flagMine,

  /// A cell that can be safely revealed (deduced from flags)
  safeReveal,

  /// A random safe cell
  safeCell,

  /// No hint available
  noHint,
}

/// Result of hint analysis
class HintResult {
  final HintType type;
  final int? cellIndex;
  final String message;

  const HintResult({
    required this.type,
    required this.cellIndex,
    required this.message,
  });
}
