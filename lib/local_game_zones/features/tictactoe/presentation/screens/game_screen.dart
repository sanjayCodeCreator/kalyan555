import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../data/models/game_state.dart';
import '../widgets/game_board.dart';
import '../widgets/game_status.dart';
import '../widgets/scoreboard.dart';

/// Main game screen
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late ConfettiController _confettiController;
  GameStatus? _previousStatus;

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

  void _checkForWinAndUpdateScore(GameState gameState) {
    // Only trigger once per game end
    if (_previousStatus == gameState.status) return;
    _previousStatus = gameState.status;

    switch (gameState.status) {
      case GameStatus.xWins:
        ref.read(scoreProvider.notifier).addXWin();
        _confettiController.play();
        break;
      case GameStatus.oWins:
        ref.read(scoreProvider.notifier).addOWin();
        _confettiController.play();
        break;
      case GameStatus.draw:
        ref.read(scoreProvider.notifier).addDraw();
        break;
      case GameStatus.playing:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    // Check for win/draw and update score
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForWinAndUpdateScore(gameState);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _previousStatus = null;
              gameNotifier.resetGame();
            },
            tooltip: 'Reset Game',
          ),
          if (gameState.mode == GameMode.twoPlayer &&
              gameState.moveHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.undo_rounded),
              onPressed: gameNotifier.undoMove,
              tooltip: 'Undo Move',
            ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Scoreboard
                  const Scoreboard(),
                  const SizedBox(height: 24),

                  // Game Mode indicator
                  _GameModeIndicator(mode: gameState.mode),
                  const SizedBox(height: 16),

                  // Status
                  const GameStatusWidget(),
                  const SizedBox(height: 32),

                  // Game Board
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: const GameBoard(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Play Again button when game is over
                  if (gameState.status.isGameOver)
                    ElevatedButton.icon(
                      onPressed: () {
                        _previousStatus = null;
                        gameNotifier.resetGame();
                      },
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Play Again'),
                    ),
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
                Color(0xFF95E1D3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GameModeIndicator extends StatelessWidget {
  final GameMode mode;

  const _GameModeIndicator({required this.mode});

  String get _modeText {
    switch (mode) {
      case GameMode.twoPlayer:
        return '👥 Two Player';
      case GameMode.vsAiEasy:
        return '🤖 vs AI (Easy)';
      case GameMode.vsAiMedium:
        return '🤖 vs AI (Medium)';
      case GameMode.vsAiHard:
        return '🤖 vs AI (Hard)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        _modeText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
