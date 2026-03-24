import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/stats_notifier.dart';
import '../../data/models/stats_model.dart';
import '../../domain/puzzle_generator.dart';

/// Statistics screen for Logic Grid Puzzle
class LGPStatsScreen extends ConsumerWidget {
  const LGPStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(logicGridStatsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                    ).createShader(bounds),
                    child: const Text(
                      '📊 Statistics',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Overall stats
              _buildOverallStats(stats),

              const SizedBox(height: 24),

              // Stats by difficulty
              _buildDifficultyStats(stats),

              const SizedBox(height: 24),

              // Achievements
              _buildAchievements(stats),

              const SizedBox(height: 24),

              // Reset button
              Center(
                child: TextButton.icon(
                  onPressed: () => _showResetDialog(context, ref),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red),
                  label: const Text(
                    'Reset Statistics',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallStats(LogicGridStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCircle(
                value: '${stats.gamesPlayed}',
                label: 'Played',
                color: Colors.blue,
              ),
              _buildStatCircle(
                value: '${stats.gamesWon}',
                label: 'Won',
                color: Colors.green,
              ),
              _buildStatCircle(
                value: '${stats.winRate.toStringAsFixed(0)}%',
                label: 'Win Rate',
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Current Streak', '${stats.currentStreak}',
                  Icons.local_fire_department_rounded, Colors.orange),
              _buildStatItem('Best Streak', '${stats.bestStreak}',
                  Icons.emoji_events_rounded, Colors.amber),
              _buildStatItem('Hints Used', '${stats.totalHintsUsed}',
                  Icons.lightbulb_rounded, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCircle({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyStats(LogicGridStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'By Difficulty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...Difficulty.values.map((d) => _buildDifficultyRow(d, stats)),
        ],
      ),
    );
  }

  Widget _buildDifficultyRow(Difficulty difficulty, LogicGridStats stats) {
    final played = stats.gamesPlayedByDifficulty[difficulty] ?? 0;
    final won = stats.gamesWonByDifficulty[difficulty] ?? 0;
    final bestTime = stats.bestTimes[difficulty];
    final avgTime = stats.getAverageTime(difficulty);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(difficulty).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  difficulty.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getDifficultyColor(difficulty),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$won / $played solved',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Best: ${bestTime != null ? LogicGridStats.formatTime(bestTime) : '--:--'}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'Avg: ${avgTime > 0 ? LogicGridStats.formatTime(avgTime) : '--:--'}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(LogicGridStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAchievement('🏆', 'First Win', stats.hasFirstWin),
              _buildAchievement('🧠', 'No Hints', stats.hasNoHintWin),
              _buildAchievement('⚡', 'Speed Solver', stats.hasSpeedSolver),
              _buildAchievement('🔥', 'Streak Master', stats.hasStreakMaster),
              _buildAchievement('👑', 'Logic Master', stats.hasMaster),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievement(String emoji, String name, bool unlocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: unlocked
            ? Colors.amber.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked
              ? Colors.amber.withOpacity(0.5)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: 16,
              color: unlocked ? null : Colors.grey,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: unlocked ? Colors.amber.shade800 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Reset Statistics?'),
          ],
        ),
        content: const Text(
            'This will permanently delete all your statistics and achievements.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(logicGridStatsProvider.notifier).resetStats();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
