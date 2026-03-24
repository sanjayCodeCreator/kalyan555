/// Cell mark states for logic grid puzzle
enum CellMark {
  unknown, // Empty cell - not yet determined
  yes, // ✔️ Match confirmed
  no, // ❌ Eliminated
  note, // Temporary annotation
}

/// A category in the logic grid puzzle (e.g., Person, Color, Pet)
class Category {
  final String name;
  final List<String> items;
  final int id;

  const Category({
    required this.name,
    required this.items,
    required this.id,
  });

  int get size => items.length;

  Category copyWith({
    String? name,
    List<String>? items,
    int? id,
  }) {
    return Category(
      name: name ?? this.name,
      items: items ?? this.items,
      id: id ?? this.id,
    );
  }
}

/// A cell in the logic grid
class GridCell {
  final int rowCategory; // Category index for row
  final int rowItem; // Item index within row category
  final int colCategory; // Category index for column
  final int colItem; // Item index within column category
  final CellMark mark;
  final Set<CellMark> notes; // For annotation mode

  const GridCell({
    required this.rowCategory,
    required this.rowItem,
    required this.colCategory,
    required this.colItem,
    this.mark = CellMark.unknown,
    this.notes = const {},
  });

  /// Unique key for this cell
  String get key => '$rowCategory-$rowItem-$colCategory-$colItem';

  GridCell copyWith({
    int? rowCategory,
    int? rowItem,
    int? colCategory,
    int? colItem,
    CellMark? mark,
    Set<CellMark>? notes,
  }) {
    return GridCell(
      rowCategory: rowCategory ?? this.rowCategory,
      rowItem: rowItem ?? this.rowItem,
      colCategory: colCategory ?? this.colCategory,
      colItem: colItem ?? this.colItem,
      mark: mark ?? this.mark,
      notes: notes ?? this.notes,
    );
  }
}

/// Clue type for logic puzzles
enum ClueType {
  direct, // Direct relationship (A is B)
  negative, // Negative relationship (A is not B)
  comparative, // Comparative (A is before B)
  conditional, // Conditional (If A then B)
}

/// A logical clue in the puzzle
class Clue {
  final int id;
  final String text;
  final ClueType type;
  final List<String> relatedCells; // Keys of related grid cells
  final bool isUsed; // Whether player has used/checked this clue

  const Clue({
    required this.id,
    required this.text,
    required this.type,
    this.relatedCells = const [],
    this.isUsed = false,
  });

  Clue copyWith({
    int? id,
    String? text,
    ClueType? type,
    List<String>? relatedCells,
    bool? isUsed,
  }) {
    return Clue(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      relatedCells: relatedCells ?? this.relatedCells,
      isUsed: isUsed ?? this.isUsed,
    );
  }
}

/// The solution mapping for a puzzle
class PuzzleSolution {
  /// Maps category-item to category-item
  /// e.g., "0-0" (Person: Alice) -> {"1-2": true} (Color: Red)
  final Map<String, Map<String, bool>> mappings;

  const PuzzleSolution({required this.mappings});

  /// Check if two items match in the solution
  bool isMatch(int cat1, int item1, int cat2, int item2) {
    final key1 = '$cat1-$item1';
    final key2 = '$cat2-$item2';

    if (mappings.containsKey(key1) && mappings[key1]!.containsKey(key2)) {
      return mappings[key1]![key2]!;
    }
    if (mappings.containsKey(key2) && mappings[key2]!.containsKey(key1)) {
      return mappings[key2]![key1]!;
    }
    return false;
  }
}

/// A complete logic grid puzzle
class Puzzle {
  final List<Category> categories;
  final List<Clue> clues;
  final PuzzleSolution solution;
  final int gridSize; // Number of items per category

  const Puzzle({
    required this.categories,
    required this.clues,
    required this.solution,
    required this.gridSize,
  });

  int get categoryCount => categories.length;

  /// Get total number of grid sections
  /// For 3 categories: we have 3 grid sections (0-1, 0-2, 1-2)
  int get sectionCount => (categoryCount * (categoryCount - 1)) ~/ 2;
}

/// Represents an action for undo/redo
class GridAction {
  final String cellKey;
  final CellMark previousMark;
  final CellMark newMark;
  final Set<CellMark>? previousNotes;
  final Set<CellMark>? newNotes;
  final List<String>?
      autoEliminatedCells; // Cells auto-eliminated by this action

  const GridAction({
    required this.cellKey,
    required this.previousMark,
    required this.newMark,
    this.previousNotes,
    this.newNotes,
    this.autoEliminatedCells,
  });
}
