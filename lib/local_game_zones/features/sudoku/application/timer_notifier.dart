import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the timer notifier
final timerProvider = StateNotifierProvider.autoDispose<TimerNotifier, int>((ref) {
  return TimerNotifier();
});

/// State notifier for game timer
class TimerNotifier extends StateNotifier<int> {
  Timer? _timer;
  bool _isPaused = false;

  TimerNotifier() : super(0);

  /// Start the timer
  void start() {
    if (_timer != null) return;
    _isPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused) {
        state++;
      }
    });
  }

  /// Pause the timer
  void pause() {
    _isPaused = true;
  }

  /// Resume the timer
  void resume() {
    _isPaused = false;
  }

  /// Stop and reset the timer
  void reset() {
    _timer?.cancel();
    _timer = null;
    _isPaused = false;
    state = 0;
  }

  /// Set the timer to a specific value (for resuming saved games)
  void setTime(int seconds) {
    state = seconds;
  }

  /// Get formatted time string
  String get formattedTime {
    final minutes = state ~/ 60;
    final seconds = state % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if timer is running
  bool get isRunning => _timer != null && !_isPaused;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider for checking if the game is paused
final isGamePausedProvider = StateProvider<bool>((ref) => false);

/// Format seconds into MM:SS
String formatTime(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}
