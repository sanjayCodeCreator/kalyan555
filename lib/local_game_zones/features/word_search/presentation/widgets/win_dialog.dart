import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/game_state.dart';

/// Win dialog shown when all words are found
class WSWinDialog extends StatefulWidget {
  final WordSearchGameState gameState;
  final VoidCallback onNewGame;
  final VoidCallback onHome;

  const WSWinDialog({
    super.key,
    required this.gameState,
    required this.onNewGame,
    required this.onHome,
  });

  @override
  State<WSWinDialog> createState() => _WSWinDialogState();
}

class _WSWinDialogState extends State<WSWinDialog>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _contentController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  final List<_ConfettiPiece> _confetti = [];

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Content animation
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOut,
      ),
    );

    // Generate confetti pieces
    _generateConfetti();

    // Start animations
    _confettiController.forward();
    _contentController.forward();
  }

  void _generateConfetti() {
    final random = Random();
    for (int i = 0; i < 50; i++) {
      _confetti.add(_ConfettiPiece(
        x: random.nextDouble(),
        delay: random.nextDouble() * 0.5,
        speed: 0.5 + random.nextDouble() * 1.0,
        rotation: random.nextDouble() * 360,
        color: _confettiColors[random.nextInt(_confettiColors.length)],
        size: 8 + random.nextDouble() * 8,
      ));
    }
  }

  static const _confettiColors = [
    Color(0xFF4ECDC4),
    Color(0xFFFF6B6B),
    Color(0xFFFFD93D),
    Color(0xFF6C63FF),
    Color(0xFFFF9F43),
    Color(0xFF95E1D3),
  ];

  @override
  void dispose() {
    _confettiController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.gameState.calculateFinalScore();

    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        return Stack(
          children: [
            // Confetti layer
            ...(_confetti.map((piece) => _buildConfettiPiece(piece))),

            // Dialog content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.shade900,
                          Colors.grey.shade800,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Trophy icon
                        const Text(
                          '🎉',
                          style: TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 16),

                        // Congratulations text
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF4ECDC4), Color(0xFFFFD93D)],
                          ).createShader(bounds),
                          child: const Text(
                            'Puzzle Complete!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Stats
                        _buildStatRow(
                          'Time',
                          widget.gameState.formattedTime,
                          Icons.timer_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow(
                          'Words Found',
                          '${widget.gameState.wordsFoundCount}',
                          Icons.check_circle_outline,
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow(
                          'Hints Used',
                          '${widget.gameState.hintsUsed}',
                          Icons.lightbulb_outline,
                        ),
                        const SizedBox(height: 16),

                        // Score
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Score: $score',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
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
                                'Home',
                                Icons.home_rounded,
                                Colors.grey,
                                widget.onHome,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildButton(
                                'Play Again',
                                Icons.replay_rounded,
                                const Color(0xFF4ECDC4),
                                widget.onNewGame,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfettiPiece(_ConfettiPiece piece) {
    final progress = (_confettiController.value - piece.delay).clamp(0.0, 1.0);
    if (progress <= 0) return const SizedBox.shrink();

    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: piece.x * screenSize.width,
      top: progress * screenSize.height * piece.speed - 50,
      child: Transform.rotate(
        angle: piece.rotation + progress * 10,
        child: Container(
          width: piece.size,
          height: piece.size,
          decoration: BoxDecoration(
            color: piece.color.withValues(alpha: 1 - progress),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfettiPiece {
  final double x;
  final double delay;
  final double speed;
  final double rotation;
  final Color color;
  final double size;

  _ConfettiPiece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.rotation,
    required this.color,
    required this.size,
  });
}
