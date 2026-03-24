import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:sm_project/controller/apiservices/api_constant.dart';
import 'package:sm_project/controller/apiservices/dio_client.dart';
import 'package:sm_project/controller/local/pref.dart';
import 'package:sm_project/controller/local/pref_names.dart';
import 'package:sm_project/controller/model/single_digit_model.dart';
import 'package:sm_project/features/gali_desawar/model/select_game_model_list.dart';
import 'package:sm_project/features/gali_desawar/notifier/model/get_all_result_model.dart';
import 'package:sm_project/features/reusubility_widget/toast.dart';

class GaliDesawarApis {
  static Future<SelectGameMarketList?> getGaliDishawarAllMarket(
      String? query) async {
    try {
      final response = await dio.get(
        '${APIConstants.baseUrl}app/market/all$query',
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
        }, followRedirects: false, maxRedirects: 0),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final getAllMarketModel = SelectGameMarketList.fromJson(response.data);

        log(json.encode(response.data), name: 'GetAllMarketModel api');

        return getAllMarketModel;
      } else {
        toast("Something went wrong");
        //  return GetAllMarketModel(status: "false", message: "Something went wrong");
      }
    } on DioException catch (e) {
      toast(e.response?.data['message'].toString() ?? "");
      log(e.response?.data['message'], name: '');
    }
    return null;
    // return GetAllMarketModel(status: "false", message: "Something went wrong");
  }

  static Future<PlayGameAllMarketModel?> postDishawarPlayGameMarket(
      List<Map<String, dynamic>> body) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${Prefs.getString(PrefNames.accessToken)}'
      };
      var data = json.encode(body);
      var dio = Dio();
      var response = await dio.request(
        '${APIConstants.baseUrl}app/bet/create',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final playGameAllMarketModel =
            PlayGameAllMarketModel.fromJson(response.data);

        log(json.encode(response.data), name: 'singleDigitModel api');

        return playGameAllMarketModel;
      } else {
        return PlayGameAllMarketModel(
            status: "false", message: "Something went wrong");
      }
    } on DioException catch (e) {
      toast(e.response?.data['message'].toString() ?? "");
      log(e.response?.data['message'], name: '');
    }
    return PlayGameAllMarketModel(
        status: "false", message: "Something went wrong");
  }

  static Future<GetAllResultModel?> getDishawarResult(String query) async {
    try {
      final response =
          await dio.get('${APIConstants.baseUrl}app/market/result/get$query',
              options: Options(headers: {
                "Accept": "application/json",
                "authorization":
                    'Bearer ${Prefs.getString(PrefNames.accessToken)}',
              }, followRedirects: false, maxRedirects: 0));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final transactionHistoryModel =
            GetAllResultModel.fromJson(response.data);

        log(json.encode(response.data), name: 'getBidsHistory api');

        return transactionHistoryModel;
      } else {
        return GetAllResultModel(status: "false");
      }
    } on DioException catch (e) {
      toast(e.response?.data['message'].toString() ?? "");
      log(e.response?.data['message'], name: '');
    }
    return GetAllResultModel(status: "false");
  }
}
