import 'package:flutter/material.dart';

/// State of a letter cell in the word search grid
class LetterCellState {
  /// The letter displayed in this cell
  final String letter;

  /// Whether this cell is part of a found word
  final bool isPartOfWord;

  /// Whether this cell is currently selected during drag
  final bool isSelected;

  /// Whether this cell is highlighted as a hint
  final bool isHighlighted;

  /// ID of the word this cell belongs to (when found)
  final int? wordId;

  /// Color assigned to this cell when part of found word
  final Color? foundColor;

  const LetterCellState({
    required this.letter,
    this.isPartOfWord = false,
    this.isSelected = false,
    this.isHighlighted = false,
    this.wordId,
    this.foundColor,
  });

  /// Create an empty cell
  factory LetterCellState.empty() {
    return const LetterCellState(letter: '');
  }

  /// Create a cell with a letter
  factory LetterCellState.withLetter(String letter) {
    return LetterCellState(letter: letter.toUpperCase());
  }

  /// Copy with modified fields
  LetterCellState copyWith({
    String? letter,
    bool? isPartOfWord,
    bool? isSelected,
    bool? isHighlighted,
    int? wordId,
    bool clearWordId = false,
    Color? foundColor,
    bool clearFoundColor = false,
  }) {
    return LetterCellState(
      letter: letter ?? this.letter,
      isPartOfWord: isPartOfWord ?? this.isPartOfWord,
      isSelected: isSelected ?? this.isSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      wordId: clearWordId ? null : (wordId ?? this.wordId),
      foundColor: clearFoundColor ? null : (foundColor ?? this.foundColor),
    );
  }

  @override
  String toString() {
    return 'LetterCellState(letter: $letter, isPartOfWord: $isPartOfWord, '
        'isSelected: $isSelected, isHighlighted: $isHighlighted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LetterCellState &&
        other.letter == letter &&
        other.isPartOfWord == isPartOfWord &&
        other.isSelected == isSelected &&
        other.isHighlighted == isHighlighted &&
        other.wordId == wordId;
  }

  @override
  int get hashCode {
    return Object.hash(letter, isPartOfWord, isSelected, isHighlighted, wordId);
  }
}
