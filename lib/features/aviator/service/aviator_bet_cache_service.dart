import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/bet_response.dart';

class AviatorBetCacheService {
  static const String _bet1Key = 'aviator_bet_1';
  static const String _bet2Key = 'aviator_bet_2';
  static const String _roundIdKey = 'aviator_round_id';
  static const String _autoPlayKey = 'aviator_autoplay_';

  Future<void> saveBet(int betIndex, BetResponse bet) async {
    final prefs = await SharedPreferences.getInstance();
    final key = betIndex == 1 ? _bet1Key : _bet2Key;
    await prefs.setString(key, jsonEncode(bet.toJson()));
    await prefs.setString(_roundIdKey, bet.roundId);
  }

  Future<BetResponse?> getBet(int betIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final key = betIndex == 1 ? _bet1Key : _bet2Key;
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    return BetResponse.fromJson(jsonDecode(jsonString));
  }

  Future<void> clearBet(int betIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final key = betIndex == 1 ? _bet1Key : _bet2Key;
    await prefs.remove(key);
  }

  Future<void> clearAllBets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bet1Key);
    await prefs.remove(_bet2Key);
    await prefs.remove(_roundIdKey);
  }

  Future<String?> getCachedRoundId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roundIdKey);
  }

  Future<void> saveAutoPlayState(
      int betIndex, Map<String, dynamic> state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_autoPlayKey$betIndex', jsonEncode(state));
  }

  Future<Map<String, dynamic>?> getAutoPlayState(int betIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$_autoPlayKey$betIndex');
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  Future<void> clearAutoPlayState(int betIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_autoPlayKey$betIndex');
  }
}
