/// Game state management with Riverpod for Matchstick Puzzle

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/game_state.dart';
import '../data/models/stats_model.dart';
import '../domain/matchstick_models.dart';
import '../domain/matchstick_validator.dart';
import '../domain/puzzle_data.dart';
import 'stats_notifier.dart';

/// Provider for the game notifier
final matchstickGameProvider =
    StateNotifierProvider<MatchstickGameNotifier, MatchstickGameState>((ref) {
  return MatchstickGameNotifier(ref);
});

/// State notifier for managing Matchstick Puzzle game
class MatchstickGameNotifier extends StateNotifier<MatchstickGameState> {
  final Ref _ref;
  Timer? _autoSaveTimer;

  MatchstickGameNotifier(this._ref) : super(MatchstickGameState.initial) {
    _loadSavedGame();
  }

  /// Load any saved game on startup
  Future<void> _loadSavedGame() async {
    final savedGame = await MatchstickStatsRepository.loadSavedGame();
    if (savedGame != null) {
      final puzzleId = savedGame['puzzleId'] as int?;
      if (puzzleId != null) {
        final puzzle = PuzzleData.getPuzzleById(puzzleId);
        if (puzzle != null) {
          // Restore saved positions
          final positions = savedGame['matchstickPositions'] as List<dynamic>?;
          List<Matchstick> restoredSticks;

          if (positions != null && positions.isNotEmpty) {
            restoredSticks = puzzle.initialMatchsticks.map((stick) {
              final saved = positions.firstWhere(
                (p) => p['id'] == stick.id,
                orElse: () => null,
              );
              if (saved != null) {
                return stick.copyWith(
                  x: (saved['x'] as num).toDouble(),
                  y: (saved['y'] as num).toDouble(),
                  angle: (saved['angle'] as num).toDouble(),
                );
              }
              return stick;
            }).toList();
          } else {
            restoredSticks = List.from(puzzle.initialMatchsticks);
          }

          state = state.copyWith(
            currentPuzzle: puzzle,
            matchsticks: restoredSticks,
            moveCount: savedGame['moveCount'] as int? ?? 0,
            hintsUsed: savedGame['hintsUsed'] as int? ?? 0,
            hintsRemaining: savedGame['hintsRemaining'] as int? ?? 3,
            elapsedSeconds: savedGame['elapsedSeconds'] as int? ?? 0,
            status: GameStatus.paused,
          );
        }
      }
    }
  }

  /// Start a new puzzle
  void startPuzzle(int puzzleId) {
    final puzzle = PuzzleData.getPuzzleById(puzzleId);
    if (puzzle == null) {
      state = state.copyWith(
        errorMessage: 'Puzzle not found',
        status: GameStatus.initial,
      );
      return;
    }

    // Clear any saved game
    MatchstickStatsRepository.clearSavedGame();

    state = MatchstickGameState(
      currentPuzzle: puzzle,
      matchsticks: List.from(puzzle.initialMatchsticks),
      status: GameStatus.playing,
      hintsRemaining: 3,
    );

    // Update stats
    _ref.read(matchstickStatsProvider.notifier).recordAttempt(puzzleId);

    // Start auto-save
    _startAutoSave();
  }

  /// Resume paused game
  void resumeGame() {
    if (state.status == GameStatus.paused) {
      state = state.copyWith(status: GameStatus.playing);
      _startAutoSave();
    }
  }

  /// Pause game
  void pauseGame() {
    if (state.status == GameStatus.playing) {
      state = state.copyWith(status: GameStatus.paused);
      _saveCurrentGame();
      _autoSaveTimer?.cancel();
    }
  }

