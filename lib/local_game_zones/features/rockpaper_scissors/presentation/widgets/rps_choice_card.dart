import 'package:flutter/material.dart';

import '../../data/models/rps_choice.dart';

/// Animated choice card widget for Rock, Paper, Scissors
class RPSChoiceCard extends StatefulWidget {
  final RPSChoice choice;
  final bool isSelected;
  final bool isDisabled;
  final bool isWinner;
  final bool isLoser;
  final VoidCallback? onTap;

  const RPSChoiceCard({
    super.key,
    required this.choice,
    this.isSelected = false,
    this.isDisabled = false,
    this.isWinner = false,
    this.isLoser = false,
    this.onTap,
  });

  @override
  State<RPSChoiceCard> createState() => _RPSChoiceCardState();
}

class _RPSChoiceCardState extends State<RPSChoiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isSelected) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(RPSChoiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _cardColor {
    if (widget.isWinner) return const Color(0xFF4ECDC4);
    if (widget.isLoser) return const Color(0xFFFF6B6B);
    if (widget.isSelected) return const Color(0xFF6C63FF);
    return Colors.white.withValues(alpha: 0.1);
  }

  Color get _borderColor {
    if (widget.isWinner) return const Color(0xFF4ECDC4);
    if (widget.isLoser) return const Color(0xFFFF6B6B);
    if (widget.isSelected) return const Color(0xFF6C63FF);
    return Colors.white.withValues(alpha: 0.3);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isDisabled ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isSelected ? _scaleAnimation.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cardColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _borderColor,
                  width: widget.isSelected ? 3 : 2,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: _borderColor.withValues(
                            alpha: _glowAnimation.value * 0.5,
                          ),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Emoji Icon
                  Text(
                    widget.choice.emoji,
                    style: TextStyle(
                      fontSize: 48,
                      color: widget.isDisabled ? Colors.grey : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Label
                  Text(
                    widget.choice.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.isDisabled
                          ? Colors.grey
                          : (widget.isSelected
                                ? const Color(0xFF6C63FF)
                                : Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
