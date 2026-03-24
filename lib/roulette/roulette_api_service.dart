import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:sm_project/controller/apiservices/api_constant.dart';
import 'package:sm_project/controller/apiservices/dio_client.dart';
import 'package:sm_project/controller/local/pref.dart';
import 'package:sm_project/controller/local/pref_names.dart';
import 'package:sm_project/features/reusubility_widget/toast.dart';
import 'package:sm_project/roulette/roulette_bid_model.dart';
import 'package:sm_project/roulette/roulette_market_model.dart';
import 'package:sm_project/roulette/roulette_result_model.dart';

class RouletteApiService {
  // Get markets for roulette app
  Future<RouletteModel?> getMarket() async {
    try {
      // Map<String, dynamic> queryParams = {};
      // queryParams['status'] = true.toString();
      final response = await dio.get(
        '${APIConstants.baseUrl}app/market/roulette/get',
        // queryParameters: queryParams,
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
        }, followRedirects: false, maxRedirects: 0),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log(json.encode(response.data), name: 'get markets api');
        if (response.data['data'] is List &&
            (response.data['data'] as List).isNotEmpty) {
          return RouletteModel.fromJson((response.data)['data'][0]);
        } else {
          return null;
        }
      }
    } on DioException catch (e) {
      toast(e.response?.data['message'].toString() ?? "");
      log(e.response?.data['message'], name: 'postSendSMS');
    }
    return null;
  }

  // Create bets for roulette
  Future<Map<String, dynamic>?> createBets(
      {required List<Map<String, dynamic>> bets}) async {
    try {
      final response = await dio.post(
        '${APIConstants.baseUrl}app/bet/roulette/create',
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
        }, followRedirects: false, maxRedirects: 0),
        data: bets,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log(json.encode(response.data), name: 'create bets api');
        return response.data;
      } else {
        return {'status': 'failure', 'message': 'Something went wrong'};
      }
    } on DioException catch (e) {
      toast(e.response?.data['message'].toString() ?? "");
      log(e.response?.data['message'], name: 'create bets api');
    }
    return {'status': 'failure', 'message': 'Something went wrong'};
  }

  // Get bets for roulette
  Future<List<RouletteBidModel>> getBets({
    required String userId,
    String? win,
    String? from, // 2025-05-30T23:59:59.999Z
    String? to, // 2025-05-30T23:59:59.999Z
  }) async {
    try {
      Map<String, dynamic> queryParams = {'user_id': userId};
      if (win != null) {
        queryParams['win'] = win.toString();
      }
      if (from != null) {
        queryParams['from'] = from;
      }
      if (to != null) {
        queryParams['to'] = to;
      }

      final response = await dio.get(
        '${APIConstants.baseUrl}app/bet/roulette/get',
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
        }, followRedirects: false, maxRedirects: 0),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log(json.encode(response.data), name: 'get bets api');
        final List<dynamic> data = response.data['data']['bet_list'] ?? [];
        return data.map((e) => RouletteBidModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } on DioException catch (e) {
      toast(e.response?.data['message'].toString() ?? "");
      log(e.response?.data['message'], name: 'postSendSMS');
    }
    return [];
  }

  // Get results for roulette
  Future<RouletteResultModel?> getResults({
    required String market,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};

      // No date filter is needed for single latest result fetch

      // These were previously used for filtering by range; kept for reference but not used now

      queryParams['market_id'] = market;

      final response = await dio.get(
        '${APIConstants.baseUrl}app/market/roulette/result/get',
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
        }, followRedirects: false, maxRedirects: 0),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log(json.encode(response.data), name: 'get results api');
        if (response.data.containsKey('data') &&
            (response.data['data'] as List).isNotEmpty) {
          return RouletteResultModel.fromJson(response.data['data'][0]);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } on DioException catch (e) {
      toast(e.response?.data['message'].toString() ?? "");
      log(e.response?.data['message'], name: 'postSendSMS');
    }
    return null;
  }

  // Get results for roulette using a single query date (yyyy-MM-dd)
  Future<List<RouletteResultModel>> getResultsByDate({
    String? queryDate, // e.g., 2025-06-09
  }) async {
    try {
      // Default to today's date (yyyy-MM-dd) if not provided
      final now = DateTime.now();
      final String defaultDate =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final Map<String, dynamic> queryParams = {
        'query_date': queryDate ?? defaultDate,
      };

      final response = await dio.get(
        '${APIConstants.baseUrl}app/market/roulette/result/get',
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
        }, followRedirects: false, maxRedirects: 0),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log(json.encode(response.data), name: 'get results api');
        if (response.data.containsKey('data') &&
            (response.data['data'] as List).isNotEmpty) {
          final List<dynamic> dataList = response.data['data'] as List<dynamic>;
          return dataList
              .map<RouletteResultModel>((e) => RouletteResultModel.fromJson(e))
              .toList();
        } else {
          return [];
        }
      } else {
        return [];
      }
    } on DioException catch (e) {
      toast(e.response?.data['message'].toString() ?? "");
      log(e.response?.data['message'], name: 'postSendSMS');
    }
    return [];
  }
}
