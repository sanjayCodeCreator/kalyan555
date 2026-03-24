/// Timer notifier for Matchstick Puzzle
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Timer state
class TimerState {
  final int seconds;
  final bool isRunning;

  const TimerState({
    this.seconds = 0,
    this.isRunning = false,
  });

  TimerState copyWith({
    int? seconds,
    bool? isRunning,
  }) {
    return TimerState(
      seconds: seconds ?? this.seconds,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  String get formatted {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

/// Provider for timer
final matchstickTimerProvider =
    StateNotifierProvider.autoDispose<MatchstickTimerNotifier, TimerState>((ref) {
  return MatchstickTimerNotifier();
});

/// Timer notifier for game
class MatchstickTimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;
  bool _disposed = false;

  MatchstickTimerNotifier() : super(const TimerState());

  /// Start the timer
  void start({int initialSeconds = 0}) {
    _timer?.cancel();
    if (_disposed) return;
    state = TimerState(seconds: initialSeconds, isRunning: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_disposed && state.isRunning) {
        state = state.copyWith(seconds: state.seconds + 1);
      }
    });
  }

  /// Pause the timer
  void pause() {
    state = state.copyWith(isRunning: false);
  }

  /// Resume the timer
  void resume() {
    if (!state.isRunning) {
      state = state.copyWith(isRunning: true);
    }
  }

  /// Stop and reset the timer
  void stop() {
    _timer?.cancel();
    _timer = null;
    state = const TimerState();
  }

  /// Reset but keep timer running
  void reset() {
    state = state.copyWith(seconds: 0);
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
