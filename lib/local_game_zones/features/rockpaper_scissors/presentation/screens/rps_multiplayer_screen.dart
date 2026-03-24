import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/rps_choice.dart';
import '../../domain/rps_game_logic.dart';
import '../widgets/rps_choice_card.dart';

/// Local multiplayer screen for same-device play
class RPSMultiplayerScreen extends ConsumerStatefulWidget {
  const RPSMultiplayerScreen({super.key});

  @override
  ConsumerState<RPSMultiplayerScreen> createState() =>
      _RPSMultiplayerScreenState();
}

class _RPSMultiplayerScreenState extends ConsumerState<RPSMultiplayerScreen> {
  int _player1Score = 0;
  int _player2Score = 0;
  int _drawCount = 0;
  int _currentPlayer = 1;
  RPSChoice? _player1Choice;
  RPSChoice? _player2Choice;
  bool _showResult = false;
  RPSResult? _result;

  void _makeChoice(RPSChoice choice) {
    HapticFeedback.lightImpact();

    setState(() {
      if (_currentPlayer == 1) {
        _player1Choice = choice;
        _currentPlayer = 2;
      } else {
        _player2Choice = choice;
        _revealResult();
      }
    });
  }

  void _revealResult() {
    if (_player1Choice == null || _player2Choice == null) return;

    final result = RPSGameLogic.determineWinner(
      _player1Choice!,
      _player2Choice!,
    );

    setState(() {
      _result = result;
      _showResult = true;

      switch (result) {
        case RPSResult.win:
          _player1Score++;
          break;
        case RPSResult.lose:
          _player2Score++;
          break;
        case RPSResult.draw:
          _drawCount++;
          break;
      }
    });
  }

  void _nextRound() {
    setState(() {
      _player1Choice = null;
      _player2Choice = null;
      _showResult = false;
      _result = null;
      _currentPlayer = 1;
    });
  }

  void _resetGame() {
    setState(() {
      _player1Score = 0;
      _player2Score = 0;
      _drawCount = 0;
      _nextRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Multiplayer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetGame,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Scoreboard
              _MultiplayerScoreboard(
                player1Score: _player1Score,
                player2Score: _player2Score,
                drawCount: _drawCount,
              ),

              const SizedBox(height: 24),

              // Current player indicator or result
              Expanded(
                child: _showResult
                    ? _ResultView(
                        player1Choice: _player1Choice!,
                        player2Choice: _player2Choice!,
                        result: _result!,
                        onNextRound: _nextRound,
                      )
                    : _PlayerTurnView(
                        currentPlayer: _currentPlayer,
                        player1HasChosen: _player1Choice != null,
                        onChoice: _makeChoice,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MultiplayerScoreboard extends StatelessWidget {
  final int player1Score;
  final int player2Score;
  final int drawCount;

  const _MultiplayerScoreboard({
    required this.player1Score,
    required this.player2Score,
    required this.drawCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ScoreItem(
                label: 'Player 1',
                score: player1Score,
                color: const Color(0xFF6C63FF),
                icon: '🔵',
              ),
              const Text(
                'VS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white54,
                ),
              ),
              _ScoreItem(
                label: 'Player 2',
                score: player2Score,
                color: const Color(0xFFFF6B6B),
                icon: '🔴',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Draws: $drawCount',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final String label;
  final int score;
  final Color color;
  final String icon;

  const _ScoreItem({
    required this.label,
    required this.score,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
        ),
        Text(
          '$score',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PlayerTurnView extends StatelessWidget {
  final int currentPlayer;
  final bool player1HasChosen;
  final Function(RPSChoice) onChoice;

  const _PlayerTurnView({
    required this.currentPlayer,
    required this.player1HasChosen,
    required this.onChoice,
  });

  @override
  Widget build(BuildContext context) {
    final color = currentPlayer == 1
        ? const Color(0xFF6C63FF)
        : const Color(0xFFFF6B6B);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pass device instruction
        if (player1HasChosen)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swap_horiz, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Pass device to Player 2',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        // Player indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color),
          ),
          child: Text(
            'Player $currentPlayer\'s Turn',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),

        const SizedBox(height: 8),
        Text(
          'Make your choice secretly!',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),

        const SizedBox(height: 32),

        // Choice cards
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: RPSChoice.values.map((choice) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: RPSChoiceCard(
                  choice: choice,
                  onTap: () => onChoice(choice),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  final RPSChoice player1Choice;
  final RPSChoice player2Choice;
  final RPSResult result;
  final VoidCallback onNextRound;

  const _ResultView({
    required this.player1Choice,
    required this.player2Choice,
    required this.result,
    required this.onNextRound,
  });

  String get _resultText {
    switch (result) {
      case RPSResult.win:
        return 'Player 1 Wins! 🎉';
      case RPSResult.lose:
        return 'Player 2 Wins! 🎉';
      case RPSResult.draw:
        return 'It\'s a Draw! 🤝';
    }
  }

  Color get _resultColor {
    switch (result) {
      case RPSResult.win:
        return const Color(0xFF6C63FF);
      case RPSResult.lose:
        return const Color(0xFFFF6B6B);
      case RPSResult.draw:
        return const Color(0xFFFFE66D);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Choices display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ChoiceReveal(
              label: 'Player 1',
              choice: player1Choice,
              color: const Color(0xFF6C63FF),
              isWinner: result == RPSResult.win,
            ),
            const Text(
              'VS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white54,
              ),
            ),
            _ChoiceReveal(
              label: 'Player 2',
              choice: player2Choice,
              color: const Color(0xFFFF6B6B),
              isWinner: result == RPSResult.lose,
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Result text
        Text(
          _resultText,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _resultColor,
          ),
        ),

        const SizedBox(height: 8),
        Text(
          RPSGameLogic.getResultDescription(
            player1Choice,
            player2Choice,
            result,
          ),
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),

        const SizedBox(height: 32),

        // Next round button
        ElevatedButton.icon(
          onPressed: onNextRound,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Next Round'),
        ),
      ],
    );
  }
}

class _ChoiceReveal extends StatelessWidget {
  final String label;
  final RPSChoice choice;
  final Color color;
  final bool isWinner;

  const _ChoiceReveal({
    required this.label,
    required this.choice,
    required this.color,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: color.withValues(alpha: 0.8)),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isWinner
                ? color.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isWinner ? color : Colors.white.withValues(alpha: 0.2),
              width: isWinner ? 3 : 2,
            ),
            boxShadow: isWinner
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(choice.emoji, style: const TextStyle(fontSize: 40)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          choice.displayName,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
