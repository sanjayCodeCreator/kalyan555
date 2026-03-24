/// Statistics screen for Matchstick Puzzle

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/stats_notifier.dart';
import '../../domain/matchstick_models.dart';

/// Stats and achievements screen
class MPStatsScreen extends ConsumerWidget {
  const MPStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(matchstickStatsProvider);
    final achievements =
        ref.read(matchstickStatsProvider.notifier).getAllAchievements();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF0F0F23),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white70,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Statistics',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main stats
                      _buildStatsCard([
                        _StatItem(
                          icon: '🧩',
                          value: '${stats.totalPuzzlesSolved}',
                          label: 'Puzzles Solved',
                        ),
                        _StatItem(
                          icon: '⭐',
                          value: '${stats.totalStars}',
                          label: 'Total Stars',
                        ),
                        _StatItem(
                          icon: '🎯',
                          value: '${stats.perfectSolves}',
                          label: 'Perfect Solves',
                        ),
                        _StatItem(
                          icon: '💡',
                          value: '${stats.totalHintsUsed}',
                          label: 'Hints Used',
                        ),
                      ]),

                      const SizedBox(height: 20),

                      // Performance stats
                      _buildStatsCard([
                        _StatItem(
                          icon: '🏃',
                          value: stats.averageMoves.toStringAsFixed(1),
                          label: 'Avg Moves',
                        ),
                        _StatItem(
                          icon: '🔥',
                          value: '${stats.bestNoHintStreak}',
                          label: 'Best Streak',
                        ),
                        _StatItem(
                          icon: '⏱️',
                          value: stats.formattedTimePlayed,
                          label: 'Time Played',
                        ),
                        _StatItem(
                          icon: '📊',
                          value:
                              '${stats.completionPercentage.toStringAsFixed(0)}%',
                          label: 'Completion',
                        ),
                      ]),

                      const SizedBox(height: 24),

                      // Achievements section
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),

                      ...achievements.map((a) => _buildAchievementCard(a)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(List<_StatItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items
            .map((item) => Expanded(
                  child: Column(
                    children: [
                      Text(item.icon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 8),
                      Text(
                        item.value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? const Color(0xFFF7931E).withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFFF7931E).withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? const Color(0xFFF7931E)
                  : Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getAchievementIcon(achievement.type),
              color: isUnlocked ? Colors.white : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.white : Colors.grey,
                  ),
                ),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnlocked
                        ? Colors.white.withValues(alpha: 0.7)
                        : Colors.grey.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(
              Icons.check_circle,
              color: Color(0xFF4ECDC4),
              size: 24,
            )
          else
            Icon(
              Icons.lock_outline,
              color: Colors.grey.withValues(alpha: 0.5),
              size: 24,
            ),
        ],
      ),
    );
  }

  IconData _getAchievementIcon(AchievementType type) {
    switch (type) {
      case AchievementType.firstSolve:
        return Icons.emoji_events;
      case AchievementType.perfectSolve:
        return Icons.star;
      case AchievementType.noHintStreak:
        return Icons.psychology;
      case AchievementType.speedster:
        return Icons.speed;
      case AchievementType.mathematician:
        return Icons.calculate;
      case AchievementType.shapemaster:
        return Icons.category;
      case AchievementType.collector:
        return Icons.collections;
      case AchievementType.completionist:
        return Icons.workspace_premium;
    }
  }
}

class _StatItem {
  final String icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });
}
