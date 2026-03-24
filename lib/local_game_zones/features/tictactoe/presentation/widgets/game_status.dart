import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../data/models/game_state.dart' as models;

/// Widget displaying game status message
class GameStatusWidget extends ConsumerWidget {
  const GameStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final colorScheme = Theme.of(context).colorScheme;

    Color textColor;
    switch (gameState.status) {
      case models.GameStatus.xWins:
        textColor = const Color(0xFFFF6B6B);
        break;
      case models.GameStatus.oWins:
        textColor = const Color(0xFF4ECDC4);
        break;
      case models.GameStatus.draw:
        textColor = colorScheme.secondary;
        break;
      case models.GameStatus.playing:
        textColor = gameState.currentPlayer == models.Player.x
            ? const Color(0xFFFF6B6B)
            : const Color(0xFF4ECDC4);
        break;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(gameState.statusMessage),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: textColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: textColor.withValues(alpha: 0.3), width: 2),
        ),
        child: Text(
          gameState.statusMessage,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
