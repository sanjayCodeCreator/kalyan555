import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../domain/puzzle_models.dart';

/// Control panel for game actions
class ControlPanelWidget extends ConsumerWidget {
  const ControlPanelWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(logicGridGameProvider);
    final hasSelection = gameState.selectedCell != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mark buttons
          _MarkButton(
            icon: Icons.check_rounded,
            label: 'Yes',
            color: Colors.green,
            isEnabled: hasSelection,
            onTap: () {
              ref.read(logicGridGameProvider.notifier).placeMark(CellMark.yes);
            },
          ),
          _MarkButton(
            icon: Icons.close_rounded,
            label: 'No',
            color: Colors.red,
            isEnabled: hasSelection,
            onTap: () {
              ref.read(logicGridGameProvider.notifier).placeMark(CellMark.no);
            },
          ),
          _MarkButton(
            icon: Icons.remove_rounded,
            label: 'Clear',
            color: Colors.grey,
            isEnabled: hasSelection,
            onTap: () {
              ref
                  .read(logicGridGameProvider.notifier)
                  .placeMark(CellMark.unknown);
            },
          ),

          // Divider
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade300,
          ),

          // Action buttons
          _ActionButton(
            icon: Icons.undo_rounded,
            label: 'Undo',
            isEnabled: gameState.undoStack.isNotEmpty,
            onTap: () {
              ref.read(logicGridGameProvider.notifier).undo();
            },
          ),
          _ActionButton(
            icon: Icons.redo_rounded,
            label: 'Redo',
            isEnabled: gameState.redoStack.isNotEmpty,
            onTap: () {
              ref.read(logicGridGameProvider.notifier).redo();
            },
          ),
          _ActionButton(
            icon: Icons.lightbulb_rounded,
            label: 'Hint',
            badge: gameState.hintsRemaining.toString(),
            isEnabled: gameState.hintsRemaining > 0,
            onTap: () {
              ref.read(logicGridGameProvider.notifier).useHint();
            },
          ),
        ],
      ),
    );
  }
}

class _MarkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isEnabled;
  final VoidCallback onTap;

  const _MarkButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.2),
                    color.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: color.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final bool isEnabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.badge,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.grey.shade700,
                    size: 20,
                  ),
                ),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
