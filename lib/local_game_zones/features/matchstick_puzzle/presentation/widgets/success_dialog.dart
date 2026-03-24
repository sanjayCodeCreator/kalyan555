/// Success dialog for puzzle completion

import 'package:flutter/material.dart';

/// Dialog shown when puzzle is successfully completed
class SuccessDialog extends StatefulWidget {
  final int stars;
  final int moves;
  final String time;
  final int allowedMoves;
  final VoidCallback onNextLevel;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  const SuccessDialog({
    super.key,
    required this.stars,
    required this.moves,
    required this.time,
    required this.allowedMoves,
    required this.onNextLevel,
    required this.onRetry,
    required this.onHome,
  });

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late List<Animation<double>> _starAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _starAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.3 + (index * 0.15),
            0.6 + (index * 0.15),
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2D2D44),
                Color(0xFF1A1A2E),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFF7931E).withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF7931E).withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFF7931E)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Title
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFF7931E)],
                ).createShader(bounds),
                child: const Text(
                  'Puzzle Solved!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final isEarned = index < widget.stars;
                  return AnimatedBuilder(
                    animation: _starAnimations[index],
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _starAnimations[index].value,
                        child: child,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.star_rounded,
                        size: 48,
                        color: isEarned
                            ? const Color(0xFFFFD700)
                            : Colors.grey.withValues(alpha: 0.3),
                        shadows: isEarned
                            ? [
                                Shadow(
                                  color: const Color(0xFFFFD700)
                                      .withValues(alpha: 0.5),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                      Icons.touch_app,
                      '${widget.moves}/${widget.allowedMoves}',
                      'Moves',
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    _buildStat(
                      Icons.timer,
                      widget.time,
                      'Time',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      color: Colors.grey,
                      onTap: widget.onHome,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildButton(
                      icon: Icons.refresh_rounded,
                      label: 'Retry',
                      color: const Color(0xFF4ECDC4),
                      onTap: widget.onRetry,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _buildButton(
                      icon: Icons.arrow_forward_rounded,
                      label: 'Next Level',
                      gradient: const [Color(0xFFFF6B35), Color(0xFFF7931E)],
                      onTap: widget.onNextLevel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFF7931E), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    Color? color,
    List<Color>? gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient != null ? LinearGradient(colors: gradient) : null,
          color: gradient == null ? color?.withValues(alpha: 0.2) : null,
          borderRadius: BorderRadius.circular(12),
          border: gradient == null
              ? Border.all(color: color?.withValues(alpha: 0.5) ?? Colors.grey)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: gradient != null ? Colors.white : color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: gradient != null ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
