import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../application/timer_notifier.dart';
import '../../data/models/game_state.dart';
import '../../domain/puzzle_generator.dart';
import '../widgets/clue_panel_widget.dart';
import '../widgets/control_panel_widget.dart';
import '../widgets/game_header_widget.dart';
import '../widgets/logic_grid_widget.dart';

/// Main game screen for Logic Grid Puzzle
class LGPGameScreen extends ConsumerStatefulWidget {
  const LGPGameScreen({super.key});

  @override
  ConsumerState<LGPGameScreen> createState() => _LGPGameScreenState();
}

class _LGPGameScreenState extends ConsumerState<LGPGameScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Start timer after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(logicGridTimerProvider.notifier).reset();
      ref.read(logicGridTimerProvider.notifier).start();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(logicGridTimerProvider.notifier).pause();
      ref.read(logicGridGameProvider.notifier).pauseGame();
    } else if (state == AppLifecycleState.resumed) {
      final gameState = ref.read(logicGridGameProvider);
      if (gameState.status == GameStatus.paused) {
        // Let user resume manually
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(logicGridGameProvider);

    // Listen for win
    ref.listen<LogicGridGameState>(logicGridGameProvider, (previous, next) {
      if (previous?.status != GameStatus.won && next.status == GameStatus.won) {
        ref.read(logicGridTimerProvider.notifier).stop();
        _showWinDialog();
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 20,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GameHeaderWidget(
                      onPause: _togglePause,
                      onReset: _showResetDialog,
                    ),
                  ),
                ],
              ),
            ),

            // Pause overlay
            if (gameState.isPaused)
              Expanded(
                child: _buildPauseOverlay(),
              )
            else ...[
              // Grid section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: LogicGridWidget(),
              ),

              const SizedBox(height: 16),

              // Clue panel
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: CluePanelWidget(),
                ),
              ),

              // Control panel
              const Padding(
                padding: EdgeInsets.all(16),
                child: ControlPanelWidget(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.pause_circle_filled_rounded,
              size: 64,
              color: Color(0xFF6C63FF),
            ),
            const SizedBox(height: 16),
            const Text(
              'Game Paused',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _togglePause,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Resume'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePause() {
    HapticFeedback.lightImpact();
    final gameState = ref.read(logicGridGameProvider);
    if (gameState.isPaused) {
      ref.read(logicGridGameProvider.notifier).resumeGame();
      ref.read(logicGridTimerProvider.notifier).resume();
    } else {
      ref.read(logicGridGameProvider.notifier).pauseGame();
      ref.read(logicGridTimerProvider.notifier).pause();
    }
  }

  void _showResetDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.refresh_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Reset Puzzle?'),
          ],
        ),
        content:
            const Text('This will clear all your progress on this puzzle.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(logicGridGameProvider.notifier).resetGame();
              ref.read(logicGridTimerProvider.notifier).reset();
              ref.read(logicGridTimerProvider.notifier).start();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showWinDialog() {
    HapticFeedback.heavyImpact();
    final gameState = ref.read(logicGridGameProvider);
    final time = ref.read(logicGridTimerProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              'Puzzle Solved!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 24),
            _buildWinStat(Icons.timer_rounded, 'Time', _formatTime(time)),
            _buildWinStat(Icons.lightbulb_rounded, 'Hints Used',
                '${gameState.hintsUsed}'),
            _buildWinStat(Icons.bar_chart_rounded, 'Difficulty',
                gameState.difficulty.displayName),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Menu'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(logicGridGameProvider.notifier)
                  .newGame(gameState.difficulty);
              ref.read(logicGridTimerProvider.notifier).reset();
              ref.read(logicGridTimerProvider.notifier).start();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildWinStat(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
