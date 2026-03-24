/// Game header widget for Matchstick Puzzle

import 'package:flutter/material.dart';
import '../../domain/matchstick_models.dart';

/// Header showing puzzle info, moves, hints, and timer
class GameHeaderWidget extends StatelessWidget {
  final MatchstickPuzzle? puzzle;
  final int moveCount;
  final int hintsRemaining;
  final String timer;
  final VoidCallback onBack;

  const GameHeaderWidget({
    super.key,
    required this.puzzle,
    required this.moveCount,
    required this.hintsRemaining,
    required this.timer,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top row with back button and title
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70,
                ),
              ),
              Expanded(
                child: Text(
                  puzzle?.title ?? 'Matchstick Puzzle',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance
            ],
          ),
          const SizedBox(height: 8),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatChip(
                icon: Icons.touch_app_rounded,
                value: '$moveCount',
                label: 'Moves',
                color: const Color(0xFFF7931E),
                subtext: puzzle != null ? '/${puzzle!.allowedMoves}' : null,
              ),
              _buildStatChip(
                icon: Icons.timer_outlined,
                value: timer,
                label: 'Time',
                color: const Color(0xFF4ECDC4),
              ),
              _buildStatChip(
                icon: Icons.lightbulb_outline,
                value: '$hintsRemaining',
                label: 'Hints',
                color: const Color(0xFFFFD54F),
              ),
              _buildDifficultyChip(puzzle?.difficulty),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    String? subtext,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (subtext != null)
                Text(
                  subtext,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(Difficulty? difficulty) {
    final color = _getDifficultyColor(difficulty);
    final label = _getDifficultyLabel(difficulty);
    final icon = _getDifficultyIcon(difficulty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            'Level',
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(Difficulty? difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return const Color(0xFF4CAF50);
      case Difficulty.medium:
        return const Color(0xFFFF9800);
      case Difficulty.hard:
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyLabel(Difficulty? difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Med';
      case Difficulty.hard:
        return 'Hard';
      default:
        return '?';
    }
  }

  IconData _getDifficultyIcon(Difficulty? difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Icons.sentiment_satisfied_alt;
      case Difficulty.medium:
        return Icons.sentiment_neutral;
      case Difficulty.hard:
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }
}
