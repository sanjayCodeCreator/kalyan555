import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../application/timer_notifier.dart';
import '../../data/models/game_state.dart';

/// Header widget showing timer, mistakes, and hints
class GameHeader extends ConsumerWidget {
  const GameHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(sudokuGameProvider);
    final elapsedSeconds = ref.watch(timerProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade50,
            Colors.grey.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Difficulty badge
          _DifficultyBadge(difficulty: gameState.difficulty),

          // Timer
          _TimerDisplay(
            seconds: elapsedSeconds,
            isPaused: gameState.status == GameStatus.paused,
            onPauseTap: () {
              HapticFeedback.lightImpact();
              if (gameState.status == GameStatus.paused) {
                ref.read(sudokuGameProvider.notifier).resumeGame();
              } else {
                ref.read(sudokuGameProvider.notifier).pauseGame();
              }
            },
          ),

          // Mistakes counter
          _MistakesCounter(
            mistakes: gameState.mistakes,
            maxMistakes: gameState.maxMistakes,
          ),

          // Hints button
          _HintsButton(
            hintsRemaining: gameState.hintsRemaining,
            onTap: gameState.hintsRemaining > 0
                ? () {
                    HapticFeedback.lightImpact();
                    ref.read(sudokuGameProvider.notifier).useHint();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final Difficulty difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getColor().withValues(alpha: 0.3)),
      ),
      child: Text(
        difficulty.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _getColor(),
        ),
      ),
    );
  }

  Color _getColor() {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
      case Difficulty.expert:
        return Colors.purple;
    }
  }
}

class _TimerDisplay extends StatelessWidget {
  final int seconds;
  final bool isPaused;
  final VoidCallback onPauseTap;

  const _TimerDisplay({
    required this.seconds,
    required this.isPaused,
    required this.onPauseTap,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: onPauseTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            size: 20,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            timeString,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MistakesCounter extends StatelessWidget {
  final int mistakes;
  final int maxMistakes;

  const _MistakesCounter({
    required this.mistakes,
    required this.maxMistakes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.close_rounded,
          size: 18,
          color: mistakes > 0 ? Colors.red.shade600 : Colors.grey.shade500,
        ),
        const SizedBox(width: 2),
        Text(
          '$mistakes/$maxMistakes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: mistakes > 0 ? Colors.red.shade600 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _HintsButton extends StatelessWidget {
  final int hintsRemaining;
  final VoidCallback? onTap;

  const _HintsButton({
    required this.hintsRemaining,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade400, Colors.orange.shade500],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                '$hintsRemaining',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
