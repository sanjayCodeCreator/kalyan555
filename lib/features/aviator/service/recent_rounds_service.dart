import 'package:dio/dio.dart';

import '../domain/models/rounds.dart';

class RecentRoundsService {
  final Dio _dio;
  final List<Rounds> _rounds = [];

  RecentRoundsService(this._dio);

  List<Rounds> get rounds => _rounds;

  Future<List<Rounds>> getRecentRounds() async {
    try {
      final response = await _dio.get('app/aviator/rounds/recent');

      if (response.data is List) {
        _rounds.clear();
        for (var item in response.data) {
          _rounds.add(Rounds.fromJson(item));
        }
      }

      return _rounds;
    } catch (e) {
      rethrow;
    }
  }

  void startListening() {
    // Fetch initial rounds
    getRecentRounds();
  }

  void addRound(Rounds round) {
    _rounds.insert(0, round);
    if (_rounds.length > 20) {
      _rounds.removeLast();
    }
  }
}
