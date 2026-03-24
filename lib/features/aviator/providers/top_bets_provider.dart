import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_provider.dart';
import '../domain/models/top_bets_model.dart';
import '../service/top_bets_service.dart';

final topBetsProvider = FutureProvider.autoDispose<TopBetsModel>((ref) async {
  final service = ref.read(topBetsServiceProvider);
  return service.getTopBets();
});

final topBetsServiceProvider = Provider<TopBetsService>((ref) {
  return TopBetsService(ref.read(dioProvider));
});

final topBetsNotifierProvider = StateNotifierProvider.autoDispose<
    TopBetsNotifier, AsyncValue<TopBetsModel>>((
  ref,
) {
  final service = ref.watch(topBetsServiceProvider);
  return TopBetsNotifier(service);
});

class TopBetsNotifier extends StateNotifier<AsyncValue<TopBetsModel>> {
  final TopBetsService _service;
  TopBetsNotifier(this._service) : super(const AsyncValue.loading()) {
    _loadTopBets();
  }

  Future<void> _loadTopBets() async {
    try {
      final bets = await _service.getTopBets();
      state = AsyncValue.data(bets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadTopBets();
  }
}
