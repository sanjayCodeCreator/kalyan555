import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../data/models/game_state.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/game_header_widget.dart';
import '../widgets/game_over_dialog.dart';

/// Main game screen for active gameplay
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  GameStatus? _previousStatus;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(minesweeperGameProvider);

    // Show game over dialog when game ends
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_previousStatus != gameState.status) {
        if (gameState.status == GameStatus.won ||
            gameState.status == GameStatus.lost) {
          showGameOverDialog(context);
        }
        _previousStatus = gameState.status;
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        title: Text(
          'Minesweeper - ${gameState.difficulty.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey.shade700,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(
                gameState.soundEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              ref.read(minesweeperGameProvider.notifier).toggleSound();
            },
          ),
          IconButton(
            icon: Icon(gameState.hapticEnabled
                ? Icons.vibration
                : Icons.phone_android),
            onPressed: () {
              ref.read(minesweeperGameProvider.notifier).toggleHaptic();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header with timer and mine counter
              const GameHeaderWidget(),

              const SizedBox(height: 12),

              // Control bar
              const GameControlBar(),

              const SizedBox(height: 16),

              // Game board
              Expanded(
                child: Center(
                  child: gameState.status == GameStatus.paused
                      ? _buildPausedOverlay()
                      : const ScrollableGameBoardWidget(),
                ),
              ),

              const SizedBox(height: 16),

              // Game info
              _buildGameInfo(gameState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPausedOverlay() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '⏸️',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          const Text(
            'PAUSED',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(minesweeperGameProvider.notifier).resumeGame();
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfo(MinesweeperGameState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _InfoItem(
            icon: '📊',
            label: 'Revealed',
            value:
                '${state.revealedCount}/${state.grid.length - state.totalMines}',
          ),
          _InfoItem(
            icon: '🚩',
            label: 'Flags',
            value: '${state.flaggedCount}/${state.totalMines}',
          ),
          _InfoItem(
            icon: '💡',
            label: 'Hints',
            value: '${state.hintsRemaining}',
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
