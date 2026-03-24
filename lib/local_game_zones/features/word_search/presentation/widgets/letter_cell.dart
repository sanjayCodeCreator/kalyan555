import 'package:flutter/material.dart';

import '../../data/models/cell_state.dart';

/// Individual letter cell widget
class LetterCell extends StatelessWidget {
  final LetterCellState cellState;
  final double cellSize;
  final VoidCallback? onTap;

  const LetterCell({
    super.key,
    required this.cellState,
    required this.cellSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: cellSize,
        height: cellSize,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBorderColor(),
            width: cellState.isSelected ? 2.5 : 1.5,
          ),
          boxShadow: _getBoxShadow(),
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: cellSize * 0.5,
              fontWeight: FontWeight.bold,
              color: _getTextColor(),
              letterSpacing: 1,
            ),
            child: Text(cellState.letter),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (cellState.isPartOfWord && cellState.foundColor != null) {
      return cellState.foundColor!.withValues(alpha: 0.3);
    }
    if (cellState.isSelected) {
      return const Color(0xFF4ECDC4).withValues(alpha: 0.4);
    }
    if (cellState.isHighlighted) {
      return const Color(0xFFFFD93D).withValues(alpha: 0.5);
    }
    return Colors.grey.shade900.withValues(alpha: 0.3);
  }

  Color _getBorderColor() {
    if (cellState.isPartOfWord && cellState.foundColor != null) {
      return cellState.foundColor!;
    }
    if (cellState.isSelected) {
      return const Color(0xFF4ECDC4);
    }
    if (cellState.isHighlighted) {
      return const Color(0xFFFFD93D);
    }
    return Colors.grey.shade700;
  }

  Color _getTextColor() {
    if (cellState.isPartOfWord && cellState.foundColor != null) {
      return cellState.foundColor!;
    }
    if (cellState.isSelected) {
      return const Color(0xFF4ECDC4);
    }
    if (cellState.isHighlighted) {
      return const Color(0xFFFFD93D);
    }
    return Colors.white;
  }

  List<BoxShadow>? _getBoxShadow() {
    if (cellState.isSelected) {
      return [
        BoxShadow(
          color: const Color(0xFF4ECDC4).withValues(alpha: 0.5),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    }
    if (cellState.isHighlighted) {
      return [
        BoxShadow(
          color: const Color(0xFFFFD93D).withValues(alpha: 0.5),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    }
    if (cellState.isPartOfWord && cellState.foundColor != null) {
      return [
        BoxShadow(
          color: cellState.foundColor!.withValues(alpha: 0.3),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];
    }
    return null;
  }
}
