import '../data/models/rps_choice.dart';

/// Core game logic for Rock Paper Scissors
class RPSGameLogic {
  /// Determine the result of a round
  /// Returns the result from the player's perspective
  static RPSResult determineWinner(RPSChoice player, RPSChoice opponent) {
    if (player == opponent) {
      return RPSResult.draw;
    }
    if (player.beats == opponent) {
      return RPSResult.win;
    }
    return RPSResult.lose;
  }

  /// Check if choice A beats choice B
  static bool beats(RPSChoice a, RPSChoice b) {
    return a.beats == b;
  }

  /// Get a description of why player won/lost
  static String getResultDescription(
    RPSChoice player,
    RPSChoice opponent,
    RPSResult result,
  ) {
    if (result == RPSResult.draw) {
      return 'Both chose ${player.displayName}!';
    }

    if (result == RPSResult.win) {
      return '${player.displayName} beats ${opponent.displayName}!';
    }

    return '${opponent.displayName} beats ${player.displayName}!';
  }
}
