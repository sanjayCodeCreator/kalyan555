import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../data/models/game_state.dart';
import '../../domain/puzzle_models.dart';
import 'grid_cell_widget.dart';

/// Widget for displaying the complete logic grid
class LogicGridWidget extends ConsumerWidget {
  const LogicGridWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(logicGridGameProvider);
    final puzzle = gameState.puzzle;

    if (puzzle == null) {
      return const Center(child: Text('No puzzle loaded'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: _buildGrid(context, ref, gameState, puzzle),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    WidgetRef ref,
    LogicGridGameState gameState,
    Puzzle puzzle,
  ) {
    final categories = puzzle.categories;
    final gridSize = puzzle.gridSize;
    const cellSize = 36.0;
    const headerHeight = 40.0;
    const headerWidth = 80.0;

    // Calculate total grid dimensions
    // For 3 categories: we show category 0 as rows, categories 1,2 as columns side by side

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column headers (category names + items)
          Row(
            children: [
              // Empty corner cell
              const SizedBox(width: headerWidth, height: headerHeight),
              // Category headers
              for (int cat = 1; cat < categories.length; cat++) ...[
                Container(
                  width: gridSize * cellSize,
                  height: headerHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getCategoryColor(cat).withOpacity(0.3),
                        _getCategoryColor(cat).withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      categories[cat].name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _getCategoryColor(cat),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          // Column item headers
          Row(
            children: [
              // Row category header
              SizedBox(
                width: headerWidth,
                height: headerHeight,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getCategoryColor(0).withOpacity(0.3),
                        _getCategoryColor(0).withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      categories[0].name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: _getCategoryColor(0),
                      ),
                    ),
                  ),
                ),
              ),
              // Item headers for each category
              for (int cat = 1; cat < categories.length; cat++)
                for (int item = 0; item < gridSize; item++)
                  Container(
                    width: cellSize,
                    height: headerHeight,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(cat).withOpacity(0.1),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 0,
                        child: Text(
                          _truncateText(categories[cat].items[item], 5),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _getCategoryColor(cat),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
          // Grid rows
          for (int row = 0; row < gridSize; row++)
            Row(
              children: [
                // Row header (item from category 0)
                Container(
                  width: headerWidth,
                  height: cellSize,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(0).withOpacity(0.1),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      _truncateText(categories[0].items[row], 8),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _getCategoryColor(0),
                      ),
                    ),
                  ),
                ),
                // Grid cells
                for (int cat = 1; cat < categories.length; cat++)
                  for (int col = 0; col < gridSize; col++)
                    SizedBox(
                      width: cellSize,
                      height: cellSize,
                      child: _buildCell(
                        ref,
                        gameState,
                        0,
                        row,
                        cat,
                        col,
                      ),
                    ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCell(
    WidgetRef ref,
    LogicGridGameState gameState,
    int cat1,
    int row,
    int cat2,
    int col,
  ) {
    final cellKey = '$cat1-$row-$cat2-$col';
    final cell = gameState.grid[cellKey];

    if (cell == null) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
      );
    }

    return GridCellWidget(
      cell: cell,
      isSelected: gameState.selectedCell == cellKey,
      isHighlighted: gameState.highlightedCells.contains(cellKey),
      isConflict: gameState.conflictCells.contains(cellKey),
      onTap: () {
        ref.read(logicGridGameProvider.notifier).selectCell(cellKey);
      },
      onLongPress: () {
        ref.read(logicGridGameProvider.notifier).selectCell(cellKey);
        ref.read(logicGridGameProvider.notifier).cycleMark();
      },
    );
  }

  Color _getCategoryColor(int index) {
    const colors = [
      Color(0xFF6C63FF),
      Color(0xFF4CAF50),
      Color(0xFFFFA726),
      Color(0xFFE91E63),
      Color(0xFF00BCD4),
    ];
    return colors[index % colors.length];
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 1)}…';
  }
}
