import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/memory_match_game_notifier.dart';
import '../../data/models/memory_match_game_state.dart';
import '../widgets/memory_grid.dart';
import '../widgets/mm_scoreboard.dart';
import '../widgets/mm_completion_dialog.dart';

/// Main game screen for Memory Match
class MMGameScreen extends ConsumerStatefulWidget {
  const MMGameScreen({super.key});

  @override
  ConsumerState<MMGameScreen> createState() => _MMGameScreenState();
}

class _MMGameScreenState extends ConsumerState<MMGameScreen> {
  bool _showedDialog = false;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(memoryMatchGameProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Show completion dialog when game ends
    if ((gameState.phase == GamePhase.completed ||
            gameState.phase == GamePhase.failed) &&
        !_showedDialog) {
      _showedDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const MMCompletionDialog(),
        ).then((_) {
          _showedDialog = false;
        });
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(context, gameState, colorScheme),

            const SizedBox(height: 16),

            // Scoreboard
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const MMScoreboard(),
            ),

            const SizedBox(height: 24),

            // Game Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: MemoryGrid(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                ),
              ),
            ),

            // Bottom Controls
            _buildBottomControls(context, gameState),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    MemoryMatchGameState gameState,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => _showExitConfirmation(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
          ),

          const Spacer(),

          // Game info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF9C27B0).withValues(alpha: 0.2),
                  const Color(0xFFE91E63).withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🧠 ${gameState.gridSize.label}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (gameState.mode != GameMode.classic) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      gameState.mode.name,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const Spacer(),

          // Pause button
          IconButton(
            onPressed: gameState.phase == GamePhase.playing
                ? () {
                    ref.read(memoryMatchGameProvider.notifier).pauseGame();
                    _showPauseMenu(context);
                  }
                : null,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.pause, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(
    BuildContext context,
    MemoryMatchGameState gameState,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Streak indicator
          if (gameState.streak > 1) _buildStreakBadge(gameState.streak),

          const Spacer(),

          // Settings toggles
          _buildToggleButton(
            icon: gameState.soundEnabled ? Icons.volume_up : Icons.volume_off,
            isActive: gameState.soundEnabled,
            onTap: () {
              ref.read(memoryMatchGameProvider.notifier).toggleSound();
            },
          ),
          const SizedBox(width: 12),
          _buildToggleButton(
            icon: gameState.hapticEnabled
                ? Icons.vibration
                : Icons.phonelink_erase,
            isActive: gameState.hapticEnabled,
            onTap: () {
              ref.read(memoryMatchGameProvider.notifier).toggleHaptic();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge(int streak) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E63), Color(0xFFFF5722)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE91E63).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '${streak}x Streak!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF9C27B0).withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFF9C27B0)
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? const Color(0xFF9C27B0) : Colors.grey,
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Game?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              ref.read(memoryMatchGameProvider.notifier).resetGame();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF44336),
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _showPauseMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.pause_circle_filled, color: Color(0xFF9C27B0)),
            const SizedBox(width: 8),
            const Text('Paused'),
          ],
        ),
        content: const Text('Take your time. The game is paused.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              ref.read(memoryMatchGameProvider.notifier).resetGame();
            },
            child: const Text('Quit'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(memoryMatchGameProvider.notifier).resumeGame();
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Resume'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
