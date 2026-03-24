import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../data/models/game_state.dart';
import '../../data/models/word_placement.dart';

/// Word list panel showing target words
class WordListPanel extends ConsumerWidget {
  const WordListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(wordSearchGameProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Find ${gameState.totalWords} Words',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${gameState.wordsFoundCount}/${gameState.totalWords}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4ECDC4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Word chips - scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: gameState.wordPlacements.map((placement) {
                  return _WordChip(
                    placement: placement,
                    isFound: gameState.foundWordIds.contains(placement.wordId),
                    isHighlighted:
                        gameState.highlightedWordId == placement.wordId,
                    color: _getWordColor(placement, gameState),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getWordColor(WordPlacement placement, WordSearchGameState gameState) {
    final index = gameState.wordPlacements.indexOf(placement);
    if (index >= 0 && index < gameState.wordColors.length) {
      return gameState.wordColors[index];
    }
    return const Color(0xFF4ECDC4);
  }
}

/// Individual word chip
class _WordChip extends StatelessWidget {
  final WordPlacement placement;
  final bool isFound;
  final bool isHighlighted;
  final Color color;

  const _WordChip({
    required this.placement,
    required this.isFound,
    required this.isHighlighted,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isFound
            ? color.withValues(alpha: 0.2)
            : isHighlighted
                ? const Color(0xFFFFD93D).withValues(alpha: 0.2)
                : Colors.grey.shade800.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFound
              ? color
              : isHighlighted
                  ? const Color(0xFFFFD93D)
                  : Colors.grey.shade700,
          width: 1.5,
        ),
      ),
      child: Text(
        placement.word,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isFound
              ? color
              : isHighlighted
                  ? const Color(0xFFFFD93D)
                  : Colors.white.withValues(alpha: 0.8),
          decoration: isFound ? TextDecoration.lineThrough : null,
          decorationColor: color,
          decorationThickness: 2,
        ),
      ),
    );
  }
}
