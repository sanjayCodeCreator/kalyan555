import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Circular countdown timer widget
class TimerWidget extends StatefulWidget {
  final int? remainingSeconds;
  final int totalSeconds;
  final bool isActive;

  const TimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.isActive = true,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Pulse when time is running out
    if (widget.remainingSeconds != null && widget.remainingSeconds! <= 10) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.remainingSeconds == null) {
      return const SizedBox.shrink();
    }

    final remaining = widget.remainingSeconds!;
    final progress = remaining / widget.totalSeconds;
    final isUrgent = remaining <= 10;
    final isCritical = remaining <= 5;

    final baseColor = isCritical
        ? Colors.red
        : isUrgent
        ? Colors.orange
        : const Color(0xFF4ECDC4);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = isUrgent ? 1.0 + (_pulseController.value * 0.05) : 1.0;

        return Transform.scale(scale: scale, child: child);
      },
      child: SizedBox(
        width: 80,
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            CustomPaint(
              size: const Size(80, 80),
              painter: _TimerPainter(
                progress: progress,
                color: baseColor,
                isUrgent: isUrgent,
              ),
            ),
            // Time text
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$remaining',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: baseColor,
                  ),
                ),
                Text(
                  'sec',
                  style: TextStyle(
                    fontSize: 12,
                    color: baseColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the timer arc
class _TimerPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isUrgent;

  _TimerPainter({
    required this.progress,
    required this.color,
    required this.isUrgent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background circle
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [color, color.withValues(alpha: 0.5)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      progressPaint,
    );

    // Glow effect when urgent
    if (isUrgent) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(center, radius, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_TimerPainter oldDelegate) {
    return progress != oldDelegate.progress || color != oldDelegate.color;
  }
}
