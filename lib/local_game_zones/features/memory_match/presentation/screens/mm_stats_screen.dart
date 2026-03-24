import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/memory_match_stats_notifier.dart';
import '../../data/models/memory_match_stats.dart';

/// Statistics screen for Memory Match
class MMStatsScreen extends ConsumerWidget {
  const MMStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(memoryMatchStatsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: colorScheme.surface,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, size: 18),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                  ).createShader(bounds),
                  child: const Text(
                    '📊 Statistics',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                centerTitle: true,
              ),
              actions: [
                IconButton(
                  onPressed: () => _showResetConfirmation(context, ref),
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset Stats',
                ),
              ],
            ),

            // Stats Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Overview Cards
                  _buildOverviewSection(stats),

                  const SizedBox(height: 24),

                  // Best Times Section
                  _buildBestTimesSection(stats),

                  const SizedBox(height: 24),

                  // Best Moves Section
                  _buildBestMovesSection(stats),

                  const SizedBox(height: 24),

                  // Achievements Section
                  _buildAchievementsSection(stats),

                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection(MemoryMatchStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.games,
                iconColor: const Color(0xFF2196F3),
                label: 'Games Played',
                value: '${stats.gamesPlayed}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.emoji_events,
                iconColor: const Color(0xFF4CAF50),
                label: 'Wins',
                value: '${stats.gamesWon}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.percent,
                iconColor: const Color(0xFF9C27B0),
                label: 'Win Rate',
                value: '${stats.winRate.toStringAsFixed(1)}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department,
                iconColor: const Color(0xFFE91E63),
                label: 'Best Streak',
                value: '${stats.longestWinStreak}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.star,
                iconColor: const Color(0xFFFFD700),
                label: 'Perfect Games',
                value: '${stats.perfectGames}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.lightbulb,
                iconColor: const Color(0xFFFF9800),
                label: 'Hints Used',
                value: '${stats.totalHintsUsed}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildBestTimesSection(MemoryMatchStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.timer, color: Color(0xFF2196F3)),
            SizedBox(width: 8),
            Text(
              'Best Times',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTimeRow('2×2 Easy', stats.bestTime2x2, const Color(0xFF4CAF50)),
        const SizedBox(height: 8),
        _buildTimeRow('4×4 Medium', stats.bestTime4x4, const Color(0xFF2196F3)),
        const SizedBox(height: 8),
        _buildTimeRow('6×6 Hard', stats.bestTime6x6, const Color(0xFFE91E63)),
      ],
    );
  }

  Widget _buildTimeRow(String label, int time, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            MemoryMatchStats.formatTime(time),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestMovesSection(MemoryMatchStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.touch_app, color: Color(0xFF9C27B0)),
            SizedBox(width: 8),
            Text(
              'Best Moves',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMovesRow(
          '2×2 Easy',
          stats.bestMoves2x2,
          2,
          const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 8),
        _buildMovesRow(
          '4×4 Medium',
          stats.bestMoves4x4,
          8,
          const Color(0xFF2196F3),
        ),
        const SizedBox(height: 8),
        _buildMovesRow(
          '6×6 Hard',
          stats.bestMoves6x6,
          18,
          const Color(0xFFE91E63),
        ),
      ],
    );
  }

  Widget _buildMovesRow(String label, int moves, int perfect, Color color) {
    final isPerfect = moves > 0 && moves == perfect;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          if (isPerfect) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '⭐ Perfect',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
          const Spacer(),
          Text(
            moves > 0 ? '$moves' : '--',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(MemoryMatchStats stats) {
    final allAchievements = [
      MemoryMatchAchievements.firstMatch,
      MemoryMatchAchievements.firstWin,
      MemoryMatchAchievements.perfectGame,
      MemoryMatchAchievements.noHints,
      MemoryMatchAchievements.speedster2x2,
      MemoryMatchAchievements.speedster4x4,
      MemoryMatchAchievements.speedster6x6,
      MemoryMatchAchievements.streakMaster3,
      MemoryMatchAchievements.streakMaster5,
      MemoryMatchAchievements.hardMaster,
      MemoryMatchAchievements.veteran10,
      MemoryMatchAchievements.veteran50,
      MemoryMatchAchievements.veteran100,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.military_tech, color: Color(0xFFFFD700)),
            const SizedBox(width: 8),
            const Text(
              'Achievements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${stats.achievements.length}/${allAchievements.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allAchievements.map((id) {
            final isUnlocked = stats.hasAchievement(id);
            return _buildAchievementChip(id, isUnlocked);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAchievementChip(String id, bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUnlocked
            ? const Color(0xFFFFD700).withValues(alpha: 0.2)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFFFFD700)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUnlocked ? Icons.check_circle : Icons.lock,
            size: 16,
            color: isUnlocked ? const Color(0xFFFFD700) : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            MemoryMatchAchievements.getName(id),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
              color: isUnlocked ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Statistics?'),
        content: const Text(
          'This will permanently delete all your game statistics and achievements. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(memoryMatchStatsProvider.notifier).resetStats();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Statistics reset'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
