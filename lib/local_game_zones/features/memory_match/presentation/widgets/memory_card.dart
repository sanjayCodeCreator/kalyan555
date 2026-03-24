import 'dart:math';
import 'package:flutter/material.dart';

import '../../data/models/memory_match_card.dart';

/// A flipping memory card widget with 3D animation
class MemoryCard extends StatefulWidget {
  final MemoryMatchCard card;
  final bool isKidsMode;
  final VoidCallback onTap;
  final double size;

  const MemoryCard({
    super.key,
    required this.card,
    required this.onTap,
    this.size = 80,
    this.isKidsMode = false,
  });

  @override
  State<MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<MemoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.isKidsMode ? 500 : 300),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Set initial state based on card state
    if (widget.card.isRevealed) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MemoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.state != widget.card.state) {
      if (widget.card.isRevealed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.card.canFlip ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * pi;
          final isShowingFront = angle < pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(angle),
            child: isShowingFront
                ? _buildCardBack()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildCardFront(),
                  ),
          );
        },
      ),
    );
  }

  /// Build the card back (hidden state)
  Widget _buildCardBack() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.help_outline_rounded,
          size: widget.size * 0.4,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  /// Build the card front (revealed state)
  Widget _buildCardFront() {
    final isMatched = widget.card.state == CardState.matched;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMatched
              ? widget.card.color
              : widget.card.color.withValues(alpha: 0.5),
          width: isMatched ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isMatched
                ? widget.card.color.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: isMatched ? 12 : 6,
            offset: const Offset(0, 3),
          ),
          if (isMatched)
            BoxShadow(
              color: widget.card.color.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 200),
              tween: Tween<double>(begin: 0.8, end: 1.0),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Icon(
                    widget.card.icon,
                    size: widget.size * (widget.isKidsMode ? 0.55 : 0.5),
                    color: widget.card.color,
                  ),
                );
              },
            ),
          ),
          if (isMatched) Positioned.fill(child: _buildMatchedOverlay()),
        ],
      ),
    );
  }

  /// Build glow overlay for matched cards
  Widget _buildMatchedOverlay() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: RadialGradient(
              colors: [
                widget.card.color.withValues(alpha: 0.2 * value),
                Colors.transparent,
              ],
            ),
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Opacity(
                opacity: value,
                child: Icon(
                  Icons.check_circle,
                  size: widget.size * 0.2,
                  color: widget.card.color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
