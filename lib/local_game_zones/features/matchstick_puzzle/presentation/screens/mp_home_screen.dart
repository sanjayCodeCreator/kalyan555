/// Home screen for Matchstick Puzzle game
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/stats_notifier.dart';
import '../../data/models/stats_model.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';
import 'stats_screen.dart';

/// Main home screen for Matchstick Puzzle
class MPHomeScreen extends ConsumerStatefulWidget {
  const MPHomeScreen({super.key});

  @override
  ConsumerState<MPHomeScreen> createState() => _MPHomeScreenState();
}

class _MPHomeScreenState extends ConsumerState<MPHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasSavedGame = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
    _checkSavedGame();
  }

  Future<void> _checkSavedGame() async {
    final savedGame = await MatchstickStatsRepository.loadSavedGame();
    if (mounted) {
      setState(() {
        _hasSavedGame = savedGame != null;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(matchstickStatsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Back button
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white70,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Game Logo
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Column(
                                children: [
                                  // Matchstick icon
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFF6B35),
                                          Color(0xFFF7931E)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF6B35)
                                              .withValues(alpha: 0.4),
                                          blurRadius: 30,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const Text(
                                      '🔥',
                                      style: TextStyle(fontSize: 60),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      colors: [
                                        Color(0xFFFF6B35),
                                        Color(0xFFF7931E)
                                      ],
                                    ).createShader(bounds),
                                    child: const Text(
                                      'Matchstick Puzzle',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Move sticks, solve puzzles!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Stats preview
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatItem('🧩',
                                      '${stats.totalPuzzlesSolved}', 'Solved'),
                                  _buildDivider(),
                                  _buildStatItem(
                                      '⭐', '${stats.totalStars}', 'Stars'),
                                  _buildDivider(),
                                  _buildStatItem('🏆', '${stats.perfectSolves}',
                                      'Perfect'),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Menu buttons
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                // Continue button (if saved game exists)
                                if (_hasSavedGame)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _MenuButton(
                                      label: 'Continue',
                                      icon: Icons.play_circle_outline_rounded,
                                      gradient: const [
                                        Color(0xFF4ECDC4),
                                        Color(0xFF44A08D)
                                      ],
                                      onTap: () => _navigateToGame(context,
                                          resume: true),
                                    ),
                                  ),

                                // Play button
                                _MenuButton(
                                  label: 'Play',
                                  icon: Icons.play_arrow_rounded,
                                  gradient: const [
                                    Color(0xFFFF6B35),
                                    Color(0xFFF7931E)
                                  ],
                                  onTap: () => _navigateToGame(context),
                                ),
                                const SizedBox(height: 12),

                                // Levels button
                                _MenuButton(
                                  label: 'Levels',
                                  icon: Icons.grid_view_rounded,
                                  gradient: const [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2)
                                  ],
                                  onTap: () => _navigateToLevels(context),
                                ),
                                const SizedBox(height: 12),

                                // Stats button
                                _MenuButton(
                                  label: 'Statistics',
                                  icon: Icons.bar_chart_rounded,
                                  gradient: const [
                                    Color(0xFF11998e),
                                    Color(0xFF38ef7d)
                                  ],
                                  onTap: () => _navigateToStats(context),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
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

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  void _navigateToGame(BuildContext context, {bool resume = false}) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MPGameScreen(resumeGame: resume),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToLevels(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MPLevelSelectScreen(),
      ),
    );
  }

  void _navigateToStats(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MPStatsScreen(),
      ),
    );
  }
}

/// Animated menu button
class _MenuButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.gradient[0].withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
