/// Level selection screen for Matchstick Puzzle

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/stats_notifier.dart';
import '../../domain/matchstick_models.dart';
import '../../domain/puzzle_data.dart';
import '../widgets/level_card_widget.dart';
import 'game_screen.dart';

/// Level selection screen
class MPLevelSelectScreen extends ConsumerWidget {
  const MPLevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(matchstickStatsProvider);
    final allPuzzles = PuzzleData.allPuzzles;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
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
                        'Select Level',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProgressItem(
                        '${stats.totalPuzzlesSolved}/${allPuzzles.length}',
                        'Completed',
                        Icons.check_circle_outline,
                        const Color(0xFF4ECDC4),
                      ),
                      _buildProgressItem(
                        '${stats.totalStars}',
                        'Total Stars',
                        Icons.star_rounded,
                        const Color(0xFFF7931E),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Level tabs
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white60,
                          tabs: const [
                            Tab(text: 'Easy'),
                            Tab(text: 'Medium'),
                            Tab(text: 'Hard'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildLevelGrid(
                              context,
                              ref,
                              PuzzleData.easyPuzzles,
                              stats,
                            ),
                            _buildLevelGrid(
                              context,
                              ref,
                              PuzzleData.mediumPuzzles,
                              stats,
                            ),
                            _buildLevelGrid(
                              context,
                              ref,
                              PuzzleData.hardPuzzles,
                              stats,
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildProgressItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelGrid(
    BuildContext context,
    WidgetRef ref,
    List<MatchstickPuzzle> puzzles,
    stats,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: puzzles.length,
        itemBuilder: (context, index) {
          final puzzle = puzzles[index];
          final progress = stats.getPuzzleProgress(puzzle.id);

          return LevelCardWidget(
            puzzleNumber: puzzle.id,
            isUnlocked: progress.isUnlocked || puzzle.id == 1,
            isCompleted: progress.isCompleted,
            stars: progress.bestStars,
            onTap: () => _startLevel(context, puzzle.id),
          );
        },
      ),
    );
  }

  void _startLevel(BuildContext context, int puzzleId) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MPGameScreen(puzzleId: puzzleId),
      ),
    );
  }
}
