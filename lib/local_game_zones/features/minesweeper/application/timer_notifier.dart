import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the Minesweeper timer
final minesweeperTimerProvider =
    StateNotifierProvider<MinesweeperTimerNotifier, int>((ref) {
  return MinesweeperTimerNotifier();
});

/// Timer state notifier for Minesweeper game
class MinesweeperTimerNotifier extends StateNotifier<int> {
  Timer? _timer;
  bool _isPaused = false;

  MinesweeperTimerNotifier() : super(0);

  /// Start the timer
  void start() {
    if (_timer != null) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        state = state + 1;
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

  /// Reset the timer
  void reset() {
    _timer?.cancel();
    _timer = null;
    _isPaused = false;
    if (mounted) {
      state = 0;
    }
  }

  /// Stop the timer
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Set time to specific value (for resume game)
  void setTime(int seconds) {
    if (mounted) {
      state = seconds;
    }
  }

  /// Get formatted time string (mm:ss)
  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Get formatted time for display (000)
  static String formatTimeDigital(int seconds) {
    if (seconds > 999) return '999';
    return seconds.toString().padLeft(3, '0');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
