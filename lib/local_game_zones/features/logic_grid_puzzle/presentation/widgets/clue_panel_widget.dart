import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../domain/puzzle_models.dart';

/// Panel for displaying game clues
class CluePanelWidget extends ConsumerWidget {
  const CluePanelWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(logicGridGameProvider);
    final puzzle = gameState.puzzle;

    if (puzzle == null || puzzle.clues.isEmpty) {
      return const Center(child: Text('No clues available'));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C63FF).withOpacity(0.1),
                  const Color(0xFF4ECDC4).withOpacity(0.1),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Color(0xFF6C63FF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Clues',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF),
                  ),
                ),
                const Spacer(),
                Text(
                  '${puzzle.clues.length} clues',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Clue list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: puzzle.clues.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final clue = puzzle.clues[index];
                final isHighlighted = gameState.highlightedClueId == clue.id;

                return _ClueItem(
                  clue: clue,
                  isHighlighted: isHighlighted,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(logicGridGameProvider.notifier)
                        .highlightClue(clue.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ClueItem extends StatelessWidget {
  final Clue clue;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _ClueItem({
    required this.clue,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isHighlighted
              ? const Color(0xFF6C63FF).withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFF6C63FF).withOpacity(0.4)
                : Colors.grey.shade200,
            width: isHighlighted ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClueIcon(),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                clue.text,
                style: TextStyle(
                  fontSize: 14,
                  color: isHighlighted
                      ? const Color(0xFF6C63FF)
                      : Colors.grey.shade800,
                  fontWeight:
                      isHighlighted ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClueIcon() {
    IconData icon;
    Color color;

    switch (clue.type) {
      case ClueType.direct:
        icon = Icons.link_rounded;
        color = Colors.green;
        break;
      case ClueType.negative:
        icon = Icons.link_off_rounded;
        color = Colors.red;
        break;
      case ClueType.comparative:
        icon = Icons.compare_arrows_rounded;
        color = Colors.orange;
        break;
      case ClueType.conditional:
        icon = Icons.call_split_rounded;
        color = Colors.blue;
        break;
    }

    return Icon(icon, size: 18, color: color.withOpacity(0.8));
  }
}
