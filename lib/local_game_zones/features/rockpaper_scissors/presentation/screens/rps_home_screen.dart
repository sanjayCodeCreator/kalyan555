import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/rps_game_notifier.dart';
import '../../data/models/rps_choice.dart';
import 'rps_game_screen.dart';
import 'rps_stats_screen.dart';
import 'rps_multiplayer_screen.dart';

/// Home screen for Rock Paper Scissors game
class RPSHomeScreen extends ConsumerStatefulWidget {
  const RPSHomeScreen({super.key});

  @override
  ConsumerState<RPSHomeScreen> createState() => _RPSHomeScreenState();
}

class _RPSHomeScreenState extends ConsumerState<RPSHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(rpsGameProvider);
    final gameNotifier = ref.read(rpsGameProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rock Paper Scissors'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Title with animated icons
                const _AnimatedTitle(),

                const SizedBox(height: 40),

                // Play buttons
                _MenuButton(
                  icon: Icons.person,
                  title: 'Single Player',
                  subtitle: 'Challenge the AI',
                  color: const Color(0xFF6C63FF),
                  onTap: () {
                    gameNotifier.resetGame();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RPSGameScreen()),
                    );
                  },
                ),

                const SizedBox(height: 16),

                _MenuButton(
                  icon: Icons.people,
                  title: 'Local Multiplayer',
                  subtitle: 'Play with a friend',
                  color: const Color(0xFF4ECDC4),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RPSMultiplayerScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                _MenuButton(
                  icon: Icons.bar_chart,
                  title: 'Statistics',
                  subtitle: 'View your progress',
                  color: const Color(0xFFFFE66D),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RPSStatsScreen()),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Settings section
                _SettingsSection(
                  gameState: gameState,
                  gameNotifier: gameNotifier,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated title with rock paper scissors icons
class _AnimatedTitle extends StatefulWidget {
  const _AnimatedTitle();

  @override
  State<_AnimatedTitle> createState() => _AnimatedTitleState();
}

class _AnimatedTitleState extends State<_AnimatedTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;

  final List<String> _emojis = ['🪨', '📄', '✂️'];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          duration: const Duration(milliseconds: 500),
          vsync: this,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() {
              _currentIndex = (_currentIndex + 1) % 3;
            });
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) _controller.forward(from: 0);
            });
          }
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
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Text(
            _emojis[_currentIndex],
            key: ValueKey(_currentIndex),
            style: const TextStyle(fontSize: 80),
          ),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D), Color(0xFF4ECDC4)],
          ).createShader(bounds),
          child: const Text(
            'RPS Battle',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Menu button widget
class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          ),
          child: Row(
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
              Expanded(
                child: Column(
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
              ),
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

/// Settings section widget
class _SettingsSection extends StatelessWidget {
  final dynamic gameState;
  final RPSGameNotifier gameNotifier;

  const _SettingsSection({required this.gameState, required this.gameNotifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),

          // Difficulty
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Difficulty',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                SegmentedButton<AIDifficulty>(
                  segments: AIDifficulty.values.map((d) {
                    return ButtonSegment(
                      value: d,
                      label: Text(
                        d.displayName,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  selected: {gameState.difficulty},
                  onSelectionChanged: (selected) {
                    gameNotifier.setDifficulty(selected.first);
                  },
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12),

          // Rounds mode
          _SettingsRow(
            label: 'Mode',
            child: DropdownButton<GameRoundsMode>(
              value: gameState.roundsMode,
              dropdownColor: const Color(0xFF1A1A2E),
              underline: const SizedBox(),
              items: GameRoundsMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(mode.displayName),
                );
              }).toList(),
              onChanged: (mode) {
                if (mode != null) gameNotifier.setRoundsMode(mode);
              },
            ),
          ),

          const Divider(color: Colors.white12),

          // Timer toggle
          _SettingsRow(
            label: 'Timer Mode',
            child: Switch(
              value: gameState.timerEnabled,
              onChanged: (_) => gameNotifier.toggleTimer(),
              activeTrackColor: const Color(0xFF4ECDC4),
            ),
          ),

          const Divider(color: Colors.white12),

          // Sound toggle
          _SettingsRow(
            label: 'Sound Effects',
            child: Switch(
              value: gameState.soundEnabled,
              onChanged: (_) => gameNotifier.toggleSound(),
              activeTrackColor: const Color(0xFF4ECDC4),
            ),
          ),

          const Divider(color: Colors.white12),

          // Haptic toggle
          _SettingsRow(
            label: 'Haptic Feedback',
            child: Switch(
              value: gameState.hapticEnabled,
              onChanged: (_) => gameNotifier.toggleHaptic(),
              activeTrackColor: const Color(0xFF4ECDC4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _SettingsRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          child,
        ],
      ),
    );
  }
}
