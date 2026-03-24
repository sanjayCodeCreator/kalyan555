import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:sm_project/controller/local/pref.dart';
import 'package:sm_project/controller/local/pref_names.dart';

import '../domain/models/cashout_response.dart';

class CashoutService {
  final Dio _dio;

  CashoutService(this._dio);

  Future<CashoutResponse> cashout(String betId, String roundId,
      {double? multiplier}) async {
    try {
      // Use main app's token from Prefs
      final token = Prefs.getString(PrefNames.accessToken);

      log('📤 Cashout request: betId=$betId, roundId=$roundId, multiplier=$multiplier');

      final response = await _dio.post(
        'app/aviator/bets/$betId/cashout',
        data: {
          'roundId': roundId,
          if (multiplier != null) 'multiplier': multiplier,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      log('📥 Cashout response: ${response.statusCode}');
      log('📥 Cashout data: ${response.data}');

      return CashoutResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Log the full error details
      log('❌ Cashout DioException:');
      log('   Status: ${e.response?.statusCode}');
      log('   Message: ${e.response?.data}');
      log('   Error: ${e.message}');
      rethrow;
    } catch (e) {
      log('❌ Cashout error: $e');
      rethrow;
    }
  }
}
