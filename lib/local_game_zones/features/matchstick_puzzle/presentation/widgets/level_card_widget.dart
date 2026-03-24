/// Level card widget for level selection grid

import 'package:flutter/material.dart';

/// Card showing level number, lock state, and star rating
class LevelCardWidget extends StatelessWidget {
  final int puzzleNumber;
  final bool isUnlocked;
  final bool isCompleted;
  final int stars;
  final VoidCallback onTap;

  const LevelCardWidget({
    super.key,
    required this.puzzleNumber,
    required this.isUnlocked,
    required this.isCompleted,
    required this.stars,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isCompleted
                      ? [
                          const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                          const Color(0xFF44A08D).withValues(alpha: 0.2),
                        ]
                      : [
                          const Color(0xFFF7931E).withValues(alpha: 0.2),
                          const Color(0xFFFF6B35).withValues(alpha: 0.1),
                        ],
                )
              : LinearGradient(
                  colors: [
                    Colors.grey.withValues(alpha: 0.2),
                    Colors.grey.withValues(alpha: 0.1),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? (isCompleted
                    ? const Color(0xFF4ECDC4).withValues(alpha: 0.5)
                    : const Color(0xFFF7931E).withValues(alpha: 0.3))
                : Colors.grey.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: (isCompleted
                            ? const Color(0xFF4ECDC4)
                            : const Color(0xFFF7931E))
                        .withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Level number or lock
            if (isUnlocked)
              Text(
                '$puzzleNumber',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isCompleted
                      ? const Color(0xFF4ECDC4)
                      : const Color(0xFFF7931E),
                ),
              )
            else
              Icon(
                Icons.lock_rounded,
                size: 32,
                color: Colors.grey.withValues(alpha: 0.5),
              ),

            const SizedBox(height: 8),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final isEarned = isCompleted && index < stars;
                return Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: isEarned
                      ? const Color(0xFFFFD700)
                      : Colors.grey.withValues(alpha: 0.3),
                );
              }),
            ),

            // Completed badge
            if (isCompleted) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '✓',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF4ECDC4),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
