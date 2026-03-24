import 'package:dio/dio.dart';

import '../domain/models/top_bets_model.dart';

class TopBetsService {
  final Dio _dio;

  TopBetsService(this._dio);

  Future<TopBetsModel> getTopBets() async {
    try {
      final response = await _dio.get('app/aviator/bets/top');

      return TopBetsModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
