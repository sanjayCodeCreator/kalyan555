import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/stats_notifier.dart';
import '../../data/models/game_state.dart';
import '../../data/models/stats_model.dart';

/// Statistics screen for Word Search
class WSStatsScreen extends ConsumerWidget {
  const WSStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(wordSearchStatsProvider);

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
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _showResetConfirmation(context, ref),
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: Colors.red.withOpacity(0.8),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                ).createShader(bounds),
                child: const Text(
                  '📊 Statistics',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Main stats grid
              _buildMainStatsGrid(stats),
              const SizedBox(height: 24),

              // Best times
              _buildSectionTitle('Best Times'),
              const SizedBox(height: 12),
              _buildBestTimesCard(stats),
              const SizedBox(height: 24),

              // Achievements
              _buildSectionTitle('Achievements'),
              const SizedBox(height: 12),
              _buildAchievementsGrid(stats),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildMainStatsGrid(WordSearchStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Games Played',
                  '${stats.gamesPlayed}',
                  Icons.sports_esports_rounded,
                  const Color(0xFF4ECDC4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Games Won',
                  '${stats.gamesWon}',
                  Icons.emoji_events_rounded,
                  const Color(0xFFFFD93D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Win Rate',
                  '${stats.winRate.toStringAsFixed(1)}%',
                  Icons.percent_rounded,
                  const Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Words Found',
                  '${stats.totalWordsFound}',
                  Icons.abc_rounded,
                  const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Current Streak',
                  '${stats.currentStreak}',
                  Icons.local_fire_department_rounded,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Best Streak',
                  '${stats.bestStreak}',
                  Icons.whatshot_rounded,
                  Colors.deepOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Avg. Solve Time',
                  stats.gamesWon > 0
                      ? WordSearchStats.formatTime(stats.averageSolveTime)
                      : '--:--',
                  Icons.timer_rounded,
                  const Color(0xFF48DBFB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Daily Complete',
                  '${stats.dailyChallengesCompleted}',
                  Icons.calendar_today_rounded,
                  const Color(0xFFA29BFE),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
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
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestTimesCard(WordSearchStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: WSDifficulty.values.map((difficulty) {
          final bestTime = stats.bestTimes[difficulty];
          final color = _getDifficultyColor(difficulty);

          return Padding(
            padding: EdgeInsets.only(
              bottom: difficulty != WSDifficulty.hard ? 12 : 0,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    difficulty.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events_rounded,
                      size: 18,
                      color: bestTime != null
                          ? color
                          : Colors.grey.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      bestTime != null
                          ? WordSearchStats.formatTime(bestTime)
                          : '--:--',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: bestTime != null
                            ? Colors.white
                            : Colors.grey.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAchievementsGrid(WordSearchStats stats) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: WSAchievement.values.map((achievement) {
        final isUnlocked = stats.unlockedAchievements.contains(achievement);

        return Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnlocked
                ? const Color(0xFF4ECDC4).withValues(alpha: 0.2)
                : Colors.grey.shade900.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnlocked
                  ? const Color(0xFF4ECDC4).withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                achievement.icon,
                style: TextStyle(
                  fontSize: 32,
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                achievement.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked
                      ? Colors.white
                      : Colors.grey.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                achievement.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: isUnlocked
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.grey.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getDifficultyColor(WSDifficulty difficulty) {
    switch (difficulty) {
      case WSDifficulty.easy:
        return const Color(0xFF4ECDC4);
      case WSDifficulty.medium:
        return const Color(0xFFFFD93D);
      case WSDifficulty.hard:
        return const Color(0xFFFF6B6B);
    }
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Reset Statistics?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will permanently delete all your stats and achievements. This action cannot be undone.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              ref.read(wordSearchStatsProvider.notifier).resetStats();
              Navigator.pop(context);
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
