import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/game_state.dart';

/// Card widget for selecting a difficulty level
class DifficultyCard extends StatelessWidget {
  final Difficulty difficulty;
  final String? bestTime;
  final VoidCallback onTap;

  const DifficultyCard({
    super.key,
    required this.difficulty,
    this.bestTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getColor().withValues(alpha: 0.15),
              _getColor().withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getColor().withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getColor().withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getGradientColors(),
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _getColor().withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getIcon(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty.label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getColor(),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDescription(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Best time
            if (bestTime != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bestTime!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),

            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: _getColor().withValues(alpha: 0.5),
              size: 20,
            ),
          ],
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

  List<Color> _getGradientColors() {
    switch (difficulty) {
      case Difficulty.easy:
        return [Colors.green.shade400, Colors.teal.shade500];
      case Difficulty.medium:
        return [Colors.orange.shade400, Colors.deepOrange.shade500];
      case Difficulty.hard:
        return [Colors.red.shade400, Colors.pink.shade500];
      case Difficulty.expert:
        return [Colors.purple.shade400, Colors.indigo.shade500];
    }
  }

  String _getIcon() {
    switch (difficulty) {
      case Difficulty.easy:
        return '🌱';
      case Difficulty.medium:
        return '🔥';
      case Difficulty.hard:
        return '💪';
      case Difficulty.expert:
        return '🧠';
    }
  }

  String _getDescription() {
    switch (difficulty) {
      case Difficulty.easy:
        return '~${difficulty.clueCount} clues • Perfect for beginners';
      case Difficulty.medium:
        return '~${difficulty.clueCount} clues • A balanced challenge';
      case Difficulty.hard:
        return '~${difficulty.clueCount} clues • Test your skills';
      case Difficulty.expert:
        return '~${difficulty.clueCount} clues • Only for masters';
    }
  }
}
