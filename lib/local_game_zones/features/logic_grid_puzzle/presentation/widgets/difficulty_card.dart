import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/puzzle_generator.dart';

/// Card widget for difficulty selection
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
    final colors = _getColors();

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors[0].withOpacity(0.2),
              colors[1].withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors[0].withOpacity(0.4),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  _getIcon(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty.displayName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors[0],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getSubtitle(),
                    style: TextStyle(
                      fontSize: 14,
                      color: colors[0].withOpacity(0.7),
                    ),
                  ),
                  if (bestTime != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          size: 14,
                          color: colors[0].withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Best: $bestTime',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors[0].withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: colors[0].withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getColors() {
    switch (difficulty) {
      case Difficulty.easy:
        return const [Color(0xFF4CAF50), Color(0xFF81C784)];
      case Difficulty.medium:
        return const [Color(0xFFFFA726), Color(0xFFFFB74D)];
      case Difficulty.hard:
        return const [Color(0xFFEF5350), Color(0xFFE57373)];
    }
  }

  String _getIcon() {
    switch (difficulty) {
      case Difficulty.easy:
        return '🟢';
      case Difficulty.medium:
        return '🟡';
      case Difficulty.hard:
        return '🔴';
    }
  }

  String _getSubtitle() {
    switch (difficulty) {
      case Difficulty.easy:
        return '3×3 grid, direct clues';
      case Difficulty.medium:
        return '4×4 grid, more categories';
      case Difficulty.hard:
        return '5×5 grid, complex clues';
    }
  }
}
