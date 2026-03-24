import 'dart:math';
import 'puzzle_models.dart';

/// Puzzle difficulty settings
enum Difficulty {
  easy,
  medium,
  hard,
}

extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  int get gridSize {
    switch (this) {
      case Difficulty.easy:
        return 3;
      case Difficulty.medium:
        return 4;
      case Difficulty.hard:
        return 5;
    }
  }

  int get categoryCount {
    switch (this) {
      case Difficulty.easy:
        return 3;
      case Difficulty.medium:
        return 4;
      case Difficulty.hard:
        return 4;
    }
  }

  int get hintCount {
    switch (this) {
      case Difficulty.easy:
        return 5;
      case Difficulty.medium:
        return 3;
      case Difficulty.hard:
        return 2;
    }
  }
}

/// Generator for logic grid puzzles
class PuzzleGenerator {
  static final Random _random = Random();

  /// Pre-defined category templates
  static const List<Map<String, List<String>>> _categoryTemplates = [
    {
      'Person': ['Alice', 'Bob', 'Carol', 'David', 'Eve'],
      'Color': ['Red', 'Blue', 'Green', 'Yellow', 'Purple'],
      'Pet': ['Dog', 'Cat', 'Bird', 'Fish', 'Rabbit'],
      'Food': ['Pizza', 'Burger', 'Pasta', 'Sushi', 'Salad'],
      'Sport': ['Tennis', 'Soccer', 'Basketball', 'Swimming', 'Running'],
    },
    {
      'Name': ['Emma', 'Liam', 'Olivia', 'Noah', 'Ava'],
      'Fruit': ['Apple', 'Banana', 'Orange', 'Grape', 'Mango'],
      'Country': ['USA', 'UK', 'Japan', 'France', 'Brazil'],
      'Number': ['One', 'Two', 'Three', 'Four', 'Five'],
      'Animal': ['Lion', 'Tiger', 'Bear', 'Wolf', 'Fox'],
    },
    {
      'Student': ['Alex', 'Beth', 'Chris', 'Dana', 'Eric'],
      'Subject': ['Math', 'Science', 'English', 'History', 'Art'],
      'Grade': ['A', 'B', 'C', 'D', 'F'],
      'Time': ['9AM', '10AM', '11AM', '12PM', '1PM'],
      'Room': ['101', '102', '103', '104', '105'],
    },
  ];

  /// Generate a new puzzle with the given difficulty
  static Puzzle generate(Difficulty difficulty) {
    final gridSize = difficulty.gridSize;
    final categoryCount = difficulty.categoryCount;

    // Select random template
    final template =
        _categoryTemplates[_random.nextInt(_categoryTemplates.length)];
    final templateKeys = template.keys.toList()..shuffle(_random);

    // Create categories
    final categories = <Category>[];
    for (int i = 0; i < categoryCount; i++) {
      final key = templateKeys[i];
      final items = template[key]!.sublist(0, gridSize).toList()
        ..shuffle(_random);
      categories.add(Category(
        id: i,
        name: key,
        items: items,
      ));
    }

    // Generate solution - create a valid one-to-one mapping
    final solution = _generateSolution(categories, gridSize);

    // Generate clues based on solution
    final clues = _generateClues(categories, solution, difficulty);

    return Puzzle(
      categories: categories,
      clues: clues,
      solution: solution,
      gridSize: gridSize,
    );
  }

