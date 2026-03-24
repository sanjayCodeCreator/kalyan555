/// Predefined puzzles for Matchstick Puzzle game
library;

import 'matchstick_models.dart';

/// Repository of all puzzles
class PuzzleData {
  /// All available puzzles
  static List<MatchstickPuzzle> get allPuzzles => [
        ...easyPuzzles,
        ...mediumPuzzles,
        ...hardPuzzles,
      ];

  /// Easy puzzles (1 move)
  static List<MatchstickPuzzle> get easyPuzzles => [
        _createEquationPuzzle1(),
        _createEquationPuzzle2(),
        _createEquationPuzzle3(),
        _createShapePuzzle1(),
        _createEquationPuzzle4(),
        _createEquationPuzzle5(),
        _createEquationPuzzle6(),
      ];

  /// Medium puzzles (2-3 moves)
  static List<MatchstickPuzzle> get mediumPuzzles => [
        _createMediumEquation1(),
        _createMediumEquation2(),
        _createMediumShape1(),
        _createMediumEquation3(),
        _createMediumEquation4(),
        _createMediumShape2(),
        _createMediumEquation5(),
      ];

  /// Hard puzzles (4+ moves)
  static List<MatchstickPuzzle> get hardPuzzles => [
        _createHardPuzzle1(),
        _createHardPuzzle2(),
        _createHardShape1(),
        _createHardPuzzle3(),
        _createHardPuzzle4(),
        _createHardShape2(),
      ];

