/// Player enum representing X, O, or empty cell
enum Player {
  x,
  o,
  none;

  String get symbol {
    switch (this) {
      case Player.x:
        return 'X';
      case Player.o:
        return 'O';
      case Player.none:
        return '';
    }
  }

  Player get opponent {
    switch (this) {
      case Player.x:
        return Player.o;
      case Player.o:
        return Player.x;
      case Player.none:
        return Player.none;
    }
  }
}

/// Game status enum
enum GameStatus {
  playing,
  xWins,
  oWins,
  draw;

  bool get isGameOver => this != GameStatus.playing;
}

/// Game mode enum
enum GameMode { twoPlayer, vsAiEasy, vsAiMedium, vsAiHard }

/// Represents the complete game state
class GameState {
  final List<Player> board;
  final Player currentPlayer;
  final GameStatus status;
  final List<int>? winningLine;
  final GameMode mode;
  final Player humanSymbol;
  final List<int> moveHistory;

  const GameState({
    required this.board,
    required this.currentPlayer,
    required this.status,
    this.winningLine,
    this.mode = GameMode.twoPlayer,
    this.humanSymbol = Player.x,
    this.moveHistory = const [],
  });

  factory GameState.initial() {
    return GameState(
      board: List.filled(9, Player.none),
      currentPlayer: Player.x,
      status: GameStatus.playing,
      winningLine: null,
      mode: GameMode.twoPlayer,
      humanSymbol: Player.x,
      moveHistory: const [],
    );
  }

  GameState copyWith({
    List<Player>? board,
    Player? currentPlayer,
    GameStatus? status,
    List<int>? winningLine,
    GameMode? mode,
    Player? humanSymbol,
    List<int>? moveHistory,
  }) {
    return GameState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      status: status ?? this.status,
      winningLine: winningLine,
      mode: mode ?? this.mode,
      humanSymbol: humanSymbol ?? this.humanSymbol,
      moveHistory: moveHistory ?? this.moveHistory,
    );
  }

  /// Check if it's the AI's turn
  bool get isAiTurn {
    if (mode == GameMode.twoPlayer) return false;
    return currentPlayer != humanSymbol && !status.isGameOver;
  }

  /// Get status message for display
  String get statusMessage {
    switch (status) {
      case GameStatus.playing:
        return "Player ${currentPlayer.symbol}'s Turn";
      case GameStatus.xWins:
        return "Player X Wins! 🎉";
      case GameStatus.oWins:
        return "Player O Wins! 🎉";
      case GameStatus.draw:
        return "Match Draw 🤝";
    }
  }
}
