import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/cell_state.dart';
import '../data/models/game_state.dart';
import '../domain/game_validation.dart';
import '../domain/hint_logic.dart';
import '../domain/puzzle_generator.dart';
import 'stats_notifier.dart';
import 'timer_notifier.dart';

/// Provider for the Sudoku game notifier
final sudokuGameProvider =
    StateNotifierProvider<SudokuGameNotifier, SudokuGameState>((ref) {
  return SudokuGameNotifier(ref);
});

/// State notifier for managing Sudoku game state
class SudokuGameNotifier extends StateNotifier<SudokuGameState> {
  final Ref _ref;

  SudokuGameNotifier(this._ref) : super(SudokuGameState.initial());

  /// Start a new game with the given difficulty
  void newGame(Difficulty difficulty) {
    // Generate puzzle
    final result = PuzzleGenerator.generate(difficulty);

    state = SudokuGameState(
      board: result.board,
      solution: result.solution,
      difficulty: difficulty,
      status: GameStatus.playing,
      mistakes: 0,
      hintsRemaining: 3,
      hintsUsed: 0,
      elapsedSeconds: 0,
      isNoteMode: false,
      undoStack: const [],
      redoStack: const [],
    );

    // Start the timer
    _ref.read(timerProvider.notifier).reset();
    _ref.read(timerProvider.notifier).start();
  }

  /// Select a cell at the given index
  void selectCell(int index) {
    if (state.status != GameStatus.playing) return;

    state = state.copyWith(selectedIndex: index);
  }

  /// Clear selection
  void clearSelection() {
    state = state.copyWith(clearSelection: true);
  }

  /// Place a number in the selected cell
  void placeNumber(int number) {
    if (state.selectedIndex == null) return;
    if (state.status != GameStatus.playing) return;

    final index = state.selectedIndex!;
    final cell = state.board[index];

    // Can't modify fixed cells
    if (cell.isFixed) return;

    // If in note mode, toggle the note
    if (state.isNoteMode) {
      _toggleNote(index, number);
      return;
    }

    // Record for undo
    final previousState = cell;
    final newCell = CellState.user(number);

    // Create new board
    final newBoard = List<CellState>.from(state.board);
    newBoard[index] = newCell;

    // Check if the placement is correct
    final isCorrect = number == state.solution[index];

    var newMistakes = state.mistakes;
    if (!isCorrect) {
      newMistakes++;
      newBoard[index] = newCell.copyWith(isError: true);
    }

    // Update error states
    final updatedBoard = GameValidation.updateErrorStates(newBoard);

    // Update undo stack
    final newUndoStack = [
      ...state.undoStack,
      MoveRecord(
        index: index,
        previousState: previousState,
        newState: updatedBoard[index],
      ),
    ];

    // Check for win or loss
    var newStatus = state.status;
    if (newMistakes >= state.maxMistakes) {
      newStatus = GameStatus.lost;
      _ref.read(timerProvider.notifier).pause();
      _recordGameResult(false);
    } else if (GameValidation.isPuzzleComplete(updatedBoard)) {
      newStatus = GameStatus.won;
      _ref.read(timerProvider.notifier).pause();
      _recordGameResult(true);
    }

    state = state.copyWith(
      board: updatedBoard,
      mistakes: newMistakes,
      status: newStatus,
      undoStack: newUndoStack,
      redoStack: const [], // Clear redo stack on new move
    );
  }

  /// Toggle a note in a cell
  void _toggleNote(int index, int number) {
    final cell = state.board[index];

    // Can't add notes to cells with values
    if (cell.value != null) return;

    final newNotes = Set<int>.from(cell.notes);
    if (newNotes.contains(number)) {
      newNotes.remove(number);
    } else {
      newNotes.add(number);
    }

    final newCell = cell.copyWith(notes: newNotes);

    // Record for undo
    final previousState = cell;

    final newBoard = List<CellState>.from(state.board);
    newBoard[index] = newCell;

    final newUndoStack = [
      ...state.undoStack,
      MoveRecord(
        index: index,
        previousState: previousState,
        newState: newCell,
      ),
    ];

    state = state.copyWith(
      board: newBoard,
      undoStack: newUndoStack,
      redoStack: const [],
    );
  }

