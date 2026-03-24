import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';

import '../data/models/ng_difficulty.dart';
import '../data/models/ng_game_state.dart';
import '../domain/ng_game_logic.dart';
import '../domain/ng_ai_assistant.dart';

/// Provider for the Number Guessing game notifier
final ngGameProvider = StateNotifierProvider<NGGameNotifier, NGGameState>((
  ref,
) {
  return NGGameNotifier();
});

/// State notifier for managing Number Guessing game state
class NGGameNotifier extends StateNotifier<NGGameState> {
  NGGameNotifier() : super(NGGameState.initial());

  Timer? _timerCountdown;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _timerCountdown?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Start a new game with the specified difficulty
  void startGame(NGDifficulty difficulty) {
    _timerCountdown?.cancel();

    final targetNumber = NGGameLogic.generateTargetNumber(difficulty);

    state = NGGameState(
      phase: NGGamePhase.playing,
      difficulty: difficulty,
      targetNumber: targetNumber,
      guessHistory: [],
      activeHints: [],
      attemptsUsed: 0,
      hintsRemaining: 3,
      gameStartTime: DateTime.now(),
      timerEnabled: state.timerEnabled,
      timerDurationSeconds: state.timerDurationSeconds,
      remainingTimeSeconds: state.timerEnabled
          ? state.timerDurationSeconds
          : null,
      soundEnabled: state.soundEnabled,
      hapticEnabled: state.hapticEnabled,
      aiAssistEnabled: state.aiAssistEnabled,
    );

    if (state.timerEnabled) {
      _startTimer();
    }

    _playSound('start');
  }

  /// Make a guess
  void makeGuess(String input) {
    if (state.isInputLocked || state.phase != NGGamePhase.playing) {
      return;
    }

    // Validate input
    final error = NGGameLogic.validateInput(input, state.difficulty);
    if (error != null) {
      state = state.copyWith(inputError: error);
      _playSound('error');
      if (state.hapticEnabled) {
        HapticFeedback.lightImpact();
      }
      return;
    }

    final guess = int.parse(input);
    final target = state.targetNumber!;

    // Check for repeated guess
    if (NGAIAssistant.isRepeatedGuess(state.rawGuesses, guess)) {
      final message = NGAIAssistant.getRepeatedGuessMessage(guess, target);
      state = state.copyWith(inputError: message, clearInputError: false);
      _playSound('error');
      return;
    }

    // Lock input during processing
    state = state.copyWith(isInputLocked: true, clearInputError: true);

    // Evaluate the guess
    final result = NGGameLogic.evaluateGuess(guess, target);
    final newEntry = GuessEntry(
      guess: guess,
      result: result,
      timestamp: DateTime.now(),
    );

    final newHistory = [...state.guessHistory, newEntry];
    final newAttemptsUsed = state.attemptsUsed + 1;

    // Generate feedback message
    String feedbackMessage;
    if (state.aiAssistEnabled && result != GuessResult.correct) {
      feedbackMessage = NGAIAssistant.suggestRange(
        state.rawGuesses,
        target,
        state.difficulty,
      );
    } else {
      feedbackMessage = result.message;
    }

    // Update state based on result
    if (result == GuessResult.correct) {
      // Player wins!
      _timerCountdown?.cancel();
      _playSound('win');
      if (state.hapticEnabled) {
        HapticFeedback.heavyImpact();
      }

      state = state.copyWith(
        phase: NGGamePhase.won,
        guessHistory: newHistory,
        attemptsUsed: newAttemptsUsed,
        lastResult: result,
        feedbackMessage: NGAIAssistant.getCelebrationMessage(
          newAttemptsUsed,
          state.difficulty,
        ),
        isInputLocked: false,
      );
    } else {
      // Check if out of attempts
      final maxAttempts = state.difficulty.maxAttempts;
      final isOutOfAttempts =
          maxAttempts != null && newAttemptsUsed >= maxAttempts;

      if (isOutOfAttempts) {
        // Player loses
        _timerCountdown?.cancel();
        _playSound('lose');
        if (state.hapticEnabled) {
          HapticFeedback.mediumImpact();
        }

        state = state.copyWith(
          phase: NGGamePhase.lost,
          guessHistory: newHistory,
          attemptsUsed: newAttemptsUsed,
          lastResult: result,
          feedbackMessage: NGAIAssistant.getGameOverMessage(target),
          isInputLocked: false,
        );
      } else {
        // Continue playing
        _playSound(result == GuessResult.tooHigh ? 'high' : 'low');
        if (state.hapticEnabled) {
          HapticFeedback.lightImpact();
        }

        state = state.copyWith(
          guessHistory: newHistory,
          attemptsUsed: newAttemptsUsed,
          lastResult: result,
          feedbackMessage: feedbackMessage,
          isInputLocked: false,
        );
      }
    }
  }

