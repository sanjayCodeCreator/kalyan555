import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/game_state.dart';
import 'game_notifier.dart';

/// Timer state
class WSTimerState {
  final int seconds;
  final bool isRunning;
  final WSTimerMode mode;
  final int timeLimit;

  const WSTimerState({
    this.seconds = 0,
    this.isRunning = false,
    this.mode = WSTimerMode.countUp,
    this.timeLimit = 300,
  });

  WSTimerState copyWith({
    int? seconds,
    bool? isRunning,
    WSTimerMode? mode,
    int? timeLimit,
  }) {
    return WSTimerState(
      seconds: seconds ?? this.seconds,
      isRunning: isRunning ?? this.isRunning,
      mode: mode ?? this.mode,
      timeLimit: timeLimit ?? this.timeLimit,
    );
  }

  /// Format time as MM:SS
  String get formattedTime {
    final displayTime = mode == WSTimerMode.countdown
        ? (timeLimit - seconds).clamp(0, timeLimit)
        : seconds;
    final minutes = displayTime ~/ 60;
    final secs = displayTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Check if time is up (countdown mode)
  bool get isTimeUp => mode == WSTimerMode.countdown && seconds >= timeLimit;
}

/// Provider for the timer notifier
final wsTimerProvider =
    StateNotifierProvider.autoDispose<WSTimerNotifier, WSTimerState>((ref) {
  return WSTimerNotifier(ref);
});

/// State notifier for managing game timer
class WSTimerNotifier extends StateNotifier<WSTimerState> {
  final Ref _ref;
  Timer? _timer;

  WSTimerNotifier(this._ref) : super(const WSTimerState());

  /// Start the timer
  void start({
    WSTimerMode mode = WSTimerMode.countUp,
    int timeLimit = 300,
  }) {
    stop();

    state = WSTimerState(
      seconds: 0,
      isRunning: true,
      mode: mode,
      timeLimit: timeLimit,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isRunning) return;

      final newSeconds = state.seconds + 1;
      state = state.copyWith(seconds: newSeconds);

      // Update game notifier
      _ref.read(wordSearchGameProvider.notifier).updateElapsedTime(newSeconds);
    });
  }

  /// Pause the timer
  void pause() {
    state = state.copyWith(isRunning: false);
  }

  /// Resume the timer
  void resume() {
    state = state.copyWith(isRunning: true);
  }

  /// Stop and reset the timer
  void stop() {
    _timer?.cancel();
    _timer = null;
    state = const WSTimerState();
  }

  /// Reset the timer without stopping
  void reset() {
    state = state.copyWith(seconds: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
