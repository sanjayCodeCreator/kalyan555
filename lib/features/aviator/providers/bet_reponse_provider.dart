import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/bet_response.dart';

/// Provider that stores bet responses indexed by bet slot (1 or 2)
final betResponseProvider =
    StateNotifierProvider<BetResponseNotifier, Map<int, BetResponse?>>((ref) {
  return BetResponseNotifier();
});

class BetResponseNotifier extends StateNotifier<Map<int, BetResponse?>> {
  BetResponseNotifier() : super({1: null, 2: null});

  void setBetResponse(int betIndex, BetResponse? response) {
    state = {...state, betIndex: response};
  }

  void clear(int betIndex) {
    state = {...state, betIndex: null};
  }

  void clearAll() {
    state = {1: null, 2: null};
  }
}

/// Provider for tracking bet placement state (placed or not)
final betStateProvider =
    StateNotifierProvider<BetStateNotifier, Map<int, bool>>((ref) {
  return BetStateNotifier();
});

class BetStateNotifier extends StateNotifier<Map<int, bool>> {
  BetStateNotifier() : super({1: false, 2: false});

  void placeBet(int betIndex) {
    state = {...state, betIndex: true};
  }

  void clearBet(int betIndex) {
    state = {...state, betIndex: false};
  }

  void clearAll() {
    state = {1: false, 2: false};
  }
}

/// Provider for wallet balance - local to aviator feature
final walletBalanceProvider =
    StateNotifierProvider<WalletBalanceNotifier, double>((ref) {
  return WalletBalanceNotifier();
});

class WalletBalanceNotifier extends StateNotifier<double> {
  WalletBalanceNotifier() : super(0.0);

  void updateBalance(double balance) {
    state = balance;
  }

  void addBalance(double amount) {
    state = state + amount;
  }

  void deductBalance(double amount) {
    state = state - amount;
  }
}
