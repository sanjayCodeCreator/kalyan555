import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';

import '../data/models/rps_choice.dart';
import '../data/models/rps_game_state.dart';
import '../domain/rps_ai_logic.dart';
import '../domain/rps_game_logic.dart';

/// Provider for the RPS game notifier
final rpsGameProvider = StateNotifierProvider<RPSGameNotifier, RPSGameState>((
  ref,
) {
  return RPSGameNotifier();
});

/// State notifier for managing RPS game state
class RPSGameNotifier extends StateNotifier<RPSGameState> {
  RPSGameNotifier() : super(RPSGameState.initial());

  Timer? _timerCountdown;
  Timer? _revealDelay;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _timerCountdown?.cancel();
    _revealDelay?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Make a choice (player selects rock, paper, or scissors)
  void makeChoice(RPSChoice choice) {
    // Prevent input during animations or locked state
    if (state.isInputLocked ||
        state.phase == GamePhase.revealing ||
        state.phase == GamePhase.result) {
      return;
    }

    // Anti-spam: lock input
    state = state.copyWith(
      isInputLocked: true,
      playerChoice: choice,
      phase: GamePhase.revealing,
      playerHistory: [...state.playerHistory, choice],
    );

    // Stop timer if running
    _timerCountdown?.cancel();

    // Play tap sound
    _playSound('tap');

    // Haptic feedback
    if (state.hapticEnabled) {
      HapticFeedback.lightImpact();
    }

    // Get AI choice
    final computerChoice = RPSAILogic.getChoice(
      state.difficulty,
      state.playerHistory,
    );

    // Delay to show animation, then reveal result
    _revealDelay = Timer(const Duration(milliseconds: 800), () {
      _revealResult(choice, computerChoice);
    });
  }

  /// Reveal the result after animation
  void _revealResult(RPSChoice playerChoice, RPSChoice computerChoice) {
    final result = RPSGameLogic.determineWinner(playerChoice, computerChoice);

    int newPlayerScore = state.playerScore;
    int newComputerScore = state.computerScore;
    int newDrawCount = state.drawCount;

    switch (result) {
      case RPSResult.win:
        newPlayerScore++;
        _playSound('win');
        if (state.hapticEnabled) {
          HapticFeedback.heavyImpact();
        }
        break;
      case RPSResult.lose:
        newComputerScore++;
        _playSound('lose');
        break;
      case RPSResult.draw:
        newDrawCount++;
        break;
    }

    state = state.copyWith(
      phase: GamePhase.result,
      computerChoice: computerChoice,
      result: result,
      playerScore: newPlayerScore,
      computerScore: newComputerScore,
      drawCount: newDrawCount,
      isInputLocked: false,
    );

    // Check for match end in Best of X mode
    if (state.isMatchOver) {
      state = state.copyWith(
        phase: GamePhase.matchEnd,
        matchWinner: state.currentMatchWinner,
      );
    }
  }

  /// Start next round
  void nextRound() {
    state = state.copyWith(
      phase: GamePhase.idle,
      clearPlayerChoice: true,
      clearComputerChoice: true,
      clearResult: true,
      currentRound: state.currentRound + 1,
      clearRemainingTime: true,
    );

    // Start timer if enabled
    if (state.timerEnabled) {
      _startTimer();
    }
  }

  /// Reset the current game (keep settings)
  void resetGame() {
    _timerCountdown?.cancel();
    _revealDelay?.cancel();

    state = RPSGameState(
      difficulty: state.difficulty,
      roundsMode: state.roundsMode,
      timerEnabled: state.timerEnabled,
      timerDuration: state.timerDuration,
      soundEnabled: state.soundEnabled,
      hapticEnabled: state.hapticEnabled,
    );
  }

  /// Reset all scores
  void resetScores() {
    state = state.copyWith(
      playerScore: 0,
      computerScore: 0,
      drawCount: 0,
      currentRound: 1,
      phase: GamePhase.idle,
      clearPlayerChoice: true,
      clearComputerChoice: true,
      clearResult: true,
      clearMatchWinner: true,
      playerHistory: [],
    );
  }

  /// Set difficulty level
  void setDifficulty(AIDifficulty difficulty) {
    state = state.copyWith(difficulty: difficulty);
  }

  /// Set rounds mode
  void setRoundsMode(GameRoundsMode mode) {
    state = state.copyWith(roundsMode: mode);
    resetScores();
  }

  /// Toggle timer mode
  void toggleTimer() {
    state = state.copyWith(timerEnabled: !state.timerEnabled);
  }

  /// Set timer duration
  void setTimerDuration(int seconds) {
    state = state.copyWith(timerDuration: seconds);
  }

  /// Toggle sound
  void toggleSound() {
    state = state.copyWith(soundEnabled: !state.soundEnabled);
  }

  /// Toggle haptic feedback
  void toggleHaptic() {
    state = state.copyWith(hapticEnabled: !state.hapticEnabled);
  }

  /// Start the countdown timer
  void _startTimer() {
    state = state.copyWith(
      remainingTime: state.timerDuration,
      phase: GamePhase.selecting,
    );

    _timerCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingTime == null || state.remainingTime! <= 1) {
        timer.cancel();
        // Auto-select random choice if timer expires
        if (state.phase == GamePhase.selecting) {
          makeChoice(RPSAILogic.getRandomChoice());
        }
      } else {
        state = state.copyWith(remainingTime: state.remainingTime! - 1);
      }
    });
  }

  /// Start a game with timer
  void startWithTimer() {
    if (state.timerEnabled) {
      _startTimer();
    }
  }

  /// Play sound effect
  Future<void> _playSound(String type) async {
    if (!state.soundEnabled) return;

    // Using system sounds as placeholder
    // In production, you'd use actual audio files
    try {
      switch (type) {
        case 'tap':
          await _audioPlayer.play(AssetSource('sounds/tap.mp3'));
          break;
        case 'win':
          await _audioPlayer.play(AssetSource('sounds/win.mp3'));
          break;
        case 'lose':
          await _audioPlayer.play(AssetSource('sounds/lose.mp3'));
          break;
      }
    } catch (_) {
      // Sounds are optional, fail silently
    }
  }
}
