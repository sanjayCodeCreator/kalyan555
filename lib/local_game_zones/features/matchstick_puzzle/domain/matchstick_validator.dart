/// Puzzle validation engine for Matchstick Puzzle game

import 'matchstick_models.dart';

/// Result of validation check
class ValidationResult {
  final bool isValid;
  final String? message;
  final List<int>? invalidMatchstickIds;

  const ValidationResult({
    required this.isValid,
    this.message,
    this.invalidMatchstickIds,
  });

  static const valid = ValidationResult(isValid: true);

  factory ValidationResult.invalid(String message, [List<int>? ids]) {
    return ValidationResult(
      isValid: false,
      message: message,
      invalidMatchstickIds: ids,
    );
  }
}

/// Validates matchstick puzzle solutions
class MatchstickValidator {
  /// Check if the current configuration matches the solution
  static bool checkSolution(
    List<Matchstick> currentSticks,
    SolutionConfig solution,
  ) {
    return solution.isSolved(currentSticks);
  }

  /// Check if a matchstick placement is valid
  static ValidationResult validatePlacement(
    Matchstick stick,
    List<GridSlot> slots,
    List<Matchstick> existingSticks,
  ) {
    // Check if position is within a valid slot
    final nearestSlot = _findNearestSlot(stick.x, stick.y, slots);
    if (nearestSlot == null) {
      return ValidationResult.invalid(
        'Invalid position - not on grid',
        [stick.id],
      );
    }

    // Check if angle is valid for this slot
    if (!nearestSlot.isValidAngle(stick.angle)) {
      return ValidationResult.invalid(
        'Invalid angle for this position',
        [stick.id],
      );
    }

    // Check for collision with other matchsticks
    for (final other in existingSticks) {
      if (other.id == stick.id) continue;
      if (_isColliding(stick, other)) {
        return ValidationResult.invalid(
          'Colliding with another matchstick',
          [stick.id, other.id],
        );
      }
    }

    return ValidationResult.valid;
  }

  /// Find nearest valid slot to a position
  static GridSlot? _findNearestSlot(
    double x,
    double y,
    List<GridSlot> slots, {
    double threshold = 30.0,
  }) {
    GridSlot? nearest;
    double minDistance = double.infinity;

    for (final slot in slots) {
      final dx = slot.canvasX - x;
      final dy = slot.canvasY - y;
      final distance = dx * dx + dy * dy;
      if (distance < minDistance && distance < threshold * threshold) {
        minDistance = distance;
        nearest = slot;
      }
    }

    return nearest;
  }

  /// Check if two matchsticks are colliding
  static bool _isColliding(Matchstick a, Matchstick b,
      {double tolerance = 10.0}) {
    final dx = (a.x - b.x).abs();
    final dy = (a.y - b.y).abs();
    final angleDiff = (a.angle - b.angle).abs();

    // Same position and angle = collision
    if (dx < tolerance && dy < tolerance && angleDiff < 1) {
      return true;
    }

    return false;
  }

  /// Snap matchstick to nearest valid grid position
  static Matchstick snapToGrid(
    Matchstick stick,
    List<GridSlot> slots,
  ) {
    final nearestSlot = _findNearestSlot(stick.x, stick.y, slots);
    if (nearestSlot == null) return stick;

    // Find nearest valid angle
    double nearestAngle = stick.angle;
    if (!nearestSlot.isValidAngle(stick.angle)) {
      double minAngleDiff = double.infinity;
      for (final angle in nearestSlot.allowedAngles) {
        final diff = (angle - stick.angle).abs();
        if (diff < minAngleDiff) {
          minAngleDiff = diff;
          nearestAngle = angle;
        }
      }
    }

    return stick.copyWith(
      x: nearestSlot.canvasX,
      y: nearestSlot.canvasY,
      angle: nearestAngle,
      gridSlotX: nearestSlot.slotX,
      gridSlotY: nearestSlot.slotY,
      state: MatchstickState.placed,
    );
  }
}

