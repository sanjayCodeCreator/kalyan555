import 'dart:async';
import 'dart:developer';

import 'package:sm_project/controller/apiservices/api_constant.dart';
import 'package:sm_project/controller/local/pref.dart';
import 'package:sm_project/controller/local/pref_names.dart';
import 'package:socket_io_client_new/socket_io_client_new.dart' as io;


import '../domain/constants/aviator_socket_constants.dart';
import '../domain/models/all_bets_model.dart';
import '../domain/models/aviator_round.dart';

class AviatorSocketService {
  // Extract base domain from APIConstants.baseUrl (remove /api/v1/)
  static String get _baseUrl {
    const baseUrl = APIConstants.baseUrl;
    // Remove trailing /api/v1/ to get just the domain
    if (baseUrl.endsWith('/api/v1/')) {
      return baseUrl.substring(0, baseUrl.length - 8);
    }
    return baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
  }

  static const String _socketNamespace = '/api/v1/aviator';

  final _stateController = StreamController<RoundState>.broadcast();
  final _tickController = StreamController<Tick>.broadcast();
  final _crashController = StreamController<Crash>.broadcast();
  final _betsController = StreamController<AllBetsModel>.broadcast();
  final _disconnectController = StreamController<void>.broadcast();

  Stream<RoundState> get stateStream => _stateController.stream;
  Stream<Tick> get tickStream => _tickController.stream;
  Stream<Crash> get crashStream => _crashController.stream;
  Stream<AllBetsModel> get betsStream => _betsController.stream;
  Stream<void> get disconnectStream => _disconnectController.stream;
  io.Socket? socket;

  void connect() async {
    if (socket != null && socket!.connected) {
      log('⚠️ Socket already connected, skipping');
      return;
    }

    // Use main app's token from Prefs
    final token = Prefs.getString(PrefNames.accessToken);
    final socketUrl = '$_baseUrl$_socketNamespace';

    log('👉 Aviator Socket - Token: ${token?.substring(0, 20) ?? "null"}...');
    log('👉 Aviator Socket - Base URL: $_baseUrl');
    log('👉 Aviator Socket - Namespace: $_socketNamespace');
    log('👉 Aviator Socket - Full URL: $socketUrl');

    try {
      socket = io.io(
        socketUrl,
        io.OptionBuilder()
            .setPath('/api/v1/socket.io')
            .setTransports(['polling', 'websocket'])
            .enableAutoConnect()
            .enableForceNew()
            .setAuth({'token': token})
            .build(),
      );
      // socket = io.io(
      //   socketUrl,
      //   io.OptionBuilder()
      //       .setTransports(['websocket'])
      //       .enableAutoConnect()
      //       .enableForceNew()
      //       .setAuth({'token': token})
      //       .build(),
      // );

      log('🔄 Socket created, attempting to connect...');

      socket!.onConnect((_) {
        log('✅ Aviator Socket connected! Socket ID: ${socket?.id}');
      });

      socket!.onConnectError((data) {
        log('❌ Aviator Socket connect error: $data');
      });

      socket!.onError((data) {
        log('❌ Aviator Socket error: $data');
      });

      socket!.onDisconnect((reason) {
        log('⚠️ Aviator Socket disconnected. Reason: $reason');
        _disconnectController.add(null);
      });

      //! state
      socket!.on(AviatorSocketConstants.roundState, (data) {
        log('📡 Round State received: $data');
        try {
          final state = RoundState.fromJson(data);
          _stateController.add(state);
          log('✅ Round State parsed: roundId=${state.roundId}, state=${state.state}');
        } catch (e) {
          log('❌ Round State parse error: $e');
        }
      });

      //! Tick
      socket!.on(AviatorSocketConstants.roundTick, (data) {
        // Only log occasional ticks to avoid spam
        try {
          final tick = Tick.fromJson(data);
          _tickController.add(tick);
          // Log every 10th tick approximately (when multiplier ends in .0x)
          if (tick.multiplier != null && tick.multiplier!.endsWith('0')) {
            log('📈 Tick: ${tick.multiplier}x');
          }
        } catch (e) {
          log('❌ Tick parse error: $e');
        }
      });

      //! Crash
      socket!.on(AviatorSocketConstants.roundCrashAt, (data) {
        log('📡 Round Crash received: $data');
        try {
          final crash = Crash.fromJson(data);
          _crashController.add(crash);
        } catch (e) {
          log('❌ Crash parse error: $e');
        }
      });

      //! Bets data
      socket!.on(AviatorSocketConstants.roundBetsData, (data) {
        log('📡 Bets data received');
        try {
          final bets = AllBetsModel.fromJson(data);
          _betsController.add(bets);
        } catch (e) {
          log('❌ Bets parse error: $e');
        }
      });

      // Manually connect
      socket!.connect();
      log('🔄 Socket.connect() called');
    } catch (e) {
      log('❌ Socket initialization error: $e');
    }
  }

  void disconnect() {
    socket?.disconnect();
    socket?.destroy();
    socket = null;
    _stateController.close();
    _tickController.close();
    _crashController.close();
    _betsController.close();
    _disconnectController.close();
    log('🔌 Aviator Socket disconnected and cleaned up');
  }
}
