/// Enum for difficulty levels in Number Guessing Game
enum NGDifficulty { easy, medium, hard }

/// Extension to provide configuration for each difficulty
extension NGDifficultyExtension on NGDifficulty {
  /// Minimum value in the range
  int get minValue => 1;

  /// Maximum value in the range
  int get maxValue {
    switch (this) {
      case NGDifficulty.easy:
        return 10;
      case NGDifficulty.medium:
        return 50;
      case NGDifficulty.hard:
        return 100;
    }
  }

  /// Maximum attempts allowed (null = unlimited)
  int? get maxAttempts {
    switch (this) {
      case NGDifficulty.easy:
        return null; // Unlimited
      case NGDifficulty.medium:
        return 10;
      case NGDifficulty.hard:
        return 5;
    }
  }

  /// Display name
  String get displayName {
    switch (this) {
      case NGDifficulty.easy:
        return 'Easy';
      case NGDifficulty.medium:
        return 'Medium';
      case NGDifficulty.hard:
        return 'Hard';
    }
  }

  /// Description
  String get description {
    switch (this) {
      case NGDifficulty.easy:
        return '1-10 • Unlimited attempts';
      case NGDifficulty.medium:
        return '1-50 • 10 attempts';
      case NGDifficulty.hard:
        return '1-100 • 5 attempts';
    }
  }

  /// Icon for the difficulty
  String get icon {
    switch (this) {
      case NGDifficulty.easy:
        return '😊';
      case NGDifficulty.medium:
        return '🎯';
      case NGDifficulty.hard:
        return '🔥';
    }
  }

  /// Color gradient for UI
  List<int> get colorCodes {
    switch (this) {
      case NGDifficulty.easy:
        return [0xFF4ECDC4, 0xFF44CF6C]; // Teal to Green
      case NGDifficulty.medium:
        return [0xFFFFE66D, 0xFFFF9F1C]; // Yellow to Orange
      case NGDifficulty.hard:
        return [0xFFFF6B6B, 0xFFEE0979]; // Red to Pink
    }
  }
}

/// Types of hints available in the game
enum HintType { evenOdd, divisibility, range }

/// Extension for hint types
extension HintTypeExtension on HintType {
  String get displayName {
    switch (this) {
      case HintType.evenOdd:
        return 'Even/Odd';
      case HintType.divisibility:
        return 'Divisible by';
      case HintType.range:
        return 'Range Hint';
    }
  }

  String get icon {
    switch (this) {
      case HintType.evenOdd:
        return '🔢';
      case HintType.divisibility:
        return '➗';
      case HintType.range:
        return '📏';
    }
  }
}

/// Represents the result of a guess
enum GuessResult { tooLow, tooHigh, correct }

/// Extension for guess results
extension GuessResultExtension on GuessResult {
  String get message {
    switch (this) {
      case GuessResult.tooLow:
        return 'Too Low! ⬆️';
      case GuessResult.tooHigh:
        return 'Too High! ⬇️';
      case GuessResult.correct:
        return 'Correct! 🎉';
    }
  }

  /// Color code for the result
  int get colorCode {
    switch (this) {
      case GuessResult.tooLow:
        return 0xFF3498DB; // Blue
      case GuessResult.tooHigh:
        return 0xFFE74C3C; // Red
      case GuessResult.correct:
        return 0xFF2ECC71; // Green
    }
  }
}
