import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';

/// Number pad widget for Sudoku input
class NumberPad extends ConsumerWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(sudokuGameProvider);
    final numberCounts = gameState.numberCounts;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Control buttons row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ControlButton(
              icon: Icons.undo_rounded,
              label: 'Undo',
              onTap: gameState.canUndo
                  ? () {
                      HapticFeedback.lightImpact();
                      ref.read(sudokuGameProvider.notifier).undo();
                    }
                  : null,
            ),
            _ControlButton(
              icon: Icons.redo_rounded,
              label: 'Redo',
              onTap: gameState.canRedo
                  ? () {
                      HapticFeedback.lightImpact();
                      ref.read(sudokuGameProvider.notifier).redo();
                    }
                  : null,
            ),
            _ControlButton(
              icon: Icons.backspace_rounded,
              label: 'Clear',
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(sudokuGameProvider.notifier).clearCell();
              },
            ),
            _NoteModeButton(
              isNoteMode: gameState.isNoteMode,
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(sudokuGameProvider.notifier).toggleNoteMode();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Number buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(9, (index) {
            final number = index + 1;
            final count = numberCounts[number] ?? 0;
            final isComplete = count >= 9;

            return _NumberButton(
              number: number,
              isComplete: isComplete,
              isNoteMode: gameState.isNoteMode,
              onTap: isComplete
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      ref.read(sudokuGameProvider.notifier).placeNumber(number);
                    },
            );
          }),
        ),
      ],
    );
  }
}

/// Individual number button
class _NumberButton extends StatelessWidget {
  final int number;
  final bool isComplete;
  final bool isNoteMode;
  final VoidCallback? onTap;

  const _NumberButton({
    required this.number,
    required this.isComplete,
    required this.isNoteMode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isComplete
                ? [Colors.grey.shade300, Colors.grey.shade400]
                : isNoteMode
                    ? [Colors.amber.shade400, Colors.orange.shade500]
                    : [colorScheme.primary, colorScheme.secondary],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: (isNoteMode ? Colors.orange : colorScheme.primary)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isComplete ? Colors.grey.shade600 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

/// Control button (undo, redo, clear)
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isEnabled ? 1.0 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(
                icon,
                color: Colors.grey.shade700,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Note mode toggle button
class _NoteModeButton extends StatelessWidget {
  final bool isNoteMode;
  final VoidCallback onTap;

  const _NoteModeButton({
    required this.isNoteMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isNoteMode
                  ? LinearGradient(
                      colors: [Colors.amber.shade400, Colors.orange.shade500],
                    )
                  : null,
              color: isNoteMode ? null : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border:
                  isNoteMode ? null : Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(
              Icons.edit_note_rounded,
              color: isNoteMode ? Colors.white : Colors.grey.shade700,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Notes',
            style: TextStyle(
              fontSize: 11,
              color: isNoteMode ? Colors.orange.shade600 : Colors.grey.shade600,
              fontWeight: isNoteMode ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
