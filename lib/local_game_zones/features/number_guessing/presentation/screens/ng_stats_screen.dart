import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/ng_stats_notifier.dart';
import '../../data/models/ng_difficulty.dart';
import '../../data/models/ng_player_stats.dart';
import '../widgets/stats_card.dart';
import 'ng_achievements_screen.dart';

/// Statistics dashboard screen
class NGStatsScreen extends ConsumerWidget {
  const NGStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(ngStatsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App bar
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '📊 Statistics',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NGAchievementsScreen(),
                      ),
                    ),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        size: 18,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats content
              Expanded(
                child: ListView(
                  children: [
                    // Main stats row
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Total Games',
                            value: '${stats.totalGames}',
                            icon: '🎮',
                            colors: const [
                              Color(0xFF667eea),
                              Color(0xFF764ba2),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'Win Rate',
                            value: '${stats.winRate.toStringAsFixed(1)}%',
                            icon: '📈',
                            colors: const [
                              Color(0xFF4ECDC4),
                              Color(0xFF44CF6C),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Wins',
                            value: '${stats.totalWins}',
                            icon: '🏆',
                            colors: const [
                              Color(0xFF4ECDC4),
                              Color(0xFF44CF6C),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            title: 'Best Streak',
                            value: '${stats.bestWinStreak}',
                            icon: '🔥',
                            colors: const [
                              Color(0xFFFF6B6B),
                              Color(0xFFEE0979),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Difficulty breakdown
                    const Text(
                      'Performance by Difficulty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...NGDifficulty.values.map((difficulty) {
                      final diffStats = stats.statsForDifficulty(difficulty);
                      final colors = difficulty.colorCodes
                          .map((c) => Color(c))
                          .toList();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DifficultyStatsCard(
                          difficulty: difficulty,
                          stats: diffStats,
                          colors: colors,
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // Recent games
                    if (stats.recentGames.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Games',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${stats.recentGames.length} games',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...stats.recentGames.take(10).map((game) {
                        return _RecentGameCard(game: game);
                      }),
                    ],

                    // Reset button
                    const SizedBox(height: 32),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => _showResetConfirmation(context, ref),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Reset All Stats',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Stats?'),
        content: const Text(
          'This will permanently delete all your statistics and achievements. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(ngStatsProvider.notifier).resetStats();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stats reset successfully')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Card showing stats for a difficulty level
class _DifficultyStatsCard extends StatelessWidget {
  final NGDifficulty difficulty;
  final DifficultyStats stats;
  final List<Color> colors;

  const _DifficultyStatsCard({
    required this.difficulty,
    required this.stats,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors[0].withValues(alpha: 0.1),
            colors[1].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors[0].withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                difficulty.icon,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors[0],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats.gamesWon}/${stats.gamesPlayed} won • ${stats.winRate.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors[0].withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (stats.bestAttempts != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${stats.bestAttempts}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors[0],
                  ),
                ),
                Text(
                  'best',
                  style: TextStyle(
                    fontSize: 11,
                    color: colors[0].withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Card showing a recent game
class _RecentGameCard extends StatelessWidget {
  final GameHistoryEntry game;

  const _RecentGameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    final diffColors = game.difficulty.colorCodes.map((c) => Color(c)).toList();
    final resultColor = game.won
        ? const Color(0xFF4ECDC4)
        : const Color(0xFFFF6B6B);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            game.won ? Icons.check_circle : Icons.cancel,
            color: resultColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: diffColors),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        game.difficulty.displayName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${game.attempts} attempts',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(game.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          if (game.targetNumber != null)
            Text(
              '#${game.targetNumber}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
