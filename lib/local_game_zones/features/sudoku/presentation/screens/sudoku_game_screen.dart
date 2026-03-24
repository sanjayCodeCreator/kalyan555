import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../application/timer_notifier.dart';
import '../../data/models/game_state.dart';
import '../widgets/game_header.dart';
import '../widgets/number_pad.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/win_dialog.dart';

/// Main game screen for Sudoku
class SudokuGameScreen extends ConsumerStatefulWidget {
  const SudokuGameScreen({super.key});

  @override
  ConsumerState<SudokuGameScreen> createState() => _SudokuGameScreenState();
}

class _SudokuGameScreenState extends ConsumerState<SudokuGameScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause game when app is backgrounded
    if (state == AppLifecycleState.paused) {
      final gameState = ref.read(sudokuGameProvider);
      if (gameState.status == GameStatus.playing) {
        ref.read(sudokuGameProvider.notifier).pauseGame();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(sudokuGameProvider);

    // Show win/lose dialogs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (gameState.status == GameStatus.won) {
        _showWinDialog(context, gameState);
      } else if (gameState.status == GameStatus.lost) {
        _showGameOverDialog(context);
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE8EAF6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _showExitConfirmation(context),
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      color: Colors.grey.shade700,
                    ),
                    const Spacer(),
                    Text(
                      'Sudoku',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _showNewGameConfirmation(context),
                      icon: const Icon(Icons.refresh_rounded),
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
              ),

              // Game header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GameHeader(),
              ),
              const SizedBox(height: 16),

              // Paused overlay or grid
              Expanded(
                child: gameState.status == GameStatus.paused
                    ? _buildPausedOverlay()
                    : const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // Sudoku grid
                            Expanded(
                              child: Center(
                                child: SudokuGrid(),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Number pad
                            NumberPad(),
                            SizedBox(height: 16),
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

  Widget _buildPausedOverlay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.pause_rounded,
              color: Colors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Game Paused',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the timer to resume',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(sudokuGameProvider.notifier).resumeGame();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Resume',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showWinDialog(BuildContext context, SudokuGameState gameState) {
    final elapsedSeconds = ref.read(timerProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WinDialog(
        difficulty: gameState.difficulty,
        timeSeconds: elapsedSeconds,
        mistakes: gameState.mistakes,
        hintsUsed: gameState.hintsUsed,
        score: gameState.score,
        onNewGame: () {
          Navigator.pop(context);
          ref.read(sudokuGameProvider.notifier).newGame(gameState.difficulty);
        },
        onHome: () {
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Go back to home
        },
      ),
    );
  }

  void _showGameOverDialog(BuildContext context) {
    final difficulty = ref.read(sudokuGameProvider).difficulty;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        onTryAgain: () {
          Navigator.pop(context);
          ref.read(sudokuGameProvider.notifier).newGame(difficulty);
        },
        onHome: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    final gameState = ref.read(sudokuGameProvider);
    if (gameState.status == GameStatus.playing) {
      ref.read(sudokuGameProvider.notifier).pauseGame();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Game?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(sudokuGameProvider.notifier).resumeGame();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showNewGameConfirmation(BuildContext context) {
    final gameState = ref.read(sudokuGameProvider);
    if (gameState.status == GameStatus.playing) {
      ref.read(sudokuGameProvider.notifier).pauseGame();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Game?'),
        content: const Text('Your current progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(sudokuGameProvider.notifier).resumeGame();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(sudokuGameProvider.notifier)
                  .newGame(gameState.difficulty);
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }
}
