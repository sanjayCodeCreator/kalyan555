import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';

import '../../application/memory_match_game_notifier.dart';
import '../../application/memory_match_stats_notifier.dart';
import '../../data/models/memory_match_game_state.dart';
import '../../domain/memory_match_logic.dart';

/// Game completion dialog with confetti
class MMCompletionDialog extends ConsumerStatefulWidget {
  const MMCompletionDialog({super.key});

  @override
  ConsumerState<MMCompletionDialog> createState() => _MMCompletionDialogState();
}

class _MMCompletionDialogState extends ConsumerState<MMCompletionDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Record game completion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordCompletion();
      _confettiController.play();
    });
  }

  void _recordCompletion() {
    final gameState = ref.read(memoryMatchGameProvider);
    ref
        .read(memoryMatchStatsProvider.notifier)
        .recordGameCompletion(
          gridSize: gameState.gridSize,
          moves: gameState.moves,
          elapsedSeconds: gameState.elapsedSeconds,
          hintsUsed: gameState.hintsUsed,
          isWin: gameState.phase == GamePhase.completed,
        );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(memoryMatchGameProvider);
    final isWin = gameState.phase == GamePhase.completed;
    final stars = MemoryMatchLogic.calculateStars(
      moves: gameState.moves,
      totalPairs: gameState.gridSize.totalPairs,
      elapsedSeconds: gameState.elapsedSeconds,
      timeLimit: gameState.gridSize.defaultTimeLimit,
    );

    return Stack(
      children: [
        // Dialog
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color:
                      (isWin
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFF44336))
                          .withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isWin
                          ? [const Color(0xFF4CAF50), const Color(0xFF8BC34A)]
                          : [const Color(0xFFF44336), const Color(0xFFFF5722)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isWin
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFFF44336))
                                .withValues(alpha: 0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    isWin ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                    size: 40,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  isWin ? 'Congratulations! 🎉' : 'Game Over',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isWin
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF44336),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  isWin
                      ? 'You matched all pairs!'
                      : _getFailureMessage(gameState),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),

                const SizedBox(height: 20),

                // Stars (only for wins)
                if (isWin) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isEarned = index < stars;
                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + (index * 200)),
                        tween: Tween<double>(begin: 0, end: 1),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Icon(
                              isEarned ? Icons.star : Icons.star_border,
                              size: 40,
                              color: isEarned
                                  ? const Color(0xFFFFD700)
                                  : Colors.grey[400],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                ],

                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(
                        'Time',
                        MemoryMatchLogic.formatTime(gameState.elapsedSeconds),
                        Icons.access_time,
                        const Color(0xFF2196F3),
                      ),
                      const SizedBox(height: 8),
                      _buildStatRow(
                        'Moves',
                        '${gameState.moves}',
                        Icons.touch_app,
                        const Color(0xFF9C27B0),
                      ),
                      if (isWin) ...[
                        const SizedBox(height: 8),
                        _buildStatRow(
                          'Score',
                          '${gameState.score}',
                          Icons.emoji_events,
                          const Color(0xFFFF9800),
                        ),
                      ],
                      if (gameState.maxStreak > 1) ...[
                        const SizedBox(height: 8),
                        _buildStatRow(
                          'Best Streak',
                          '${gameState.maxStreak}x',
                          Icons.local_fire_department,
                          const Color(0xFFE91E63),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ref
                              .read(memoryMatchGameProvider.notifier)
                              .resetGame();
                        },
                        icon: const Icon(Icons.home),
                        label: const Text('Home'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ref
                              .read(memoryMatchGameProvider.notifier)
                              .startGame(
                                gridSize: gameState.gridSize,
                                mode: gameState.mode,
                                isKidsMode: gameState.isKidsMode,
                              );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Play Again'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: isWin
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Confetti (only for wins)
        if (isWin)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFFE91E63),
                Color(0xFF9C27B0),
                Color(0xFF2196F3),
                Color(0xFF4CAF50),
                Color(0xFFFFEB3B),
                Color(0xFFFF9800),
              ],
              createParticlePath: (size) {
                return Path()..addOval(
                  Rect.fromCircle(center: Offset.zero, radius: size.width / 2),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getFailureMessage(MemoryMatchGameState state) {
    if (state.mode == GameMode.timed) {
      return 'Time ran out!';
    } else if (state.mode == GameMode.limitedMoves) {
      return 'Out of moves!';
    }
    return 'Better luck next time!';
  }
}
