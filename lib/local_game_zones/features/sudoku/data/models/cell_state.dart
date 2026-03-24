// Sudoku cell state model - Represents the state of a single cell in the Sudoku grid

/// Type of cell in the Sudoku grid
enum CellType {
  /// Cell with a pre-filled fixed number (part of the puzzle)
  fixed,

  /// Cell with a user-entered number
  user,

  /// Empty cell
  empty,
}

/// Represents the state of a single cell in the Sudoku grid
class CellState {
  /// The value in the cell (1-9, or null if empty)
  final int? value;

  /// Notes/candidates for this cell (pencil marks)
  final Set<int> notes;

  /// Whether this is a fixed cell (part of the puzzle)
  final bool isFixed;

  /// Whether this cell has an error (conflicts with another cell)
  final bool isError;

  const CellState({
    this.value,
    this.notes = const {},
    this.isFixed = false,
    this.isError = false,
  });

  /// Create a fixed cell with a value
  factory CellState.fixed(int value) {
    return CellState(value: value, isFixed: true);
  }

  /// Create an empty user cell
  factory CellState.empty() {
    return const CellState();
  }

  /// Create a user cell with a value
  factory CellState.user(int value) {
    return CellState(value: value, isFixed: false);
  }

  /// The type of this cell
  CellType get type {
    if (isFixed) return CellType.fixed;
    if (value != null) return CellType.user;
    return CellType.empty;
  }

  /// Whether this cell is empty
  bool get isEmpty => value == null && notes.isEmpty;

  /// Whether this cell has notes
  bool get hasNotes => notes.isNotEmpty;

  /// Copy with modified fields
  CellState copyWith({
    int? value,
    Set<int>? notes,
    bool? isFixed,
    bool? isError,
    bool clearValue = false,
  }) {
    return CellState(
      value: clearValue ? null : (value ?? this.value),
      notes: notes ?? this.notes,
      isFixed: isFixed ?? this.isFixed,
      isError: isError ?? this.isError,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CellState &&
        other.value == value &&
        _setEquals(other.notes, notes) &&
        other.isFixed == isFixed &&
        other.isError == isError;
  }

  @override
  int get hashCode =>
      value.hashCode ^ notes.hashCode ^ isFixed.hashCode ^ isError.hashCode;

  static bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    for (final item in a) {
      if (!b.contains(item)) return false;
    }
    return true;
  }
}