  /// Get puzzle by ID
  static MatchstickPuzzle? getPuzzleById(int id) {
    try {
      return allPuzzles.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get puzzles by difficulty
  static List<MatchstickPuzzle> getPuzzlesByDifficulty(Difficulty difficulty) {
    return allPuzzles.where((p) => p.difficulty == difficulty).toList();
  }

  /// Get next puzzle after given ID
  static MatchstickPuzzle? getNextPuzzle(int currentId) {
    final index = allPuzzles.indexWhere((p) => p.id == currentId);
    if (index >= 0 && index < allPuzzles.length - 1) {
      return allPuzzles[index + 1];
    }
    return null;
  }

  // =====================
  // EASY PUZZLES (1 move)
  // =====================

  /// Puzzle 1: 6+4=4 → 0+4=4 (remove one stick from 6)
  static MatchstickPuzzle _createEquationPuzzle1() {
    const baseX = 40.0;
    const baseY = 100.0;
    const stickLen = 60.0;
    const gap = 70.0;

    return MatchstickPuzzle(
      id: 1,
      title: 'Fix the Equation',
      objective: 'Move 1 matchstick to make the equation correct',
      type: PuzzleType.mathEquation,
      difficulty: Difficulty.easy,
      allowedMoves: 1,
      initialMatchsticks: [
        // Number 6 (5 sticks)
        const Matchstick(id: 1, x: baseX, y: baseY, angle: 0),
        const Matchstick(id: 2, x: baseX, y: baseY + stickLen, angle: 0),
        const Matchstick(id: 3, x: baseX, y: baseY, angle: 90, isMovable: true),
        const Matchstick(id: 4, x: baseX, y: baseY + stickLen / 2, angle: 90),
        const Matchstick(
            id: 5, x: baseX + stickLen / 2, y: baseY + stickLen / 2, angle: 90),
        // Plus sign
        const Matchstick(
            id: 6,
            x: baseX + gap,
            y: baseY + stickLen / 2,
            angle: 0,
            isMovable: false),
        const Matchstick(
            id: 7,
            x: baseX + gap + 15,
            y: baseY + stickLen / 4,
            angle: 90,
            isMovable: false),
        // Number 4 (4 sticks)
        const Matchstick(id: 8, x: baseX + gap * 2, y: baseY, angle: 90),
        const Matchstick(
            id: 9, x: baseX + gap * 2, y: baseY + stickLen / 2, angle: 0),
        const Matchstick(
            id: 10, x: baseX + gap * 2 + stickLen / 2, y: baseY, angle: 90),
        const Matchstick(
            id: 11,
            x: baseX + gap * 2 + stickLen / 2,
            y: baseY + stickLen / 2,
            angle: 90),
        // Equals sign
        const Matchstick(
            id: 12,
            x: baseX + gap * 3,
            y: baseY + stickLen / 3,
            angle: 0,
            isMovable: false),
        const Matchstick(
            id: 13,
            x: baseX + gap * 3,
            y: baseY + stickLen * 2 / 3,
            angle: 0,
            isMovable: false),
        // Number 4 result (4 sticks)
        const Matchstick(id: 14, x: baseX + gap * 4, y: baseY, angle: 90),
        const Matchstick(
            id: 15, x: baseX + gap * 4, y: baseY + stickLen / 2, angle: 0),
        const Matchstick(
            id: 16, x: baseX + gap * 4 + stickLen / 2, y: baseY, angle: 90),
        const Matchstick(
            id: 17,
            x: baseX + gap * 4 + stickLen / 2,
            y: baseY + stickLen / 2,
            angle: 90),
      ],
      gridSlots: _generateGridSlots(6, 4, baseX, baseY, 30),
      solution: const SolutionConfig(
        positions: {
          3: (x: baseX + gap * 4 + stickLen, y: baseY, angle: 90),
        },
      ),
      hint: 'The 6 can become 0',
      explanation: 'Remove one stick from 6 to make 0. 0+4=4 is correct!',
    );
  }

  /// Puzzle 2: 1+1=3 → 1+1=2
  static MatchstickPuzzle _createEquationPuzzle2() {
    const baseX = 50.0;
    const baseY = 100.0;
    const stickLen = 60.0;
    const gap = 60.0;

    return MatchstickPuzzle(
      id: 2,
      title: 'Simple Addition',
      objective: 'Move 1 matchstick to correct the sum',
      type: PuzzleType.mathEquation,
      difficulty: Difficulty.easy,
      allowedMoves: 1,
      initialMatchsticks: [
        // Number 1 (1 stick vertical)
        const Matchstick(id: 1, x: baseX, y: baseY, angle: 90),
        // Plus
        const Matchstick(
            id: 2, x: baseX + gap, y: baseY + 20, angle: 0, isMovable: false),
        const Matchstick(
            id: 3, x: baseX + gap + 15, y: baseY, angle: 90, isMovable: false),
        // Number 1
        const Matchstick(id: 4, x: baseX + gap * 2, y: baseY, angle: 90),
        // Equals
        const Matchstick(
            id: 5,
            x: baseX + gap * 3,
            y: baseY + 10,
            angle: 0,
            isMovable: false),
        const Matchstick(
            id: 6,
            x: baseX + gap * 3,
            y: baseY + 30,
            angle: 0,
            isMovable: false),
        // Number 3 (5 sticks) - one needs to move to make 2
        const Matchstick(id: 7, x: baseX + gap * 4, y: baseY, angle: 0),
        const Matchstick(
            id: 8, x: baseX + gap * 4, y: baseY + stickLen / 2, angle: 0),
        const Matchstick(
            id: 9, x: baseX + gap * 4, y: baseY + stickLen, angle: 0),
        const Matchstick(
            id: 10,
            x: baseX + gap * 4 + 30,
            y: baseY,
            angle: 90,
            isMovable: true),
        const Matchstick(
            id: 11,
            x: baseX + gap * 4 + 30,
            y: baseY + stickLen / 2,
            angle: 90),
      ],
      gridSlots: _generateGridSlots(6, 3, baseX, baseY, 30),
      solution: const SolutionConfig(
        positions: {
          10: (x: baseX + gap * 4, y: baseY, angle: 90),
        },
      ),
      hint: 'Change the 3 into a 2',
      explanation: 'Move one stick from 3 to make 2. 1+1=2!',
    );
  }

  /// Puzzle 3: 5-3=5 → 5-0=5
  static MatchstickPuzzle _createEquationPuzzle3() {
    const baseX = 50.0;
    const baseY = 100.0;
    const stickLen = 60.0;
    const gap = 60.0;

    return MatchstickPuzzle(
      id: 3,
      title: 'Subtraction Fix',
      objective: 'Move 1 matchstick to make subtraction correct',
      type: PuzzleType.mathEquation,
      difficulty: Difficulty.easy,
      allowedMoves: 1,
      initialMatchsticks: [
        // Number 5 (5 sticks)
        const Matchstick(id: 1, x: baseX, y: baseY, angle: 0),
        const Matchstick(id: 2, x: baseX, y: baseY + stickLen / 2, angle: 0),
        const Matchstick(id: 3, x: baseX, y: baseY + stickLen, angle: 0),
        const Matchstick(id: 4, x: baseX, y: baseY, angle: 90),
        const Matchstick(
            id: 5, x: baseX + 30, y: baseY + stickLen / 2, angle: 90),
        // Minus
        const Matchstick(
            id: 6,
            x: baseX + gap,
            y: baseY + stickLen / 2,
            angle: 0,
            isMovable: false),
        // Number 3 (5 sticks) - needs to become 0
        const Matchstick(id: 7, x: baseX + gap * 2, y: baseY, angle: 0),
        const Matchstick(
            id: 8,
            x: baseX + gap * 2,
            y: baseY + stickLen / 2,
            angle: 0,
            isMovable: true),
        const Matchstick(
            id: 9, x: baseX + gap * 2, y: baseY + stickLen, angle: 0),
        const Matchstick(id: 10, x: baseX + gap * 2 + 30, y: baseY, angle: 90),
        const Matchstick(
            id: 11,
            x: baseX + gap * 2 + 30,
            y: baseY + stickLen / 2,
            angle: 90),
        // Equals
        const Matchstick(
            id: 12,
            x: baseX + gap * 3,
            y: baseY + 15,
            angle: 0,
            isMovable: false),
        const Matchstick(
            id: 13,
            x: baseX + gap * 3,
            y: baseY + 35,
            angle: 0,
            isMovable: false),
        // Number 5 (5 sticks)
        const Matchstick(id: 14, x: baseX + gap * 4, y: baseY, angle: 0),
        const Matchstick(
            id: 15, x: baseX + gap * 4, y: baseY + stickLen / 2, angle: 0),
        const Matchstick(
            id: 16, x: baseX + gap * 4, y: baseY + stickLen, angle: 0),
        const Matchstick(id: 17, x: baseX + gap * 4, y: baseY, angle: 90),
        const Matchstick(
            id: 18,
            x: baseX + gap * 4 + 30,
            y: baseY + stickLen / 2,
            angle: 90),
      ],
      gridSlots: _generateGridSlots(7, 4, baseX, baseY, 30),
      solution: const SolutionConfig(
        positions: {
          8: (x: baseX + gap * 2, y: baseY, angle: 90),
        },
      ),
      hint: 'Can you turn 3 into 0?',
      explanation: 'Move middle stick of 3 to close it into 0. 5-0=5!',
    );
  }

  /// Puzzle 4: Shape - Remove 1 to leave 2 squares
  static MatchstickPuzzle _createShapePuzzle1() {
    const baseX = 80.0;
    const baseY = 100.0;
    const size = 60.0;

    return MatchstickPuzzle(
      id: 4,
      title: 'Two Squares',
      objective: 'Remove 1 matchstick to leave exactly 2 squares',
      type: PuzzleType.shapeFormation,
      difficulty: Difficulty.easy,
      allowedMoves: 1,
      initialMatchsticks: [
        // 3 connected squares (12 sticks, shared sides)
        // Top row
        const Matchstick(id: 1, x: baseX, y: baseY, angle: 0),
        const Matchstick(id: 2, x: baseX + size, y: baseY, angle: 0),
        const Matchstick(id: 3, x: baseX + size * 2, y: baseY, angle: 0),
        // Middle row
        const Matchstick(id: 4, x: baseX, y: baseY + size, angle: 0),
        const Matchstick(
            id: 5, x: baseX + size, y: baseY + size, angle: 0, isMovable: true),
        const Matchstick(id: 6, x: baseX + size * 2, y: baseY + size, angle: 0),
        // Verticals
        const Matchstick(id: 7, x: baseX, y: baseY, angle: 90),
        const Matchstick(id: 8, x: baseX + size, y: baseY, angle: 90),
        const Matchstick(id: 9, x: baseX + size * 2, y: baseY, angle: 90),
        const Matchstick(id: 10, x: baseX + size * 3, y: baseY, angle: 90),
      ],
      gridSlots: _generateGridSlots(5, 3, baseX, baseY, size),
      solution: const SolutionConfig(
        positions: {
          5: (x: -100, y: -100, angle: 0), // Removed (off-screen)
        },
      ),
      hint: 'Remove a shared edge',
      explanation: 'Remove the middle bottom stick to break one square!',
    );
  }

  /// Puzzle 5: 2+2=5 → 2+3=5
  static MatchstickPuzzle _createEquationPuzzle4() {
    const baseX = 40.0;
    const baseY = 100.0;
    const gap = 65.0;

    return MatchstickPuzzle(
      id: 5,
      title: 'Quick Math',
      objective: 'Move 1 matchstick to fix the equation',
      type: PuzzleType.mathEquation,
      difficulty: Difficulty.easy,
      allowedMoves: 1,
      initialMatchsticks: _generateEquationSticks('2+2=5', baseX, baseY, gap),
      gridSlots: _generateGridSlots(7, 3, baseX, baseY, 30),
      solution: const SolutionConfig(positions: {}),
      hint: 'Change one of the 2s',
      explanation: 'Move one stick from first 2 to make 3. 2+3=5!',
    );
  }

  /// Puzzle 6: 3+3=8 → 3+5=8
  static MatchstickPuzzle _createEquationPuzzle5() {
    const baseX = 40.0;
    const baseY = 100.0;
    const gap = 65.0;

    return MatchstickPuzzle(
      id: 6,
      title: 'Make It Eight',
      objective: 'Move 1 matchstick to get 8',
      type: PuzzleType.mathEquation,
      difficulty: Difficulty.easy,
      allowedMoves: 1,
      initialMatchsticks: _generateEquationSticks('3+3=8', baseX, baseY, gap),
      gridSlots: _generateGridSlots(7, 3, baseX, baseY, 30),
      solution: const SolutionConfig(positions: {}),
      hint: 'One 3 can become 5',
      explanation: 'Move stick from second 3 to make 5. 3+5=8!',
    );
  }

  /// Puzzle 7: 9-3=2 → 9-7=2
  static MatchstickPuzzle _createEquationPuzzle6() {
    const baseX = 40.0;
    const baseY = 100.0;
    const gap = 65.0;

    return MatchstickPuzzle(
      id: 7,
      title: 'Minus Seven',
      objective: 'Move 1 matchstick to correct the subtraction',
      type: PuzzleType.mathEquation,
      difficulty: Difficulty.easy,
      allowedMoves: 1,
      initialMatchsticks: _generateEquationSticks('9-3=2', baseX, baseY, gap),
      gridSlots: _generateGridSlots(7, 3, baseX, baseY, 30),
      solution: const SolutionConfig(positions: {}),
      hint: 'Turn 3 into 7',
      explanation: 'Flip a stick from 3 to make 7. 9-7=2!',
    );
  }

  // =======================
  // MEDIUM PUZZLES (2-3 moves)
  // =======================

  static MatchstickPuzzle _createMediumEquation1() {
    return MatchstickPuzzle(
      id: 8,
      title: 'Double Move',
      objective: 'Move 2 matchsticks to make the equation correct',
      type: PuzzleType.mathEquation,
      difficulty: Difficulty.medium,
      allowedMoves: 2,
      initialMatchsticks: _generateEquationSticks('6+1=8', 40, 100, 65),
      gridSlots: _generateGridSlots(7, 3, 40, 100, 30),
      solution: const SolutionConfig(positions: {}),
      hint: 'Change both numbers on the left',
      explanation: 'Transform 6→8 and 1→0 gives 8+0=8',
    );
  }

  static MatchstickPuzzle _createMediumEquation2() {
    return MatchstickPuzzle(
      id: 9,
      title: 'Roman Numerals I',
      objective: 'Move 2 matchsticks: VI = II → IV = IV',
      type: PuzzleType.mathEquation,
      difficulty: Difficulty.medium,
      allowedMoves: 2,
      initialMatchsticks: _generateRomanSticks('VI=II', 60, 120, 50),
      gridSlots: _generateGridSlots(6, 2, 60, 120, 40),
      solution: const SolutionConfig(positions: {}),
      hint: 'Both sides should show 4',
      explanation: 'Rearrange to make IV=IV (4=4)',
    );
  }

  static MatchstickPuzzle _createMediumShape1() {
    const baseX = 80.0;
    const baseY = 80.0;
    const size = 50.0;

    return MatchstickPuzzle(
      id: 10,
      title: 'Square Challenge',
      objective: 'Move 2 matchsticks to make 3 equal squares',
      type: PuzzleType.shapeFormation,
      difficulty: Difficulty.medium,
      allowedMoves: 2,
      initialMatchsticks: [
        // L-shaped 4 squares arrangement
        const Matchstick(id: 1, x: baseX, y: baseY, angle: 0),
        const Matchstick(id: 2, x: baseX + size, y: baseY, angle: 0),
        const Matchstick(id: 3, x: baseX, y: baseY + size, angle: 0),
        const Matchstick(id: 4, x: baseX + size, y: baseY + size, angle: 0),
        const Matchstick(id: 5, x: baseX, y: baseY + size * 2, angle: 0),
        const Matchstick(id: 6, x: baseX, y: baseY, angle: 90),
        const Matchstick(id: 7, x: baseX + size, y: baseY, angle: 90),
        const Matchstick(id: 8, x: baseX + size * 2, y: baseY, angle: 90),
        const Matchstick(id: 9, x: baseX, y: baseY + size, angle: 90),
        const Matchstick(id: 10, x: baseX + size, y: baseY + size, angle: 90),
      ],
      gridSlots: _generateGridSlots(4, 4, baseX, baseY, size),
      solution: const SolutionConfig(positions: {}),
      hint: 'Rearrange to form a row',
      explanation: 'Move 2 sticks to create 3 squares in a row',
    );
  }

  static MatchstickPuzzle _createMediumEquation3() {
    return MatchstickPuzzle(
      id: 11,
      title: 'From Wrong to Right',
      objective: 'Move 2 matchsticks: 1+9=6 → ?',
      type: PuzzleType.mathEquation,
      difficulty: Difficulty.medium,
      allowedMoves: 2,
      initialMatchsticks: _generateEquationSticks('1+9=6', 40, 100, 65),
      gridSlots: _generateGridSlots(7, 3, 40, 100, 30),
      solution: const SolutionConfig(positions: {}),
      hint: 'Make it 1+5=6',
      explanation: 'Move 2 sticks from 9 to make 5. 1+5=6!',
    );
  }

  static MatchstickPuzzle _createMediumEquation4() {
    return MatchstickPuzzle(
      id: 12,
      title: 'Multiplication Intro',
      objective: 'Move 2 matchsticks to fix: 2×3=9',
      type: PuzzleType.mathEquation,
      difficulty: Difficulty.medium,
      allowedMoves: 2,
      initialMatchsticks: _generateEquationSticks('2x3=9', 40, 100, 65),
      gridSlots: _generateGridSlots(7, 3, 40, 100, 30),
      solution: const SolutionConfig(positions: {}),
      hint: 'Make it 3×3=9',
      explanation: 'Change 2 to 3. 3×3=9!',
    );
  }

  static MatchstickPuzzle _createMediumShape2() {
    const baseX = 60.0;
    const baseY = 100.0;

    return MatchstickPuzzle(
      id: 13,
      title: 'Triangle to Square',
      objective: 'Move 2 matchsticks to change triangle into square',
      type: PuzzleType.shapeFormation,
      difficulty: Difficulty.medium,
      allowedMoves: 2,
      initialMatchsticks: [
        // Large triangle
        const Matchstick(id: 1, x: baseX + 60, y: baseY, angle: 0),
        const Matchstick(id: 2, x: baseX, y: baseY + 60, angle: 45),
        const Matchstick(id: 3, x: baseX + 90, y: baseY + 60, angle: 135),
        const Matchstick(id: 4, x: baseX + 30, y: baseY + 90, angle: 0),
      ],
      gridSlots: _generateGridSlots(4, 3, baseX, baseY, 50),
      solution: const SolutionConfig(positions: {}),
      hint: 'Form 4 right angles',
      explanation: 'Rearrange to form a square shape',
    );
  }

  static MatchstickPuzzle _createMediumEquation5() {
    return MatchstickPuzzle(
      id: 14,
      title: 'Balance Equation',
      objective: 'Move 3 matchsticks: 8-4=0 → ?',
      type: PuzzleType.mathEquation,
      difficulty: Difficulty.medium,
      allowedMoves: 3,
      initialMatchsticks: _generateEquationSticks('8-4=0', 40, 100, 65),
      gridSlots: _generateGridSlots(7, 3, 40, 100, 30),
      solution: const SolutionConfig(positions: {}),
      hint: 'Make it 8-8=0',
      explanation: 'Transform 4 into 8. 8-8=0!',
    );
  }

  // ======================
  // HARD PUZZLES (4+ moves)
  // ======================

  static MatchstickPuzzle _createHardPuzzle1() {
    return MatchstickPuzzle(
      id: 15,
      title: 'Advanced Math',
      objective: 'Move 4 matchsticks to fix: 1+1+1=6',
      type: PuzzleType.mathEquation,
      difficulty: Difficulty.hard,
      allowedMoves: 4,
      initialMatchsticks: _generateEquationSticks('1+1+1=6', 30, 100, 50),
      gridSlots: _generateGridSlots(9, 3, 30, 100, 25),
      solution: const SolutionConfig(positions: {}),
      hint: 'Make it 1+1+1=3',
      explanation: 'Simplify 6 to 3. 1+1+1=3!',
    );
  }

  static MatchstickPuzzle _createHardPuzzle2() {
    return MatchstickPuzzle(
      id: 16,
      title: 'Roman Numerals II',
      objective: 'Move 4 matchsticks: XVII = VI → ?',
      type: PuzzleType.mathEquation,
      difficulty: Difficulty.hard,
      allowedMoves: 4,
      initialMatchsticks: _generateRomanSticks('XVII=VI', 40, 120, 35),
      gridSlots: _generateGridSlots(9, 2, 40, 120, 30),
      solution: const SolutionConfig(positions: {}),
      hint: 'Balance both sides',
      explanation: 'Rearrange to create equal values on both sides',
    );
  }

  static MatchstickPuzzle _createHardShape1() {
    const baseX = 60.0;
    const baseY = 80.0;
    const size = 45.0;

    return MatchstickPuzzle(
      id: 17,
      title: 'Fish to Arrow',
      objective: 'Move 4 matchsticks to transform fish into arrow',
      type: PuzzleType.shapeFormation,
      difficulty: Difficulty.hard,
      allowedMoves: 4,
      initialMatchsticks: [
        // Fish shape (8 sticks)
        const Matchstick(id: 1, x: baseX, y: baseY + size / 2, angle: 45),
        const Matchstick(id: 2, x: baseX, y: baseY + size, angle: 135),
        const Matchstick(id: 3, x: baseX + size, y: baseY, angle: 90),
        const Matchstick(id: 4, x: baseX + size, y: baseY + size, angle: 90),
        const Matchstick(
            id: 5, x: baseX + size * 2, y: baseY + size / 2, angle: 45),
        const Matchstick(
            id: 6, x: baseX + size * 2, y: baseY + size, angle: 135),
        const Matchstick(id: 7, x: baseX + size * 3, y: baseY, angle: 90),
        const Matchstick(
            id: 8, x: baseX + size * 3, y: baseY + size, angle: 90),
      ],
      gridSlots: _generateGridSlots(6, 4, baseX, baseY, size),
      solution: const SolutionConfig(positions: {}),
      hint: 'Think about arrow pointing right',
      explanation: 'Rearrange to form → shape',
    );
  }

  static MatchstickPuzzle _createHardPuzzle3() {
    return MatchstickPuzzle(
      id: 18,
      title: 'Complex Equation',
      objective: 'Move 4 matchsticks: 8+8=91 → ?',
      type: PuzzleType.mathEquation,
      difficulty: Difficulty.hard,
      allowedMoves: 4,
      initialMatchsticks: _generateEquationSticks('8+8=91', 40, 100, 60),
      gridSlots: _generateGridSlots(8, 3, 40, 100, 30),
      solution: const SolutionConfig(positions: {}),
      hint: 'Make it 9+8=17',
      explanation: 'Multiple transformations needed',
    );
  }

  static MatchstickPuzzle _createHardPuzzle4() {
    return MatchstickPuzzle(
      id: 19,
      title: 'Division Challenge',
      objective: 'Move 5 matchsticks to fix: 9÷3=1',
      type: PuzzleType.mathEquation,
      difficulty: Difficulty.hard,
      allowedMoves: 5,
      initialMatchsticks: _generateEquationSticks('9/3=1', 40, 100, 65),
      gridSlots: _generateGridSlots(7, 3, 40, 100, 30),
      solution: const SolutionConfig(positions: {}),
      hint: 'Result should be 3',
      explanation: 'Modify to make 9÷3=3',
    );
  }

  static MatchstickPuzzle _createHardShape2() {
    const baseX = 50.0;
    const baseY = 80.0;
    const size = 40.0;

    return MatchstickPuzzle(
      id: 20,
      title: 'House Builder',
      objective: 'Move 5 matchsticks to build 2 houses from 1',
      type: PuzzleType.shapeFormation,
      difficulty: Difficulty.hard,
      allowedMoves: 5,
      initialMatchsticks: [
        // House shape (6 sticks)
        const Matchstick(id: 1, x: baseX, y: baseY + size, angle: 0),
        const Matchstick(id: 2, x: baseX, y: baseY + size * 2, angle: 0),
        const Matchstick(id: 3, x: baseX, y: baseY + size, angle: 90),
        const Matchstick(id: 4, x: baseX + size, y: baseY + size, angle: 90),
        const Matchstick(id: 5, x: baseX, y: baseY + size / 2, angle: 45),
        const Matchstick(
            id: 6, x: baseX + size / 2, y: baseY + size / 2, angle: 135),
        // Extra sticks
        const Matchstick(id: 7, x: baseX + size * 2, y: baseY + size, angle: 0),
        const Matchstick(
            id: 8, x: baseX + size * 2, y: baseY + size * 2, angle: 0),
        const Matchstick(
            id: 9, x: baseX + size * 2, y: baseY + size, angle: 90),
        const Matchstick(
            id: 10, x: baseX + size * 3, y: baseY + size, angle: 90),
      ],
      gridSlots: _generateGridSlots(5, 4, baseX, baseY, size),
      solution: const SolutionConfig(positions: {}),
      hint: 'Make 2 smaller houses',
      explanation: 'Rearrange to form 2 house shapes',
    );
  }

  // =================
  // HELPER METHODS
  // =================

  /// Generate grid slots for a puzzle
  static List<GridSlot> _generateGridSlots(
    int cols,
    int rows,
    double baseX,
    double baseY,
    double spacing,
  ) {
    final slots = <GridSlot>[];
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        slots.add(GridSlot(
          slotX: x,
          slotY: y,
          canvasX: baseX + x * spacing,
          canvasY: baseY + y * spacing,
          allowedAngles: const [0, 45, 90, 135],
        ));
      }
    }
    return slots;
  }

