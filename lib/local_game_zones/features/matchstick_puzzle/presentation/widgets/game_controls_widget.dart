/// Game control buttons widget

import 'package:flutter/material.dart';

/// Control buttons for hint, undo, redo, reset
class GameControlsWidget extends StatelessWidget {
  final bool canUndo;
  final bool canRedo;
  final bool hasHints;
  final int hintsRemaining;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onHint;
  final VoidCallback onReset;

  const GameControlsWidget({
    super.key,
    required this.canUndo,
    required this.canRedo,
    required this.hasHints,
    required this.hintsRemaining,
    required this.onUndo,
    required this.onRedo,
    required this.onHint,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: Icons.undo_rounded,
            label: 'Undo',
            isEnabled: canUndo,
            onTap: onUndo,
          ),
          _ControlButton(
            icon: Icons.redo_rounded,
            label: 'Redo',
            isEnabled: canRedo,
            onTap: onRedo,
          ),
          _ControlButton(
            icon: Icons.lightbulb_outline_rounded,
            label: 'Hint ($hintsRemaining)',
            isEnabled: hasHints,
            isHighlighted: true,
            onTap: onHint,
          ),
          _ControlButton(
            icon: Icons.refresh_rounded,
            label: 'Reset',
            isEnabled: true,
            isDanger: true,
            onTap: onReset,
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;
  final bool isHighlighted;
  final bool isDanger;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isEnabled,
    this.isHighlighted = false,
    this.isDanger = false,
    required this.onTap,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
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
    _scaleAnimation = Tween<double>(begin: 1, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _buttonColor {
    if (!widget.isEnabled) return Colors.grey.withValues(alpha: 0.3);
    if (widget.isDanger) return const Color(0xFFE57373);
    if (widget.isHighlighted) return const Color(0xFFF7931E);
    return Colors.white.withValues(alpha: 0.15);
  }

  Color get _iconColor {
    if (!widget.isEnabled) return Colors.grey;
    if (widget.isDanger) return Colors.white;
    if (widget.isHighlighted) return Colors.white;
    return Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isEnabled ? (_) => _controller.forward() : null,
      onTapUp: widget.isEnabled
          ? (_) {
              _controller.reverse();
              widget.onTap();
            }
          : null,
      onTapCancel: widget.isEnabled ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _buttonColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isEnabled
                  ? (widget.isHighlighted
                      ? const Color(0xFFF7931E).withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.1))
                  : Colors.transparent,
            ),
            boxShadow:
                widget.isEnabled && (widget.isHighlighted || widget.isDanger)
                    ? [
                        BoxShadow(
                          color: (widget.isDanger
                                  ? const Color(0xFFE57373)
                                  : const Color(0xFFF7931E))
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: _iconColor,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  color: _iconColor,
                  fontWeight: widget.isHighlighted || widget.isDanger
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
