import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/game_state.dart';

/// Difficulty selection card widget
class WSDifficultyCard extends StatefulWidget {
  final WSDifficulty difficulty;
  final String? bestTime;
  final VoidCallback onTap;

  const WSDifficultyCard({
    super.key,
    required this.difficulty,
    this.bestTime,
    required this.onTap,
  });

  @override
  State<WSDifficultyCard> createState() => _WSDifficultyCardState();
}

class _WSDifficultyCardState extends State<WSDifficultyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getDifficultyColors();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors[0].withValues(alpha: 0.2),
                  colors[1].withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors[0].withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors[0].withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getDifficultyIcon(),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.difficulty.label,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colors[0],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getDifficultyDescription(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      if (widget.bestTime != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.emoji_events_rounded,
                              size: 14,
                              color: colors[0],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Best: ${widget.bestTime}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors[0],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: colors[0].withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getDifficultyColors() {
    switch (widget.difficulty) {
      case WSDifficulty.easy:
        return [const Color(0xFF4ECDC4), const Color(0xFF44A08D)];
      case WSDifficulty.medium:
        return [const Color(0xFFFFD93D), const Color(0xFFFF9F43)];
      case WSDifficulty.hard:
        return [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)];
    }
  }

  String _getDifficultyIcon() {
    switch (widget.difficulty) {
      case WSDifficulty.easy:
        return '🔤';
      case WSDifficulty.medium:
        return '🔠';
      case WSDifficulty.hard:
        return '🧩';
    }
  }

  String _getDifficultyDescription() {
    switch (widget.difficulty) {
      case WSDifficulty.easy:
        return '${widget.difficulty.gridSize}×${widget.difficulty.gridSize} grid • Horizontal only';
      case WSDifficulty.medium:
        return '${widget.difficulty.gridSize}×${widget.difficulty.gridSize} grid • Horizontal + Vertical';
      case WSDifficulty.hard:
        return '${widget.difficulty.gridSize}×${widget.difficulty.gridSize} grid • All directions';
    }
  }
}
