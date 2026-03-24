import 'dart:math';

import '../data/models/ng_difficulty.dart';

/// Core game logic for Number Guessing Game
class NGGameLogic {
  static final Random _random = Random();

  /// Generate a random target number within the difficulty range
  static int generateTargetNumber(NGDifficulty difficulty) {
    final min = difficulty.minValue;
    final max = difficulty.maxValue;
    return _random.nextInt(max - min + 1) + min;
  }

  /// Evaluate a guess against the target
  static GuessResult evaluateGuess(int guess, int target) {
    if (guess < target) {
      return GuessResult.tooLow;
    } else if (guess > target) {
      return GuessResult.tooHigh;
    } else {
      return GuessResult.correct;
    }
  }

  /// Validate user input
  /// Returns null if valid, error message if invalid
  static String? validateInput(String input, NGDifficulty difficulty) {
    if (input.isEmpty) {
      return 'Please enter a number';
    }

    final number = int.tryParse(input);
    if (number == null) {
      return 'Please enter a valid number';
    }

    final min = difficulty.minValue;
    final max = difficulty.maxValue;

    if (number < min || number > max) {
      return 'Enter a number between $min and $max';
    }

    return null; // Valid
  }

  /// Calculate even/odd hint
  static String getEvenOddHint(int target) {
    return target.isEven ? 'The number is EVEN' : 'The number is ODD';
  }

  /// Calculate divisibility hint
  static String getDivisibilityHint(int target) {
    // Find an interesting divisor
    final divisors = <int>[];
    for (int i = 2; i <= 10; i++) {
      if (target % i == 0) {
        divisors.add(i);
      }
    }

    if (divisors.isEmpty) {
      return 'The number is not divisible by 2-10';
    }

    // Pick a random divisor from the list
    final divisor = divisors[_random.nextInt(divisors.length)];
    return 'The number is divisible by $divisor';
  }

  /// Calculate range hint based on guess history
  static String getRangeHint(
    int target,
    List<int> guessHistory,
    NGDifficulty difficulty,
  ) {
    int lowerBound = difficulty.minValue;
    int upperBound = difficulty.maxValue;

    for (final guess in guessHistory) {
      if (guess < target && guess > lowerBound) {
        lowerBound = guess;
      }
      if (guess > target && guess < upperBound) {
        upperBound = guess;
      }
    }

    // Narrow down the range a bit more if possible
    final rangeSize = upperBound - lowerBound;
    if (rangeSize > 10) {
      // Give a tighter range
      if (target - lowerBound > upperBound - target) {
        // Target is closer to upper bound
        lowerBound = target - (rangeSize ~/ 4);
      } else {
        // Target is closer to lower bound
        upperBound = target + (rangeSize ~/ 4);
      }
    }

    return 'Try between $lowerBound and $upperBound';
  }

  /// Get a hint based on type
  static String getHint(
    HintType type,
    int target,
    List<int> guessHistory,
    NGDifficulty difficulty,
  ) {
    switch (type) {
      case HintType.evenOdd:
        return getEvenOddHint(target);
      case HintType.divisibility:
        return getDivisibilityHint(target);
      case HintType.range:
        return getRangeHint(target, guessHistory, difficulty);
    }
  }

  /// Calculate score based on attempts and time (lower is better)
  static int calculateScore(
    int attempts,
    Duration? timeTaken,
    NGDifficulty difficulty,
  ) {
    // Base score from attempts (fewer = higher score)
    final maxAttempts = difficulty.maxAttempts ?? 20;
    final attemptScore = ((maxAttempts - attempts + 1) / maxAttempts * 1000)
        .round();

    // Time bonus if timer was used
    int timeBonus = 0;
    if (timeTaken != null) {
      final seconds = timeTaken.inSeconds;
      timeBonus = (300 - seconds).clamp(
        0,
        300,
      ); // Max 300 bonus for fast completion
    }

    // Difficulty multiplier
    final difficultyMultiplier = switch (difficulty) {
      NGDifficulty.easy => 1.0,
      NGDifficulty.medium => 1.5,
      NGDifficulty.hard => 2.0,
    };

    return ((attemptScore + timeBonus) * difficultyMultiplier).round();
  }
}