  /// Select a matchstick for interaction
  void selectMatchstick(int matchstickId) {
    final matchstick = state.matchsticks.firstWhere(
      (m) => m.id == matchstickId,
      orElse: () => state.matchsticks.first,
    );

    if (!matchstick.isMovable) {
      state = state.copyWith(
        errorMessage: 'This matchstick cannot be moved',
        highlightedMatchstickIds: {matchstickId},
      );
      // Clear error after delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          state =
              state.copyWith(clearError: true, highlightedMatchstickIds: {});
        }
      });
      return;
    }

    final updatedStick = matchstick.copyWith(state: MatchstickState.selected);
    final updatedSticks = state.matchsticks.map((m) {
      if (m.id == matchstickId) return updatedStick;
      return m.copyWith(state: MatchstickState.idle);
    }).toList();

    state = state.copyWith(
      matchsticks: updatedSticks,
      selectedMatchstick: updatedStick,
      clearError: true,
    );
  }

  /// Start dragging a matchstick
  void startDrag(int matchstickId) {
    if (state.status != GameStatus.playing) return;

    final matchstick = state.matchsticks.firstWhere(
      (m) => m.id == matchstickId,
      orElse: () => state.matchsticks.first,
    );

    if (!matchstick.isMovable) return;

    final updatedStick = matchstick.copyWith(state: MatchstickState.dragging);
    final updatedSticks = state.matchsticks.map((m) {
      if (m.id == matchstickId) return updatedStick;
      return m;
    }).toList();

    state = state.copyWith(
      matchsticks: updatedSticks,
      draggingMatchstick: updatedStick,
    );
  }

  /// Update position during drag
  void updateDragPosition(int matchstickId, double x, double y) {
    if (state.draggingMatchstick?.id != matchstickId) return;

    final updatedSticks = state.matchsticks.map((m) {
      if (m.id == matchstickId) {
        return m.copyWith(x: x, y: y);
      }
      return m;
    }).toList();

    final updatedDragging = state.draggingMatchstick?.copyWith(x: x, y: y);

    state = state.copyWith(
      matchsticks: updatedSticks,
      draggingMatchstick: updatedDragging,
    );
  }

  /// End drag and place matchstick
  void endDrag(int matchstickId, double x, double y) {
    if (state.currentPuzzle == null) return;

    final matchstick = state.matchsticks.firstWhere(
      (m) => m.id == matchstickId,
      orElse: () => state.matchsticks.first,
    );

    // Record move for undo
    final moveRecord = MoveRecord(
      matchstickId: matchstickId,
      fromX: matchstick.x,
      fromY: matchstick.y,
      fromAngle: matchstick.angle,
      toX: x,
      toY: y,
      toAngle: matchstick.angle,
      timestamp: DateTime.now(),
    );

    // Snap to grid
    final tempStick = matchstick.copyWith(x: x, y: y);
    final snappedStick = MatchstickValidator.snapToGrid(
      tempStick,
      state.currentPuzzle!.gridSlots,
    );

    // Validate placement
    final validation = MatchstickValidator.validatePlacement(
      snappedStick,
      state.currentPuzzle!.gridSlots,
      state.matchsticks.where((m) => m.id != matchstickId).toList(),
    );

    if (!validation.isValid) {
      // Invalid placement - return to original position
      state = state.copyWith(
        errorMessage: validation.message,
        highlightedMatchstickIds:
            validation.invalidMatchstickIds?.toSet() ?? {},
        clearDraggingMatchstick: true,
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          state =
              state.copyWith(clearError: true, highlightedMatchstickIds: {});
        }
      });
      return;
    }

    // Check if position actually changed
    final positionChanged = (snappedStick.x - matchstick.x).abs() > 5 ||
        (snappedStick.y - matchstick.y).abs() > 5 ||
        (snappedStick.angle - matchstick.angle).abs() > 1;

    final updatedSticks = state.matchsticks.map((m) {
      if (m.id == matchstickId) return snappedStick;
      return m;
    }).toList();

    final newUndoStack =
        positionChanged ? [...state.undoStack, moveRecord] : state.undoStack;

    state = state.copyWith(
      matchsticks: updatedSticks,
      moveCount: positionChanged ? state.moveCount + 1 : state.moveCount,
      undoStack: newUndoStack,
      redoStack:
          positionChanged ? [] : state.redoStack, // Clear redo on new move
      clearDraggingMatchstick: true,
      clearSelectedMatchstick: true,
    );

    // Check for solution
    _checkSolution();
  }

  /// Rotate the selected matchstick
  void rotateMatchstick(int matchstickId) {
    if (state.status != GameStatus.playing) return;

    final matchstick = state.matchsticks.firstWhere(
      (m) => m.id == matchstickId,
      orElse: () => state.matchsticks.first,
    );

    if (!matchstick.isMovable) return;

    final newAngle = matchstick.nextAngle;
    final rotatedStick = matchstick.copyWith(angle: newAngle);

    // Check if rotation is valid
    if (state.currentPuzzle != null) {
      final validation = MatchstickValidator.validatePlacement(
        rotatedStick,
        state.currentPuzzle!.gridSlots,
        state.matchsticks.where((m) => m.id != matchstickId).toList(),
      );

      if (!validation.isValid) {
        state = state.copyWith(errorMessage: 'Cannot rotate here');
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            state = state.copyWith(clearError: true);
          }
        });
        return;
      }
    }

    // Record move
    final moveRecord = MoveRecord(
      matchstickId: matchstickId,
      fromX: matchstick.x,
      fromY: matchstick.y,
      fromAngle: matchstick.angle,
      toX: matchstick.x,
      toY: matchstick.y,
      toAngle: newAngle,
      timestamp: DateTime.now(),
    );

    final updatedSticks = state.matchsticks.map((m) {
      if (m.id == matchstickId) return rotatedStick;
      return m;
    }).toList();

    state = state.copyWith(
      matchsticks: updatedSticks,
      moveCount: state.moveCount + 1,
      undoStack: [...state.undoStack, moveRecord],
      redoStack: [],
    );

    _checkSolution();
  }

  /// Use a hint
  void useHint() {
    if (!state.hasHints || state.currentPuzzle == null) return;

    // Find movable matchsticks
    final movableSticks = state.matchsticks.where((m) => m.isMovable).toList();
    if (movableSticks.isEmpty) return;

    // Highlight a random movable matchstick
    final hintStick = movableSticks.first;

    state = state.copyWith(
      hintsUsed: state.hintsUsed + 1,
      hintsRemaining: state.hintsRemaining - 1,
      highlightedMatchstickIds: {hintStick.id},
    );

    // Update stats
    _ref.read(matchstickStatsProvider.notifier).recordHintUsed();

    // Clear highlight after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        state = state.copyWith(highlightedMatchstickIds: {});
      }
    });
  }

  /// Undo last move
  void undo() {
    if (!state.canUndo) return;

    final lastMove = state.undoStack.last;
    final newUndoStack = List<MoveRecord>.from(state.undoStack)..removeLast();

    final updatedSticks = state.matchsticks.map((m) {
      if (m.id == lastMove.matchstickId) {
        return m.copyWith(
          x: lastMove.fromX,
          y: lastMove.fromY,
          angle: lastMove.fromAngle,
        );
      }
      return m;
    }).toList();

    state = state.copyWith(
      matchsticks: updatedSticks,
      moveCount: state.moveCount > 0 ? state.moveCount - 1 : 0,
      undoStack: newUndoStack,
      redoStack: [...state.redoStack, lastMove],
    );
  }

  /// Redo undone move
  void redo() {
    if (!state.canRedo) return;

    final redoMove = state.redoStack.last;
    final newRedoStack = List<MoveRecord>.from(state.redoStack)..removeLast();

    final updatedSticks = state.matchsticks.map((m) {
      if (m.id == redoMove.matchstickId) {
        return m.copyWith(
          x: redoMove.toX,
          y: redoMove.toY,
          angle: redoMove.toAngle,
        );
      }
      return m;
    }).toList();

    state = state.copyWith(
      matchsticks: updatedSticks,
      moveCount: state.moveCount + 1,
      undoStack: [...state.undoStack, redoMove],
      redoStack: newRedoStack,
    );
  }

  /// Reset puzzle to initial state
  void resetPuzzle() {
    if (state.currentPuzzle == null) return;

    state = state.copyWith(
      matchsticks: List.from(state.currentPuzzle!.initialMatchsticks),
      moveCount: 0,
      undoStack: [],
      redoStack: [],
      status: GameStatus.playing,
      clearSelectedMatchstick: true,
      clearDraggingMatchstick: true,
      clearError: true,
    );
  }

  /// Update elapsed time
  void updateTime(int seconds) {
    state = state.copyWith(elapsedSeconds: seconds);
  }

  /// Check if current configuration solves the puzzle
  void _checkSolution() {
    if (state.currentPuzzle == null) return;

    final isSolved = MatchstickValidator.checkSolution(
      state.matchsticks,
      state.currentPuzzle!.solution,
    );

    if (isSolved) {
      final stars = state.currentPuzzle!.getStars(
        state.moveCount,
        state.hintsUsed,
      );

      state = state.copyWith(
        status: GameStatus.completed,
        starsEarned: stars,
      );

      // Record completion
      _ref.read(matchstickStatsProvider.notifier).recordCompletion(
            puzzleId: state.currentPuzzle!.id,
            moves: state.moveCount,
            hints: state.hintsUsed,
            time: state.elapsedSeconds,
            stars: stars,
          );

      // Clear saved game
      MatchstickStatsRepository.clearSavedGame();
      _autoSaveTimer?.cancel();
    }
  }

  /// Start auto-save timer
  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _saveCurrentGame(),
    );
  }

  /// Save current game state
  void _saveCurrentGame() {
    if (state.currentPuzzle == null) return;
    if (state.status != GameStatus.playing &&
        state.status != GameStatus.paused) {
      return;
    }

    final gameData = {
      'puzzleId': state.currentPuzzle!.id,
      'matchstickPositions': state.matchsticks
          .map((m) => {
                'id': m.id,
                'x': m.x,
                'y': m.y,
                'angle': m.angle,
              })
          .toList(),
      'moveCount': state.moveCount,
      'hintsUsed': state.hintsUsed,
      'hintsRemaining': state.hintsRemaining,
      'elapsedSeconds': state.elapsedSeconds,
      'savedAt': DateTime.now().toIso8601String(),
    };

    MatchstickStatsRepository.saveGame(gameData);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _saveCurrentGame();
    super.dispose();
  }
}
