import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/game_state.dart';
import '../domain/ai_logic.dart';
import '../domain/game_logic.dart';

/// Provider for the game notifier
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});

/// State notifier for managing game state
class GameNotifier extends StateNotifier<GameState> {
  GameNotifier() : super(GameState.initial());

  /// Make a move at the given index
  void makeMove(int index) {
    // Ignore if game is over or cell is occupied
    if (state.status.isGameOver || state.board[index] != Player.none) {
      return;
    }

    // Ignore if it's AI's turn
    if (state.isAiTurn) {
      return;
    }

    _executeMoveAt(index);
  }

  /// Execute move at position (internal use for both player and AI)
  void _executeMoveAt(int index) {
    final newBoard = List<Player>.from(state.board);
    newBoard[index] = state.currentPlayer;

    final newMoveHistory = [...state.moveHistory, index];
    final status = GameLogic.getGameStatus(newBoard);
    final winningLine = GameLogic.getWinningLine(newBoard);

    state = state.copyWith(
      board: newBoard,
      currentPlayer: state.currentPlayer.opponent,
      status: status,
      winningLine: winningLine,
      moveHistory: newMoveHistory,
    );

    // Trigger AI move if applicable
    if (state.isAiTurn) {
      _scheduleAiMove();
    }
  }

  /// Schedule AI move with a small delay for better UX
  void _scheduleAiMove() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!state.isAiTurn) return; // Game might have been reset

      final aiPlayer = state.humanSymbol.opponent;
      final moveIndex = AiLogic.getMove(state.board, state.mode, aiPlayer);

      if (moveIndex >= 0) {
        _executeMoveAt(moveIndex);
      }
    });
  }

  /// Reset the game to initial state
  void resetGame() {
    final newState = GameState.initial().copyWith(
      mode: state.mode,
      humanSymbol: state.humanSymbol,
    );
    state = newState;

    // If AI goes first, trigger AI move
    if (state.isAiTurn) {
      _scheduleAiMove();
    }
  }

  /// Set game mode
  void setGameMode(GameMode mode) {
    state = GameState.initial().copyWith(mode: mode);

    // If AI goes first, trigger AI move
    if (state.isAiTurn) {
      _scheduleAiMove();
    }
  }

  /// Set human player symbol (X or O)
  void setHumanSymbol(Player symbol) {
    if (symbol == Player.none) return;

    state = GameState.initial().copyWith(mode: state.mode, humanSymbol: symbol);

    // If AI goes first (human is O), trigger AI move
    if (state.isAiTurn) {
      _scheduleAiMove();
    }
  }

  /// Undo the last move
  void undoMove() {
    if (state.moveHistory.isEmpty) return;
    if (state.mode != GameMode.twoPlayer) {
      // In AI mode, undo both AI and player moves
      if (state.moveHistory.length < 2) return;

      final newBoard = List<Player>.from(state.board);
      final newHistory = List<int>.from(state.moveHistory);

      // Undo AI move
      newBoard[newHistory.removeLast()] = Player.none;
      // Undo player move
      newBoard[newHistory.removeLast()] = Player.none;

      state = state.copyWith(
        board: newBoard,
        currentPlayer: state.humanSymbol,
        status: GameStatus.playing,
        moveHistory: newHistory,
      );
    } else {
      // In two player mode, undo single move
      final newBoard = List<Player>.from(state.board);
      final newHistory = List<int>.from(state.moveHistory);

      final lastMove = newHistory.removeLast();
      newBoard[lastMove] = Player.none;

      state = state.copyWith(
        board: newBoard,
        currentPlayer: state.currentPlayer.opponent,
        status: GameStatus.playing,
        moveHistory: newHistory,
      );
    }
  }
}
