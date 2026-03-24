import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/puzzle_models.dart';

/// Widget for a single cell in the logic grid
class GridCellWidget extends StatelessWidget {
  final GridCell cell;
  final bool isSelected;
  final bool isHighlighted;
  final bool isConflict;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const GridCellWidget({
    super.key,
    required this.cell,
    this.isSelected = false,
    this.isHighlighted = false,
    this.isConflict = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onLongPress();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6C63FF)
                : isConflict
                    ? Colors.red.withOpacity(0.6)
                    : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isConflict) {
      return Colors.red.withOpacity(0.15);
    }
    if (isHighlighted) {
      return const Color(0xFF6C63FF).withOpacity(0.1);
    }
    if (isSelected) {
      return const Color(0xFF6C63FF).withOpacity(0.05);
    }

    switch (cell.mark) {
      case CellMark.yes:
        return Colors.green.withOpacity(0.15);
      case CellMark.no:
        return Colors.grey.withOpacity(0.08);
      case CellMark.note:
        return Colors.blue.withOpacity(0.1);
      case CellMark.unknown:
        return Colors.white;
    }
  }

  Widget _buildContent() {
    switch (cell.mark) {
      case CellMark.yes:
        return const Icon(
          Icons.check_rounded,
          key: ValueKey('yes'),
          color: Colors.green,
          size: 20,
        );
      case CellMark.no:
        return const Icon(
          Icons.close_rounded,
          key: ValueKey('no'),
          color: Colors.red,
          size: 20,
        );
      case CellMark.note:
        return const Icon(
          Icons.circle_outlined,
          key: ValueKey('note'),
          color: Colors.blue,
          size: 14,
        );
      case CellMark.unknown:
        return const SizedBox.shrink(key: ValueKey('unknown'));
    }
  }
}
