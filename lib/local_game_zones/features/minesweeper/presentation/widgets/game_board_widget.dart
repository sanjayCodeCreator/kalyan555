import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../data/models/game_state.dart';
import 'cell_widget.dart';

/// Game board widget with responsive grid
class GameBoardWidget extends ConsumerWidget {
  const GameBoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(minesweeperGameProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate cell size based on screen width and grid size
    final maxBoardWidth = screenWidth - 32; // Padding
    final maxBoardHeight =
        screenHeight * 0.55; // Leave room for header/controls

    final cellWidth = maxBoardWidth / gameState.cols;
    final cellHeight = maxBoardHeight / gameState.rows;
    final cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;
    final actualCellSize = cellSize.clamp(24.0, 48.0);

    final boardWidth = actualCellSize * gameState.cols;
    final boardHeight = actualCellSize * gameState.rows;

    return Container(
      width: boardWidth + 8,
      height: boardHeight + 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade600,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: _buildGrid(gameState, actualCellSize, ref),
    );
  }

  Widget _buildGrid(
    MinesweeperGameState gameState,
    double cellSize,
    WidgetRef ref,
  ) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gameState.cols,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: gameState.grid.length,
      itemBuilder: (context, index) {
        final cell = gameState.grid[index];
        final isHighlighted = gameState.highlightedHintCell == index;

        return SizedBox(
          width: cellSize,
          height: cellSize,
          child: CellWidget(
            cell: cell,
            isHighlighted: isHighlighted,
            onTap: () => _handleCellTap(ref, index, gameState),
            onLongPress: () => _handleCellLongPress(ref, index),
          ),
        );
      },
    );
  }

  void _handleCellTap(WidgetRef ref, int index, MinesweeperGameState state) {
    if (state.status == GameStatus.paused) return;
    ref.read(minesweeperGameProvider.notifier).onCellTap(index);
  }

  void _handleCellLongPress(WidgetRef ref, int index) {
    ref.read(minesweeperGameProvider.notifier).onCellLongPress(index);
  }
}

/// Scrollable game board for larger grids
class ScrollableGameBoardWidget extends ConsumerWidget {
  const ScrollableGameBoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(minesweeperGameProvider);

    // For expert mode or large grids, make scrollable
    final isLargeGrid = gameState.cols > 16 || gameState.rows > 16;

    if (!isLargeGrid) {
      return Center(child: const GameBoardWidget());
    }

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(20),
      minScale: 0.5,
      maxScale: 2.0,
      child: Center(child: const GameBoardWidget()),
    );
  }
}
