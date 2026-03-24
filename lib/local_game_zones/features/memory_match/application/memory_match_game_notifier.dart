import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';

import '../data/models/memory_match_card.dart';
import '../data/models/memory_match_game_state.dart';
import '../domain/memory_match_logic.dart';

/// Provider for the Memory Match game notifier
final memoryMatchGameProvider =
    StateNotifierProvider<MemoryMatchGameNotifier, MemoryMatchGameState>((ref) {
      return MemoryMatchGameNotifier();
    });

/// State notifier for managing Memory Match game state
class MemoryMatchGameNotifier extends StateNotifier<MemoryMatchGameState> {
  MemoryMatchGameNotifier() : super(MemoryMatchGameState.initial());

  Timer? _gameTimer;
  Timer? _flipBackTimer;
  Timer? _hintTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _gameTimer?.cancel();
    _flipBackTimer?.cancel();
    _hintTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Start a new game with specified settings
  void startGame({
    required GridSize gridSize,
    GameMode mode = GameMode.classic,
    bool isKidsMode = false,
  }) {
    _gameTimer?.cancel();
    _flipBackTimer?.cancel();
    _hintTimer?.cancel();

    final cards = MemoryMatchLogic.generateCards(gridSize);
    final hints = isKidsMode
        ? gridSize.defaultHints + 2
        : gridSize.defaultHints;

    int? remainingTime;
    int? remainingMoves;

    if (mode == GameMode.timed) {
      remainingTime = gridSize.defaultTimeLimit;
    } else if (mode == GameMode.limitedMoves) {
      remainingMoves = gridSize.defaultMoveLimit;
    }

    state = MemoryMatchGameState(
      phase: mode == GameMode.training ? GamePhase.playing : GamePhase.playing,
      gridSize: gridSize,
      mode: mode,
      cards: cards,
      hintsRemaining: hints,
      remainingTime: remainingTime,
      remainingMoves: remainingMoves,
      isKidsMode: isKidsMode,
      soundEnabled: state.soundEnabled,
      hapticEnabled: state.hapticEnabled,
      trainingPreview: mode == GameMode.training,
    );

    // Start training preview if in training mode
    if (mode == GameMode.training) {
      _showTrainingPreview();
    } else {
      _startGameTimer();
    }
  }

  /// Show training preview (reveal all cards briefly)
  void _showTrainingPreview() {
    // Reveal all cards
    final revealedCards = state.cards
        .map((card) => card.copyWith(state: CardState.visible))
        .toList();

    state = state.copyWith(
      cards: revealedCards,
      trainingPreview: true,
      isInputLocked: true,
    );

    // Preview duration based on grid size
    final previewDuration = Duration(seconds: state.gridSize.size);

    _hintTimer = Timer(previewDuration, () {
      // Hide all cards
      final hiddenCards = state.cards
          .map((card) => card.copyWith(state: CardState.hidden))
          .toList();

      state = state.copyWith(
        cards: hiddenCards,
        trainingPreview: false,
        isInputLocked: false,
      );

      _startGameTimer();
    });
  }

  /// Flip a card by index
  void flipCard(int index) {
    // Validate flip action
    if (state.isInputLocked ||
        state.showingHint ||
        state.trainingPreview ||
        state.phase != GamePhase.playing) {
      return;
    }

    if (index < 0 || index >= state.cards.length) return;

    final card = state.cards[index];

    // Can't flip already revealed cards
    if (!card.canFlip) return;

    // Can't flip the same card that's already selected
    if (state.firstFlippedIndex == index) return;

    // Play flip sound
    _playSound('flip');

    // Haptic feedback
    if (state.hapticEnabled) {
      HapticFeedback.lightImpact();
    }

    // Update card state to visible
    final updatedCards = List<MemoryMatchCard>.from(state.cards);
    updatedCards[index] = card.copyWith(state: CardState.visible);

    if (!state.hasFirstCard) {
      // First card flip
      state = state.copyWith(cards: updatedCards, firstFlippedIndex: index);
    } else {
      // Second card flip
      state = state.copyWith(
        cards: updatedCards,
        secondFlippedIndex: index,
        isInputLocked: true,
        moves: state.moves + 1,
        remainingMoves: state.remainingMoves != null
            ? state.remainingMoves! - 1
            : null,
      );

      // Check for match after a short delay
      final flipDelay = state.isKidsMode
          ? const Duration(milliseconds: 1200)
          : const Duration(milliseconds: 800);

      _flipBackTimer = Timer(flipDelay, _checkMatch);
    }
  }

  /// Check if the two flipped cards match
  void _checkMatch() {
    if (state.firstFlippedIndex == null || state.secondFlippedIndex == null) {
      return;
    }

    final firstCard = state.cards[state.firstFlippedIndex!];
    final secondCard = state.cards[state.secondFlippedIndex!];
    final isMatch = MemoryMatchLogic.checkMatch(firstCard, secondCard);

    final updatedCards = List<MemoryMatchCard>.from(state.cards);

    if (isMatch) {
      // Match found!
      updatedCards[state.firstFlippedIndex!] = firstCard.copyWith(
        state: CardState.matched,
      );
      updatedCards[state.secondFlippedIndex!] = secondCard.copyWith(
        state: CardState.matched,
      );

      final newMatchedPairs = state.matchedPairs + 1;
      final newStreak = state.streak + 1;
      final newMaxStreak = newStreak > state.maxStreak
          ? newStreak
          : state.maxStreak;

      // Play match sound
      _playSound('match');

      if (state.hapticEnabled) {
        HapticFeedback.heavyImpact();
      }

      state = state.copyWith(
        cards: updatedCards,
        matchedPairs: newMatchedPairs,
        streak: newStreak,
        maxStreak: newMaxStreak,
        clearFirstFlipped: true,
        clearSecondFlipped: true,
        isInputLocked: false,
      );

      // Check for game completion
      if (state.isComplete) {
        _onGameComplete();
      }
    } else {
      // No match - flip cards back
      updatedCards[state.firstFlippedIndex!] = firstCard.copyWith(
        state: CardState.hidden,
      );
      updatedCards[state.secondFlippedIndex!] = secondCard.copyWith(
        state: CardState.hidden,
      );

      // Reset streak on mismatch
      state = state.copyWith(
        cards: updatedCards,
        streak: 0,
        clearFirstFlipped: true,
        clearSecondFlipped: true,
        isInputLocked: false,
      );
    }

    // Check for game failure (limited moves mode)
    if (state.hasFailed) {
      _onGameFailed();
    }
  }

