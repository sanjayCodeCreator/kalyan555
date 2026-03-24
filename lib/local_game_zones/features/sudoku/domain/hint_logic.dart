import '../data/models/cell_state.dart';
import 'game_validation.dart';

/// Hint logic for Sudoku game
class HintLogic {
  /// Get the correct value for a cell from the solution
  static int? getHint(int index, List<int> solution, List<CellState> board) {
    // Don't give hints for fixed cells
    if (board[index].isFixed) return null;

    // Don't give hints for already correctly filled cells
    if (board[index].value == solution[index]) return null;

    return solution[index];
  }

  /// Find the best cell to hint (easiest to deduce)
  static int? findBestCellForHint(List<CellState> board, List<int> solution) {
    int? bestCell;
    int minCandidates = 10;

    for (int i = 0; i < 81; i++) {
      final cell = board[i];

      // Skip fixed or correctly filled cells
      if (cell.isFixed) continue;
      if (cell.value == solution[i]) continue;

      // Get number of candidates
      final candidates = GameValidation.getCandidates(board, i);
      if (candidates.length == 1) {
        // Found a naked single - perfect hint candidate
        return i;
      }

      if (candidates.length < minCandidates && candidates.isNotEmpty) {
        minCandidates = candidates.length;
        bestCell = i;
      }
    }

    return bestCell;
  }

  /// Get smart hint with explanation
  static ({int index, int value, String explanation})? getSmartHint(
    List<CellState> board,
    List<int> solution,
  ) {
    // First, check for naked singles (cells with only one candidate)
    for (int i = 0; i < 81; i++) {
      if (board[i].value != null) continue;

      final candidates = GameValidation.getCandidates(board, i);
      if (candidates.length == 1) {
        return (
          index: i,
          value: candidates.first,
          explanation: 'This cell can only contain ${candidates.first}',
        );
      }
    }

    // Check for hidden singles in rows
    for (int row = 0; row < 9; row++) {
      for (int num = 1; num <= 9; num++) {
        final possibleCells = <int>[];
        for (int col = 0; col < 9; col++) {
          final index = row * 9 + col;
          if (board[index].value == null) {
            final candidates = GameValidation.getCandidates(board, index);
            if (candidates.contains(num)) {
              possibleCells.add(index);
            }
          } else if (board[index].value == num) {
            possibleCells.clear();
            break;
          }
        }
        if (possibleCells.length == 1) {
          return (
            index: possibleCells.first,
            value: num,
            explanation: '$num can only go here in this row',
          );
        }
      }
    }

    // Check for hidden singles in columns
    for (int col = 0; col < 9; col++) {
      for (int num = 1; num <= 9; num++) {
        final possibleCells = <int>[];
        for (int row = 0; row < 9; row++) {
          final index = row * 9 + col;
          if (board[index].value == null) {
            final candidates = GameValidation.getCandidates(board, index);
            if (candidates.contains(num)) {
              possibleCells.add(index);
            }
          } else if (board[index].value == num) {
            possibleCells.clear();
            break;
          }
        }
        if (possibleCells.length == 1) {
          return (
            index: possibleCells.first,
            value: num,
            explanation: '$num can only go here in this column',
          );
        }
      }
    }

    // Check for hidden singles in boxes
    for (int box = 0; box < 9; box++) {
      final boxRow = (box ~/ 3) * 3;
      final boxCol = (box % 3) * 3;

      for (int num = 1; num <= 9; num++) {
        final possibleCells = <int>[];
        for (int r = boxRow; r < boxRow + 3; r++) {
          for (int c = boxCol; c < boxCol + 3; c++) {
            final index = r * 9 + c;
            if (board[index].value == null) {
              final candidates = GameValidation.getCandidates(board, index);
              if (candidates.contains(num)) {
                possibleCells.add(index);
              }
            } else if (board[index].value == num) {
              possibleCells.clear();
              break;
            }
          }
        }
        if (possibleCells.length == 1) {
          return (
            index: possibleCells.first,
            value: num,
            explanation: '$num can only go here in this box',
          );
        }
      }
    }

    // Fallback: just give any correct value
    final bestCell = findBestCellForHint(board, solution);
    if (bestCell != null) {
      return (
        index: bestCell,
        value: solution[bestCell],
        explanation: 'The correct value for this cell',
      );
    }

    return null;
  }

  /// Auto-fill all candidates (pencil marks) for empty cells
  static List<CellState> autoFillCandidates(List<CellState> board) {
    final updatedBoard = <CellState>[];

    for (int i = 0; i < 81; i++) {
      final cell = board[i];
      if (cell.value != null || cell.isFixed) {
        updatedBoard.add(cell);
      } else {
        final candidates = GameValidation.getCandidates(board, i);
        updatedBoard.add(cell.copyWith(notes: candidates));
      }
    }

    return updatedBoard;
  }

  /// Remove a number from candidates in affected cells after a placement
  static List<CellState> removeCandidateAfterPlacement(
    List<CellState> board,
    int placedIndex,
    int placedValue,
  ) {
    final row = placedIndex ~/ 9;
    final col = placedIndex % 9;
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;

    final affectedIndices = <int>{};

    // Row
    for (int c = 0; c < 9; c++) {
      affectedIndices.add(row * 9 + c);
    }

    // Column
    for (int r = 0; r < 9; r++) {
      affectedIndices.add(r * 9 + col);
    }

    // Box
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        affectedIndices.add(r * 9 + c);
      }
    }

    affectedIndices.remove(placedIndex);

    final updatedBoard = List<CellState>.from(board);
    for (final index in affectedIndices) {
      final cell = updatedBoard[index];
      if (cell.notes.contains(placedValue)) {
        final newNotes = Set<int>.from(cell.notes)..remove(placedValue);
        updatedBoard[index] = cell.copyWith(notes: newNotes);
      }
    }

    return updatedBoard;
  }
}
