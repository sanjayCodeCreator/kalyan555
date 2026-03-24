import 'dart:math';

import '../data/models/memory_match_card.dart';
import '../data/models/memory_match_game_state.dart';

/// Memory Match game logic utilities
class MemoryMatchLogic {
  static final _random = Random();

  /// Generate a shuffled deck of cards for the given grid size
  static List<MemoryMatchCard> generateCards(GridSize gridSize) {
    final totalPairs = gridSize.totalPairs;
    final cards = <MemoryMatchCard>[];

    // Create pairs of cards
    for (int pairId = 0; pairId < totalPairs; pairId++) {
      final icon = CardIcons.icons[pairId % CardIcons.icons.length];
      final color = CardIcons.colors[pairId % CardIcons.colors.length];

      // Create two cards for each pair
      cards.add(
        MemoryMatchCard(
          id: pairId * 2,
          pairId: pairId,
          icon: icon,
          color: color,
        ),
      );
      cards.add(
        MemoryMatchCard(
          id: pairId * 2 + 1,
          pairId: pairId,
          icon: icon,
          color: color,
        ),
      );
    }

    // Shuffle the cards
    cards.shuffle(_random);

    // Reassign IDs based on position for easier indexing
    for (int i = 0; i < cards.length; i++) {
      cards[i] = cards[i].copyWith(id: i);
    }

    return cards;
  }

  /// Check if two cards match
  static bool checkMatch(MemoryMatchCard card1, MemoryMatchCard card2) {
    return card1.pairId == card2.pairId && card1.id != card2.id;
  }

  /// Calculate score based on game performance
  static int calculateScore({
    required GridSize gridSize,
    required int moves,
    required int elapsedSeconds,
    required int streak,
    required int hintsUsed,
    required GameMode mode,
    required bool isComplete,
  }) {
    if (!isComplete) return 0;

    int score = 0;
    final totalPairs = gridSize.totalPairs;

    // Base score for completion (larger grids = more points)
    switch (gridSize) {
      case GridSize.small:
        score += 100;
        break;
      case GridSize.medium:
        score += 500;
        break;
      case GridSize.large:
        score += 1000;
        break;
    }

    // Move efficiency bonus
    final perfectMoves = totalPairs; // Minimum possible moves
    final moveEfficiency = perfectMoves / moves;
    score += (moveEfficiency * 200).round();

    // Time bonus (faster = more points)
    final expectedTime = gridSize.defaultTimeLimit;
    if (elapsedSeconds < expectedTime) {
      final timeBonus = ((expectedTime - elapsedSeconds) / expectedTime * 300)
          .round();
      score += timeBonus;
    }

    // Streak bonus
    score += streak * 25;

    // Hint penalty
    score -= hintsUsed * 50;

    // Mode multiplier
    switch (mode) {
      case GameMode.timed:
        score = (score * 1.2).round();
        break;
      case GameMode.limitedMoves:
        score = (score * 1.5).round();
        break;
      case GameMode.training:
        score = (score * 0.5).round();
        break;
      case GameMode.classic:
        break;
    }

    return score.clamp(0, 9999);
  }

  /// Check if game qualifies as perfect (no mistakes)
  static bool isPerfectGame(int moves, int totalPairs) {
    return moves == totalPairs;
  }

  /// Get unmatched card indices for hint feature
  static List<int> getUnmatchedCardIndices(List<MemoryMatchCard> cards) {
    final unmatched = <int>[];
    for (int i = 0; i < cards.length; i++) {
      if (cards[i].state != CardState.matched) {
        unmatched.add(i);
      }
    }
    return unmatched;
  }

  /// Get a random pair for hint (returns indices of two matching cards)
  static List<int>? getHintPair(List<MemoryMatchCard> cards) {
    final unmatched = <int, List<int>>{};

    for (int i = 0; i < cards.length; i++) {
      if (cards[i].state != CardState.matched) {
        final pairId = cards[i].pairId;
        unmatched.putIfAbsent(pairId, () => []);
        unmatched[pairId]!.add(i);
      }
    }

    if (unmatched.isEmpty) return null;

    // Get a random pair
    final pairs = unmatched.values
        .where((indices) => indices.length == 2)
        .toList();
    if (pairs.isEmpty) return null;

    return pairs[_random.nextInt(pairs.length)];
  }

  /// Calculate star rating (1-3 stars)
  static int calculateStars({
    required int moves,
    required int totalPairs,
    required int elapsedSeconds,
    required int timeLimit,
  }) {
    final moveRatio = totalPairs / moves;
    final timeRatio = timeLimit > 0
        ? (timeLimit - elapsedSeconds) / timeLimit
        : 1.0;

    // Perfect game = 3 stars
    if (moveRatio >= 0.9 && timeRatio >= 0.5) return 3;
    // Good game = 2 stars
    if (moveRatio >= 0.5 && timeRatio >= 0.25) return 2;
    // Completed = 1 star
    return 1;
  }

  /// Format seconds as MM:SS string
  static String formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Get grid column count for responsive layout
  static int getColumnCount(GridSize gridSize, double screenWidth) {
    return gridSize.size;
  }

  /// Calculate card size for responsive grid
  static double calculateCardSize({
    required GridSize gridSize,
    required double availableWidth,
    required double availableHeight,
    required double spacing,
  }) {
    final columns = gridSize.size;
    final rows = gridSize.size;

    final maxWidthCard = (availableWidth - (spacing * (columns - 1))) / columns;
    final maxHeightCard = (availableHeight - (spacing * (rows - 1))) / rows;

    return min(maxWidthCard, maxHeightCard);
  }
}
