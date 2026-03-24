import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../application/timer_notifier.dart';

/// Game header with timer, score, and action buttons
class WSGameHeader extends ConsumerWidget {
  final VoidCallback onPause;
  final VoidCallback onHint;
  final VoidCallback onShuffle;

  const WSGameHeader({
    super.key,
    required this.onPause,
    required this.onHint,
    required this.onShuffle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(wordSearchGameProvider);
    final timerState = ref.watch(wsTimerProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Timer
          _buildInfoChip(
            icon: Icons.timer_outlined,
            label: timerState.formattedTime,
            color: timerState.isTimeUp ? Colors.red : const Color(0xFF4ECDC4),
          ),

          const SizedBox(width: 8),

          // Difficulty badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _getDifficultyColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getDifficultyColor(),
                width: 1,
              ),
            ),
            child: Text(
              gameState.difficulty.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getDifficultyColor(),
              ),
            ),
          ),

          const Spacer(),

          // Hint button
          _buildActionButton(
            icon: Icons.lightbulb_outline,
            label: '${gameState.hintsRemaining}',
            onTap: gameState.hintsRemaining > 0 ? onHint : null,
            color: const Color(0xFFFFD93D),
          ),

          const SizedBox(width: 8),

          // Shuffle button
          _buildActionButton(
            icon: Icons.refresh_rounded,
            onTap: onShuffle,
            color: const Color(0xFF6C63FF),
          ),

          const SizedBox(width: 8),

          // Pause button
          _buildActionButton(
            icon: Icons.pause_rounded,
            onTap: onPause,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    return const Color(0xFF4ECDC4);
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    String? label,
    VoidCallback? onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap != null
            ? () {
                HapticFeedback.lightImpact();
                onTap();
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: onTap != null ? 0.15 : 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: onTap != null ? 0.3 : 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: color.withValues(alpha: onTap != null ? 1.0 : 0.3),
              ),
              if (label != null) ...[
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color.withValues(alpha: onTap != null ? 1.0 : 0.3),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
