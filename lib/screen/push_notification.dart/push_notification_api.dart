import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:sm_project/controller/apiservices/api_constant.dart';
import 'package:sm_project/controller/apiservices/dio_client.dart';
import 'package:sm_project/controller/local/pref.dart';
import 'package:sm_project/controller/local/pref_names.dart';

import 'dart:developer';
import 'package:dio/dio.dart';

class PushNotificationApi {
  static Future<void> updateFCMToken(String fcmToken) async {
    try {
      log("${Prefs.getString(PrefNames.userData)}",name:  "preffs");
      final Map<String, dynamic> data = {
        "fcm": fcmToken,
      };
      print("updateFCMToken---> $fcmToken");

      final response = await dio.put(
        '${APIConstants.baseUrl}app/users/update', // updated path
        options: Options(
          headers: {
            "Accept": "application/json",
            "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
          },
          followRedirects: false,
          maxRedirects: 0,
          validateStatus: (status) => true,
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        log("FCM token updated successfully: ${response.data}", name: 'updateFCMToken');
      } else {
        // Log detailed error information
        log(
          "Failed to update FCM token. Status: ${response.statusCode}, "
              "Response: ${response.data}",
          name: 'updateFCMToken',
        );
      }
    } on DioException catch (dioError) {
      // Log Dio-specific errors with request info
      log(
        "DioException caught while updating FCM token: ${dioError.message}\n"
            "Request path: ${dioError.requestOptions.path}\n"
            "Status code: ${dioError.response?.statusCode}\n"
            "Response data: ${dioError.response?.data}",
        name: 'updateFCMToken',
      );
    } catch (e, stackTrace) {
      // Log any other unexpected errors
      log("Unexpected error: $e", name: 'updateFCMToken', stackTrace: stackTrace);
    }
  }
}