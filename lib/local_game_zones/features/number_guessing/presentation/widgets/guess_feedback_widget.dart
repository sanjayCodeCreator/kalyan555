import 'package:flutter/material.dart';

import '../../data/models/ng_difficulty.dart';

/// Animated widget displaying guess feedback
class GuessFeedbackWidget extends StatefulWidget {
  final GuessResult? result;
  final String? message;

  const GuessFeedbackWidget({super.key, this.result, this.message});

  @override
  State<GuessFeedbackWidget> createState() => _GuessFeedbackWidgetState();
}

class _GuessFeedbackWidgetState extends State<GuessFeedbackWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));
  }

  @override
  void didUpdateWidget(GuessFeedbackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.result != oldWidget.result && widget.result != null) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.result == null) {
      return const SizedBox(height: 80);
    }

    final color = Color(widget.result!.colorCode);
    final isWrong = widget.result != GuessResult.correct;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double offset = 0;
        if (isWrong && _controller.value < 0.5) {
          offset =
              _shakeAnimation.value *
              ((_controller.value * 20).floor() % 2 == 0 ? 1 : -1);
        }

        return Transform.translate(
          offset: Offset(offset, 0),
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.2),
              color.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.result!.message,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (widget.message != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.message!,
                style: TextStyle(
                  fontSize: 16,
                  color: color.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