/// Validates equation-based matchstick puzzles
class EquationValidator {
  /// Roman numeral values
  static const Map<String, int> romanValues = {
    'I': 1,
    'V': 5,
    'X': 10,
    'L': 50,
    'C': 100,
  };

  /// Parse Roman numeral to integer
  static int? parseRoman(String roman) {
    if (roman.isEmpty) return null;

    int result = 0;
    int prevValue = 0;

    for (int i = roman.length - 1; i >= 0; i--) {
      final char = roman[i];
      final value = romanValues[char];
      if (value == null) return null;

      if (value < prevValue) {
        result -= value;
      } else {
        result += value;
        prevValue = value;
      }
    }

    return result;
  }

  /// Check if an equation string is valid
  static bool isValidEquation(String equation) {
    // Split equation by =
    final parts = equation.split('=');
    if (parts.length != 2) return false;

    final leftSide = _evaluateExpression(parts[0].trim());
    final rightSide = _evaluateExpression(parts[1].trim());

    if (leftSide == null || rightSide == null) return false;

    return leftSide == rightSide;
  }

  /// Evaluate a simple arithmetic expression
  static int? _evaluateExpression(String expr) {
    expr = expr.replaceAll(' ', '');

    // Try parsing as simple integer first
    final simpleInt = int.tryParse(expr);
    if (simpleInt != null) return simpleInt;

    // Try parsing as Roman numeral
    final roman = parseRoman(expr);
    if (roman != null) return roman;

    // Handle addition
    if (expr.contains('+')) {
      final parts = expr.split('+');
      int sum = 0;
      for (final part in parts) {
        final value = _evaluateExpression(part);
        if (value == null) return null;
        sum += value;
      }
      return sum;
    }

    // Handle subtraction (simple case)
    if (expr.contains('-')) {
      final parts = expr.split('-');
      if (parts.isEmpty) return null;

      int result = _evaluateExpression(parts[0]) ?? 0;
      for (int i = 1; i < parts.length; i++) {
        final value = _evaluateExpression(parts[i]);
        if (value == null) return null;
        result -= value;
      }
      return result;
    }

    return null;
  }
}

/// Validates shape-based matchstick puzzles
class ShapeValidator {
  /// Count complete squares formed by matchsticks
  static int countSquares(List<Matchstick> sticks, double gridSize) {
    // Group matchsticks by position
    final horizontals = <String, Matchstick>{};
    final verticals = <String, Matchstick>{};

    for (final stick in sticks) {
      final key = '${stick.gridSlotX ?? stick.x.round()}'
          '-${stick.gridSlotY ?? stick.y.round()}';

      if (stick.angle == 0) {
        horizontals[key] = stick;
      } else if (stick.angle == 90) {
        verticals[key] = stick;
      }
    }

    // Count unit squares
    int squares = 0;
    for (final h in horizontals.keys) {
      final parts = h.split('-');
      final x = int.parse(parts[0]);
      final y = int.parse(parts[1]);

      // Check if we have all 4 sides
      final top = horizontals['$x-$y'];
      final bottom = horizontals['$x-${y + 1}'];
      final left = verticals['$x-$y'];
      final right = verticals['${x + 1}-$y'];

      if (top != null && bottom != null && left != null && right != null) {
        squares++;
      }
    }

    return squares;
  }

  /// Count complete triangles formed by matchsticks
  static int countTriangles(List<Matchstick> sticks) {
    // Triangles need 3 sticks at specific angles
    int triangles = 0;

    // Group by approximate center
    final groups = <String, List<Matchstick>>{};
    for (final stick in sticks) {
      final key = '${(stick.x / 50).round()}-${(stick.y / 50).round()}';
      groups.putIfAbsent(key, () => []).add(stick);
    }

    for (final group in groups.values) {
      if (group.length >= 3) {
        // Check for triangle angles (0, 60, 120 or variations)
        final angles = group.map((s) => s.angle).toSet();
        if (_hasTriangleAngles(angles)) {
          triangles++;
        }
      }
    }

    return triangles;
  }

  static bool _hasTriangleAngles(Set<double> angles) {
    // Basic check for equilateral triangle angles
    return angles.length >= 3;
  }
}
