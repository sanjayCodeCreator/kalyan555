/// CustomPainter-based matchstick board widget

import 'package:flutter/material.dart';
import '../../domain/matchstick_models.dart';

/// Widget displaying the matchstick puzzle board
class MatchstickBoardWidget extends StatelessWidget {
  final List<Matchstick> matchsticks;
  final Set<int> highlightedIds;
  final int? selectedId;
  final void Function(int id) onMatchstickTap;
  final void Function(int id) onMatchstickDragStart;
  final void Function(int id, Offset position) onMatchstickDragUpdate;
  final void Function(int id, Offset position) onMatchstickDragEnd;
  final void Function(int id) onMatchstickDoubleTap;

  const MatchstickBoardWidget({
    super.key,
    required this.matchsticks,
    required this.highlightedIds,
    required this.selectedId,
    required this.onMatchstickTap,
    required this.onMatchstickDragStart,
    required this.onMatchstickDragUpdate,
    required this.onMatchstickDragEnd,
    required this.onMatchstickDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D44),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Grid background
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _GridPainter(),
                ),

                // Matchsticks
                ...matchsticks.map((stick) => _buildMatchstick(stick)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchstick(Matchstick stick) {
    final isHighlighted = highlightedIds.contains(stick.id);
    final isSelected = selectedId == stick.id;
    final isDragging = stick.state == MatchstickState.dragging;

    return Positioned(
      left: stick.x - 25,
      top: stick.y - 5,
      child: GestureDetector(
        onTap: stick.isMovable ? () => onMatchstickTap(stick.id) : null,
        onDoubleTap:
            stick.isMovable ? () => onMatchstickDoubleTap(stick.id) : null,
        onPanStart:
            stick.isMovable ? (_) => onMatchstickDragStart(stick.id) : null,
        onPanUpdate: stick.isMovable
            ? (details) => onMatchstickDragUpdate(
                  stick.id,
                  Offset(
                    stick.x + details.delta.dx,
                    stick.y + details.delta.dy,
                  ),
                )
            : null,
        onPanEnd: stick.isMovable
            ? (details) =>
                onMatchstickDragEnd(stick.id, Offset(stick.x, stick.y))
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()
            ..translate(25.0, 25.0)
            ..rotateZ(stick.angle * 3.14159 / 180)
            ..translate(-25.0, -25.0),
          child: AnimatedScale(
            scale: isDragging ? 1.15 : (isSelected ? 1.1 : 1.0),
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: 50,
              height: 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getMatchstickColors(
                    isHighlighted: isHighlighted,
                    isSelected: isSelected,
                    isDragging: isDragging,
                    isMovable: stick.isMovable,
                  ),
                ),
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  if (isHighlighted || isSelected || isDragging)
                    BoxShadow(
                      color: const Color(0xFFF7931E).withValues(alpha: 0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Stack(
                children: [
                  // Matchstick head (red tip)
                  Positioned(
                    left: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFFFF4444),
                            const Color(0xFFCC0000),
                          ],
                        ),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  // Wood grain effect
                  Positioned.fill(
                    left: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFD4A574),
                            const Color(0xFFC9956C),
                            const Color(0xFFD4A574),
                          ],
                        ),
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getMatchstickColors({
    required bool isHighlighted,
    required bool isSelected,
    required bool isDragging,
    required bool isMovable,
  }) {
    if (isDragging) {
      return [const Color(0xFFFFA726), const Color(0xFFFF9800)];
    }
    if (isHighlighted) {
      return [const Color(0xFFFFC107), const Color(0xFFFFB300)];
    }
    if (isSelected) {
      return [const Color(0xFFFFE082), const Color(0xFFFFD54F)];
    }
    if (!isMovable) {
      return [const Color(0xFF8D6E63), const Color(0xFF795548)];
    }
    return [const Color(0xFFD4A574), const Color(0xFFC9956C)];
  }
}

/// Paints grid background
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const spacing = 30.0;

    // Vertical lines
    for (double x = spacing; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Grid dots
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