  /// Use a hint
  void useHint(HintType type) {
    if (state.hintsRemaining <= 0 || state.phase != NGGamePhase.playing) {
      return;
    }

    // Check if this hint type is already active
    if (state.activeHints.any((h) => h.type == type)) {
      return;
    }

    final hintMessage = NGGameLogic.getHint(
      type,
      state.targetNumber!,
      state.rawGuesses,
      state.difficulty,
    );

    final newHint = ActiveHint(type: type, message: hintMessage);
    state = state.copyWith(
      activeHints: [...state.activeHints, newHint],
      hintsRemaining: state.hintsRemaining - 1,
    );

    _playSound('hint');
    if (state.hapticEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  /// Reset the game (keep settings)
  void resetGame() {
    _timerCountdown?.cancel();
    state = NGGameState(
      timerEnabled: state.timerEnabled,
      timerDurationSeconds: state.timerDurationSeconds,
      soundEnabled: state.soundEnabled,
      hapticEnabled: state.hapticEnabled,
      aiAssistEnabled: state.aiAssistEnabled,
    );
  }

  /// Play again with same difficulty
  void playAgain() {
    startGame(state.difficulty);
  }

  /// Set difficulty (before starting)
  void setDifficulty(NGDifficulty difficulty) {
    if (state.phase == NGGamePhase.idle) {
      state = state.copyWith(difficulty: difficulty);
    }
  }

  /// Toggle timer mode
  void toggleTimer() {
    state = state.copyWith(timerEnabled: !state.timerEnabled);
  }

  /// Set timer duration
  void setTimerDuration(int seconds) {
    state = state.copyWith(timerDurationSeconds: seconds);
  }

  /// Toggle sound
  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
  }

  /// Toggle haptic feedback
  void toggleHaptic() {
    state = state.copyWith(hapticEnabled: !state.hapticEnabled);
  }

  /// Toggle AI assist
  void toggleAIAssist() {
    state = state.copyWith(aiAssistEnabled: !state.aiAssistEnabled);
  }

  /// Start the countdown timer
  void _startTimer() {
    state = state.copyWith(remainingTimeSeconds: state.timerDurationSeconds);

    _timerCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingTimeSeconds == null ||
          state.remainingTimeSeconds! <= 1) {
        timer.cancel();
        // Time's up - game over
        if (state.phase == NGGamePhase.playing) {
          _playSound('timeout');
          if (state.hapticEnabled) {
            HapticFeedback.heavyImpact();
          }
          state = state.copyWith(
            phase: NGGamePhase.lost,
            remainingTimeSeconds: 0,
            feedbackMessage: NGAIAssistant.getGameOverMessage(
              state.targetNumber!,
            ),
          );
        }
      } else {
        state = state.copyWith(
          remainingTimeSeconds: state.remainingTimeSeconds! - 1,
        );

        // Warning sounds in final 10 seconds
        if (state.remainingTimeSeconds! <= 10) {
          _playSound('tick');
        }
      }
    });
  }

  /// Play sound effect
  Future<void> _playSound(String type) async {
    if (!state.soundEnabled) return;

    try {
      switch (type) {
        case 'start':
          await _audioPlayer.play(AssetSource('sounds/start.mp3'));
          break;
        case 'win':
          await _audioPlayer.play(AssetSource('sounds/win.mp3'));
          break;
        case 'lose':
        case 'timeout':
          await _audioPlayer.play(AssetSource('sounds/lose.mp3'));
          break;
        case 'high':
        case 'low':
          await _audioPlayer.play(AssetSource('sounds/tap.mp3'));
          break;
        case 'hint':
          await _audioPlayer.play(AssetSource('sounds/hint.mp3'));
          break;
        case 'error':
          await _audioPlayer.play(AssetSource('sounds/error.mp3'));
          break;
        case 'tick':
          await _audioPlayer.play(AssetSource('sounds/tick.mp3'));
          break;
      }
    } catch (_) {
      // Sounds are optional, fail silently
    }
  }
}
