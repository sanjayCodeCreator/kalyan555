import 'package:flutter/material.dart';

import '../../data/models/ng_difficulty.dart';
import '../../data/models/ng_game_state.dart';

/// Widget to display active hints as chips
class HintDisplayWidget extends StatelessWidget {
  final List<ActiveHint> activeHints;
  final int hintsRemaining;
  final void Function(HintType) onUseHint;
  final bool enabled;

  const HintDisplayWidget({
    super.key,
    required this.activeHints,
    required this.hintsRemaining,
    required this.onUseHint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hint buttons row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final type in HintType.values) ...[
              Expanded(
                child: _HintButton(
                  type: type,
                  isUsed: activeHints.any((h) => h.type == type),
                  hintsRemaining: hintsRemaining,
                  onTap: enabled ? () => onUseHint(type) : null,
                ),
              ),
              if (type != HintType.values.last) const SizedBox(width: 8),
            ],
          ],
        ),

        // Remaining hints indicator
        const SizedBox(height: 12),
        Center(
          child: Text(
            '$hintsRemaining hints remaining',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),

        // Active hints display
        if (activeHints.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: activeHints
                .map((hint) => _ActiveHintChip(hint: hint))
                .toList(),
          ),
        ],
      ],
    );
  }
}

/// Single hint button
class _HintButton extends StatelessWidget {
  final HintType type;
  final bool isUsed;
  final int hintsRemaining;
  final VoidCallback? onTap;

  const _HintButton({
    required this.type,
    required this.isUsed,
    required this.hintsRemaining,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = !isUsed && hintsRemaining > 0;

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: isAvailable
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF9B59B6).withValues(alpha: 0.3),
                    const Color(0xFF3498DB).withValues(alpha: 0.2),
                  ],
                )
              : null,
          color: isAvailable ? null : Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAvailable
                ? const Color(0xFF9B59B6).withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              type.icon,
              style: TextStyle(
                fontSize: 18,
                color: isUsed ? Colors.grey : null,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                type.displayName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isAvailable ? const Color(0xFF9B59B6) : Colors.grey,
                ),
              ),
            ),
            if (isUsed) ...[
              const SizedBox(height: 2),
              const Icon(Icons.check, size: 12, color: Colors.green),
            ],
          ],
        ),
      ),
    );
  }
}

/// Chip showing an active hint
class _ActiveHintChip extends StatelessWidget {
  final ActiveHint hint;

  const _ActiveHintChip({required this.hint});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667eea).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(hint.type.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              hint.message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