  /// Generate matchsticks for an equation string
  static List<Matchstick> _generateEquationSticks(
    String equation,
    double baseX,
    double baseY,
    double gap,
  ) {
    final sticks = <Matchstick>[];
    int id = 1;
    double currentX = baseX;
    const stickLen = 50.0;

    for (final char in equation.split('')) {
      if (char == '+') {
        // Plus sign (2 sticks)
        sticks.add(Matchstick(
          id: id++,
          x: currentX,
          y: baseY + stickLen / 2,
          angle: 0,
          isMovable: false,
        ));
        sticks.add(Matchstick(
          id: id++,
          x: currentX + 15,
          y: baseY + stickLen / 4,
          angle: 90,
          isMovable: false,
        ));
        currentX += gap * 0.7;
      } else if (char == '-') {
        sticks.add(Matchstick(
          id: id++,
          x: currentX,
          y: baseY + stickLen / 2,
          angle: 0,
          isMovable: false,
        ));
        currentX += gap * 0.6;
      } else if (char == '=') {
        sticks.add(Matchstick(
          id: id++,
          x: currentX,
          y: baseY + stickLen / 3,
          angle: 0,
          isMovable: false,
        ));
        sticks.add(Matchstick(
          id: id++,
          x: currentX,
          y: baseY + stickLen * 2 / 3,
          angle: 0,
          isMovable: false,
        ));
        currentX += gap * 0.7;
      } else if (char == 'x' || char == '×') {
        sticks.add(Matchstick(
          id: id++,
          x: currentX,
          y: baseY + stickLen / 4,
          angle: 45,
          isMovable: false,
        ));
        sticks.add(Matchstick(
          id: id++,
          x: currentX,
          y: baseY + stickLen / 4,
          angle: 135,
          isMovable: false,
        ));
        currentX += gap * 0.7;
      } else if (char == '/') {
        sticks.add(Matchstick(
          id: id++,
          x: currentX,
          y: baseY,
          angle: 45,
          isMovable: false,
        ));
        currentX += gap * 0.6;
      } else {
        // Digit
        final digitSticks = _getDigitSticks(
          char,
          id,
          currentX,
          baseY,
          stickLen,
        );
        sticks.addAll(digitSticks);
        id += digitSticks.length;
        currentX += gap;
      }
    }

    return sticks;
  }

