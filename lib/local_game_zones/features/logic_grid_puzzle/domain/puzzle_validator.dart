import 'puzzle_models.dart';

/// Validator for logic grid puzzle
class PuzzleValidator {
  /// Check if the current grid state is valid (no conflicts)
  static bool isValidState(Map<String, GridCell> grid, Puzzle puzzle) {
    // Check each grid section for conflicts
    for (int cat1 = 0; cat1 < puzzle.categoryCount - 1; cat1++) {
      for (int cat2 = cat1 + 1; cat2 < puzzle.categoryCount; cat2++) {
        if (!_isSectionValid(grid, puzzle, cat1, cat2)) {
          return false;
        }
      }
    }
    return true;
  }

  /// Check if a specific grid section is valid
  static bool _isSectionValid(
    Map<String, GridCell> grid,
    Puzzle puzzle,
    int cat1,
    int cat2,
  ) {
    final size = puzzle.gridSize;

    // Check each row - at most one "yes"
    for (int row = 0; row < size; row++) {
      int yesCount = 0;
      for (int col = 0; col < size; col++) {
        final key = '$cat1-$row-$cat2-$col';
        if (grid[key]?.mark == CellMark.yes) {
          yesCount++;
        }
      }
      if (yesCount > 1) return false;
    }

    // Check each column - at most one "yes"
    for (int col = 0; col < size; col++) {
      int yesCount = 0;
      for (int row = 0; row < size; row++) {
        final key = '$cat1-$row-$cat2-$col';
        if (grid[key]?.mark == CellMark.yes) {
          yesCount++;
        }
      }
      if (yesCount > 1) return false;
    }

    return true;
  }

  /// Check if the puzzle is complete (all relationships resolved)
  static bool isPuzzleComplete(Map<String, GridCell> grid, Puzzle puzzle) {
    // For each grid section, check if exactly one "yes" per row/column
    for (int cat1 = 0; cat1 < puzzle.categoryCount - 1; cat1++) {
      for (int cat2 = cat1 + 1; cat2 < puzzle.categoryCount; cat2++) {
        if (!_isSectionComplete(grid, puzzle, cat1, cat2)) {
          return false;
        }
      }
    }
    return true;
  }

  /// Check if a grid section is complete
  static bool _isSectionComplete(
    Map<String, GridCell> grid,
    Puzzle puzzle,
    int cat1,
    int cat2,
  ) {
    final size = puzzle.gridSize;

    // Check each row has exactly one "yes"
    for (int row = 0; row < size; row++) {
      int yesCount = 0;
      for (int col = 0; col < size; col++) {
        final key = '$cat1-$row-$cat2-$col';
        if (grid[key]?.mark == CellMark.yes) {
          yesCount++;
        }
      }
      if (yesCount != 1) return false;
    }

    // Check each column has exactly one "yes"
    for (int col = 0; col < size; col++) {
      int yesCount = 0;
      for (int row = 0; row < size; row++) {
        final key = '$cat1-$row-$cat2-$col';
        if (grid[key]?.mark == CellMark.yes) {
          yesCount++;
        }
      }
      if (yesCount != 1) return false;
    }

    return true;
  }

  /// Validate solution against the puzzle's correct answer
  static bool isSolutionCorrect(Map<String, GridCell> grid, Puzzle puzzle) {
    if (!isPuzzleComplete(grid, puzzle)) return false;

    // Check each "yes" mark against the solution
    for (final entry in grid.entries) {
      final cell = entry.value;
      if (cell.mark == CellMark.yes) {
        final isCorrect = puzzle.solution.isMatch(
          cell.rowCategory,
          cell.rowItem,
          cell.colCategory,
          cell.colItem,
        );
        if (!isCorrect) return false;
      }
    }

    return true;
  }

  /// Find conflicts in current grid state
  static List<String> findConflicts(Map<String, GridCell> grid, Puzzle puzzle) {
    final conflicts = <String>[];

    for (int cat1 = 0; cat1 < puzzle.categoryCount - 1; cat1++) {
      for (int cat2 = cat1 + 1; cat2 < puzzle.categoryCount; cat2++) {
        conflicts.addAll(_findSectionConflicts(grid, puzzle, cat1, cat2));
      }
    }

    return conflicts;
  }

