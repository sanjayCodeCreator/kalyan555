import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/sound_manager.dart';
import '../domain/models/all_bets_model.dart';
import '../domain/models/aviator_round.dart';
import '../service/aviator_socket_service.dart';

final aviatorRoundProvider = Provider.autoDispose<AviatorSocketService>((ref) {
  final service = AviatorSocketService();
  service.connect();
  ref.onDispose(() {
    // Stop background music when exiting
    SoundManager.stopAviatorMusic();
    // Disconnect socket
    service.disconnect();
  });
  return service;
});
// //! Round State Provider
final aviatorStateProvider = StreamProvider.autoDispose<RoundState>((ref) {
  final service = ref.watch(aviatorRoundProvider);
  return service.stateStream;
});

//! Round Tick Provider
final aviatorTickProvider = StreamProvider.autoDispose<Tick>((ref) {
  final service = ref.watch(aviatorRoundProvider);
  return service.tickStream;
});

//! Disconnect Provider
final aviatorDisconnectProvider = StreamProvider.autoDispose<void>((ref) {
  final service = ref.watch(aviatorRoundProvider);
  return service.disconnectStream;
});
//! Crash provider

// final aviatorCrashProvider = StreamProvider<Crash>((ref) {
//   final service = ref.watch(aviatorRoundProvider);
//   return service.crashStream;
// });

//! --- State Notifier ---

class AviatorRoundNotifier extends StateNotifier<RoundState?> {
  final AviatorSocketService _service;
  late final StreamSubscription _sub;
  bool _isDisposed = false;

  AviatorRoundNotifier(this._service) : super(null) {
    // Listen to the socket stream and update state
    _sub = _service.stateStream.listen((round) {
      if (!_isDisposed) {
        state = round;
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _sub.cancel();
    super.dispose();
  }
}

final aviatorRoundNotifierProvider =
    StateNotifierProvider.autoDispose<AviatorRoundNotifier, RoundState?>((ref) {
  final service = ref.watch(aviatorRoundProvider);
  return AviatorRoundNotifier(service);
});

//! --- Crash Notifier ---
class AviatorCrashNotifier extends StateNotifier<Crash?> {
  final AviatorSocketService _service;
  late final StreamSubscription _sub;
  bool _isDisposed = false;

  AviatorCrashNotifier(this._service) : super(null) {
    _sub = _service.crashStream.listen((crash) {
      if (!_isDisposed) {
        state = crash;
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _sub.cancel();
    super.dispose();
  }
}

final aviatorCrashNotifierProvider =
    StateNotifierProvider.autoDispose<AviatorCrashNotifier, Crash?>((ref) {
  final service = ref.watch(aviatorRoundProvider);
  return AviatorCrashNotifier(service);
});

//! Bets Notifier
class AviatorBetsNotifier extends StateNotifier<AllBetsModel?> {
  final AviatorSocketService _service;
  late final StreamSubscription _sub;
  bool _isDisposed = false;

  AviatorBetsNotifier(this._service) : super(null) {
    _sub = _service.betsStream.listen((bets) {
      if (!_isDisposed) {
        state = bets;
      }
    });
  }
  @override
  void dispose() {
    _isDisposed = true;
    _sub.cancel();
    super.dispose();
  }
}

final aviatorBetsNotifierProvider =
    StateNotifierProvider.autoDispose<AviatorBetsNotifier, AllBetsModel?>((
  ref,
) {
  final service = ref.watch(aviatorRoundProvider);
  return AviatorBetsNotifier(service);
});

//! Flushbar List Provider for managing active Flushbars
class AviatorFlushbarListNotifier extends StateNotifier<List<Flushbar>> {
  AviatorFlushbarListNotifier() : super([]);

  void add(Flushbar flushbar) {
    state = [...state, flushbar];
  }

  void dismissAll() {
    for (var flushbar in state) {
      flushbar.dismiss();
    }
    state = [];
  }
}

final aviatorFlushbarListProvider =
    StateNotifierProvider<AviatorFlushbarListNotifier, List<Flushbar>>(
  (ref) => AviatorFlushbarListNotifier(),
);