  /// Generate matchsticks for a single digit
  static List<Matchstick> _getDigitSticks(
    String digit,
    int startId,
    double x,
    double y,
    double len,
  ) {
    final sticks = <Matchstick>[];
    int id = startId;
    final halfLen = len / 2;

    // 7-segment display positions:
    // Segments: top (0), topRight (90), bottomRight (90), bottom (0),
    //           bottomLeft (90), topLeft (90), middle (0)

    switch (digit) {
      case '0':
        sticks.addAll([
          Matchstick(id: id++, x: x, y: y, angle: 0), // top
          Matchstick(id: id++, x: x + halfLen, y: y, angle: 90), // topRight
          Matchstick(
              id: id++,
              x: x + halfLen,
              y: y + halfLen,
              angle: 90), // bottomRight
          Matchstick(id: id++, x: x, y: y + len, angle: 0), // bottom
          Matchstick(id: id++, x: x, y: y + halfLen, angle: 90), // bottomLeft
          Matchstick(id: id++, x: x, y: y, angle: 90), // topLeft
        ]);
        break;
      case '1':
        sticks.addAll([
          Matchstick(id: id++, x: x + halfLen, y: y, angle: 90), // topRight
          Matchstick(
              id: id++,
              x: x + halfLen,
              y: y + halfLen,
              angle: 90), // bottomRight
        ]);
        break;
      case '2':
        sticks.addAll([
          Matchstick(id: id++, x: x, y: y, angle: 0), // top
          Matchstick(id: id++, x: x + halfLen, y: y, angle: 90), // topRight
          Matchstick(id: id++, x: x, y: y + halfLen, angle: 0), // middle
          Matchstick(id: id++, x: x, y: y + halfLen, angle: 90), // bottomLeft
          Matchstick(id: id++, x: x, y: y + len, angle: 0), // bottom
        ]);
        break;
      case '3':
        sticks.addAll([
          Matchstick(id: id++, x: x, y: y, angle: 0), // top
          Matchstick(id: id++, x: x + halfLen, y: y, angle: 90), // topRight
          Matchstick(
              id: id++,
              x: x + halfLen,
              y: y + halfLen,
              angle: 90), // bottomRight
          Matchstick(id: id++, x: x, y: y + halfLen, angle: 0), // middle
          Matchstick(id: id++, x: x, y: y + len, angle: 0), // bottom
        ]);
        break;
      case '4':
        sticks.addAll([
          Matchstick(id: id++, x: x, y: y, angle: 90), // topLeft
          Matchstick(id: id++, x: x, y: y + halfLen, angle: 0), // middle
          Matchstick(id: id++, x: x + halfLen, y: y, angle: 90), // topRight
          Matchstick(
              id: id++,
              x: x + halfLen,
              y: y + halfLen,
              angle: 90), // bottomRight
        ]);
        break;
      case '5':
        sticks.addAll([
          Matchstick(id: id++, x: x, y: y, angle: 0), // top
          Matchstick(id: id++, x: x, y: y, angle: 90), // topLeft
          Matchstick(id: id++, x: x, y: y + halfLen, angle: 0), // middle
          Matchstick(
              id: id++,
              x: x + halfLen,
              y: y + halfLen,
              angle: 90), // bottomRight
          Matchstick(id: id++, x: x, y: y + len, angle: 0), // bottom
        ]);
        break;
      case '6':
        sticks.addAll([
          Matchstick(id: id++, x: x, y: y, angle: 0), // top
          Matchstick(id: id++, x: x, y: y, angle: 90), // topLeft
          Matchstick(id: id++, x: x, y: y + halfLen, angle: 0), // middle
          Matchstick(id: id++, x: x, y: y + halfLen, angle: 90), // bottomLeft
          Matchstick(
              id: id++,
              x: x + halfLen,
              y: y + halfLen,
              angle: 90), // bottomRight
          Matchstick(id: id++, x: x, y: y + len, angle: 0), // bottom
        ]);
        break;
      case '7':
        sticks.addAll([
          Matchstick(id: id++, x: x, y: y, angle: 0), // top
          Matchstick(id: id++, x: x + halfLen, y: y, angle: 90), // topRight
          Matchstick(
              id: id++,
              x: x + halfLen,
              y: y + halfLen,
              angle: 90), // bottomRight
        ]);
        break;
      case '8':
        sticks.addAll([
          Matchstick(id: id++, x: x, y: y, angle: 0), // top
          Matchstick(id: id++, x: x + halfLen, y: y, angle: 90), // topRight
          Matchstick(
              id: id++,
              x: x + halfLen,
              y: y + halfLen,
              angle: 90), // bottomRight
          Matchstick(id: id++, x: x, y: y + len, angle: 0), // bottom
          Matchstick(id: id++, x: x, y: y + halfLen, angle: 90), // bottomLeft
          Matchstick(id: id++, x: x, y: y, angle: 90), // topLeft
          Matchstick(id: id++, x: x, y: y + halfLen, angle: 0), // middle
        ]);
        break;
      case '9':
        sticks.addAll([
          Matchstick(id: id++, x: x, y: y, angle: 0), // top
          Matchstick(id: id++, x: x + halfLen, y: y, angle: 90), // topRight
          Matchstick(
              id: id++,
              x: x + halfLen,
              y: y + halfLen,
              angle: 90), // bottomRight
          Matchstick(id: id++, x: x, y: y + len, angle: 0), // bottom
          Matchstick(id: id++, x: x, y: y, angle: 90), // topLeft
          Matchstick(id: id++, x: x, y: y + halfLen, angle: 0), // middle
        ]);
        break;
    }

    return sticks;
  }

