/// Represents the choices in Rock Paper Scissors
enum RPSChoice {
  rock,
  paper,
  scissors;

  /// Get the display emoji for this choice
  String get emoji {
    switch (this) {
      case RPSChoice.rock:
        return '🪨';
      case RPSChoice.paper:
        return '📄';
      case RPSChoice.scissors:
        return '✂️';
    }
  }

  /// Get the display name for this choice
  String get displayName {
    switch (this) {
      case RPSChoice.rock:
        return 'Rock';
      case RPSChoice.paper:
        return 'Paper';
      case RPSChoice.scissors:
        return 'Scissors';
    }
  }

  /// Get what this choice beats
  RPSChoice get beats {
    switch (this) {
      case RPSChoice.rock:
        return RPSChoice.scissors;
      case RPSChoice.paper:
        return RPSChoice.rock;
      case RPSChoice.scissors:
        return RPSChoice.paper;
    }
  }

  /// Get what beats this choice
  RPSChoice get beatenBy {
    switch (this) {
      case RPSChoice.rock:
        return RPSChoice.paper;
      case RPSChoice.paper:
        return RPSChoice.scissors;
      case RPSChoice.scissors:
        return RPSChoice.rock;
    }
  }
}

/// Result of a round
enum RPSResult {
  win,
  lose,
  draw;

  String get message {
    switch (this) {
      case RPSResult.win:
        return 'You Win! 🎉';
      case RPSResult.lose:
        return 'You Lose! 😢';
      case RPSResult.draw:
        return 'Draw! 🤝';
    }
  }
}

/// AI difficulty levels
enum AIDifficulty {
  easy,
  medium,
  hard;

  String get displayName {
    switch (this) {
      case AIDifficulty.easy:
        return 'Easy';
      case AIDifficulty.medium:
        return 'Medium';
      case AIDifficulty.hard:
        return 'Hard';
    }
  }

  String get description {
    switch (this) {
      case AIDifficulty.easy:
        return 'Random moves';
      case AIDifficulty.medium:
        return 'Sometimes predicts';
      case AIDifficulty.hard:
        return 'Pattern learning';
    }
  }
}

/// Best of X mode options
enum GameRoundsMode {
  infinite,
  bestOf3,
  bestOf5,
  bestOf7;

  int? get targetWins {
    switch (this) {
      case GameRoundsMode.infinite:
        return null;
      case GameRoundsMode.bestOf3:
        return 2;
      case GameRoundsMode.bestOf5:
        return 3;
      case GameRoundsMode.bestOf7:
        return 4;
    }
  }

  String get displayName {
    switch (this) {
      case GameRoundsMode.infinite:
        return 'Infinite';
      case GameRoundsMode.bestOf3:
        return 'Best of 3';
      case GameRoundsMode.bestOf5:
        return 'Best of 5';
      case GameRoundsMode.bestOf7:
        return 'Best of 7';
    }
  }
}
