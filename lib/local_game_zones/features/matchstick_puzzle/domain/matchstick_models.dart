/// Core domain models for Matchstick Puzzle game

/// Difficulty levels for puzzles
enum Difficulty {
  easy, // 1 move
  medium, // 2-3 moves
  hard, // 4+ moves
}

/// Type of puzzle
enum PuzzleType {
  mathEquation, // Roman/Arabic numeral equations
  shapeFormation, // Squares, triangles
  logicPattern, // Logic-based patterns
}

/// State of a matchstick during interaction
enum MatchstickState {
  idle,
  selected,
  dragging,
  placed,
}

/// Represents a single matchstick on the board
class Matchstick {
  final int id;
  final double x; // X position on canvas
  final double y; // Y position on canvas
  final double angle; // Rotation angle in degrees (0, 45, 90, 135)
  final bool isMovable; // Can this stick be moved?
  final MatchstickState state;
  final int? gridSlotX; // Grid slot for snapping
  final int? gridSlotY; // Grid slot for snapping

  const Matchstick({
    required this.id,
    required this.x,
    required this.y,
    this.angle = 0,
    this.isMovable = true,
    this.state = MatchstickState.idle,
    this.gridSlotX,
    this.gridSlotY,
  });

  /// Valid angles for matchsticks
  static const List<double> validAngles = [0, 45, 90, 135];

  /// Get next rotation angle
  double get nextAngle {
    final currentIndex = validAngles.indexOf(angle);
    final nextIndex = (currentIndex + 1) % validAngles.length;
    return validAngles[nextIndex];
  }

  Matchstick copyWith({
    int? id,
    double? x,
    double? y,
    double? angle,
    bool? isMovable,
    MatchstickState? state,
    int? gridSlotX,
    int? gridSlotY,
  }) {
    return Matchstick(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      angle: angle ?? this.angle,
      isMovable: isMovable ?? this.isMovable,
      state: state ?? this.state,
      gridSlotX: gridSlotX ?? this.gridSlotX,
      gridSlotY: gridSlotY ?? this.gridSlotY,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Matchstick &&
        other.id == id &&
        other.x == x &&
        other.y == y &&
        other.angle == angle;
  }

  @override
  int get hashCode => Object.hash(id, x, y, angle);
}

/// Represents a valid position/slot on the grid for matchsticks
class GridSlot {
  final int slotX;
  final int slotY;
  final double canvasX; // Actual canvas position
  final double canvasY;
  final List<double> allowedAngles; // Which angles are valid here

  const GridSlot({
    required this.slotX,
    required this.slotY,
    required this.canvasX,
    required this.canvasY,
    this.allowedAngles = const [0, 90],
  });

  bool isValidAngle(double angle) => allowedAngles.contains(angle);
}

/// Records a move for undo/redo
class MoveRecord {
  final int matchstickId;
  final double fromX;
  final double fromY;
  final double fromAngle;
  final double toX;
  final double toY;
  final double toAngle;
  final DateTime timestamp;

  const MoveRecord({
    required this.matchstickId,
    required this.fromX,
    required this.fromY,
    required this.fromAngle,
    required this.toX,
    required this.toY,
    required this.toAngle,
    required this.timestamp,
  });

  /// Create reversed move for undo
  MoveRecord get reversed => MoveRecord(
        matchstickId: matchstickId,
        fromX: toX,
        fromY: toY,
        fromAngle: toAngle,
        toX: fromX,
        toY: fromY,
        toAngle: fromAngle,
        timestamp: DateTime.now(),
      );
}

/// Target configuration that represents a solved state
class SolutionConfig {
  /// Map of matchstick ID to expected (x, y, angle)
  final Map<int, ({double x, double y, double angle})> positions;

  const SolutionConfig({required this.positions});

  /// Check if current matchsticks match the solution
  bool isSolved(List<Matchstick> matchsticks) {
    for (final stick in matchsticks) {
      if (!positions.containsKey(stick.id)) continue;
      final expected = positions[stick.id]!;
      // Allow small tolerance for floating point
      if ((stick.x - expected.x).abs() > 5 ||
          (stick.y - expected.y).abs() > 5 ||
          (stick.angle - expected.angle).abs() > 1) {
        return false;
      }
    }
    return true;
  }
}

/// A complete matchstick puzzle
class MatchstickPuzzle {
  final int id;
  final String title;
  final String objective; // "Move 1 matchstick to make equation correct"
  final PuzzleType type;
  final Difficulty difficulty;
  final int allowedMoves;
  final List<Matchstick> initialMatchsticks;
  final List<GridSlot> gridSlots; // Valid positions
  final SolutionConfig solution;
  final String? hint; // Optional hint text
  final String? explanation; // Solution explanation

  const MatchstickPuzzle({
    required this.id,
    required this.title,
    required this.objective,
    required this.type,
    required this.difficulty,
    required this.allowedMoves,
    required this.initialMatchsticks,
    required this.gridSlots,
    required this.solution,
    this.hint,
    this.explanation,
  });

  /// Get star rating based on moves used
  int getStars(int movesUsed, int hintsUsed) {
    if (hintsUsed > 0) return 1;
    if (movesUsed <= allowedMoves) return 3;
    if (movesUsed <= allowedMoves + 1) return 2;
    return 1;
  }
}

/// Player's progress on a specific puzzle
class PuzzleProgress {
  final int puzzleId;
  final bool isUnlocked;
  final bool isCompleted;
  final int bestMoves;
  final int bestStars;
  final int attempts;

  const PuzzleProgress({
    required this.puzzleId,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.bestMoves = 0,
    this.bestStars = 0,
    this.attempts = 0,
  });

  PuzzleProgress copyWith({
    int? puzzleId,
    bool? isUnlocked,
    bool? isCompleted,
    int? bestMoves,
    int? bestStars,
    int? attempts,
  }) {
    return PuzzleProgress(
      puzzleId: puzzleId ?? this.puzzleId,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      bestMoves: bestMoves ?? this.bestMoves,
      bestStars: bestStars ?? this.bestStars,
      attempts: attempts ?? this.attempts,
    );
  }

  Map<String, dynamic> toJson() => {
        'puzzleId': puzzleId,
        'isUnlocked': isUnlocked,
        'isCompleted': isCompleted,
        'bestMoves': bestMoves,
        'bestStars': bestStars,
        'attempts': attempts,
      };

  factory PuzzleProgress.fromJson(Map<String, dynamic> json) {
    return PuzzleProgress(
      puzzleId: json['puzzleId'] as int,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      bestMoves: json['bestMoves'] as int? ?? 0,
      bestStars: json['bestStars'] as int? ?? 0,
      attempts: json['attempts'] as int? ?? 0,
    );
  }
}

/// Achievement types
enum AchievementType {
  firstSolve, // Complete first puzzle
  perfectSolve, // Complete with minimum moves
  noHintStreak, // 5 puzzles without hints
  speedster, // Complete in under 30 seconds
  mathematician, // Complete all math puzzles
  shapemaster, // Complete all shape puzzles
  collector, // Collect 50 total stars
  completionist, // Complete all puzzles
}

/// Player achievement
class Achievement {
  final AchievementType type;
  final String title;
  final String description;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.type,
    required this.title,
    required this.description,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    AchievementType? type,
    String? title,
    String? description,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}
