import 'dart:math';

import 'package:flutter/material.dart';

import '../data/models/cell_state.dart';
import '../data/models/game_state.dart';
import '../data/models/word_placement.dart';
import 'word_lists.dart';
import 'word_placer.dart';

/// Grid generator for creating Word Search puzzles
class GridGenerator {
  static final _random = Random();

  /// Characters used to fill empty cells
  static const _fillCharacters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  /// Colors for found words (cycling through)
  static final List<Color> wordColors = [
    const Color(0xFF4ECDC4), // Teal
    const Color(0xFFFF6B6B), // Coral
    const Color(0xFF95E1D3), // Mint
    const Color(0xFFFFD93D), // Yellow
    const Color(0xFF6C63FF), // Purple
    const Color(0xFFFF9F43), // Orange
    const Color(0xFFEE5A5A), // Red
    const Color(0xFF48DBFB), // Cyan
    const Color(0xFFA29BFE), // Lavender
    const Color(0xFF00D2D3), // Turquoise
    const Color(0xFFFF78C4), // Pink
    const Color(0xFF2ECC71), // Green
  ];

  /// Generate a complete Word Search puzzle
  static ({
    List<LetterCellState> grid,
    List<WordPlacement> wordPlacements,
    List<Color> colors,
  }) generate({
    required WSDifficulty difficulty,
    bool isKidsMode = false,
  }) {
    final gridSize = difficulty.gridSize;
    final wordCount = difficulty.wordCount;
    final allowedDirections = difficulty.allowedDirections;

    // Create empty grid
    final gridChars = List<String>.filled(gridSize * gridSize, '');

    // Get words for this puzzle
    final words = isKidsMode
        ? WordLists.getKidsWords(
            wordCount + 3) // Get extra in case some don't fit
        : WordLists.getWordsForGridSize(gridSize, wordCount + 5);

    // Sort words by length (longest first) for better placement
    words.sort((a, b) => b.length.compareTo(a.length));

    // Place words
    final placements = <WordPlacement>[];
    int wordId = 0;

    for (final word in words) {
      if (placements.length >= wordCount) break;

      final placement = WordPlacer.placeWord(
        word: word,
        grid: gridChars,
        gridSize: gridSize,
        allowedDirections: allowedDirections,
        wordId: wordId,
      );

      if (placement != null) {
        placements.add(placement);
        wordId++;
      }
    }

    // Fill remaining cells with random letters
    for (int i = 0; i < gridChars.length; i++) {
      if (gridChars[i] == '') {
        gridChars[i] = _fillCharacters[_random.nextInt(_fillCharacters.length)];
      }
    }

    // Convert to LetterCellState list
    final grid =
        gridChars.map((char) => LetterCellState.withLetter(char)).toList();

    // Assign colors to words
    final colors = List<Color>.generate(
      placements.length,
      (index) => wordColors[index % wordColors.length],
    );

    return (grid: grid, wordPlacements: placements, colors: colors);
  }

  /// Generate a daily challenge puzzle
  static ({
    List<LetterCellState> grid,
    List<WordPlacement> wordPlacements,
    List<Color> colors,
  }) generateDailyChallenge() {
    // Daily challenge is always medium difficulty
    const difficulty = WSDifficulty.medium;
    final gridSize = difficulty.gridSize;
    final wordCount = difficulty.wordCount;

    // Create empty grid
    final gridChars = List<String>.filled(gridSize * gridSize, '');

    // Get daily themed words
    final words = WordLists.getDailyWords(wordCount + 3, gridSize - 1);

    // Sort by length for better placement
    words.sort((a, b) => b.length.compareTo(a.length));

    // Place words
    final placements = <WordPlacement>[];
    int wordId = 0;

    for (final word in words) {
      if (placements.length >= wordCount) break;

      final placement = WordPlacer.placeWord(
        word: word,
        grid: gridChars,
        gridSize: gridSize,
        allowedDirections: difficulty.allowedDirections,
        wordId: wordId,
      );

      if (placement != null) {
        placements.add(placement);
        wordId++;
      }
    }

    // Fill remaining cells
    for (int i = 0; i < gridChars.length; i++) {
      if (gridChars[i] == '') {
        gridChars[i] = _fillCharacters[_random.nextInt(_fillCharacters.length)];
      }
    }

    // Convert to LetterCellState list
    final grid =
        gridChars.map((char) => LetterCellState.withLetter(char)).toList();

    // Assign colors
    final colors = List<Color>.generate(
      placements.length,
      (index) => wordColors[index % wordColors.length],
    );

    return (grid: grid, wordPlacements: placements, colors: colors);
  }

  /// Shuffle/regenerate the puzzle with new words
  static ({
    List<LetterCellState> grid,
    List<WordPlacement> wordPlacements,
    List<Color> colors,
  }) regenerate({
    required WSDifficulty difficulty,
    bool isKidsMode = false,
  }) {
    return generate(difficulty: difficulty, isKidsMode: isKidsMode);
  }
}
