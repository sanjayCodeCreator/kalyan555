import 'package:flutter/material.dart';
import 'package:sm_project/local_game_zones/features/rockpaper_scissors/data/models/rps_choice.dart';
import 'package:sm_project/local_game_zones/features/rockpaper_scissors/presentation/screens/rps_game_screen.dart';

/// Scoreboard widget for RPS game
class RPSScoreboard extends StatelessWidget {
  final int playerScore;
  final int computerScore;
  final int drawCount;
  final int? currentRound;
  final int? targetWins;
  final AIDifficulty difficulty;

  const RPSScoreboard({
    super.key,
    required this.playerScore,
    required this.computerScore,
    required this.drawCount,
    this.currentRound,
    this.targetWins,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),
          // Round indicator (for Best of X mode)
          if (currentRound != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 6),
                  Text(
                    targetWins != null
                        ? 'Round $currentRound • First to $targetWins wins'
                        : 'Round $currentRound',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Difficulty indicator
                  DifficultyBadge(difficulty: difficulty),
                ],
              ),
            ),

          // Scores row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Player score
              _ScoreItem(
                label: 'You',
                score: playerScore,
                color: const Color(0xFF4ECDC4),
                icon: '👤',
              ),

              // VS
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ),

              // Computer score
              _ScoreItem(
                label: 'CPU',
                score: computerScore,
                color: const Color(0xFFFF6B6B),
                icon: '🤖',
              ),
            ],
          ),

          Text(
            'Draws: $drawCount',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final String icon;

  const _ScoreItem({
    required this.label,
    required this.score,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),

        Text(
          label,
          style: TextStyle(fontSize: 14, color: color.withValues(alpha: 0.8)),
        ),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Text(
            '$score',
            key: ValueKey(score),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
