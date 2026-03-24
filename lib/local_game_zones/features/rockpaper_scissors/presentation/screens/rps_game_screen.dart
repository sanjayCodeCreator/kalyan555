import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/rps_game_notifier.dart';
import '../../application/rps_stats_notifier.dart';
import '../../data/models/rps_choice.dart';
import '../../data/models/rps_game_state.dart';
import '../widgets/rps_choice_card.dart';
import '../widgets/rps_countdown_timer.dart';
import '../widgets/rps_result_display.dart';
import '../widgets/rps_scoreboard.dart';
import '../widgets/rps_vs_animation.dart';

/// Main game screen for Rock Paper Scissors
class RPSGameScreen extends ConsumerStatefulWidget {
  const RPSGameScreen({super.key});

  @override
  ConsumerState<RPSGameScreen> createState() => _RPSGameScreenState();
}

class _RPSGameScreenState extends ConsumerState<RPSGameScreen> {
  late ConfettiController _confettiController;
  RPSResult? _previousResult;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _checkForWinAndCelebrate(RPSGameState gameState) {
    if (_previousResult == gameState.result) return;
    _previousResult = gameState.result;

    if (gameState.result == RPSResult.win) {
      _confettiController.play();
    }

    // Record stats
    if (gameState.result != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(rpsStatsProvider.notifier)
            .recordResult(
              playerChoice: gameState.playerChoice!,
              isWin: gameState.result == RPSResult.win,
              isLoss: gameState.result == RPSResult.lose,
              isDraw: gameState.result == RPSResult.draw,
              difficulty: gameState.difficulty,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(rpsGameProvider);
    final gameNotifier = ref.read(rpsGameProvider.notifier);

    // Check for win celebration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForWinAndCelebrate(gameState);
    });

    final isPlaying =
        gameState.phase == GamePhase.idle ||
        gameState.phase == GamePhase.selecting;
    final isRevealing = gameState.phase == GamePhase.revealing;
    final showResult =
        gameState.phase == GamePhase.result ||
        gameState.phase == GamePhase.matchEnd;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RPS Battle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _previousResult = null;
              gameNotifier.resetScores();
            },
            tooltip: 'Reset Scores',
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Scoreboard
                  RPSScoreboard(
                    playerScore: gameState.playerScore,
                    computerScore: gameState.computerScore,
                    drawCount: gameState.drawCount,
                    currentRound: gameState.currentRound,
                    targetWins: gameState.roundsMode.targetWins,
                    difficulty: gameState.difficulty,
                  ),

                  // Timer (if enabled)
                  if (gameState.timerEnabled &&
                      gameState.phase == GamePhase.selecting)
                    RPSCountdownTimer(
                      remainingTime: gameState.remainingTime,
                      totalTime: gameState.timerDuration,
                    ),

                  // VS Animation area
                  Flexible(
                    child: Center(
                      child: showResult || isRevealing
                          ? SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RPSVsAnimation(
                                    playerChoice: gameState.playerChoice,
                                    computerChoice: gameState.computerChoice,
                                    isRevealing: showResult,
                                  ),
                                  if (showResult)
                                    RPSResultDisplay(
                                      result: gameState.result,
                                      playerChoice: gameState.playerChoice,
                                      computerChoice: gameState.computerChoice,
                                    ),
                                ],
                              ),
                            )
                          : const _InstructionText(),
                    ),
                  ),

                  // Match End overlay
                  if (gameState.phase == GamePhase.matchEnd)
                    _MatchEndOverlay(
                      winner: gameState.matchWinner,
                      onPlayAgain: () {
                        _previousResult = null;
                        gameNotifier.resetScores();
                      },
                    ),

                  // Choice cards
                  if (gameState.phase != GamePhase.matchEnd) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: RPSChoice.values.map((choice) {
                        final isWinner =
                            showResult &&
                            gameState.result == RPSResult.win &&
                            gameState.playerChoice == choice;
                        final isLoser =
                            showResult &&
                            gameState.result == RPSResult.lose &&
                            gameState.playerChoice == choice;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: RPSChoiceCard(
                              choice: choice,
                              isSelected: gameState.playerChoice == choice,
                              isDisabled: !isPlaying,
                              isWinner: isWinner,
                              isLoser: isLoser,
                              onTap: () => gameNotifier.makeChoice(choice),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    if (showResult && gameState.phase != GamePhase.matchEnd)
                      ElevatedButton.icon(
                        onPressed: () {
                          _previousResult = null;
                          gameNotifier.nextRound();
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Next Round'),
                      ),

                    if (gameState.timerEnabled &&
                        gameState.phase == GamePhase.idle)
                      ElevatedButton.icon(
                        onPressed: () => gameNotifier.startWithTimer(),
                        icon: const Icon(Icons.timer),
                        label: const Text('Start Timer'),
                      ),
                  ],
                ],
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              maxBlastForce: 20,
              minBlastForce: 5,
              gravity: 0.2,
              colors: const [
                Color(0xFFFF6B6B),
                Color(0xFF4ECDC4),
                Color(0xFF6C63FF),
                Color(0xFFFFE66D),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DifficultyBadge extends StatelessWidget {
  final AIDifficulty difficulty;

  const DifficultyBadge({required this.difficulty});

  Color get _color {
    switch (difficulty) {
      case AIDifficulty.easy:
        return const Color(0xFF4ECDC4);
      case AIDifficulty.medium:
        return const Color(0xFFFFE66D);
      case AIDifficulty.hard:
        return const Color(0xFFFF6B6B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.5)),
      ),
      child: Text(
        '🤖 ${difficulty.displayName} AI',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _color,
        ),
      ),
    );
  }
}

class _InstructionText extends StatelessWidget {
  const _InstructionText();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('👇', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 8),
        Text(
          'Choose your move!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _MatchEndOverlay extends StatelessWidget {
  final String? winner;
  final VoidCallback onPlayAgain;

  const _MatchEndOverlay({required this.winner, required this.onPlayAgain});

  @override
  Widget build(BuildContext context) {
    final isPlayerWinner = winner == 'player';

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color:
            (isPlayerWinner ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B))
                .withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPlayerWinner
              ? const Color(0xFF4ECDC4)
              : const Color(0xFFFF6B6B),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isPlayerWinner ? '🏆 You Win the Match!' : '😢 CPU Wins the Match!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isPlayerWinner
                  ? const Color(0xFF4ECDC4)
                  : const Color(0xFFFF6B6B),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onPlayAgain,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
}
