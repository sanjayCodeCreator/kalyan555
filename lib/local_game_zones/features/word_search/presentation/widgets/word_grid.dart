import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../data/models/game_state.dart';
import 'letter_cell.dart';

/// Word search grid widget with gesture handling
class WordGrid extends ConsumerStatefulWidget {
  const WordGrid({super.key});

  @override
  ConsumerState<WordGrid> createState() => _WordGridState();
}

class _WordGridState extends ConsumerState<WordGrid> {
  int? _currentTouchIndex;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(wordSearchGameProvider);

    if (gameState.grid.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cell size based on available space
        final availableWidth = constraints.maxWidth;
        final cellSize = (availableWidth - 16) / gameState.gridSize;

        return GestureDetector(
          onPanStart: (details) =>
              _handlePanStart(details, cellSize, gameState),
          onPanUpdate: (details) =>
              _handlePanUpdate(details, cellSize, gameState),
          onPanEnd: (_) => _handlePanEnd(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gameState.gridSize,
                childAspectRatio: 1,
              ),
              itemCount: gameState.grid.length,
              itemBuilder: (context, index) {
                return LetterCell(
                  cellState: gameState.grid[index],
                  cellSize: cellSize - 4,
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _handlePanStart(
    DragStartDetails details,
    double cellSize,
    WordSearchGameState gameState,
  ) {
    final index = _getIndexFromPosition(
      details.localPosition,
      cellSize,
      gameState.gridSize,
    );

    if (index != null && index < gameState.grid.length) {
      _currentTouchIndex = index;
      ref.read(wordSearchGameProvider.notifier).startSelection(index);
    }
  }

  void _handlePanUpdate(
    DragUpdateDetails details,
    double cellSize,
    WordSearchGameState gameState,
  ) {
    final index = _getIndexFromPosition(
      details.localPosition,
      cellSize,
      gameState.gridSize,
    );

    if (index != null &&
        index < gameState.grid.length &&
        index != _currentTouchIndex) {
      _currentTouchIndex = index;
      ref.read(wordSearchGameProvider.notifier).updateSelection(index);
    }
  }

  void _handlePanEnd() {
    _currentTouchIndex = null;
    ref.read(wordSearchGameProvider.notifier).endSelection();
  }

  int? _getIndexFromPosition(
    Offset position,
    double cellSize,
    int gridSize,
  ) {
    // Adjust for padding
    final adjustedPosition = Offset(
      position.dx - 8,
      position.dy - 8,
    );

    if (adjustedPosition.dx < 0 || adjustedPosition.dy < 0) return null;

    final col = (adjustedPosition.dx / cellSize).floor();
    final row = (adjustedPosition.dy / cellSize).floor();

    if (col < 0 || col >= gridSize || row < 0 || row >= gridSize) {
      return null;
    }

    return row * gridSize + col;
  }
}
