import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/game_state.dart';
import '../domain/puzzle_generator.dart';
import '../domain/puzzle_models.dart';
import '../domain/puzzle_validator.dart';
import 'stats_notifier.dart';

/// Provider for the Logic Grid Puzzle game notifier
final logicGridGameProvider =
    StateNotifierProvider<LogicGridGameNotifier, LogicGridGameState>((ref) {
  return LogicGridGameNotifier(ref);
});

/// State notifier for managing Logic Grid Puzzle game state
class LogicGridGameNotifier extends StateNotifier<LogicGridGameState> {
  final Ref _ref;

  LogicGridGameNotifier(this._ref) : super(LogicGridGameState.initial());

  /// Start a new game with the given difficulty
  void newGame(Difficulty difficulty) {
    final puzzle = PuzzleGenerator.generate(difficulty);
    final grid = _initializeGrid(puzzle);

    state = LogicGridGameState(
      puzzle: puzzle,
      difficulty: difficulty,
      grid: grid,
      hintsRemaining: difficulty.hintCount,
      status: GameStatus.playing,
    );
  }

  /// Initialize empty grid for puzzle
  Map<String, GridCell> _initializeGrid(Puzzle puzzle) {
    final grid = <String, GridCell>{};

    for (int cat1 = 0; cat1 < puzzle.categoryCount - 1; cat1++) {
      for (int cat2 = cat1 + 1; cat2 < puzzle.categoryCount; cat2++) {
        for (int row = 0; row < puzzle.gridSize; row++) {
          for (int col = 0; col < puzzle.gridSize; col++) {
            final key = '$cat1-$row-$cat2-$col';
            grid[key] = GridCell(
              rowCategory: cat1,
              rowItem: row,
              colCategory: cat2,
              colItem: col,
            );
          }
        }
      }
    }

    return grid;
  }

  /// Select a cell
  void selectCell(String cellKey) {
    if (!state.isPlaying) return;

    state = state.copyWith(
      selectedCell: state.selectedCell == cellKey ? null : cellKey,
      clearSelectedCell: state.selectedCell == cellKey,
    );
  }

  /// Clear selection
  void clearSelection() {
    state = state.copyWith(clearSelectedCell: true);
  }

  /// Cycle through marks: unknown -> yes -> no -> unknown
  void cycleMark() {
    if (!state.isPlaying || state.selectedCell == null) return;

    final cellKey = state.selectedCell!;
    final currentCell = state.grid[cellKey];
    if (currentCell == null) return;

    final CellMark newMark;
    switch (currentCell.mark) {
      case CellMark.unknown:
        newMark = CellMark.yes;
        break;
      case CellMark.yes:
        newMark = CellMark.no;
        break;
      case CellMark.no:
      case CellMark.note:
        newMark = CellMark.unknown;
        break;
    }

    _placeMark(cellKey, newMark);
  }

  /// Place a specific mark
  void placeMark(CellMark mark) {
    if (!state.isPlaying || state.selectedCell == null) return;
    _placeMark(state.selectedCell!, mark);
  }

  /// Internal method to place a mark with auto-elimination
  void _placeMark(String cellKey, CellMark newMark) {
    final currentCell = state.grid[cellKey];
    if (currentCell == null) return;

    final previousMark = currentCell.mark;
    if (previousMark == newMark) return;

    final newGrid = Map<String, GridCell>.from(state.grid);
    final autoEliminated = <String>[];

    // Update the target cell
    newGrid[cellKey] = currentCell.copyWith(mark: newMark);

    // Auto-eliminate if placing "yes"
    if (newMark == CellMark.yes && state.puzzle != null) {
      final toEliminate = PuzzleValidator.getCellsToEliminate(
        cellKey,
        state.grid,
        state.puzzle!,
      );

      for (final elimKey in toEliminate) {
        final elimCell = newGrid[elimKey];
        if (elimCell != null && elimCell.mark == CellMark.unknown) {
          newGrid[elimKey] = elimCell.copyWith(mark: CellMark.no);
          autoEliminated.add(elimKey);
        }
      }
    }

    // Create action for undo
    final action = GridAction(
      cellKey: cellKey,
      previousMark: previousMark,
      newMark: newMark,
      autoEliminatedCells: autoEliminated,
    );

    // Check for conflicts
    final conflicts = PuzzleValidator.findConflicts(newGrid, state.puzzle!);

    // Check for mistakes in strict mode
    int mistakes = state.mistakesCount;
    if (newMark == CellMark.yes && state.puzzle != null) {
      final parts = cellKey.split('-');
      if (parts.length == 4) {
        final isCorrect = state.puzzle!.solution.isMatch(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
          int.parse(parts[3]),
        );
        if (!isCorrect) {
          mistakes++;
        }
      }
    }

    state = state.copyWith(
      grid: newGrid,
      undoStack: [...state.undoStack, action],
      redoStack: [],
      conflictCells: conflicts.toSet(),
      mistakesCount: mistakes,
    );

    // Check for win
    _checkWinCondition();
  }

  /// Toggle note mode
  void toggleNoteMode() {
    state = state.copyWith(isNoteMode: !state.isNoteMode);
  }

