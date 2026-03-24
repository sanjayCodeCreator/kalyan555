import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/memory_match_game_notifier.dart';
import '../../data/models/memory_match_game_state.dart';
import '../../domain/memory_match_logic.dart';

/// Scoreboard widget showing game stats
class MMScoreboard extends ConsumerWidget {
  const MMScoreboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(memoryMatchGameProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Timer
          _StatItem(
            icon: _getTimerIcon(gameState),
            iconColor: _getTimerColor(gameState),
            label: 'Time',
            value: _getTimeDisplay(gameState),
          ),

          // Divider
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.withValues(alpha: 0.3),
          ),

          // Moves
          _StatItem(
            icon: Icons.touch_app_rounded,
            iconColor: const Color(0xFF9C27B0),
            label: 'Moves',
            value: _getMovesDisplay(gameState),
          ),

          // Divider
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.withValues(alpha: 0.3),
          ),

          // Matched
          _StatItem(
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF4CAF50),
            label: 'Matched',
            value: '${gameState.matchedPairs}/${gameState.gridSize.totalPairs}',
          ),

          // Hint button
          if (gameState.phase == GamePhase.playing)
            _HintButton(
              hintsRemaining: gameState.hintsRemaining,
              onTap: () {
                ref.read(memoryMatchGameProvider.notifier).useHint();
              },
            ),
        ],
      ),
    );
  }

  IconData _getTimerIcon(MemoryMatchGameState state) {
    if (state.mode == GameMode.timed) {
      return Icons.timer;
    }
    return Icons.access_time;
  }

  Color _getTimerColor(MemoryMatchGameState state) {
    if (state.mode == GameMode.timed && state.remainingTime != null) {
      if (state.remainingTime! < 10) {
        return Colors.red;
      } else if (state.remainingTime! < 30) {
        return Colors.orange;
      }
    }
    return const Color(0xFF2196F3);
  }

  String _getTimeDisplay(MemoryMatchGameState state) {
    if (state.mode == GameMode.timed && state.remainingTime != null) {
      return MemoryMatchLogic.formatTime(state.remainingTime!);
    }
    return MemoryMatchLogic.formatTime(state.elapsedSeconds);
  }

  String _getMovesDisplay(MemoryMatchGameState state) {
    if (state.mode == GameMode.limitedMoves && state.remainingMoves != null) {
      return '${state.moves}/${state.gridSize.defaultMoveLimit}';
    }
    return '${state.moves}';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}

class _HintButton extends StatelessWidget {
  final int hintsRemaining;
  final VoidCallback onTap;

  const _HintButton({required this.hintsRemaining, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isEnabled = hintsRemaining > 0;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isEnabled
              ? const Color(0xFFFF9800).withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled
                ? const Color(0xFFFF9800)
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 22,
              color: isEnabled ? const Color(0xFFFF9800) : Colors.grey,
            ),
            Text(
              '$hintsRemaining',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isEnabled ? const Color(0xFFFF9800) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
