import 'package:dio/dio.dart';
import 'package:sm_project/controller/local/pref.dart';
import 'package:sm_project/controller/local/pref_names.dart';

import '../domain/constants/aviator_api_constants.dart';
import '../domain/models/bet_request.dart';
import '../domain/models/bet_response.dart';

class BetApiService {
  final Dio _dio;

  BetApiService(this._dio);

  Future<BetResponse> placeBet(BetRequest request) async {
    try {
      // Use main app's token from Prefs
      final token = Prefs.getString(PrefNames.accessToken);

      final response = await _dio.post(
        AviatorApiConstants.bet,
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return BetResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
