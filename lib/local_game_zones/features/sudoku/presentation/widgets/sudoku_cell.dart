import 'package:flutter/material.dart';

import '../../data/models/cell_state.dart';

/// Widget representing a single cell in the Sudoku grid
class SudokuCell extends StatelessWidget {
  final CellState cell;
  final bool isSelected;
  final bool isHighlighted;
  final bool isSameValue;
  final VoidCallback onTap;

  const SudokuCell({
    super.key,
    required this.cell,
    required this.isSelected,
    required this.isHighlighted,
    required this.isSameValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
        child: cell.hasNotes ? _buildNotes(context) : _buildValue(context),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (isSelected) {
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.3);
    }
    if (cell.isError) {
      return Colors.red.withValues(alpha: 0.2);
    }
    if (isSameValue && cell.value != null) {
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
    }
    if (isHighlighted) {
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);
    }
    if (cell.isFixed) {
      return Colors.grey.shade100;
    }
    return Colors.white;
  }

  Widget _buildValue(BuildContext context) {
    if (cell.value == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Text(
          '${cell.value}',
          key: ValueKey(cell.value),
          style: TextStyle(
            fontSize: 24,
            fontWeight: cell.isFixed ? FontWeight.bold : FontWeight.w500,
            color: _getTextColor(context),
          ),
        ),
      ),
    );
  }

  Color _getTextColor(BuildContext context) {
    if (cell.isError) {
      return Colors.red.shade700;
    }
    if (cell.isFixed) {
      return Colors.grey.shade800;
    }
    return Theme.of(context).colorScheme.primary;
  }

  Widget _buildNotes(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = constraints.maxWidth / 3;
        return Wrap(
          children: List.generate(9, (index) {
            final number = index + 1;
            final hasNote = cell.notes.contains(number);
            return SizedBox(
              width: cellSize,
              height: cellSize,
              child: Center(
                child: Text(
                  hasNote ? '$number' : '',
                  style: TextStyle(
                    fontSize: cellSize * 0.6,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
