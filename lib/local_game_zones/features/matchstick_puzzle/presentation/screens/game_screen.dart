/// Main game screen for Matchstick Puzzle

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../application/timer_notifier.dart';
import '../../data/models/game_state.dart';
import '../../domain/puzzle_data.dart';
import '../widgets/matchstick_board_widget.dart';
import '../widgets/game_header_widget.dart';
import '../widgets/game_controls_widget.dart';
import '../widgets/success_dialog.dart';

/// Main game screen
class MPGameScreen extends ConsumerStatefulWidget {
  final int? puzzleId;
  final bool resumeGame;

  const MPGameScreen({
    super.key,
    this.puzzleId,
    this.resumeGame = false,
  });

  @override
  ConsumerState<MPGameScreen> createState() => _MPGameScreenState();
}

class _MPGameScreenState extends ConsumerState<MPGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Start game after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  void _initializeGame() {
    if (widget.resumeGame) {
      ref.read(matchstickGameProvider.notifier).resumeGame();
    } else {
      final puzzleId = widget.puzzleId ?? 1;
      ref.read(matchstickGameProvider.notifier).startPuzzle(puzzleId);
    }
    ref.read(matchstickTimerProvider.notifier).start();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    ref.read(matchstickTimerProvider.notifier).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(matchstickGameProvider);
    final timerState = ref.watch(matchstickTimerProvider);

    // Update game notifier with current time
    ref.listen<TimerState>(
      matchstickTimerProvider,
      (_, state) {
        ref.read(matchstickGameProvider.notifier).updateTime(state.seconds);
      },
    );

    // Show success dialog when completed
    ref.listen<MatchstickGameState>(
      matchstickGameProvider,
      (prev, state) {
        if (prev?.status != GameStatus.completed &&
            state.status == GameStatus.completed) {
          _showSuccessDialog();
        }

        // Shake on error
        if (state.errorMessage != null && prev?.errorMessage == null) {
          HapticFeedback.heavyImpact();
          _shakeController.forward(from: 0);
        }
      },
    );

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
              GameHeaderWidget(
                puzzle: gameState.currentPuzzle,
                moveCount: gameState.moveCount,
                hintsRemaining: gameState.hintsRemaining,
                timer: timerState.formatted,
                onBack: () {
                  ref.read(matchstickGameProvider.notifier).pauseGame();
                  Navigator.pop(context);
                },
              ),

              // Puzzle objective
              if (gameState.currentPuzzle != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF7931E).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            gameState.currentPuzzle!.objective,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Game board
              Expanded(
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    final shake =
                        _shakeAnimation.value * 5 * (1 - _shakeAnimation.value);
                    return Transform.translate(
                      offset: Offset(
                          shake *
                              ((_shakeAnimation.value * 10).toInt().isEven
                                  ? 1
                                  : -1),
                          0),
                      child: child,
                    );
                  },
                  child: MatchstickBoardWidget(
                    matchsticks: gameState.matchsticks,
                    highlightedIds: gameState.highlightedMatchstickIds,
                    selectedId: gameState.selectedMatchstick?.id,
                    onMatchstickTap: (id) {
                      HapticFeedback.selectionClick();
                      ref
                          .read(matchstickGameProvider.notifier)
                          .selectMatchstick(id);
                    },
                    onMatchstickDragStart: (id) {
                      HapticFeedback.lightImpact();
                      ref.read(matchstickGameProvider.notifier).startDrag(id);
                    },
                    onMatchstickDragUpdate: (id, position) {
                      ref
                          .read(matchstickGameProvider.notifier)
                          .updateDragPosition(
                            id,
                            position.dx,
                            position.dy,
                          );
                    },
                    onMatchstickDragEnd: (id, position) {
                      HapticFeedback.mediumImpact();
                      ref.read(matchstickGameProvider.notifier).endDrag(
                            id,
                            position.dx,
                            position.dy,
                          );
                    },
                    onMatchstickDoubleTap: (id) {
                      HapticFeedback.lightImpact();
                      ref
                          .read(matchstickGameProvider.notifier)
                          .rotateMatchstick(id);
                    },
                  ),
                ),
              ),

              // Error message
              if (gameState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      gameState.errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Controls
              GameControlsWidget(
                canUndo: gameState.canUndo,
                canRedo: gameState.canRedo,
                hasHints: gameState.hasHints,
                hintsRemaining: gameState.hintsRemaining,
                onUndo: () {
                  HapticFeedback.lightImpact();
                  ref.read(matchstickGameProvider.notifier).undo();
                },
                onRedo: () {
                  HapticFeedback.lightImpact();
                  ref.read(matchstickGameProvider.notifier).redo();
                },
                onHint: () {
                  HapticFeedback.mediumImpact();
                  ref.read(matchstickGameProvider.notifier).useHint();
                },
                onReset: () {
                  HapticFeedback.heavyImpact();
                  _showResetConfirmation();
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    ref.read(matchstickTimerProvider.notifier).pause();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final state = ref.read(matchstickGameProvider);
        return SuccessDialog(
          stars: state.starsEarned,
          moves: state.moveCount,
          time: state.formattedTime,
          allowedMoves: state.currentPuzzle?.allowedMoves ?? 1,
          onNextLevel: () {
            Navigator.pop(context);
            final nextPuzzle =
                PuzzleData.getNextPuzzle(state.currentPuzzle?.id ?? 1);
            if (nextPuzzle != null) {
              ref
                  .read(matchstickGameProvider.notifier)
                  .startPuzzle(nextPuzzle.id);
              ref.read(matchstickTimerProvider.notifier).start();
            } else {
              Navigator.pop(context); // Return to home
            }
          },
          onRetry: () {
            Navigator.pop(context);
            ref.read(matchstickGameProvider.notifier).resetPuzzle();
            ref.read(matchstickTimerProvider.notifier).start();
          },
          onHome: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Reset Puzzle?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'All your progress will be lost.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(matchstickGameProvider.notifier).resetPuzzle();
              ref.read(matchstickTimerProvider.notifier).reset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
            ),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
