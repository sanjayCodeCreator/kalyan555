import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_provider.dart';
import '../domain/models/my_bets_model.dart';
import '../service/bet_history_service.dart';

final myBetsProvider = FutureProvider.autoDispose<MyBetsModel>((ref) async {
  final service = ref.read(betHistoryServiceProvider);
  return service.getBetHistory();
});

final betHistoryServiceProvider = Provider<BetHistoryService>((ref) {
  return BetHistoryService(ref.read(dioProvider));
});

final myBetsNotifierProvider =
    StateNotifierProvider.autoDispose<MyBetsNotifier, AsyncValue<MyBetsModel>>((
  ref,
) {
  final service = ref.watch(betHistoryServiceProvider);
  return MyBetsNotifier(service);
});

class MyBetsNotifier extends StateNotifier<AsyncValue<MyBetsModel>> {
  final BetHistoryService _service;
  MyBetsNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadBets();
  }

  Future<void> _loadBets() async {
    try {
      final bets = await _service.getBetHistory();
      state = AsyncValue.data(bets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadBets();
  }

  Future<void> fetchBetHistory() async {
    await _loadBets();
  }
}

/// Alias for myBetsNotifierProvider for backward compatibility
final betHistoryProvider = myBetsNotifierProvider;
