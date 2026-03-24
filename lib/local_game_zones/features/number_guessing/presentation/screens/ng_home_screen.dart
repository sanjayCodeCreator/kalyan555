import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/ng_game_notifier.dart';
import '../../application/ng_stats_notifier.dart';
import '../../data/models/ng_difficulty.dart';
import '../../data/models/ng_game_state.dart';
import '../widgets/number_input_field.dart';
import '../widgets/guess_feedback_widget.dart';
import '../widgets/hint_display_widget.dart';
import '../widgets/attempts_indicator.dart';
import '../widgets/timer_widget.dart';
import '../widgets/difficulty_selector.dart';
import '../widgets/game_over_dialog.dart';
import 'ng_settings_screen.dart';
import 'ng_stats_screen.dart';

/// Main game screen for Number Guessing Game
class NGHomeScreen extends ConsumerStatefulWidget {
  const NGHomeScreen({super.key});

  @override
  ConsumerState<NGHomeScreen> createState() => _NGHomeScreenState();
}

class _NGHomeScreenState extends ConsumerState<NGHomeScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _showDifficultySelector = true;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _startGame(NGDifficulty difficulty) {
    ref.read(ngGameProvider.notifier).startGame(difficulty);
    setState(() {
      _showDifficultySelector = false;
    });
    _inputController.clear();
  }

  void _makeGuess() {
    final input = _inputController.text.trim();
    if (input.isNotEmpty) {
      ref.read(ngGameProvider.notifier).makeGuess(input);
      _inputController.clear();
    }
  }

  void _useHint(HintType type) {
    ref.read(ngGameProvider.notifier).useHint(type);
  }

  void _playAgain() {
    Navigator.of(context).pop();
    ref.read(ngGameProvider.notifier).playAgain();
    _inputController.clear();
  }

  void _goHome() {
    Navigator.of(context).pop();
    ref.read(ngGameProvider.notifier).resetGame();
    setState(() {
      _showDifficultySelector = true;
    });
  }

  void _recordStats(NGGameState state) {
    final hintsUsed = 3 - state.hintsRemaining;
    ref
        .read(ngStatsProvider.notifier)
        .recordResult(
          difficulty: state.difficulty,
          won: state.phase == NGGamePhase.won,
          attempts: state.attemptsUsed,
          targetNumber: state.targetNumber ?? 0,
          timeSeconds: state.durationPlayed?.inSeconds,
          hintsUsed: hintsUsed,
        );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(ngGameProvider);

    // Show game over dialog when game ends
    ref.listen<NGGameState>(ngGameProvider, (previous, next) {
      if (previous?.phase != next.phase && next.isGameOver) {
        _recordStats(next);
        _showGameOverDialog(next);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // App bar
              _buildAppBar(gameState),
              const SizedBox(height: 20),

              // Main content
              Expanded(
                child: _showDifficultySelector
                    ? _buildDifficultySelection()
                    : _buildGameContent(gameState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(NGGameState state) {
    return Row(
      children: [
        // Back button
        IconButton(
          onPressed: () {
            if (state.phase == NGGamePhase.playing) {
              _showExitConfirmation();
            } else {
              Navigator.of(context).pop();
            }
          },
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

        // Title
        Expanded(
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ).createShader(bounds),
            child: const Text(
              '🔢 Number Guessing',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Menu buttons
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NGStatsScreen()),
              ),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  size: 18,
                  color: Color(0xFF4ECDC4),
                ),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NGSettingsScreen()),
              ),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings,
                  size: 18,
                  color: Color(0xFF9B59B6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultySelection() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            '🎮',
            style: TextStyle(
              fontSize: 64,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ready to Play?',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Guess the secret number!',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 40),
          DifficultySelector(
            selectedDifficulty: ref.watch(ngGameProvider).difficulty,
            onSelect: (difficulty) {
              ref.read(ngGameProvider.notifier).setDifficulty(difficulty);
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _startGame(ref.read(ngGameProvider).difficulty),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF667eea).withValues(alpha: 0.4),
              ),
              child: const Text(
                'Start Game 🚀',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent(NGGameState state) {
    final colors = state.difficulty.colorCodes.map((c) => Color(c)).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Difficulty badge and timer row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${state.difficulty.icon} ${state.difficulty.displayName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (state.timerEnabled)
                TimerWidget(
                  remainingSeconds: state.remainingTimeSeconds,
                  totalSeconds: state.timerDurationSeconds,
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Attempts indicator
          AttemptsIndicator(
            maxAttempts: state.difficulty.maxAttempts,
            attemptsUsed: state.attemptsUsed,
          ),
          const SizedBox(height: 24),

          // Feedback
          GuessFeedbackWidget(
            result: state.lastResult,
            message: state.feedbackMessage,
          ),
          const SizedBox(height: 24),

          // Number input
          NumberInputField(
            controller: _inputController,
            minValue: state.difficulty.minValue,
            maxValue: state.difficulty.maxValue,
            errorText: state.inputError,
            enabled: state.phase == NGGamePhase.playing,
            onSubmitted: _makeGuess,
          ),
          const SizedBox(height: 16),

          // Guess button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: state.phase == NGGamePhase.playing ? _makeGuess : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors[0],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
              ),
              child: const Text(
                'Guess! 🎯',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Hints
          HintDisplayWidget(
            activeHints: state.activeHints,
            hintsRemaining: state.hintsRemaining,
            onUseHint: _useHint,
            enabled: state.phase == NGGamePhase.playing,
          ),
          const SizedBox(height: 24),

          // Guess history
          if (state.guessHistory.isNotEmpty) _buildGuessHistory(state),
        ],
      ),
    );
  }

  Widget _buildGuessHistory(NGGameState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Guesses',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.guessHistory.reversed.map((entry) {
            final color = Color(entry.result.colorCode);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${entry.guess}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    entry.result == GuessResult.tooLow
                        ? Icons.arrow_upward
                        : entry.result == GuessResult.tooHigh
                        ? Icons.arrow_downward
                        : Icons.check,
                    size: 16,
                    color: color,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showGameOverDialog(NGGameState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialog(
        won: state.phase == NGGamePhase.won,
        targetNumber: state.targetNumber ?? 0,
        attempts: state.attemptsUsed,
        difficulty: state.difficulty,
        timeTaken: state.durationPlayed,
        onPlayAgain: _playAgain,
        onHome: _goHome,
      ),
    );
  }

  void _showExitConfirmation() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Game?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
