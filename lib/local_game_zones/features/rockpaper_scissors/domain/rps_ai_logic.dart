import 'dart:math';

import '../data/models/rps_choice.dart';

/// AI logic for Rock Paper Scissors with different difficulty levels
class RPSAILogic {
  static final Random _random = Random();

  /// Get AI choice based on difficulty level
  static RPSChoice getChoice(
    AIDifficulty difficulty,
    List<RPSChoice> playerHistory,
  ) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return getRandomChoice();
      case AIDifficulty.medium:
        return getMediumChoice(playerHistory);
      case AIDifficulty.hard:
        return getHardChoice(playerHistory);
    }
  }

  /// Easy: Pure random selection
  static RPSChoice getRandomChoice() {
    return RPSChoice.values[_random.nextInt(3)];
  }

  /// Medium: 50% random, 50% counter based on last move
  static RPSChoice getMediumChoice(List<RPSChoice> playerHistory) {
    // If no history or 50% chance, play random
    if (playerHistory.isEmpty || _random.nextBool()) {
      return getRandomChoice();
    }

    // Counter the last player move
    final lastMove = playerHistory.last;
    return lastMove.beatenBy;
  }

  /// Hard: Pattern recognition + weighted counter strategy
  static RPSChoice getHardChoice(List<RPSChoice> playerHistory) {
    if (playerHistory.length < 3) {
      return getMediumChoice(playerHistory);
    }

    // Analyze patterns
    final prediction = _predictNextMove(playerHistory);

    // 80% of the time, counter the prediction
    if (_random.nextDouble() < 0.8) {
      return prediction.beatenBy;
    }

    // 20% random to avoid being too predictable
    return getRandomChoice();
  }

  /// Predict player's next move based on patterns
  static RPSChoice _predictNextMove(List<RPSChoice> history) {
    if (history.isEmpty) return getRandomChoice();

    // Count frequency of each choice
    final frequency = <RPSChoice, int>{
      RPSChoice.rock: 0,
      RPSChoice.paper: 0,
      RPSChoice.scissors: 0,
    };

    for (final choice in history) {
      frequency[choice] = frequency[choice]! + 1;
    }

    // Check for recent patterns (last 5 moves)
    final recentHistory = history.length > 5
        ? history.sublist(history.length - 5)
        : history;

    // Look for repeating pattern
    if (recentHistory.length >= 3) {
      // Check if player tends to repeat
      final lastMove = recentHistory.last;
      int repeatCount = 0;
      for (int i = recentHistory.length - 2; i >= 0; i--) {
        if (recentHistory[i] == lastMove) {
          repeatCount++;
        } else {
          break;
        }
      }

      // If repeating, predict they'll repeat again
      if (repeatCount >= 2) {
        return lastMove;
      }

      // Check for cycling pattern (rock -> paper -> scissors -> rock)
      if (recentHistory.length >= 3) {
        final secondLast = recentHistory[recentHistory.length - 2];
        final thirdLast = recentHistory[recentHistory.length - 3];

        // Check if it's a winning progression (they beat what they previously chose)
        if (secondLast.beatenBy == lastMove &&
            thirdLast.beatenBy == secondLast) {
          // Predict continuation
          return lastMove.beatenBy;
        }
      }
    }

    // Check for win/loss reaction patterns
    // (This would need result history, but we'll use move frequency for now)

    // Default: predict the most frequent choice
    RPSChoice mostFrequent = RPSChoice.rock;
    int maxCount = 0;
    frequency.forEach((choice, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = choice;
      }
    });

    // Add some randomness based on frequency weights
    final total = frequency.values.fold(0, (a, b) => a + b);
    if (total > 0) {
      final randomValue = _random.nextInt(total);
      int cumulative = 0;
      for (final entry in frequency.entries) {
        cumulative += entry.value;
        if (randomValue < cumulative) {
          return entry.key;
        }
      }
    }

    return mostFrequent;
  }

  /// Probability-based weighted selection
  static RPSChoice getProbabilisticChoice(Map<RPSChoice, double> weights) {
    final total = weights.values.fold(0.0, (a, b) => a + b);
    if (total == 0) return getRandomChoice();

    final randomValue = _random.nextDouble() * total;
    double cumulative = 0;

    for (final entry in weights.entries) {
      cumulative += entry.value;
      if (randomValue < cumulative) {
        return entry.key;
      }
    }

    return RPSChoice.rock;
  }
}
