import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../application/timer_notifier.dart';
import '../../data/models/game_state.dart';

/// Game header with timer, mine counter, and restart button
class GameHeaderWidget extends ConsumerWidget {
  const GameHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(minesweeperGameProvider);
    final time = ref.watch(minesweeperTimerProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade600,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mine counter
          _DigitalDisplay(
            value: gameState.minesRemaining.clamp(0, 999),
            icon: '💣',
          ),

          // Face button (restart)
          _FaceButton(status: gameState.status),

          // Timer
          _DigitalDisplay(
            value: time.clamp(0, 999),
            icon: '⏱️',
          ),
        ],
      ),
    );
  }
}

/// Digital display for mine count and timer
class _DigitalDisplay extends StatelessWidget {
  final int value;
  final String icon;

  const _DigitalDisplay({
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.grey.shade700,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            value.toString().padLeft(3, '0'),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF0000),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Face button for restart
class _FaceButton extends ConsumerWidget {
  final GameStatus status;

  const _FaceButton({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(minesweeperGameProvider.notifier).newGame();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.yellow.shade200,
              Colors.yellow.shade400,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.grey.shade600,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Text(
            _getFaceEmoji(),
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }

  String _getFaceEmoji() {
    switch (status) {
      case GameStatus.idle:
        return '🙂';
      case GameStatus.playing:
        return '🙂';
      case GameStatus.paused:
        return '😴';
      case GameStatus.won:
        return '😎';
      case GameStatus.lost:
        return '😵';
    }
  }
}

/// Control bar with flag mode and hint button
class GameControlBar extends ConsumerWidget {
  const GameControlBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(minesweeperGameProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Flag mode toggle
          _ControlButton(
            icon: '🚩',
            label: 'Flag',
            isActive: gameState.flagMode,
            onTap: () {
              ref.read(minesweeperGameProvider.notifier).toggleFlagMode();
            },
          ),

          // Hint button
          _ControlButton(
            icon: '💡',
            label: 'Hint (${gameState.hintsRemaining})',
            isActive: false,
            onTap: gameState.status == GameStatus.playing &&
                    gameState.hintsRemaining > 0
                ? () {
                    ref.read(minesweeperGameProvider.notifier).useHint();
                  }
                : null,
          ),

          // Pause/Resume button
          if (gameState.status == GameStatus.playing ||
              gameState.status == GameStatus.paused)
            _ControlButton(
              icon: gameState.status == GameStatus.paused ? '▶️' : '⏸️',
              label: gameState.status == GameStatus.paused ? 'Resume' : 'Pause',
              isActive: false,
              onTap: () {
                if (gameState.status == GameStatus.paused) {
                  ref.read(minesweeperGameProvider.notifier).resumeGame();
                } else {
                  ref.read(minesweeperGameProvider.notifier).pauseGame();
                }
              },
            ),
        ],
      ),
    );
  }
}

/// Control button widget
class _ControlButton extends StatelessWidget {
  final String icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.orange.shade200
              : onTap == null
                  ? Colors.grey.shade300
                  : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.orange : Colors.grey.shade400,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: onTap == null ? Colors.grey : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