  /// Find conflicts in a specific section
  static List<String> _findSectionConflicts(
    Map<String, GridCell> grid,
    Puzzle puzzle,
    int cat1,
    int cat2,
  ) {
    final conflicts = <String>[];
    final size = puzzle.gridSize;

    // Check rows
    for (int row = 0; row < size; row++) {
      final yesCells = <String>[];
      for (int col = 0; col < size; col++) {
        final key = '$cat1-$row-$cat2-$col';
        if (grid[key]?.mark == CellMark.yes) {
          yesCells.add(key);
        }
      }
      if (yesCells.length > 1) {
        conflicts.addAll(yesCells);
      }
    }

    // Check columns
    for (int col = 0; col < size; col++) {
      final yesCells = <String>[];
      for (int row = 0; row < size; row++) {
        final key = '$cat1-$row-$cat2-$col';
        if (grid[key]?.mark == CellMark.yes) {
          yesCells.add(key);
        }
      }
      if (yesCells.length > 1) {
        conflicts.addAll(yesCells);
      }
    }

    return conflicts.toSet().toList(); // Remove duplicates
  }

  /// Get cells to auto-eliminate when placing a "yes"
  static List<String> getCellsToEliminate(
    String cellKey,
    Map<String, GridCell> grid,
    Puzzle puzzle,
  ) {
    final parts = cellKey.split('-');
    if (parts.length != 4) return [];

    final cat1 = int.parse(parts[0]);
    final row = int.parse(parts[1]);
    final cat2 = int.parse(parts[2]);
    final col = int.parse(parts[3]);

    final toEliminate = <String>[];
    final size = puzzle.gridSize;

    // Eliminate other cells in same row
    for (int c = 0; c < size; c++) {
      if (c != col) {
        final key = '$cat1-$row-$cat2-$c';
        if (grid[key]?.mark == CellMark.unknown) {
          toEliminate.add(key);
        }
      }
    }

    // Eliminate other cells in same column
    for (int r = 0; r < size; r++) {
      if (r != row) {
        final key = '$cat1-$r-$cat2-$col';
        if (grid[key]?.mark == CellMark.unknown) {
          toEliminate.add(key);
        }
      }
    }

    return toEliminate;
  }

  /// Get a hint - find a cell that can be logically deduced
  static String? getHint(Map<String, GridCell> grid, Puzzle puzzle) {
    // First, check for cells where only one option remains in a row/column
    for (int cat1 = 0; cat1 < puzzle.categoryCount - 1; cat1++) {
      for (int cat2 = cat1 + 1; cat2 < puzzle.categoryCount; cat2++) {
        final hint = _getHintForSection(grid, puzzle, cat1, cat2);
        if (hint != null) return hint;
      }
    }

    return null;
  }

  /// Get hint for a specific grid section
  static String? _getHintForSection(
    Map<String, GridCell> grid,
    Puzzle puzzle,
    int cat1,
    int cat2,
  ) {
    final size = puzzle.gridSize;

    // Check rows - if only one unknown cell, it must be "yes"
    for (int row = 0; row < size; row++) {
      int unknownCount = 0;
      String? lastUnknown;
      bool hasYes = false;

      for (int col = 0; col < size; col++) {
        final key = '$cat1-$row-$cat2-$col';
        final mark = grid[key]?.mark ?? CellMark.unknown;

        if (mark == CellMark.unknown) {
          unknownCount++;
          lastUnknown = key;
        } else if (mark == CellMark.yes) {
          hasYes = true;
          break;
        }
      }

      if (!hasYes && unknownCount == 1 && lastUnknown != null) {
        return lastUnknown;
      }
    }

    // Check columns
    for (int col = 0; col < size; col++) {
      int unknownCount = 0;
      String? lastUnknown;
      bool hasYes = false;

      for (int row = 0; row < size; row++) {
        final key = '$cat1-$row-$cat2-$col';
        final mark = grid[key]?.mark ?? CellMark.unknown;

        if (mark == CellMark.unknown) {
          unknownCount++;
          lastUnknown = key;
        } else if (mark == CellMark.yes) {
          hasYes = true;
          break;
        }
      }

      if (!hasYes && unknownCount == 1 && lastUnknown != null) {
        return lastUnknown;
      }
    }

    return null;
  }
}
