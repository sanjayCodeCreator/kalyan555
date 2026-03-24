import '../data/models/word_placement.dart';

/// Hint system for helping players find words
class HintLogic {
  /// Get a hint for an unfound word
  /// Returns the word ID and first cell index to highlight
  static ({int wordId, int firstCellIndex, WordDirection direction})? getHint({
    required List<WordPlacement> wordPlacements,
    required Set<int> foundWordIds,
    int? currentHighlightedWordId,
  }) {
    // Find unfound words
    final unfoundWords =
        wordPlacements.where((p) => !foundWordIds.contains(p.wordId)).toList();

    if (unfoundWords.isEmpty) return null;

    // If there's a currently highlighted word, skip to next one
    WordPlacement wordToHint;
    if (currentHighlightedWordId != null) {
      final currentIndex = unfoundWords.indexWhere(
        (p) => p.wordId == currentHighlightedWordId,
      );

      if (currentIndex >= 0 && currentIndex < unfoundWords.length - 1) {
        // Move to next unfound word
        wordToHint = unfoundWords[currentIndex + 1];
      } else {
        // Wrap around to first unfound word
        wordToHint = unfoundWords.first;
      }
    } else {
      // Start with first unfound word
      wordToHint = unfoundWords.first;
    }

    return (
      wordId: wordToHint.wordId,
      firstCellIndex: wordToHint.cellIndices.first,
      direction: wordToHint.direction,
    );
  }

  /// Get the cells to highlight for a hint
  static List<int> getHintCells({
    required WordPlacement placement,
    HintLevel level = HintLevel.firstLetter,
  }) {
    switch (level) {
      case HintLevel.firstLetter:
        return [placement.cellIndices.first];
      case HintLevel.firstTwoLetters:
        if (placement.cellIndices.length >= 2) {
          return placement.cellIndices.sublist(0, 2);
        }
        return [placement.cellIndices.first];
      case HintLevel.entireWord:
        return placement.cellIndices;
    }
  }

  /// Calculate hint penalty for score
  static int getHintPenalty(HintLevel level) {
    switch (level) {
      case HintLevel.firstLetter:
        return 50;
      case HintLevel.firstTwoLetters:
        return 75;
      case HintLevel.entireWord:
        return 150;
    }
  }

  /// Get direction hint text
  static String getDirectionHint(WordDirection direction) {
    switch (direction) {
      case WordDirection.horizontal:
        return 'Look horizontally →';
      case WordDirection.horizontalReverse:
        return 'Look horizontally ←';
      case WordDirection.vertical:
        return 'Look vertically ↓';
      case WordDirection.verticalReverse:
        return 'Look vertically ↑';
      case WordDirection.diagonalDown:
        return 'Look diagonally ↘';
      case WordDirection.diagonalUp:
        return 'Look diagonally ↗';
      case WordDirection.diagonalDownReverse:
        return 'Look diagonally ↖';
      case WordDirection.diagonalUpReverse:
        return 'Look diagonally ↙';
    }
  }

  /// Check if a hint should be automatically suggested
  /// (e.g., player struggling with a word for too long)
  static bool shouldSuggestHint({
    required int elapsedSeconds,
    required int wordsFound,
    required int totalWords,
    required int lastWordFoundTime,
  }) {
    // Suggest hint if no word found for more than 60 seconds
    final timeSinceLastWord = elapsedSeconds - lastWordFoundTime;
    if (timeSinceLastWord > 60 && wordsFound < totalWords) {
      return true;
    }

    return false;
  }
}

/// Hint level determines how much of the word to reveal
enum HintLevel {
  /// Show only the first letter
  firstLetter,

  /// Show the first two letters
  firstTwoLetters,

  /// Show the entire word (maximum penalty)
  entireWord,
}
