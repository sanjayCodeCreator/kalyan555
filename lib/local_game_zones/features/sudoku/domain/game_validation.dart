import '../data/models/cell_state.dart';

/// Sudoku game validation logic
class GameValidation {
  /// Check if a value at an index conflicts with other cells
  static bool hasConflict(List<CellState> board, int index, int value) {
    final row = index ~/ 9;
    final col = index % 9;

    // Check row
    for (int c = 0; c < 9; c++) {
      final i = row * 9 + c;
      if (i != index && board[i].value == value) return true;
    }

    // Check column
    for (int r = 0; r < 9; r++) {
      final i = r * 9 + col;
      if (i != index && board[i].value == value) return true;
    }

    // Check 3x3 box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        final i = r * 9 + c;
        if (i != index && board[i].value == value) return true;
      }
    }

    return false;
  }

  /// Get all conflicting cell indices for a given cell
  static List<int> getConflictingCells(List<CellState> board, int index) {
    final value = board[index].value;
    if (value == null) return [];

    final conflicts = <int>[];
    final row = index ~/ 9;
    final col = index % 9;

    // Check row
    for (int c = 0; c < 9; c++) {
      final i = row * 9 + c;
      if (i != index && board[i].value == value) conflicts.add(i);
    }

    // Check column
    for (int r = 0; r < 9; r++) {
      final i = r * 9 + col;
      if (i != index && board[i].value == value && !conflicts.contains(i)) {
        conflicts.add(i);
      }
    }

    // Check 3x3 box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        final i = r * 9 + c;
        if (i != index && board[i].value == value && !conflicts.contains(i)) {
          conflicts.add(i);
        }
      }
    }

    return conflicts;
  }

  /// Check if the puzzle is complete and valid
  static bool isPuzzleComplete(List<CellState> board) {
    // Check if all cells are filled
    for (final cell in board) {
      if (cell.value == null) return false;
    }

    // Check if all cells are valid
    for (int i = 0; i < 81; i++) {
      if (hasConflict(board, i, board[i].value!)) return false;
    }

    return true;
  }

  /// Check if a specific cell value matches the solution
  static bool isCorrectValue(int index, int value, List<int> solution) {
    return solution[index] == value;
  }

  /// Get possible candidates for a cell
  static Set<int> getCandidates(List<CellState> board, int index) {
    if (board[index].value != null) return {};

    final candidates = <int>{};
    for (int n = 1; n <= 9; n++) {
      if (!hasConflict(board, index, n)) {
        candidates.add(n);
      }
    }
    return candidates;
  }

  /// Update error states for all cells in the board
  static List<CellState> updateErrorStates(List<CellState> board) {
    final updatedBoard = <CellState>[];

    for (int i = 0; i < 81; i++) {
      final cell = board[i];
      if (cell.value == null || cell.isFixed) {
        updatedBoard.add(cell.copyWith(isError: false));
      } else {
        final hasError = hasConflict(board, i, cell.value!);
        updatedBoard.add(cell.copyWith(isError: hasError));
      }
    }

    return updatedBoard;
  }

  /// Get box index (0-8) for a cell
  static int getBoxIndex(int cellIndex) {
    final row = cellIndex ~/ 9;
    final col = cellIndex % 9;
    return (row ~/ 3) * 3 + (col ~/ 3);
  }

  /// Get row index (0-8) for a cell
  static int getRowIndex(int cellIndex) => cellIndex ~/ 9;

  /// Get column index (0-8) for a cell
  static int getColIndex(int cellIndex) => cellIndex % 9;
}
