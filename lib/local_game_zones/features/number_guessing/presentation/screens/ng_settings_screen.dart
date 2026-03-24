import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/ng_game_notifier.dart';

/// Settings screen for Number Guessing Game
class NGSettingsScreen extends ConsumerWidget {
  const NGSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(ngGameProvider);
    final notifier = ref.read(ngGameProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App bar
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '⚙️ Settings',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Settings list
              Expanded(
                child: ListView(
                  children: [
                    // Timer section
                    _SettingsSection(
                      title: 'Timer Mode',
                      icon: '⏱️',
                      children: [
                        _SettingsSwitch(
                          title: 'Enable Timer',
                          subtitle: 'Add time pressure to your game',
                          value: gameState.timerEnabled,
                          onChanged: (_) => notifier.toggleTimer(),
                        ),
                        if (gameState.timerEnabled) ...[
                          const SizedBox(height: 16),
                          _TimerDurationSelector(
                            currentDuration: gameState.timerDurationSeconds,
                            onChanged: notifier.setTimerDuration,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Feedback section
                    _SettingsSection(
                      title: 'Feedback',
                      icon: '🔔',
                      children: [
                        _SettingsSwitch(
                          title: 'Sound Effects',
                          subtitle: 'Play sounds during gameplay',
                          value: gameState.soundEnabled,
                          onChanged: (_) => notifier.toggleSound(),
                        ),
                        const SizedBox(height: 12),
                        _SettingsSwitch(
                          title: 'Haptic Feedback',
                          subtitle: 'Vibrate on actions',
                          value: gameState.hapticEnabled,
                          onChanged: (_) => notifier.toggleHaptic(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // AI section
                    _SettingsSection(
                      title: 'AI Assistant',
                      icon: '🤖',
                      children: [
                        _SettingsSwitch(
                          title: 'Smart Hints',
                          subtitle: 'Get AI-powered range suggestions',
                          value: gameState.aiAssistEnabled,
                          onChanged: (_) => notifier.toggleAIAssist(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Rules section
                    _SettingsSection(
                      title: 'How to Play',
                      icon: '📖',
                      children: const [
                        _RuleItem(
                          number: '1',
                          text: 'Choose a difficulty level',
                        ),
                        _RuleItem(
                          number: '2',
                          text: 'Enter your guess and submit',
                        ),
                        _RuleItem(
                          number: '3',
                          text: 'Use hints if you get stuck',
                        ),
                        _RuleItem(
                          number: '4',
                          text:
                              'Find the number before running out of attempts!',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings section container
class _SettingsSection extends StatelessWidget {
  final String title;
  final String icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

/// Settings switch item
class _SettingsSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(value: value, onChanged: onChanged),
      ],
    );
  }
}

/// Timer duration selector
class _TimerDurationSelector extends StatelessWidget {
  final int currentDuration;
  final ValueChanged<int> onChanged;

  const _TimerDurationSelector({
    required this.currentDuration,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final durations = [30, 60, 90, 120];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timer Duration',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Row(
          children: durations.map((seconds) {
            final isSelected = seconds == currentDuration;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => onChanged(seconds),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF667eea)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF667eea)
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${seconds}s',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Rule item
class _RuleItem extends StatelessWidget {
  final String number;
  final String text;

  const _RuleItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667eea),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
