import 'dart:math';

import '../data/models/game_state.dart';
import 'game_logic.dart';

/// AI logic for computer player with different difficulty levels
class AiLogic {
  static final _random = Random();

  /// Easy AI: Makes completely random moves
  static int easyMove(List<Player> board) {
    final available = GameLogic.getAvailableMoves(board);
    if (available.isEmpty) return -1;
    return available[_random.nextInt(available.length)];
  }

  /// Medium AI: Blocks winning moves and tries to win, otherwise random
  static int mediumMove(List<Player> board, Player aiPlayer) {
    final available = GameLogic.getAvailableMoves(board);
    if (available.isEmpty) return -1;

    // First, try to win
    for (final move in available) {
      final testBoard = List<Player>.from(board);
      testBoard[move] = aiPlayer;
      if (GameLogic.checkWinner(testBoard) == aiPlayer) {
        return move;
      }
    }

    // Second, block opponent's winning move
    final opponent = aiPlayer.opponent;
    for (final move in available) {
      final testBoard = List<Player>.from(board);
      testBoard[move] = opponent;
      if (GameLogic.checkWinner(testBoard) == opponent) {
        return move;
      }
    }

    // Take center if available
    if (board[4] == Player.none) {
      return 4;
    }

    // Otherwise, random move
    return available[_random.nextInt(available.length)];
  }

  /// Hard AI: Uses Minimax algorithm - unbeatable
  static int hardMove(List<Player> board, Player aiPlayer) {
    final available = GameLogic.getAvailableMoves(board);
    if (available.isEmpty) return -1;

    int bestScore = -1000;
    int bestMove = available.first;

    for (final move in available) {
      final testBoard = List<Player>.from(board);
      testBoard[move] = aiPlayer;
      final score = _minimax(testBoard, 0, false, aiPlayer);
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  /// Minimax algorithm for optimal move calculation
  static int _minimax(
    List<Player> board,
    int depth,
    bool isMaximizing,
    Player aiPlayer,
  ) {
    final winner = GameLogic.checkWinner(board);

    // Terminal states
    if (winner == aiPlayer) return 10 - depth;
    if (winner == aiPlayer.opponent) return depth - 10;
    if (GameLogic.isBoardFull(board)) return 0;

    final available = GameLogic.getAvailableMoves(board);

    if (isMaximizing) {
      int bestScore = -1000;
      for (final move in available) {
        final testBoard = List<Player>.from(board);
        testBoard[move] = aiPlayer;
        final score = _minimax(testBoard, depth + 1, false, aiPlayer);
        bestScore = max(bestScore, score);
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (final move in available) {
        final testBoard = List<Player>.from(board);
        testBoard[move] = aiPlayer.opponent;
        final score = _minimax(testBoard, depth + 1, true, aiPlayer);
        bestScore = min(bestScore, score);
      }
      return bestScore;
    }
  }

  /// Get AI move based on difficulty
  static int getMove(List<Player> board, GameMode mode, Player aiPlayer) {
    switch (mode) {
      case GameMode.vsAiEasy:
        return easyMove(board);
      case GameMode.vsAiMedium:
        return mediumMove(board, aiPlayer);
      case GameMode.vsAiHard:
        return hardMove(board, aiPlayer);
      default:
        return -1;
    }
  }
}
