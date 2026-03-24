import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../data/models/game_state.dart';
import 'sudoku_cell.dart';

/// Widget representing the 9x9 Sudoku grid
class SudokuGrid extends ConsumerWidget {
  const SudokuGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(sudokuGameProvider);

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade800, width: 2),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: CustomPaint(
            painter: _GridPainter(),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                return _buildCell(context, ref, gameState, index);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(
    BuildContext context,
    WidgetRef ref,
    SudokuGameState gameState,
    int index,
  ) {
    final isSelected = gameState.selectedIndex == index;
    final isHighlighted = _isHighlighted(gameState, index);
    final isSameValue = _isSameValue(gameState, index);

    return SudokuCell(
      cell: gameState.board[index],
      isSelected: isSelected,
      isHighlighted: isHighlighted,
      isSameValue: isSameValue,
      onTap: () => ref.read(sudokuGameProvider.notifier).selectCell(index),
    );
  }

  bool _isHighlighted(SudokuGameState state, int index) {
    if (state.selectedIndex == null) return false;
    return state.selectedRowIndices.contains(index) ||
        state.selectedColIndices.contains(index) ||
        state.selectedBoxIndices.contains(index);
  }

  bool _isSameValue(SudokuGameState state, int index) {
    return state.sameValueIndices.contains(index);
  }
}

/// Custom painter for thick 3x3 box borders
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final cellWidth = size.width / 9;
    final cellHeight = size.height / 9;

    // Draw thick lines for 3x3 boxes
    for (int i = 0; i <= 3; i++) {
      final x = i * 3 * cellWidth;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (int i = 0; i <= 3; i++) {
      final y = i * 3 * cellHeight;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
