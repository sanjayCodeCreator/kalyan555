import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/memory_match_game_notifier.dart';
import 'memory_card.dart';

/// Responsive grid of memory cards
class MemoryGrid extends ConsumerWidget {
  final double maxHeight;

  const MemoryGrid({super.key, this.maxHeight = 500});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(memoryMatchGameProvider);

    if (gameState.cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final gridSize = gameState.gridSize.size;
        final spacing = gameState.isKidsMode ? 12.0 : 8.0;

        // Calculate card size based on available space
        final availableWidth =
            constraints.maxWidth - (spacing * (gridSize - 1));
        final availableHeight = maxHeight - (spacing * (gridSize - 1));

        final cardWidth = availableWidth / gridSize;
        final cardHeight = availableHeight / gridSize;
        final cardSize = cardWidth < cardHeight ? cardWidth : cardHeight;

        return Center(
          child: SizedBox(
            width: (cardSize * gridSize) + (spacing * (gridSize - 1)),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
              ),
              itemCount: gameState.cards.length,
              itemBuilder: (context, index) {
                return _buildAnimatedCard(
                  ref: ref,
                  card: gameState.cards[index],
                  index: index,
                  cardSize: cardSize,
                  isKidsMode: gameState.isKidsMode,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCard({
    required WidgetRef ref,
    required dynamic card,
    required int index,
    required double cardSize,
    required bool isKidsMode,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 30)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: MemoryCard(
              card: card,
              size: cardSize,
              isKidsMode: isKidsMode,
              onTap: () {
                ref.read(memoryMatchGameProvider.notifier).flipCard(index);
              },
            ),
          ),
        );
      },
    );
  }
}
