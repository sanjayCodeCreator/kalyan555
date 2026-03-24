import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/rps_stats_notifier.dart';
import '../../data/models/rps_player_stats.dart';

/// Statistics and achievements screen
class RPSStatsScreen extends ConsumerWidget {
  const RPSStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(rpsStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _showResetDialog(context, ref),
            tooltip: 'Reset Stats',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview card
              _OverviewCard(stats: stats),

              const SizedBox(height: 24),

              // Win rate
              _WinRateCard(stats: stats),

              const SizedBox(height: 24),

              // Choice frequency
              _ChoiceFrequencyCard(stats: stats),

              const SizedBox(height: 24),

              // Achievements
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _AchievementsGrid(unlockedIds: stats.unlockedAchievements),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Statistics?'),
        content: const Text(
          'This will clear all your stats and achievements. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(rpsStatsProvider.notifier).resetStats();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final RPSPlayerStats stats;

  const _OverviewCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6C63FF).withValues(alpha: 0.2),
            const Color(0xFF4ECDC4).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Text(
            '📊 Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Total Games',
                value: '${stats.totalMatches}',
                color: const Color(0xFF6C63FF),
              ),
              _StatItem(
                label: 'Wins',
                value: '${stats.totalWins}',
                color: const Color(0xFF4ECDC4),
              ),
              _StatItem(
                label: 'Losses',
                value: '${stats.totalLosses}',
                color: const Color(0xFFFF6B6B),
              ),
              _StatItem(
                label: 'Draws',
                value: '${stats.totalDraws}',
                color: const Color(0xFFFFE66D),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Current Streak',
                value: '${stats.currentWinStreak}',
                color: const Color(0xFFFF6B6B),
                icon: '🔥',
              ),
              _StatItem(
                label: 'Best Streak',
                value: '${stats.bestWinStreak}',
                color: const Color(0xFFFFE66D),
                icon: '⭐',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (icon != null) Text(icon!, style: const TextStyle(fontSize: 20)),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _WinRateCard extends StatelessWidget {
  final RPSPlayerStats stats;

  const _WinRateCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final winRate = stats.winRate;
    final color = winRate >= 50
        ? const Color(0xFF4ECDC4)
        : const Color(0xFFFF6B6B);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
              border: Border.all(color: color, width: 4),
            ),
            child: Center(
              child: Text(
                '${winRate.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Win Rate',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  winRate >= 50
                      ? 'Great job! Keep it up! 🎉'
                      : 'Keep practicing! You\'ll improve! 💪',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceFrequencyCard extends StatelessWidget {
  final RPSPlayerStats stats;

  const _ChoiceFrequencyCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats.choiceFrequency.values.fold(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 Choice Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...stats.choiceFrequency.entries.map((entry) {
            final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ChoiceBar(
                emoji: entry.key.emoji,
                name: entry.key.displayName,
                count: entry.value,
                percentage: percentage,
              ),
            );
          }),
          if (stats.mostUsedChoice != null)
            Text(
              'Favorite: ${stats.mostUsedChoice!.displayName} ${stats.mostUsedChoice!.emoji}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChoiceBar extends StatelessWidget {
  final String emoji;
  final String name;
  final int count;
  final double percentage;

  const _ChoiceBar({
    required this.emoji,
    required this.name,
    required this.count,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  Text(
                    '$count (${percentage.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6C63FF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  final List<String> unlockedIds;

  const _AchievementsGrid({required this.unlockedIds});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: RPSAchievement.all.length,
      itemBuilder: (context, index) {
        final achievement = RPSAchievement.all[index];
        final isUnlocked = unlockedIds.contains(achievement.id);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUnlocked
                ? const Color(0xFF4ECDC4).withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnlocked
                  ? const Color(0xFF4ECDC4).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isUnlocked ? achievement.icon : '🔒',
                style: TextStyle(
                  fontSize: 28,
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                achievement.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.white : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 10,
                  color: isUnlocked
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.grey.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
