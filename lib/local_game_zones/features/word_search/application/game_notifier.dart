import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/cell_state.dart';
import '../data/models/game_state.dart';
import '../data/models/word_placement.dart';
import '../domain/grid_generator.dart';
import '../domain/hint_logic.dart';
import '../domain/word_validator.dart';
import 'stats_notifier.dart';

/// Provider for the Word Search game notifier
final wordSearchGameProvider =
    StateNotifierProvider<WordSearchGameNotifier, WordSearchGameState>((ref) {
  return WordSearchGameNotifier(ref);
});

/// State notifier for managing Word Search game state
class WordSearchGameNotifier extends StateNotifier<WordSearchGameState> {
  final Ref _ref;

  WordSearchGameNotifier(this._ref) : super(WordSearchGameState.initial());

  /// Start a new game with the given difficulty
  void newGame(WSDifficulty difficulty, {bool isKidsMode = false}) {
    final result = GridGenerator.generate(
      difficulty: difficulty,
      isKidsMode: isKidsMode,
    );

    state = WordSearchGameState(
      grid: result.grid,
      gridSize: difficulty.gridSize,
      difficulty: difficulty,
      wordPlacements: result.wordPlacements,
      foundWordIds: {},
      selectedPath: [],
      status: WSGameStatus.playing,
      elapsedSeconds: 0,
      hintsRemaining: 3,
      hintsUsed: 0,
      mistakes: 0,
      wordColors: result.colors,
    );
  }

  /// Start daily challenge
  void startDailyChallenge() {
    final result = GridGenerator.generateDailyChallenge();

    state = WordSearchGameState(
      grid: result.grid,
      gridSize: WSDifficulty.medium.gridSize,
      difficulty: WSDifficulty.medium,
      wordPlacements: result.wordPlacements,
      foundWordIds: {},
      selectedPath: [],
      status: WSGameStatus.playing,
      timerMode: WSTimerMode.countdown,
      timeLimit: 300, // 5 minutes
      elapsedSeconds: 0,
      hintsRemaining: 2, // Fewer hints for daily
      hintsUsed: 0,
      mistakes: 0,
      wordColors: result.colors,
    );
  }

  /// Shuffle and generate new puzzle with same difficulty
  void shuffleGrid() {
    newGame(state.difficulty);
  }

  /// Start selection at a cell
  void startSelection(int index) {
    if (state.status != WSGameStatus.playing) return;

    // Update grid to show selection
    final newGrid = List<LetterCellState>.from(state.grid);
    newGrid[index] = newGrid[index].copyWith(isSelected: true);

    state = state.copyWith(
      selectedPath: [index],
      grid: newGrid,
      clearHighlight: true,
    );
  }

  /// Update selection during drag
  void updateSelection(int index) {
    if (state.status != WSGameStatus.playing) return;
    if (state.selectedPath.isEmpty) return;

    // Don't add if already in path (except for going backward)
    final path = List<int>.from(state.selectedPath);

    // If this is the previous cell in path, remove last cell (going backward)
    if (path.length >= 2 && path[path.length - 2] == index) {
      final newGrid = List<LetterCellState>.from(state.grid);
      final removedIndex = path.removeLast();
      newGrid[removedIndex] = newGrid[removedIndex].copyWith(isSelected: false);

      state = state.copyWith(selectedPath: path, grid: newGrid);
      return;
    }

    // Don't add if already in path
    if (path.contains(index)) return;

    // Get all cells between current end and new index
    final lastIndex = path.last;
    final cellsBetween = WordValidator.getCellsBetween(
      startIndex: lastIndex,
      endIndex: index,
      gridSize: state.gridSize,
    );

    // Skip the first one as it's already in path
    final newCells = cellsBetween.skip(1).toList();

    // Check if the path would still be valid
    final testPath = [...path, ...newCells];
    if (!WordValidator.isValidSelectionPath(
      path: testPath,
      gridSize: state.gridSize,
    )) {
      return;
    }

    // Update grid to show selection
    final newGrid = List<LetterCellState>.from(state.grid);
    for (final cellIndex in newCells) {
      if (!path.contains(cellIndex)) {
        newGrid[cellIndex] = newGrid[cellIndex].copyWith(isSelected: true);
      }
    }

    state = state.copyWith(
      selectedPath: testPath,
      grid: newGrid,
    );
  }

  /// End selection and validate word
  void endSelection() {
    if (state.status != WSGameStatus.playing) return;
    if (state.selectedPath.isEmpty) {
      _clearSelection();
      return;
    }

    // Get grid letters
    final gridLetters = state.grid.map((c) => c.letter).toList();

    // Validate selection
    final validatedWord = WordValidator.validateSelection(
      selectedPath: state.selectedPath,
      wordPlacements: state.wordPlacements,
      gridLetters: gridLetters,
      foundWordIds: state.foundWordIds,
    );

    if (validatedWord != null) {
      _markWordAsFound(validatedWord);
    } else {
      _handleInvalidSelection();
    }

    _clearSelection();
  }

