import 'package:flutter/material.dart';

import '../../data/models/rps_choice.dart';

/// VS animation widget showing player vs computer choices
class RPSVsAnimation extends StatefulWidget {
  final RPSChoice? playerChoice;
  final RPSChoice? computerChoice;
  final bool isRevealing;

  const RPSVsAnimation({
    super.key,
    this.playerChoice,
    this.computerChoice,
    this.isRevealing = false,
  });

  @override
  State<RPSVsAnimation> createState() => _RPSVsAnimationState();
}

class _RPSVsAnimationState extends State<RPSVsAnimation>
    with TickerProviderStateMixin {
  late AnimationController _vsController;
  late AnimationController _choiceController;
  late Animation<double> _vsScale;
  late Animation<double> _choiceScale;

  @override
  void initState() {
    super.initState();

    _vsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _choiceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _vsScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _vsController, curve: Curves.elasticOut));

    _choiceScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _choiceController, curve: Curves.elasticOut),
    );

    _vsController.forward();
  }

  @override
  void didUpdateWidget(RPSVsAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRevealing && !oldWidget.isRevealing) {
      _choiceController.forward();
    }
    if (!widget.isRevealing && oldWidget.isRevealing) {
      _choiceController.reset();
    }
  }

  @override
  void dispose() {
    _vsController.dispose();
    _choiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Player choice
          Expanded(
            child: _ChoiceDisplay(
              choice: widget.playerChoice,
              label: 'You',
              revealed: true,
              animation: _choiceScale,
            ),
          ),

          // VS Badge
          ScaleTransition(
            scale: _vsScale,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF6B6B), Color(0xFF6C63FF)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Text(
                'VS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Computer choice
          Expanded(
            child: _ChoiceDisplay(
              choice: widget.computerChoice,
              label: 'CPU',
              revealed: widget.isRevealing,
              animation: _choiceScale,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceDisplay extends StatelessWidget {
  final RPSChoice? choice;
  final String label;
  final bool revealed;
  final Animation<double> animation;

  const _ChoiceDisplay({
    required this.choice,
    required this.label,
    required this.revealed,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Container(
            key: ValueKey(choice?.emoji ?? 'empty'),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: choice == null
                  ? Text(
                      revealed ? '?' : '🤔',
                      style: const TextStyle(fontSize: 40),
                    )
                  : Text(
                      revealed ? choice!.emoji : '❓',
                      style: const TextStyle(fontSize: 40),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
