import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/game_notifier.dart';
import '../../data/models/game_state.dart';
import '../widgets/scoreboard.dart';
import 'game_screen.dart';

/// Home screen with game mode selection
class LocalGameHomeScreen extends ConsumerWidget {
  const LocalGameHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 40),

                        // Title
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFF4ECDC4)],
                          ).createShader(bounds),
                          child: const Text(
                            'Tic Tac Toe',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose your game mode',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Scoreboard
                        const Scoreboard(),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Game mode buttons
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Two Player Mode
                        _GameModeButton(
                          icon: Icons.people_rounded,
                          title: 'Two Player',
                          subtitle: 'Play with a friend',
                          color: const Color(0xFF6C63FF),
                          onTap: () =>
                              _startGame(context, ref, GameMode.twoPlayer),
                        ),
                        const SizedBox(height: 16),

                        // VS AI Section
                        Text(
                          '— vs Computer —',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _GameModeButton(
                                icon: Icons.sentiment_satisfied_rounded,
                                title: 'Easy',
                                subtitle: 'Random moves',
                                color: const Color(0xFF4ECDC4),
                                compact: true,
                                onTap: () =>
                                    _startGame(context, ref, GameMode.vsAiEasy),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _GameModeButton(
                                icon: Icons.psychology_rounded,
                                title: 'Medium',
                                subtitle: 'Defensive AI',
                                color: const Color(0xFFFFE66D),
                                compact: true,
                                onTap: () => _startGame(
                                  context,
                                  ref,
                                  GameMode.vsAiMedium,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _GameModeButton(
                                icon: Icons.smart_toy_rounded,
                                title: 'Hard',
                                subtitle: 'Unbeatable',
                                color: const Color(0xFFFF6B6B),
                                compact: true,
                                onTap: () =>
                                    _startGame(context, ref, GameMode.vsAiHard),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Reset scores button
                    TextButton.icon(
                      onPressed: () => _showResetScoresDialog(context, ref),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Reset Scores'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _startGame(BuildContext context, WidgetRef ref, GameMode mode) {
    ref.read(gameProvider.notifier).setGameMode(mode);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }

  void _showResetScoresDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Scores?'),
        content: const Text(
          'This will clear all win/loss/draw records. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(scoreProvider.notifier).resetScores();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _GameModeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  const _GameModeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(compact ? 12 : 20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          ),
          child: compact
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: color.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: color.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: color.withValues(alpha: 0.5),
                      size: 20,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
