import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

import '../../data/models/ng_difficulty.dart';
import '../../data/models/ng_player_stats.dart';

/// Premium styled dialog for game over (win/loss)
class GameOverDialog extends StatefulWidget {
  final bool won;
  final int targetNumber;
  final int attempts;
  final NGDifficulty difficulty;
  final Duration? timeTaken;
  final List<String>? newAchievements;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  const GameOverDialog({
    super.key,
    required this.won,
    required this.targetNumber,
    required this.attempts,
    required this.difficulty,
    this.timeTaken,
    this.newAchievements,
    required this.onPlayAgain,
    required this.onHome,
  });

  @override
  State<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<GameOverDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    if (widget.won) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.won
        ? [const Color(0xFF4ECDC4), const Color(0xFF44CF6C)]
        : [const Color(0xFFFF6B6B), const Color(0xFFEE0979)];

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Confetti
        if (widget.won)
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            maxBlastForce: 20,
            minBlastForce: 8,
            gravity: 0.2,
          ),

        // Dialog
        ScaleTransition(
          scale: _scaleAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors[0].withValues(alpha: 0.15),
                    colors[1].withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colors[0].withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: colors,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors[0].withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.won ? '🎉' : '😔',
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    widget.won ? 'You Won!' : 'Game Over',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colors[0],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Number reveal
                  Text(
                    'The number was ${widget.targetNumber}',
                    style: TextStyle(
                      fontSize: 18,
                      color: colors[0].withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  _StatRow(
                    icon: Icons.sports_esports,
                    label: 'Attempts',
                    value: '${widget.attempts}',
                    color: colors[0],
                  ),
                  const SizedBox(height: 8),
                  _StatRow(
                    icon: Icons.signal_cellular_alt,
                    label: 'Difficulty',
                    value: widget.difficulty.displayName,
                    color: colors[0],
                  ),
                  if (widget.timeTaken != null) ...[
                    const SizedBox(height: 8),
                    _StatRow(
                      icon: Icons.timer,
                      label: 'Time',
                      value: '${widget.timeTaken!.inSeconds}s',
                      color: colors[0],
                    ),
                  ],

                  // Achievements
                  if (widget.newAchievements != null &&
                      widget.newAchievements!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      '🎖️ New Achievements!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: widget.newAchievements!.map((id) {
                        final achievement = NGAchievement.all.firstWhere(
                          (a) => a.id == id,
                          orElse: () => const NGAchievement(
                            id: 'unknown',
                            title: 'Achievement',
                            description: '',
                            icon: '🏅',
                          ),
                        );
                        return Chip(
                          avatar: Text(achievement.icon),
                          label: Text(achievement.title),
                          backgroundColor: colors[0].withValues(alpha: 0.1),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onHome,
                          icon: const Icon(Icons.home),
                          label: const Text('Home'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors[0],
                            side: BorderSide(color: colors[0]),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onPlayAgain,
                          icon: const Icon(Icons.replay),
                          label: const Text('Play Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors[0],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Row showing a stat with icon
class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color.withValues(alpha: 0.7))),
        const Text(': '),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
