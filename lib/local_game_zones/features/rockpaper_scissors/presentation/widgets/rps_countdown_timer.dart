import 'package:flutter/material.dart';

/// Countdown timer widget for timer mode
class RPSCountdownTimer extends StatefulWidget {
  final int? remainingTime;
  final int totalTime;

  const RPSCountdownTimer({
    super.key,
    required this.remainingTime,
    required this.totalTime,
  });

  @override
  State<RPSCountdownTimer> createState() => _RPSCountdownTimerState();
}

class _RPSCountdownTimerState extends State<RPSCountdownTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(RPSCountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.remainingTime != oldWidget.remainingTime) {
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _timerColor {
    if (widget.remainingTime == null) return Colors.grey;
    if (widget.remainingTime! <= 1) return const Color(0xFFFF6B6B);
    if (widget.remainingTime! <= 2) return const Color(0xFFFFE66D);
    return const Color(0xFF4ECDC4);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.remainingTime == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _timerColor.withValues(alpha: 0.2),
              border: Border.all(color: _timerColor, width: 4),
              boxShadow: [
                BoxShadow(
                  color: _timerColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${widget.remainingTime}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _timerColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
