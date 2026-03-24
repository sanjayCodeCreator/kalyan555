import 'dart:math';

import '../data/models/ng_difficulty.dart';

/// AI Assistant for providing intelligent hints and suggestions
class NGAIAssistant {
  static final Random _random = Random();

  /// Suggest a range for the next guess based on history
  static String suggestRange(
    List<int> guessHistory,
    int target,
    NGDifficulty difficulty,
  ) {
    if (guessHistory.isEmpty) {
      final mid = (difficulty.minValue + difficulty.maxValue) ~/ 2;
      return 'Start with $mid';
    }

    int lowerBound = difficulty.minValue;
    int upperBound = difficulty.maxValue;

    // Narrow down based on previous guesses
    for (final guess in guessHistory) {
      if (guess < target && guess > lowerBound) {
        lowerBound = guess + 1;
      }
      if (guess > target && guess < upperBound) {
        upperBound = guess - 1;
      }
    }

    if (lowerBound == upperBound) {
      return 'It must be $lowerBound!';
    }

    final suggestedGuess = (lowerBound + upperBound) ~/ 2;
    return 'Try $suggestedGuess (between $lowerBound-$upperBound)';
  }

  /// Get adaptive difficulty based on player performance
  static NGDifficulty getAdaptiveDifficulty(int wins, int losses) {
    if (wins + losses < 3) {
      return NGDifficulty.easy; // Not enough data
    }

    final winRate = wins / (wins + losses);

    if (winRate >= 0.8) {
      return NGDifficulty.hard;
    } else if (winRate >= 0.5) {
      return NGDifficulty.medium;
    } else {
      return NGDifficulty.easy;
    }
  }

  /// Detect if the player is repeating guesses (potential cheat/mistake)
  static bool isRepeatedGuess(List<int> guessHistory, int guess) {
    return guessHistory.contains(guess);
  }

  /// Get a helpful message for repeated guess
  static String getRepeatedGuessMessage(int guess, int target) {
    if (guess < target) {
      return 'You already tried $guess. It was too low!';
    } else if (guess > target) {
      return 'You already tried $guess. It was too high!';
    }
    return 'You already guessed $guess';
  }

  /// Generate a random motivational message
  static String getMotivationalMessage(int attemptsUsed, int? maxAttempts) {
    final messages = [
      'Keep going! 💪',
      'You\'re getting closer! 🎯',
      'Trust your instincts! ✨',
      'Nice try! Keep at it! 🌟',
      'You\'ve got this! 🚀',
    ];

    if (maxAttempts != null) {
      final remaining = maxAttempts - attemptsUsed;
      if (remaining <= 2) {
        return 'Only $remaining ${remaining == 1 ? 'attempt' : 'attempts'} left! 😬';
      }
      if (remaining <= maxAttempts ~/ 2) {
        return 'Halfway there! $remaining attempts remaining 🎲';
      }
    }

    return messages[_random.nextInt(messages.length)];
  }

  /// Get celebration message based on performance
  static String getCelebrationMessage(int attempts, NGDifficulty difficulty) {
    final maxAttempts = difficulty.maxAttempts;

    if (attempts == 1) {
      return 'INCREDIBLE! First try! 🏆✨';
    }
    if (attempts == 2) {
      return 'AMAZING! Only 2 guesses! 🌟';
    }
    if (attempts <= 3) {
      return 'EXCELLENT! You\'re a pro! 🎯';
    }

    if (maxAttempts != null) {
      if (attempts <= maxAttempts ~/ 2) {
        return 'GREAT JOB! Well under the limit! 💪';
      }
      if (attempts < maxAttempts) {
        return 'NICE! You made it! 🎉';
      }
      return 'PHEW! Just in time! 😅';
    }

    if (attempts <= 5) {
      return 'GREAT! That was quick! 🚀';
    }
    if (attempts <= 10) {
      return 'WELL DONE! Good game! 👏';
    }
    return 'You got it! Practice makes perfect! 📚';
  }

  /// Get console message for game over
  static String getGameOverMessage(int target) {
    return 'The number was $target. Better luck next time! 🍀';
  }
}