  /// Generate matchsticks for Roman numerals
  static List<Matchstick> _generateRomanSticks(
    String expression,
    double baseX,
    double baseY,
    double gap,
  ) {
    final sticks = <Matchstick>[];
    int id = 1;
    double currentX = baseX;
    const stickLen = 60.0;

    for (final char in expression.split('')) {
      if (char == 'I') {
        sticks.add(Matchstick(
          id: id++,
          x: currentX,
          y: baseY,
          angle: 90,
        ));
        currentX += gap * 0.5;
      } else if (char == 'V') {
        sticks.add(Matchstick(
          id: id++,
          x: currentX,
          y: baseY,
          angle: 45,
        ));
        sticks.add(Matchstick(
          id: id++,
          x: currentX + 20,
          y: baseY,
          angle: 135,
        ));
        currentX += gap;
      } else if (char == 'X') {
        sticks.add(Matchstick(
          id: id++,
          x: currentX,
          y: baseY,
          angle: 45,
        ));
        sticks.add(Matchstick(
          id: id++,
          x: currentX,
          y: baseY,
          angle: 135,
        ));
        currentX += gap;
      } else if (char == '=') {
        sticks.add(Matchstick(
          id: id++,
          x: currentX,
          y: baseY + stickLen / 3,
          angle: 0,
          isMovable: false,
        ));
        sticks.add(Matchstick(
          id: id++,
          x: currentX,
          y: baseY + stickLen * 2 / 3,
          angle: 0,
          isMovable: false,
        ));
        currentX += gap;
      }
    }

    return sticks;
  }
}