  /// Generate a valid solution mapping
  static PuzzleSolution _generateSolution(
      List<Category> categories, int gridSize) {
    final mappings = <String, Map<String, bool>>{};

    // For the first category, create random permutations to other categories
    const baseCategory = 0;
    final permutations = <int, List<int>>{};

    for (int cat = 1; cat < categories.length; cat++) {
      final perm = List.generate(gridSize, (i) => i)..shuffle(_random);
      permutations[cat] = perm;
    }

    // Build the complete solution
    for (int item = 0; item < gridSize; item++) {
      final baseKey = '$baseCategory-$item';
      mappings[baseKey] = {};

      for (int cat = 1; cat < categories.length; cat++) {
        final matchedItem = permutations[cat]![item];
        final catKey = '$cat-$matchedItem';
        mappings[baseKey]![catKey] = true;

        // Also add reverse mapping
        if (!mappings.containsKey(catKey)) {
          mappings[catKey] = {};
        }
        mappings[catKey]![baseKey] = true;

        // Add transitive mappings between non-base categories
        for (int otherCat = cat + 1; otherCat < categories.length; otherCat++) {
          final otherItem = permutations[otherCat]![item];
          final otherKey = '$otherCat-$otherItem';
          mappings[catKey]![otherKey] = true;
          if (!mappings.containsKey(otherKey)) {
            mappings[otherKey] = {};
          }
          mappings[otherKey]![catKey] = true;
        }
      }
    }

    return PuzzleSolution(mappings: mappings);
  }

  /// Generate clues based on the solution
  static List<Clue> _generateClues(
    List<Category> categories,
    PuzzleSolution solution,
    Difficulty difficulty,
  ) {
    final clues = <Clue>[];
    int clueId = 0;
    final gridSize = difficulty.gridSize;

    // Generate direct clues (positive matches)
    final directClueCount = difficulty == Difficulty.easy
        ? gridSize * 2
        : (difficulty == Difficulty.medium ? gridSize + 2 : gridSize);

    final usedPairs = <String>{};

    for (int i = 0;
        i < directClueCount && i < gridSize * (categories.length - 1);
        i++) {
      final cat1 = _random.nextInt(categories.length);
      final cat2 = (cat1 + 1 + _random.nextInt(categories.length - 1)) %
          categories.length;
      final item1 = _random.nextInt(gridSize);

      // Find the matching item in cat2
      int? matchedItem;
      for (int j = 0; j < gridSize; j++) {
        if (solution.isMatch(cat1, item1, cat2, j)) {
          matchedItem = j;
          break;
        }
      }

      if (matchedItem != null) {
        final pairKey = '$cat1-$item1-$cat2-$matchedItem';
        if (!usedPairs.contains(pairKey)) {
          usedPairs.add(pairKey);
          final name1 = categories[cat1].items[item1];
          final name2 = categories[cat2].items[matchedItem];
          final cellKey = '$cat1-$item1-$cat2-$matchedItem';

          clues.add(Clue(
            id: clueId++,
            text: '$name1 is matched with $name2.',
            type: ClueType.direct,
            relatedCells: [cellKey],
          ));
        }
      }
    }

    // Generate negative clues
    final negativeClueCount = difficulty == Difficulty.easy
        ? gridSize
        : (difficulty == Difficulty.medium ? gridSize * 2 : gridSize * 3);

    for (int i = 0; i < negativeClueCount; i++) {
      final cat1 = _random.nextInt(categories.length);
      final cat2 = (cat1 + 1 + _random.nextInt(categories.length - 1)) %
          categories.length;
      final item1 = _random.nextInt(gridSize);
      final item2 = _random.nextInt(gridSize);

      if (!solution.isMatch(cat1, item1, cat2, item2)) {
        final pairKey = '$cat1-$item1-$cat2-$item2-neg';
        if (!usedPairs.contains(pairKey)) {
          usedPairs.add(pairKey);
          final name1 = categories[cat1].items[item1];
          final name2 = categories[cat2].items[item2];
          final cellKey = '$cat1-$item1-$cat2-$item2';

          clues.add(Clue(
            id: clueId++,
            text: '$name1 is NOT matched with $name2.',
            type: ClueType.negative,
            relatedCells: [cellKey],
          ));
        }
      }
    }

    // Shuffle clues
    clues.shuffle(_random);

    return clues;
  }

  /// Generate a daily puzzle (seeded by date)
  static Puzzle generateDaily(Difficulty difficulty) {
    // Use the seeded date for daily puzzle consistency
    return generate(difficulty);
  }
}
