import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_provider.dart';
import '../domain/models/rounds.dart';
import '../service/recent_rounds_service.dart';

final recentRoundsServiceProvider = Provider<RecentRoundsService>((ref) {
  return RecentRoundsService(ref.read(dioProvider));
});

/// FutureProvider for fetching recent rounds
final recentRoundsProvider =
    FutureProvider.autoDispose<List<Rounds>>((ref) async {
  final service = ref.read(recentRoundsServiceProvider);
  return service.getRecentRounds();
});
