import '../data/models/cell_state.dart';
import 'mine_generator.dart';

/// Game validation and reveal logic for Minesweeper
class GameValidation {
  /// Check if the player has won (all non-mine cells revealed)
  static bool checkWinCondition(List<CellData> grid) {
    for (final cell in grid) {
      // If there's a non-mine cell that's not revealed, game is not won
      if (!cell.hasMine && !cell.isRevealed) {
        return false;
      }
    }
    return true;
  }

  /// Reveal a cell and return updated grid with indices of revealed cells
  /// Uses flood-fill algorithm for empty cells
  static ({List<CellData> grid, Set<int> revealedIndices, bool hitMine})
      revealCell(
    List<CellData> grid,
    int index,
    int rows,
    int cols,
  ) {
    if (index < 0 || index >= grid.length) {
      return (grid: grid, revealedIndices: <int>{}, hitMine: false);
    }

    final cell = grid[index];

    // Can't reveal flagged or already revealed cells
    if (cell.isFlagged || cell.isRevealed) {
      return (grid: grid, revealedIndices: <int>{}, hitMine: false);
    }

    // Check if hit a mine
    if (cell.hasMine) {
      // Reveal all mines on game over
      final updatedGrid = _revealAllMines(grid);
      return (grid: updatedGrid, revealedIndices: <int>{index}, hitMine: true);
    }

    // Reveal the cell and flood-fill if empty
    final (updatedGrid, revealedIndices) =
        _floodFillReveal(grid, index, rows, cols);

    return (
      grid: updatedGrid,
      revealedIndices: revealedIndices,
      hitMine: false
    );
  }

  /// Flood-fill reveal for empty cells
  static (List<CellData>, Set<int>) _floodFillReveal(
    List<CellData> grid,
    int startIndex,
    int rows,
    int cols,
  ) {
    final updatedGrid = List<CellData>.from(grid);
    final revealed = <int>{};
    final toProcess = <int>[startIndex];

    while (toProcess.isNotEmpty) {
      final index = toProcess.removeLast();

      if (revealed.contains(index)) continue;
      if (index < 0 || index >= updatedGrid.length) continue;

      final cell = updatedGrid[index];
      if (cell.isRevealed || cell.isFlagged || cell.hasMine) continue;

      // Reveal this cell
      updatedGrid[index] = cell.copyWith(state: CellState.revealed);
      revealed.add(index);

      // If cell is empty (no adjacent mines), reveal neighbors
      if (cell.adjacentMines == 0) {
        final neighbors = MineGenerator.getNeighborIndices(index, rows, cols);
        for (final neighbor in neighbors) {
          if (!revealed.contains(neighbor) &&
              !updatedGrid[neighbor].isRevealed &&
              !updatedGrid[neighbor].isFlagged) {
            toProcess.add(neighbor);
          }
        }
      }
    }

    return (updatedGrid, revealed);
  }

  /// Reveal all mines (for game over)
  static List<CellData> _revealAllMines(List<CellData> grid) {
    return grid.map((cell) {
      if (cell.hasMine) {
        return cell.copyWith(state: CellState.revealed);
      }
      return cell;
    }).toList();
  }

  /// Chord reveal - reveal all neighbors if flag count matches adjacent mines
  static ({List<CellData> grid, Set<int> revealedIndices, bool hitMine})
      chordReveal(
    List<CellData> grid,
    int index,
    int rows,
    int cols,
  ) {
    final cell = grid[index];

    // Only works on revealed numbered cells
    if (!cell.isRevealed || cell.adjacentMines == 0) {
      return (grid: grid, revealedIndices: <int>{}, hitMine: false);
    }

    final neighbors = MineGenerator.getNeighborIndices(index, rows, cols);
    final flaggedCount = neighbors.where((n) => grid[n].isFlagged).length;

    // Only chord if flag count matches adjacent mines
    if (flaggedCount != cell.adjacentMines) {
      return (grid: grid, revealedIndices: <int>{}, hitMine: false);
    }

    // Reveal all non-flagged neighbors
    var updatedGrid = List<CellData>.from(grid);
    final allRevealed = <int>{};
    var hitMine = false;

    for (final neighbor in neighbors) {
      if (!updatedGrid[neighbor].isFlagged &&
          !updatedGrid[neighbor].isRevealed) {
        final result = revealCell(updatedGrid, neighbor, rows, cols);
        updatedGrid = result.grid;
        allRevealed.addAll(result.revealedIndices);
        if (result.hitMine) {
          hitMine = true;
          break;
        }
      }
    }

    return (grid: updatedGrid, revealedIndices: allRevealed, hitMine: hitMine);
  }

  /// Toggle flag on a cell (cycles: hidden -> flagged -> questionMark -> hidden)
  static CellData toggleFlag(CellData cell, {bool useQuestionMark = true}) {
    switch (cell.state) {
      case CellState.hidden:
        return cell.copyWith(state: CellState.flagged);
      case CellState.flagged:
        return cell.copyWith(
          state: useQuestionMark ? CellState.questionMark : CellState.hidden,
        );
      case CellState.questionMark:
        return cell.copyWith(state: CellState.hidden);
      case CellState.revealed:
        return cell; // Can't flag revealed cells
    }
  }

  /// Count correctly placed flags
  static int countCorrectFlags(List<CellData> grid) {
    int correct = 0;
    for (final cell in grid) {
      if (cell.isFlagged && cell.hasMine) {
        correct++;
      }
    }
    return correct;
  }

  /// Count incorrectly placed flags
  static int countWrongFlags(List<CellData> grid) {
    int wrong = 0;
    for (final cell in grid) {
      if (cell.isFlagged && !cell.hasMine) {
        wrong++;
      }
    }
    return wrong;
  }
}
