import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../application/stats_notifier.dart';
import '../../data/models/game_state.dart';
import '../../data/models/stats_model.dart';
import '../widgets/difficulty_card.dart';
import 'stats_screen.dart';
import 'sudoku_game_screen.dart';

/// Home screen for Sudoku game with difficulty selection
class SudokuHomeScreen extends ConsumerStatefulWidget {
  const SudokuHomeScreen({super.key});

  @override
  ConsumerState<SudokuHomeScreen> createState() => _SudokuHomeScreenState();
}

class _SudokuHomeScreenState extends ConsumerState<SudokuHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(sudokuStatsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
            // gradient: LinearGradient(
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            //   colors: [
            //     Color(0xFFF8F9FA),
            //     Color(0xFFE8F5E9),
            //     Color(0xFFFFF3E0),
            //   ],
            // ),
            ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Back button and stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                        color: Colors.white.withOpacity(0.8),
                      ),
                      IconButton(
                        onPressed: () => _navigateToStats(context),
                        icon: const Icon(Icons.bar_chart_rounded),
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ],
                  ),

                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                    ).createShader(bounds),
                    child: const Text(
                      '🔢 Sudoku',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Train your brain with puzzles',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats summary
                  _buildStatsSummary(stats),
                  const SizedBox(height: 32),

                  // Difficulty selection header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Difficulty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Difficulty cards
                  ...Difficulty.values.map((difficulty) {
                    final bestTime = stats.bestTimes[difficulty];
                    return DifficultyCard(
                      difficulty: difficulty,
                      bestTime: bestTime != null
                          ? SudokuStats.formatTime(bestTime)
                          : null,
                      onTap: () => _startGame(difficulty),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummary(SudokuStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            Colors.white.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.sports_esports_rounded,
            label: 'Played',
            value: '${stats.gamesPlayed}',
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.emoji_events_rounded,
            label: 'Won',
            value: '${stats.gamesWon}',
            color: Colors.amber,
          ),
          _buildStatItem(
            icon: Icons.percent_rounded,
            label: 'Win Rate',
            value: '${stats.winRate.toStringAsFixed(0)}%',
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.local_fire_department_rounded,
            label: 'Streak',
            value: '${stats.currentStreak}',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
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

  void _startGame(Difficulty difficulty) {
    HapticFeedback.lightImpact();
    ref.read(sudokuGameProvider.notifier).newGame(difficulty);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SudokuGameScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToStats(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StatsScreen()),
    );
  }
}
