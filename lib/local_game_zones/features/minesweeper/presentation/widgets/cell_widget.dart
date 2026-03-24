import 'package:flutter/material.dart';

import '../../data/models/cell_state.dart';

/// Individual cell widget for Minesweeper grid
class CellWidget extends StatelessWidget {
  final CellData cell;
  final bool isHighlighted;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CellWidget({
    super.key,
    required this.cell,
    this.isHighlighted = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          gradient: _getBackgroundGradient(),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isHighlighted
                ? Colors.yellow.shade600
                : cell.isRevealed
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
            width: isHighlighted ? 2.5 : 1.5,
          ),
          boxShadow: cell.isRevealed
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildCellContent(),
          ),
        ),
      ),
    );
  }

  LinearGradient _getBackgroundGradient() {
    if (isHighlighted) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.yellow.shade100,
          Colors.yellow.shade200,
        ],
      );
    }

    if (cell.isRevealed) {
      if (cell.hasMine) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade300,
            Colors.red.shade400,
          ],
        );
      }
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.grey.shade200,
          Colors.grey.shade300,
        ],
      );
    }

    if (cell.isFlagged) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.orange.shade100,
          Colors.orange.shade200,
        ],
      );
    }

    if (cell.isQuestionMark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.purple.shade100,
          Colors.purple.shade200,
        ],
      );
    }

    // Hidden cell - classic 3D raised look
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFD0D0D0),
        Color(0xFFB0B0B0),
      ],
    );
  }

  Widget _buildCellContent() {
    if (cell.isFlagged) {
      return const Text(
        '🚩',
        key: ValueKey('flag'),
        style: TextStyle(fontSize: 18),
      );
    }

    if (cell.isQuestionMark) {
      return const Text(
        '❓',
        key: ValueKey('question'),
        style: TextStyle(fontSize: 16),
      );
    }

    if (!cell.isRevealed) {
      return const SizedBox.shrink(key: ValueKey('hidden'));
    }

    // Revealed cell
    if (cell.hasMine) {
      return const Text(
        '💣',
        key: ValueKey('mine'),
        style: TextStyle(fontSize: 18),
      );
    }

    if (cell.adjacentMines > 0) {
      return Text(
        '${cell.adjacentMines}',
        key: ValueKey('number_${cell.adjacentMines}'),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(CellData.numberColors[cell.adjacentMines - 1]),
        ),
      );
    }

    return const SizedBox.shrink(key: ValueKey('empty'));
  }
}

/// Animated cell for mine explosion
class ExplodingCellWidget extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const ExplodingCellWidget({
    super.key,
    this.onAnimationComplete,
  });

  @override
  State<ExplodingCellWidget> createState() => _ExplodingCellWidgetState();
}

class _ExplodingCellWidgetState extends State<ExplodingCellWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward().then((_) {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: const Text(
        '💥',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