  /// Use a hint (briefly show all unmatched cards)
  void useHint() {
    if (state.hintsRemaining <= 0 ||
        state.showingHint ||
        state.phase != GamePhase.playing) {
      return;
    }

    // Play hint sound
    _playSound('hint');

    // Reveal all unmatched cards
    final revealedCards = state.cards.map((card) {
      if (card.state == CardState.hidden) {
        return card.copyWith(state: CardState.visible);
      }
      return card;
    }).toList();

    state = state.copyWith(
      cards: revealedCards,
      hintsRemaining: state.hintsRemaining - 1,
      hintsUsed: state.hintsUsed + 1,
      showingHint: true,
      isInputLocked: true,
    );

    // Hide cards after hint duration
    final hintDuration = state.isKidsMode
        ? const Duration(seconds: 3)
        : const Duration(seconds: 2);

    _hintTimer = Timer(hintDuration, () {
      final hiddenCards = state.cards.map((card) {
        if (card.state == CardState.visible) {
          return card.copyWith(state: CardState.hidden);
        }
        return card;
      }).toList();

      state = state.copyWith(
        cards: hiddenCards,
        showingHint: false,
        isInputLocked: false,
        clearFirstFlipped: true,
        clearSecondFlipped: true,
      );
    });
  }

  /// Start the game timer
  void _startGameTimer() {
    _gameTimer?.cancel();

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.phase != GamePhase.playing) {
        timer.cancel();
        return;
      }

      if (state.mode == GameMode.timed && state.remainingTime != null) {
        // Countdown timer
        final newTime = state.remainingTime! - 1;
        state = state.copyWith(
          elapsedSeconds: state.elapsedSeconds + 1,
          remainingTime: newTime,
        );

        if (newTime <= 0) {
          timer.cancel();
          _onGameFailed();
        }
      } else {
        // Count-up timer
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  /// Handle game completion
  void _onGameComplete() {
    _gameTimer?.cancel();

    final score = MemoryMatchLogic.calculateScore(
      gridSize: state.gridSize,
      moves: state.moves,
      elapsedSeconds: state.elapsedSeconds,
      streak: state.maxStreak,
      hintsUsed: state.hintsUsed,
      mode: state.mode,
      isComplete: true,
    );

    _playSound('win');

    if (state.hapticEnabled) {
      HapticFeedback.heavyImpact();
    }

    state = state.copyWith(phase: GamePhase.completed, score: score);
  }

  /// Handle game failure
  void _onGameFailed() {
    _gameTimer?.cancel();

    _playSound('lose');

    state = state.copyWith(phase: GamePhase.failed);
  }

  /// Pause the game
  void pauseGame() {
    if (state.phase == GamePhase.playing) {
      _gameTimer?.cancel();
      state = state.copyWith(phase: GamePhase.paused);
    }
  }

  /// Resume the game
  void resumeGame() {
    if (state.phase == GamePhase.paused) {
      state = state.copyWith(phase: GamePhase.playing);
      _startGameTimer();
    }
  }

  /// Reset game to initial state
  void resetGame() {
    _gameTimer?.cancel();
    _flipBackTimer?.cancel();
    _hintTimer?.cancel();

    state = MemoryMatchGameState(
      soundEnabled: state.soundEnabled,
      hapticEnabled: state.hapticEnabled,
      isKidsMode: state.isKidsMode,
    );
  }

  /// Toggle sound effects
  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
  }

  /// Toggle haptic feedback
  void toggleHaptic() {
    state = state.copyWith(hapticEnabled: !state.hapticEnabled);
  }

  /// Set kids mode
  void setKidsMode(bool enabled) {
    state = state.copyWith(isKidsMode: enabled);
  }

  /// Set grid size (for settings)
  void setGridSize(GridSize gridSize) {
    state = state.copyWith(gridSize: gridSize);
  }

  /// Set game mode (for settings)
  void setGameMode(GameMode mode) {
    state = state.copyWith(mode: mode);
  }

  /// Play sound effect
  Future<void> _playSound(String type) async {
    if (!state.soundEnabled) return;

    try {
      switch (type) {
        case 'flip':
          await _audioPlayer.play(AssetSource('sounds/tap.mp3'));
          break;
        case 'match':
          await _audioPlayer.play(AssetSource('sounds/win.mp3'));
          break;
        case 'win':
          await _audioPlayer.play(AssetSource('sounds/win.mp3'));
          break;
        case 'lose':
          await _audioPlayer.play(AssetSource('sounds/lose.mp3'));
          break;
        case 'hint':
          await _audioPlayer.play(AssetSource('sounds/tap.mp3'));
          break;
      }
    } catch (_) {
      // Sounds are optional, fail silently
    }
  }
}
