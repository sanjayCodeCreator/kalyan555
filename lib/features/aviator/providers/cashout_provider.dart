import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/dio_provider.dart';
import '../service/cashout_service.dart';

final cashoutServiceProvider = Provider<CashoutService>((ref) {
  return CashoutService(ref.read(dioProvider));
});