  /// Undo last action
  void undo() {
    if (!state.isPlaying || state.undoStack.isEmpty) return;

    final action = state.undoStack.last;
    final newGrid = Map<String, GridCell>.from(state.grid);

    // Restore the main cell
    final cell = newGrid[action.cellKey];
    if (cell != null) {
      newGrid[action.cellKey] = cell.copyWith(mark: action.previousMark);
    }

    // Restore auto-eliminated cells
    if (action.autoEliminatedCells != null) {
      for (final elimKey in action.autoEliminatedCells!) {
        final elimCell = newGrid[elimKey];
        if (elimCell != null) {
          newGrid[elimKey] = elimCell.copyWith(mark: CellMark.unknown);
        }
      }
    }

    final conflicts = PuzzleValidator.findConflicts(newGrid, state.puzzle!);

    state = state.copyWith(
      grid: newGrid,
      undoStack: state.undoStack.sublist(0, state.undoStack.length - 1),
      redoStack: [...state.redoStack, action],
      conflictCells: conflicts.toSet(),
    );
  }

  /// Redo last undone action
  void redo() {
    if (!state.isPlaying || state.redoStack.isEmpty) return;

    final action = state.redoStack.last;
    final newGrid = Map<String, GridCell>.from(state.grid);

    // Reapply the action
    final cell = newGrid[action.cellKey];
    if (cell != null) {
      newGrid[action.cellKey] = cell.copyWith(mark: action.newMark);
    }

    // Reapply auto-eliminations
    if (action.autoEliminatedCells != null) {
      for (final elimKey in action.autoEliminatedCells!) {
        final elimCell = newGrid[elimKey];
        if (elimCell != null) {
          newGrid[elimKey] = elimCell.copyWith(mark: CellMark.no);
        }
      }
    }

    final conflicts = PuzzleValidator.findConflicts(newGrid, state.puzzle!);

    state = state.copyWith(
      grid: newGrid,
      undoStack: [...state.undoStack, action],
      redoStack: state.redoStack.sublist(0, state.redoStack.length - 1),
      conflictCells: conflicts.toSet(),
    );

    _checkWinCondition();
  }

  /// Use a hint
  void useHint() {
    if (!state.isPlaying || state.hintsRemaining <= 0 || state.puzzle == null) {
      return;
    }

    final hintCell = PuzzleValidator.getHint(state.grid, state.puzzle!);
    if (hintCell != null) {
      state = state.copyWith(
        selectedCell: hintCell,
        hintsRemaining: state.hintsRemaining - 1,
        hintsUsed: state.hintsUsed + 1,
      );

      // Auto-place the correct mark
      _placeMark(hintCell, CellMark.yes);
    }
  }

  /// Highlight clue and related cells
  void highlightClue(int clueId) {
    if (!state.isPlaying || state.puzzle == null) return;

    final clue = state.puzzle!.clues.firstWhere(
      (c) => c.id == clueId,
      orElse: () => state.puzzle!.clues.first,
    );

    if (state.highlightedClueId == clueId) {
      // Toggle off
      state = state.copyWith(
        clearHighlightedClue: true,
        highlightedCells: {},
      );
    } else {
      state = state.copyWith(
        highlightedClueId: clueId,
        highlightedCells: clue.relatedCells.toSet(),
      );
    }
  }

  /// Clear clue highlight
  void clearClueHighlight() {
    state = state.copyWith(
      clearHighlightedClue: true,
      highlightedCells: {},
    );
  }

  /// Pause game
  void pauseGame() {
    if (state.status != GameStatus.playing) return;
    state = state.copyWith(status: GameStatus.paused);
  }

  /// Resume game
  void resumeGame() {
    if (state.status != GameStatus.paused) return;
    state = state.copyWith(status: GameStatus.playing);
  }

  /// Update elapsed time
  void updateElapsedTime(int seconds) {
    if (!state.isPlaying) return;
    state = state.copyWith(elapsedSeconds: seconds);
  }

  /// Check win condition
  void _checkWinCondition() {
    if (state.puzzle == null) return;

    if (PuzzleValidator.isSolutionCorrect(state.grid, state.puzzle!)) {
      state = state.copyWith(status: GameStatus.won);
      _recordGameResult(won: true);
    }
  }

  /// Record game result to stats
  void _recordGameResult({required bool won}) {
    final statsNotifier = _ref.read(logicGridStatsProvider.notifier);
    statsNotifier.recordGame(
      difficulty: state.difficulty,
      won: won,
      timeSeconds: state.elapsedSeconds,
      hintsUsed: state.hintsUsed,
    );
  }

  /// Reset game
  void resetGame() {
    if (state.puzzle == null) return;

    final grid = _initializeGrid(state.puzzle!);
    state = state.copyWith(
      grid: grid,
      selectedCell: null,
      undoStack: [],
      redoStack: [],
      elapsedSeconds: 0,
      hintsRemaining: state.difficulty.hintCount,
      hintsUsed: 0,
      mistakesCount: 0,
      status: GameStatus.playing,
      conflictCells: {},
    );
  }
}
