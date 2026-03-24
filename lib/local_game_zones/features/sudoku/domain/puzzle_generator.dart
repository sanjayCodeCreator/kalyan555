import 'dart:math';

import '../data/models/cell_state.dart';
import '../data/models/game_state.dart';

/// Sudoku puzzle generator with unique solution guarantee
class PuzzleGenerator {
  static final _random = Random();

  /// Generate a new puzzle with the given difficulty
  static ({List<CellState> board, List<int> solution}) generate(
    Difficulty difficulty,
  ) {
    // Generate a complete valid Sudoku grid
    final solution = _generateCompleteSolution();

    // Create puzzle by removing cells based on difficulty
    final puzzle = _createPuzzle(solution, difficulty);

    return (board: puzzle, solution: solution);
  }

  /// Generate a complete valid Sudoku solution using backtracking
  static List<int> _generateCompleteSolution() {
    final board = List<int>.filled(81, 0);
    _fillBoard(board);
    return board;
  }

  /// Fill the board with valid numbers using backtracking
  static bool _fillBoard(List<int> board) {
    final emptyCell = _findEmptyCell(board);
    if (emptyCell == -1) {
      return true; // Board is complete
    }

    // Try numbers 1-9 in random order
    final numbers = List.generate(9, (i) => i + 1)..shuffle(_random);

    for (final num in numbers) {
      if (_isValidPlacement(board, emptyCell, num)) {
        board[emptyCell] = num;

        if (_fillBoard(board)) {
          return true;
        }

        board[emptyCell] = 0;
      }
    }

    return false;
  }

  /// Find the first empty cell in the board
  static int _findEmptyCell(List<int> board) {
    for (int i = 0; i < 81; i++) {
      if (board[i] == 0) return i;
    }
    return -1;
  }

  /// Check if placing a number at an index is valid
  static bool _isValidPlacement(List<int> board, int index, int num) {
    final row = index ~/ 9;
    final col = index % 9;

    // Check row
    for (int c = 0; c < 9; c++) {
      if (board[row * 9 + c] == num) return false;
    }

    // Check column
    for (int r = 0; r < 9; r++) {
      if (board[r * 9 + col] == num) return false;
    }

    // Check 3x3 box
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (board[r * 9 + c] == num) return false;
      }
    }

    return true;
  }

  /// Create a puzzle by removing cells from a complete solution
  static List<CellState> _createPuzzle(
      List<int> solution, Difficulty difficulty) {
    final puzzle = List<int>.from(solution);
    final cellsToRemove = 81 - difficulty.clueCount;

    // Create list of all cell indices and shuffle
    final indices = List.generate(81, (i) => i)..shuffle(_random);

    int removed = 0;
    for (final index in indices) {
      if (removed >= cellsToRemove) break;

      final backup = puzzle[index];
      puzzle[index] = 0;

      // Check if puzzle still has unique solution
      if (_hasUniqueSolution(puzzle)) {
        removed++;
      } else {
        // Restore cell if removing it creates multiple solutions
        puzzle[index] = backup;
      }
    }

    // Convert to CellState list
    return List.generate(81, (i) {
      if (puzzle[i] != 0) {
        return CellState.fixed(puzzle[i]);
      }
      return CellState.empty();
    });
  }

  /// Check if the puzzle has a unique solution
  static bool _hasUniqueSolution(List<int> puzzle) {
    int solutionCount = 0;
    final board = List<int>.from(puzzle);
    _countSolutions(board, () {
      solutionCount++;
    });
    return solutionCount == 1;
  }

  /// Count solutions (stops after finding 2)
  static bool _countSolutions(List<int> board, VoidCallback onSolutionFound) {
    final emptyCell = _findEmptyCell(board);
    if (emptyCell == -1) {
      onSolutionFound();
      return true;
    }

    int solutionsFound = 0;
    for (int num = 1; num <= 9; num++) {
      if (_isValidPlacement(board, emptyCell, num)) {
        board[emptyCell] = num;

        if (_countSolutions(board, () {
          solutionsFound++;
          onSolutionFound();
        })) {
          if (solutionsFound >= 2) {
            board[emptyCell] = 0;
            return true;
          }
        }

        board[emptyCell] = 0;
      }
    }

    return solutionsFound > 0;
  }
}

/// Callback type for void functions
typedef VoidCallback = void Function();
