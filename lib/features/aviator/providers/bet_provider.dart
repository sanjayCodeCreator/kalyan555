import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_provider.dart';
import '../service/bet_api_service.dart';

final betApiServiceProvider = Provider<BetApiService>((ref) {
  return BetApiService(ref.read(dioProvider));
});

/// Alias for betApiServiceProvider for backward compatibility
final betServiceProvider = betApiServiceProvider;
