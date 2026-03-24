import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../application/timer_notifier.dart';
import '../../data/models/game_state.dart';
import '../widgets/game_header.dart';
import '../widgets/word_grid.dart';
import '../widgets/word_list_panel.dart';

/// Main game screen for Word Search
class WordSearchGameScreen extends ConsumerStatefulWidget {
  final bool isDailyChallenge;

  const WordSearchGameScreen({
    super.key,
    this.isDailyChallenge = false,
  });

  @override
  ConsumerState<WordSearchGameScreen> createState() =>
      _WordSearchGameScreenState();
}

class _WordSearchGameScreenState extends ConsumerState<WordSearchGameScreen>
    with WidgetsBindingObserver {
  bool _hasShownWinDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Start timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameState = ref.read(wordSearchGameProvider);
      ref.read(wsTimerProvider.notifier).start(
            mode: gameState.timerMode,
            timeLimit: gameState.timeLimit,
          );
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
      ref.read(wordSearchGameProvider.notifier).pauseGame();
      ref.read(wsTimerProvider.notifier).pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(wordSearchGameProvider);

    // Listen for win state - auto start new game after all words found
    ref.listen<WordSearchGameState>(wordSearchGameProvider, (previous, next) {
      if (next.status == WSGameStatus.won && !_hasShownWinDialog) {
        _hasShownWinDialog = true;
        ref.read(wsTimerProvider.notifier).pause();

        // Show brief celebration and auto-start new game
        HapticFeedback.heavyImpact();
        _showCompletionSnackbar(context, next);

        // Auto start new game after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _hasShownWinDialog = false;
            ref.read(wordSearchGameProvider.notifier).shuffleGrid();
            ref.read(wsTimerProvider.notifier).start();
          }
        });
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (gameState.status == WSGameStatus.playing) {
          await _showExitConfirmation(context);
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Main game content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Back button
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (gameState.status == WSGameStatus.playing) {
                              _showExitConfirmation(context);
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.arrow_back_ios_rounded),
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const Spacer(),
                        if (widget.isDailyChallenge)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '📅 Daily Challenge',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Game header
                    WSGameHeader(
                      onPause: _handlePause,
                      onHint: _handleHint,
                      onShuffle: () => _showShuffleConfirmation(context),
                    ),
                    const SizedBox(height: 16),

                    // Word grid
                    const Expanded(
                      flex: 4,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: WordGrid(),
                        ),
                      ),
                    ),

                    // Word list panel
                    const Expanded(
                      flex: 2,
                      child: WordListPanel(),
                    ),
                  ],
                ),
              ),

              // Paused overlay
              if (gameState.status == WSGameStatus.paused)
                _buildPausedOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPausedOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pause_circle_filled_rounded,
              size: 80,
              color: Color(0xFF4ECDC4),
            ),
            const SizedBox(height: 24),
            const Text(
              'Game Paused',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _handleResume,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Resume'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                ref.read(wsTimerProvider.notifier).stop();
                Navigator.pop(context);
              },
              child: const Text(
                'Quit Game',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePause() {
    HapticFeedback.lightImpact();
    ref.read(wordSearchGameProvider.notifier).pauseGame();
    ref.read(wsTimerProvider.notifier).pause();
  }

  void _handleResume() {
    HapticFeedback.lightImpact();
    ref.read(wordSearchGameProvider.notifier).resumeGame();
    ref.read(wsTimerProvider.notifier).resume();
  }

  void _handleHint() {
    HapticFeedback.lightImpact();
    ref.read(wordSearchGameProvider.notifier).useHint();
  }

  /// Show brief completion celebration snackbar
  void _showCompletionSnackbar(
    BuildContext context,
    WordSearchGameState gameState,
  ) {
    final score = gameState.calculateFinalScore();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'All words found!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Score: $score • Starting new puzzle...',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4ECDC4),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _showExitConfirmation(BuildContext context) async {
    ref.read(wordSearchGameProvider.notifier).pauseGame();
    ref.read(wsTimerProvider.notifier).pause();

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Exit Game?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Your progress will be lost. Are you sure?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
              ref.read(wordSearchGameProvider.notifier).resumeGame();
              ref.read(wsTimerProvider.notifier).resume();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF4ECDC4)),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(wsTimerProvider.notifier).stop();
              Navigator.pop(context, true);
            },
            child: const Text(
              'Exit',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldExit == true && context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _showShuffleConfirmation(BuildContext context) async {
    final shouldShuffle = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'New Puzzle?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Generate a new puzzle? Current progress will be lost.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'New Puzzle',
              style: TextStyle(color: Color(0xFF4ECDC4)),
            ),
          ),
        ],
      ),
    );

    if (shouldShuffle == true) {
      HapticFeedback.mediumImpact();
      _hasShownWinDialog = false;
      ref.read(wordSearchGameProvider.notifier).shuffleGrid();
      ref.read(wsTimerProvider.notifier).start();
    }
  }
}