  /// Mark a word as found
  void _markWordAsFound(WordPlacement word) {
    final newFoundIds = Set<int>.from(state.foundWordIds)..add(word.wordId);

    // Get color for this word
    final wordIndex = state.wordPlacements.indexWhere(
      (p) => p.wordId == word.wordId,
    );
    final wordColor = wordIndex < state.wordColors.length
        ? state.wordColors[wordIndex]
        : Colors.green;

    // Update grid to mark cells as part of found word
    final newGrid = List<LetterCellState>.from(state.grid);
    for (final cellIndex in word.cellIndices) {
      newGrid[cellIndex] = newGrid[cellIndex].copyWith(
        isPartOfWord: true,
        wordId: word.wordId,
        foundColor: wordColor,
      );
    }

    // Check if all words found
    final allFound = newFoundIds.length == state.wordPlacements.length;

    state = state.copyWith(
      grid: newGrid,
      foundWordIds: newFoundIds,
      status: allFound ? WSGameStatus.won : state.status,
      score: allFound ? state.calculateFinalScore() : state.score,
    );

    // Record stats if won
    if (allFound) {
      _recordGameResult();
    }
  }

  /// Handle invalid selection
  void _handleInvalidSelection() {
    state = state.copyWith(mistakes: state.mistakes + 1);
  }

  /// Clear the current selection
  void _clearSelection() {
    final newGrid = List<LetterCellState>.from(state.grid);
    for (int i = 0; i < newGrid.length; i++) {
      if (newGrid[i].isSelected) {
        newGrid[i] = newGrid[i].copyWith(isSelected: false);
      }
    }

    state = state.copyWith(
      selectedPath: [],
      grid: newGrid,
    );
  }

  /// Use a hint
  void useHint() {
    if (state.status != WSGameStatus.playing) return;
    if (state.hintsRemaining <= 0) return;

    final hint = HintLogic.getHint(
      wordPlacements: state.wordPlacements,
      foundWordIds: state.foundWordIds,
      currentHighlightedWordId: state.highlightedWordId,
    );

    if (hint == null) return;

    // Highlight the first cell of the hint word
    final newGrid = List<LetterCellState>.from(state.grid);

    // Clear previous highlights
    for (int i = 0; i < newGrid.length; i++) {
      if (newGrid[i].isHighlighted) {
        newGrid[i] = newGrid[i].copyWith(isHighlighted: false);
      }
    }

    // Highlight hint cells
    final hintWord = state.wordPlacements.firstWhere(
      (p) => p.wordId == hint.wordId,
    );
    final hintCells = HintLogic.getHintCells(
      placement: hintWord,
      level: HintLevel.firstLetter,
    );

    for (final cellIndex in hintCells) {
      newGrid[cellIndex] = newGrid[cellIndex].copyWith(isHighlighted: true);
    }

    state = state.copyWith(
      grid: newGrid,
      hintsRemaining: state.hintsRemaining - 1,
      hintsUsed: state.hintsUsed + 1,
      highlightedWordId: hint.wordId,
    );
  }

  /// Clear hint highlight
  void clearHintHighlight() {
    final newGrid = List<LetterCellState>.from(state.grid);
    for (int i = 0; i < newGrid.length; i++) {
      if (newGrid[i].isHighlighted) {
        newGrid[i] = newGrid[i].copyWith(isHighlighted: false);
      }
    }

    state = state.copyWith(grid: newGrid, clearHighlight: true);
  }

  /// Pause the game
  void pauseGame() {
    if (state.status == WSGameStatus.playing) {
      state = state.copyWith(status: WSGameStatus.paused);
    }
  }

  /// Resume the game
  void resumeGame() {
    if (state.status == WSGameStatus.paused) {
      state = state.copyWith(status: WSGameStatus.playing);
    }
  }

  /// Update elapsed time from timer
  void updateElapsedTime(int seconds) {
    if (state.status != WSGameStatus.playing) return;

    state = state.copyWith(elapsedSeconds: seconds);

    // Check for countdown timeout
    if (state.timerMode == WSTimerMode.countdown && state.remainingTime <= 0) {
      // Time's up - end game
      state = state.copyWith(
        status: WSGameStatus.won, // Or could be a "lost" state
        score: state.calculateFinalScore(),
      );
      _recordGameResult();
    }
  }

  /// Record game result to stats
  void _recordGameResult() {
    _ref.read(wordSearchStatsProvider.notifier).recordGame(
          won: state.status == WSGameStatus.won,
          difficulty: state.difficulty,
          time: state.elapsedSeconds,
          wordsFound: state.wordsFoundCount,
          hintsUsed: state.hintsUsed,
          score: state.calculateFinalScore(),
        );
  }
}
