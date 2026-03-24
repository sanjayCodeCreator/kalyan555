import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../data/models/game_state.dart';

/// Difficulty selector widget
class DifficultySelectorWidget extends ConsumerWidget {
  final VoidCallback? onDifficultySelected;

  const DifficultySelectorWidget({
    super.key,
    this.onDifficultySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(minesweeperGameProvider);

    return Column(
      children: [
        // Difficulty cards
        _DifficultyCard(
          difficulty: Difficulty.beginner,
          isSelected: gameState.difficulty == Difficulty.beginner,
          description: '9×9 grid • 10 mines',
          icon: '😊',
          colors: [Colors.green.shade400, Colors.green.shade600],
          onTap: () => _selectDifficulty(ref, Difficulty.beginner),
        ),
        const SizedBox(height: 12),
        _DifficultyCard(
          difficulty: Difficulty.intermediate,
          isSelected: gameState.difficulty == Difficulty.intermediate,
          description: '16×16 grid • 40 mines',
          icon: '😐',
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          onTap: () => _selectDifficulty(ref, Difficulty.intermediate),
        ),
        const SizedBox(height: 12),
        _DifficultyCard(
          difficulty: Difficulty.expert,
          isSelected: gameState.difficulty == Difficulty.expert,
          description: '30×16 grid • 99 mines',
          icon: '😈',
          colors: [Colors.red.shade400, Colors.red.shade600],
          onTap: () => _selectDifficulty(ref, Difficulty.expert),
        ),
        const SizedBox(height: 12),
        _DifficultyCard(
          difficulty: Difficulty.custom,
          isSelected: gameState.difficulty == Difficulty.custom,
          description: 'Create your own',
          icon: '⚙️',
          colors: [Colors.purple.shade400, Colors.purple.shade600],
          onTap: () => _showCustomDialog(context, ref),
        ),
      ],
    );
  }

  void _selectDifficulty(WidgetRef ref, Difficulty difficulty) {
    ref.read(minesweeperGameProvider.notifier).newGame(difficulty: difficulty);
    onDifficultySelected?.call();
  }

  void _showCustomDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _CustomDifficultyDialog(
        onConfirm: (rows, cols, mines) {
          ref.read(minesweeperGameProvider.notifier).newGame(
                difficulty: Difficulty.custom,
                customRows: rows,
                customCols: cols,
                customMines: mines,
              );
          onDifficultySelected?.call();
        },
      ),
    );
  }
}

/// Difficulty card widget
class _DifficultyCard extends StatelessWidget {
  final Difficulty difficulty;
  final bool isSelected;
  final String description;
  final String icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.difficulty,
    required this.isSelected,
    required this.description,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? colors
                : [
                    colors[0].withValues(alpha: 0.3),
                    colors[1].withValues(alpha: 0.3)
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors[1] : Colors.grey.shade400,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors[0].withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.9)
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom difficulty dialog
class _CustomDifficultyDialog extends StatefulWidget {
  final void Function(int rows, int cols, int mines) onConfirm;

  const _CustomDifficultyDialog({required this.onConfirm});

  @override
  State<_CustomDifficultyDialog> createState() =>
      _CustomDifficultyDialogState();
}

class _CustomDifficultyDialogState extends State<_CustomDifficultyDialog> {
  int _rows = 10;
  int _cols = 10;
  int _mines = 15;

  int get _maxMines => (_rows * _cols * 0.7).floor();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Text('⚙️ '),
          Text('Custom Game'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SliderRow(
            label: 'Rows',
            value: _rows,
            min: 5,
            max: 30,
            onChanged: (value) {
              setState(() {
                _rows = value;
                if (_mines > _maxMines) _mines = _maxMines;
              });
            },
          ),
          const SizedBox(height: 16),
          _SliderRow(
            label: 'Columns',
            value: _cols,
            min: 5,
            max: 30,
            onChanged: (value) {
              setState(() {
                _cols = value;
                if (_mines > _maxMines) _mines = _maxMines;
              });
            },
          ),
          const SizedBox(height: 16),
          _SliderRow(
            label: 'Mines',
            value: _mines,
            min: 1,
            max: _maxMines.clamp(1, 200),
            onChanged: (value) {
              setState(() {
                _mines = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Grid: $_rows × $_cols = ${_rows * _cols} cells\nMines: $_mines (${(_mines / (_rows * _cols) * 100).toStringAsFixed(1)}%)',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onConfirm(_rows, _cols, _mines);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: const Text('Start Game'),
        ),
      ],
    );
  }
}

/// Slider row for custom settings
class _SliderRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
