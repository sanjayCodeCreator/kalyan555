import 'package:flutter/material.dart';

import '../../data/models/rps_choice.dart';
import '../../domain/rps_game_logic.dart';

/// Widget to display the result with animations
class RPSResultDisplay extends StatefulWidget {
  final RPSResult? result;
  final RPSChoice? playerChoice;
  final RPSChoice? computerChoice;

  const RPSResultDisplay({
    super.key,
    this.result,
    this.playerChoice,
    this.computerChoice,
  });

  @override
  State<RPSResultDisplay> createState() => _RPSResultDisplayState();
}

class _RPSResultDisplayState extends State<RPSResultDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    if (widget.result != null) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(RPSResultDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.result != oldWidget.result && widget.result != null) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _resultColor {
    switch (widget.result) {
      case RPSResult.win:
        return const Color(0xFF4ECDC4);
      case RPSResult.lose:
        return const Color(0xFFFF6B6B);
      case RPSResult.draw:
        return const Color(0xFFFFE66D);
      case null:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.result == null) {
      return const SizedBox(height: 100);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Result text
            Text(
              widget.result!.message,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _resultColor,
              ),
            ),
            const SizedBox(height: 8),
            // Description
            if (widget.playerChoice != null && widget.computerChoice != null)
              Text(
                RPSGameLogic.getResultDescription(
                  widget.playerChoice!,
                  widget.computerChoice!,
                  widget.result!,
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
