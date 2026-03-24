import 'package:dio/dio.dart';
import 'package:sm_project/controller/local/pref.dart';
import 'package:sm_project/controller/local/pref_names.dart';
import 'package:sm_project/controller/local/user_details.dart';

import '../domain/models/my_bets_model.dart';

class BetHistoryService {
  final Dio _dio;

  BetHistoryService(this._dio);

  Future<MyBetsModel> getBetHistory() async {
    try {
      // Use main app's user data and token
      final userData = UserData.geUserData();
      final userId = userData?.data?.id ?? '';
      final token = Prefs.getString(PrefNames.accessToken);

      final response = await _dio.get(
        'app/aviator/bets/history/user/$userId?limit=50&page=1',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return MyBetsModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
