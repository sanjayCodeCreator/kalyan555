import 'package:flutter/material.dart';

import '../../data/models/game_state.dart';

/// Individual cell widget for the game board
class GameCell extends StatelessWidget {
  final int index;
  final Player player;
  final bool isWinningCell;
  final VoidCallback onTap;

  const GameCell({
    super.key,
    required this.index,
    required this.player,
    required this.isWinningCell,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isWinningCell
              ? (player == Player.x
                    ? const Color(0xFFFF6B6B).withValues(alpha: 0.3)
                    : const Color(0xFF4ECDC4).withValues(alpha: 0.3))
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isWinningCell
                ? (player == Player.x
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF4ECDC4))
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isWinningCell ? 3 : 1,
          ),
          boxShadow: player != Player.none
              ? [
                  BoxShadow(
                    color:
                        (player == Player.x
                                ? const Color(0xFFFF6B6B)
                                : const Color(0xFF4ECDC4))
                            .withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: player != Player.none ? 1.0 : 0.0,
            curve: Curves.elasticOut,
            child: Text(
              player.symbol,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: player == Player.x
                    ? const Color(0xFFFF6B6B)
                    : const Color(0xFF4ECDC4),
                shadows: [
                  Shadow(
                    color:
                        (player == Player.x
                                ? const Color(0xFFFF6B6B)
                                : const Color(0xFF4ECDC4))
                            .withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
