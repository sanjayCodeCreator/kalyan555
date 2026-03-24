import '../data/models/game_state.dart';

/// Game logic utilities for win/draw detection
class GameLogic {
  /// All possible winning combinations
  static const List<List<int>> winningCombinations = [
    [0, 1, 2], // Top row
    [3, 4, 5], // Middle row
    [6, 7, 8], // Bottom row
    [0, 3, 6], // Left column
    [1, 4, 7], // Middle column
    [2, 5, 8], // Right column
    [0, 4, 8], // Diagonal top-left to bottom-right
    [2, 4, 6], // Diagonal top-right to bottom-left
  ];

  /// Check if there's a winner and return the winner
  static Player? checkWinner(List<Player> board) {
    for (final combo in winningCombinations) {
      final a = board[combo[0]];
      final b = board[combo[1]];
      final c = board[combo[2]];

      if (a != Player.none && a == b && b == c) {
        return a;
      }
    }
    return null;
  }

  /// Get the winning line positions (for highlighting)
  static List<int>? getWinningLine(List<Player> board) {
    for (final combo in winningCombinations) {
      final a = board[combo[0]];
      final b = board[combo[1]];
      final c = board[combo[2]];

      if (a != Player.none && a == b && b == c) {
        return combo;
      }
    }
    return null;
  }

  /// Check if the board is full (for draw detection)
  static bool isBoardFull(List<Player> board) {
    return !board.contains(Player.none);
  }

  /// Check if the game is over
  static bool isGameOver(List<Player> board) {
    return checkWinner(board) != null || isBoardFull(board);
  }

  /// Get current game status based on board state
  static GameStatus getGameStatus(List<Player> board) {
    final winner = checkWinner(board);
    if (winner == Player.x) return GameStatus.xWins;
    if (winner == Player.o) return GameStatus.oWins;
    if (isBoardFull(board)) return GameStatus.draw;
    return GameStatus.playing;
  }

  /// Get all available (empty) cell indices
  static List<int> getAvailableMoves(List<Player> board) {
    final moves = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == Player.none) {
        moves.add(i);
      }
    }
    return moves;
  }
}
