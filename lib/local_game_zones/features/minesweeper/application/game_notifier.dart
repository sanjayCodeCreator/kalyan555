import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/cell_state.dart';
import '../data/models/game_state.dart';
import '../domain/game_validation.dart';
import '../domain/hint_logic.dart';
import '../domain/mine_generator.dart';
import 'stats_notifier.dart';
import 'timer_notifier.dart';

/// Provider for the Minesweeper game notifier
final minesweeperGameProvider =
    StateNotifierProvider<MinesweeperGameNotifier, MinesweeperGameState>((ref) {
  return MinesweeperGameNotifier(ref);
});

/// Main game state notifier for Minesweeper
class MinesweeperGameNotifier extends StateNotifier<MinesweeperGameState> {
  final Ref _ref;
  static const _saveKey = 'minesweeper_saved_game';

  MinesweeperGameNotifier(this._ref) : super(MinesweeperGameState.initial()) {
    _loadSavedGame();
  }

  /// Load saved game from SharedPreferences
  Future<void> _loadSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedGame = prefs.getString(_saveKey);

      if (savedGame != null && mounted) {
        final gameMap = jsonDecode(savedGame) as Map<String, dynamic>;
        final loadedState = MinesweeperGameState.fromJson(gameMap);

        // Only restore if game was in progress
        if (loadedState.status == GameStatus.playing ||
            loadedState.status == GameStatus.paused) {
          state = loadedState.copyWith(status: GameStatus.paused);
          _ref
              .read(minesweeperTimerProvider.notifier)
              .setTime(loadedState.elapsedSeconds);
        }
      }
    } catch (e) {
      // Keep initial state on error
    }
  }

  /// Save game to SharedPreferences
  Future<void> _saveGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentState = state.copyWith(
        elapsedSeconds: _ref.read(minesweeperTimerProvider),
      );
      await prefs.setString(_saveKey, jsonEncode(currentState.toJson()));
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Clear saved game
  Future<void> _clearSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_saveKey);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Start a new game
  void newGame({
    Difficulty? difficulty,
    int? customRows,
    int? customCols,
    int? customMines,
  }) {
    final diff = difficulty ?? state.difficulty;
    final rows = customRows ?? state.customRows;
    final cols = customCols ?? state.customCols;
    final mines = customMines ?? state.customMines;

    // Calculate actual grid dimensions
    final actualRows = diff == Difficulty.custom ? rows : diff.rows;
    final actualCols = diff == Difficulty.custom ? cols : diff.cols;

    // Create empty grid
    final grid = MineGenerator.createEmptyGrid(actualRows, actualCols);

    // Reset timer
    _ref.read(minesweeperTimerProvider.notifier).reset();

    state = MinesweeperGameState(
      grid: grid,
      difficulty: diff,
      customRows: rows,
      customCols: cols,
      customMines: mines,
      status: GameStatus.idle,
      flagsPlaced: 0,
      elapsedSeconds: 0,
      flagMode: false,
      hintsRemaining:
          diff == Difficulty.custom ? 5 : 3, // Unlimited hints for custom
      highlightedHintCell: null,
      isFirstMove: true,
      soundEnabled: state.soundEnabled,
      hapticEnabled: state.hapticEnabled,
    );

    _clearSavedGame();
  }

  /// Handle cell tap
  void onCellTap(int index) {
    if (state.status == GameStatus.won ||
        state.status == GameStatus.lost ||
        state.status == GameStatus.paused) {
      return;
    }

    final cell = state.grid[index];

    // If flag mode or cell is flagged/question mark, toggle flag
    if (state.flagMode) {
      toggleFlag(index);
      return;
    }

    // If cell is flagged, don't reveal
    if (cell.isFlagged || cell.isQuestionMark) {
      return;
    }

    // If revealed cell with number, try chord reveal
    if (cell.isRevealed && cell.adjacentMines > 0) {
      _chordReveal(index);
      return;
    }

    // Reveal the cell
    _revealCell(index);
  }

  /// Handle cell long press (flag toggle)
  void onCellLongPress(int index) {
    if (state.status == GameStatus.won ||
        state.status == GameStatus.lost ||
        state.status == GameStatus.paused) {
      return;
    }

    toggleFlag(index);

    // Haptic feedback
    if (state.hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Reveal a cell
  void _revealCell(int index) {
    var grid = List<CellData>.from(state.grid);

    // First move - generate mines
    if (state.isFirstMove) {
      grid = MineGenerator.generateMines(
        rows: state.rows,
        cols: state.cols,
        mineCount: state.totalMines,
        firstTapIndex: index,
      );

      // Start timer
      _ref.read(minesweeperTimerProvider.notifier).start();

      state = state.copyWith(
        grid: grid,
        status: GameStatus.playing,
        isFirstMove: false,
        gameStartTime: DateTime.now(),
        clearHighlightedHint: true,
      );
    }

    // Reveal the cell
    final result = GameValidation.revealCell(
      state.grid,
      index,
      state.rows,
      state.cols,
    );

    // Check for mine hit
    if (result.hitMine) {
      _gameOver(false);
      return;
    }

    // Update state
    state = state.copyWith(
      grid: result.grid,
      clearHighlightedHint: true,
    );

    // Check win condition
    if (GameValidation.checkWinCondition(state.grid)) {
      _gameOver(true);
    } else {
      // Auto-save
      _saveGame();
    }
  }

  /// Chord reveal (double-tap on revealed number)
  void _chordReveal(int index) {
    final result = GameValidation.chordReveal(
      state.grid,
      index,
      state.rows,
      state.cols,
    );

    if (result.revealedIndices.isEmpty) return;

    if (result.hitMine) {
      _gameOver(false);
      return;
    }

    state = state.copyWith(grid: result.grid);

    if (GameValidation.checkWinCondition(state.grid)) {
      _gameOver(true);
    } else {
      _saveGame();
    }
  }

  /// Toggle flag on a cell
  void toggleFlag(int index) {
    if (state.status != GameStatus.playing && state.status != GameStatus.idle) {
      return;
    }

    final cell = state.grid[index];
    if (cell.isRevealed) return;

    // Start game if first action is flagging
    if (state.status == GameStatus.idle) {
      state = state.copyWith(status: GameStatus.playing);
      _ref.read(minesweeperTimerProvider.notifier).start();
    }

    final updatedCell = GameValidation.toggleFlag(cell, useQuestionMark: true);
    final updatedGrid = List<CellData>.from(state.grid);
    updatedGrid[index] = updatedCell;

    // Update flag count
    int flagsChange = 0;
    if (cell.isHidden && updatedCell.isFlagged) {
      flagsChange = 1;
    } else if (cell.isFlagged && !updatedCell.isFlagged) {
      flagsChange = -1;
    }

    state = state.copyWith(
      grid: updatedGrid,
      flagsPlaced: state.flagsPlaced + flagsChange,
      clearHighlightedHint: true,
    );

    _saveGame();
  }

  /// Toggle flag mode
  void toggleFlagMode() {
    state = state.copyWith(flagMode: !state.flagMode);
  }

  /// Use a hint
  void useHint() {
    if (state.hintsRemaining <= 0 || state.status != GameStatus.playing) {
      return;
    }

    final hint = HintLogic.analyzeBoard(state.grid, state.rows, state.cols);

    if (hint.cellIndex != null) {
      state = state.copyWith(
        highlightedHintCell: hint.cellIndex,
        hintsRemaining: state.hintsRemaining - 1,
      );

      // Haptic feedback
      if (state.hapticEnabled) {
        HapticFeedback.lightImpact();
      }
    }
  }

  /// Clear hint highlight
  void clearHintHighlight() {
    state = state.copyWith(clearHighlightedHint: true);
  }

  /// Pause the game
  void pauseGame() {
    if (state.status != GameStatus.playing) return;

    _ref.read(minesweeperTimerProvider.notifier).pause();
    state = state.copyWith(
      status: GameStatus.paused,
      elapsedSeconds: _ref.read(minesweeperTimerProvider),
    );
    _saveGame();
  }

  /// Resume the game
  void resumeGame() {
    if (state.status != GameStatus.paused) return;

    _ref.read(minesweeperTimerProvider.notifier).resume();
    state = state.copyWith(status: GameStatus.playing);
  }

  /// Handle game over
  void _gameOver(bool won) {
    _ref.read(minesweeperTimerProvider.notifier).stop();

    final time = _ref.read(minesweeperTimerProvider);
    final wrongFlags = GameValidation.countWrongFlags(state.grid);
    final usedFlags = state.flagsPlaced > 0;

    // Record stats
    _ref.read(minesweeperStatsProvider.notifier).recordGame(
          won: won,
          difficulty: state.difficulty,
          time: time,
          usedFlags: usedFlags,
          wrongFlags: wrongFlags,
        );

    // Reveal all mines if lost
    var finalGrid = state.grid;
    if (!won) {
      finalGrid = state.grid.map((cell) {
        if (cell.hasMine) {
          return cell.copyWith(state: CellState.revealed);
        }
        return cell;
      }).toList();
    } else {
      // Flag all mines on win
      finalGrid = state.grid.map((cell) {
        if (cell.hasMine && !cell.isFlagged) {
          return cell.copyWith(state: CellState.flagged);
        }
        return cell;
      }).toList();
    }

    state = state.copyWith(
      grid: finalGrid,
      status: won ? GameStatus.won : GameStatus.lost,
      elapsedSeconds: time,
    );

    // Clear saved game
    _clearSavedGame();

    // Haptic feedback
    if (state.hapticEnabled) {
      if (won) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.vibrate();
      }
    }
  }

  /// Toggle sound
  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
  }

  /// Toggle haptic
  void toggleHaptic() {
    state = state.copyWith(hapticEnabled: !state.hapticEnabled);
  }

  /// Check if there's a saved game
  Future<bool> hasSavedGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_saveKey);
    } catch (e) {
      return false;
    }
  }
}