  /// Clear the selected cell
  void clearCell() {
    if (state.selectedIndex == null) return;
    if (state.status != GameStatus.playing) return;

    final index = state.selectedIndex!;
    final cell = state.board[index];

    // Can't clear fixed cells
    if (cell.isFixed) return;

    // Nothing to clear
    if (cell.value == null && cell.notes.isEmpty) return;

    final previousState = cell;
    final newCell = CellState.empty();

    final newBoard = List<CellState>.from(state.board);
    newBoard[index] = newCell;

    // Update error states
    final updatedBoard = GameValidation.updateErrorStates(newBoard);

    final newUndoStack = [
      ...state.undoStack,
      MoveRecord(
        index: index,
        previousState: previousState,
        newState: updatedBoard[index],
      ),
    ];

    state = state.copyWith(
      board: updatedBoard,
      undoStack: newUndoStack,
      redoStack: const [],
    );
  }

  /// Toggle note mode
  void toggleNoteMode() {
    state = state.copyWith(isNoteMode: !state.isNoteMode);
  }

  /// Use a hint
  void useHint() {
    if (state.hintsRemaining <= 0) return;
    if (state.status != GameStatus.playing) return;

    // Find best cell for hint
    final hint = HintLogic.getSmartHint(state.board, state.solution);
    if (hint == null) return;

    // Select the cell
    state = state.copyWith(selectedIndex: hint.index);

    // Record for undo
    final previousState = state.board[hint.index];
    final newCell = CellState.user(hint.value);

    final newBoard = List<CellState>.from(state.board);
    newBoard[hint.index] = newCell;

    // Update error states
    final updatedBoard = GameValidation.updateErrorStates(newBoard);

    final newUndoStack = [
      ...state.undoStack,
      MoveRecord(
        index: hint.index,
        previousState: previousState,
        newState: updatedBoard[hint.index],
      ),
    ];

    // Check for win
    var newStatus = state.status;
    if (GameValidation.isPuzzleComplete(updatedBoard)) {
      newStatus = GameStatus.won;
      _ref.read(timerProvider.notifier).pause();
      _recordGameResult(true);
    }

    state = state.copyWith(
      board: updatedBoard,
      hintsRemaining: state.hintsRemaining - 1,
      hintsUsed: state.hintsUsed + 1,
      status: newStatus,
      undoStack: newUndoStack,
      redoStack: const [],
    );
  }

  /// Undo the last move
  void undo() {
    if (state.undoStack.isEmpty) return;
    if (state.status != GameStatus.playing) return;

    final move = state.undoStack.last;
    final newUndoStack = List<MoveRecord>.from(state.undoStack)..removeLast();
    final newRedoStack = [...state.redoStack, move];

    final newBoard = List<CellState>.from(state.board);
    newBoard[move.index] = move.previousState;

    // Update error states
    final updatedBoard = GameValidation.updateErrorStates(newBoard);

    state = state.copyWith(
      board: updatedBoard,
      selectedIndex: move.index,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );
  }

  /// Redo a previously undone move
  void redo() {
    if (state.redoStack.isEmpty) return;
    if (state.status != GameStatus.playing) return;

    final move = state.redoStack.last;
    final newRedoStack = List<MoveRecord>.from(state.redoStack)..removeLast();
    final newUndoStack = [...state.undoStack, move];

    final newBoard = List<CellState>.from(state.board);
    newBoard[move.index] = move.newState;

    // Update error states
    final updatedBoard = GameValidation.updateErrorStates(newBoard);

    state = state.copyWith(
      board: updatedBoard,
      selectedIndex: move.index,
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );
  }

  /// Pause the game
  void pauseGame() {
    if (state.status != GameStatus.playing) return;

    _ref.read(timerProvider.notifier).pause();
    state = state.copyWith(
      status: GameStatus.paused,
      elapsedSeconds: _ref.read(timerProvider),
    );
  }

  /// Resume the game
  void resumeGame() {
    if (state.status != GameStatus.paused) return;

    _ref.read(timerProvider.notifier).resume();
    state = state.copyWith(status: GameStatus.playing);
  }

  /// Auto-fill all candidates
  void autoFillCandidates() {
    if (state.status != GameStatus.playing) return;

    final updatedBoard = HintLogic.autoFillCandidates(state.board);
    state = state.copyWith(board: updatedBoard);
  }

  /// Update elapsed time from timer
  void updateElapsedTime(int seconds) {
    state = state.copyWith(elapsedSeconds: seconds);
  }

  /// Record game result to stats
  void _recordGameResult(bool won) {
    _ref.read(sudokuStatsProvider.notifier).recordGame(
          won: won,
          difficulty: state.difficulty,
          timeSeconds: _ref.read(timerProvider),
          hintsUsed: state.hintsUsed,
          mistakes: state.mistakes,
        );
  }
}
