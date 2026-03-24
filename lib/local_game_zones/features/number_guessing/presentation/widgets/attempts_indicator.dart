import 'package:flutter/material.dart';

/// Visual indicator for remaining attempts
class AttemptsIndicator extends StatelessWidget {
  final int? maxAttempts;
  final int attemptsUsed;

  const AttemptsIndicator({
    super.key,
    required this.maxAttempts,
    required this.attemptsUsed,
  });

  @override
  Widget build(BuildContext context) {
    // For unlimited attempts, just show count
    if (maxAttempts == null) {
      return _UnlimitedAttemptsView(attemptsUsed: attemptsUsed);
    }

    return _LimitedAttemptsView(
      maxAttempts: maxAttempts!,
      attemptsUsed: attemptsUsed,
    );
  }
}

/// View for unlimited attempts mode
class _UnlimitedAttemptsView extends StatelessWidget {
  final int attemptsUsed;

  const _UnlimitedAttemptsView({required this.attemptsUsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4ECDC4).withValues(alpha: 0.2),
            const Color(0xFF44CF6C).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.all_inclusive, color: Color(0xFF4ECDC4), size: 20),
          const SizedBox(width: 8),
          Text(
            'Attempts: $attemptsUsed',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4ECDC4),
            ),
          ),
        ],
      ),
    );
  }
}

/// View for limited attempts mode with visual dots
class _LimitedAttemptsView extends StatelessWidget {
  final int maxAttempts;
  final int attemptsUsed;

  const _LimitedAttemptsView({
    required this.maxAttempts,
    required this.attemptsUsed,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = maxAttempts - attemptsUsed;
    final isLow = remaining <= 2;
    final isCritical = remaining <= 1;

    final color = isCritical
        ? Colors.red
        : isLow
        ? Colors.orange
        : const Color(0xFF4ECDC4);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCritical ? Icons.warning_amber_rounded : Icons.sports_esports,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '$remaining ${remaining == 1 ? 'attempt' : 'attempts'} left',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(maxAttempts, (index) {
            final isUsed = index < attemptsUsed;
            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 1.0, end: isUsed ? 0.3 : 1.0),
              builder: (context, value, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUsed
                        ? Colors.grey.withValues(alpha: value)
                        : color.withValues(alpha: value),
                    border: Border.all(
                      color: isUsed
                          ? Colors.grey.withValues(alpha: 0.5)
                          : color,
                      width: 2,
                    ),
                    boxShadow: isUsed
                        ? null
                        : [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
