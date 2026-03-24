import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_notifier.dart';

/// Provider for the game timer
final logicGridTimerProvider =
    StateNotifierProvider.autoDispose<LogicGridTimerNotifier, int>((ref) {
  return LogicGridTimerNotifier(ref);
});

/// Timer state notifier for Logic Grid Puzzle
class LogicGridTimerNotifier extends StateNotifier<int> {
  final Ref _ref;
  Timer? _timer;

  LogicGridTimerNotifier(this._ref) : super(0);

  /// Start the timer
  void start() {
    stop();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state++;
      _ref.read(logicGridGameProvider.notifier).updateElapsedTime(state);
    });
  }

  /// Stop the timer
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Reset the timer
  void reset() {
    stop();
    state = 0;
  }

  /// Pause the timer
  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  /// Resume the timer
  void resume() {
    if (_timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        state++;
        _ref.read(logicGridGameProvider.notifier).updateElapsedTime(state);
      });
    }
  }

  /// Format time as mm:ss
  String get formattedTime {
    final minutes = state ~/ 60;
    final seconds = state % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
