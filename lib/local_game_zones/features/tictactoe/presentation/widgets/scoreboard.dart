import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Score data class
class ScoreData {
  final int xWins;
  final int oWins;
  final int draws;

  const ScoreData({this.xWins = 0, this.oWins = 0, this.draws = 0});

  ScoreData copyWith({int? xWins, int? oWins, int? draws}) {
    return ScoreData(
      xWins: xWins ?? this.xWins,
      oWins: oWins ?? this.oWins,
      draws: draws ?? this.draws,
    );
  }
}

/// Score notifier for managing persistent scores
class ScoreNotifier extends StateNotifier<ScoreData> {
  ScoreNotifier() : super(const ScoreData()) {
    _loadScores();
  }

  static const _xWinsKey = 'x_wins';
  static const _oWinsKey = 'o_wins';
  static const _drawsKey = 'draws';

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    state = ScoreData(
      xWins: prefs.getInt(_xWinsKey) ?? 0,
      oWins: prefs.getInt(_oWinsKey) ?? 0,
      draws: prefs.getInt(_drawsKey) ?? 0,
    );
  }

  Future<void> _saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_xWinsKey, state.xWins);
    await prefs.setInt(_oWinsKey, state.oWins);
    await prefs.setInt(_drawsKey, state.draws);
  }

  void addXWin() {
    state = state.copyWith(xWins: state.xWins + 1);
    _saveScores();
  }

  void addOWin() {
    state = state.copyWith(oWins: state.oWins + 1);
    _saveScores();
  }

  void addDraw() {
    state = state.copyWith(draws: state.draws + 1);
    _saveScores();
  }

  Future<void> resetScores() async {
    state = const ScoreData();
    await _saveScores();
  }
}

/// Provider for score notifier
final scoreProvider = StateNotifierProvider<ScoreNotifier, ScoreData>((ref) {
  return ScoreNotifier();
});

/// Scoreboard widget displaying X wins, O wins, and draws
class Scoreboard extends ConsumerWidget {
  const Scoreboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scores = ref.watch(scoreProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ScoreItem(
            label: 'X',
            score: scores.xWins,
            color: const Color(0xFFFF6B6B),
          ),
          Container(
            width: 1,
            height: 40,
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
          _ScoreItem(
            label: 'Draw',
            score: scores.draws,
            color: colorScheme.secondary,
          ),
          Container(
            width: 1,
            height: 40,
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
          _ScoreItem(
            label: 'O',
            score: scores.oWins,
            color: const Color(0xFF4ECDC4),
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

  const _ScoreItem({
    required this.label,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            '$score',
            key: ValueKey(score),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
