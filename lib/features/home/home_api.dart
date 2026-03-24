import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:sm_project/controller/apiservices/api_constant.dart';
import 'package:sm_project/controller/apiservices/dio_client.dart';
import 'package:sm_project/utils/filecollection.dart';

class HomeApi {
  static Future<(List<String>, double)> getHomeBanner() async {
    try {
      final response = await dio.get('${APIConstants.baseUrl}app/slider/get',
          options: Options(headers: {
            "Accept": "application/json",
            "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
          }, followRedirects: false, maxRedirects: 0));
      if (response.statusCode == 200) {
        if (response.data['status'] == 'success' &&
            response.data['data'] is List) {
          final data = List<String>.from(
              response.data['data'].map((e) => e['link'].toString().trim()));

          if (data.isNotEmpty) {
            final size = await calculateImageDimension(data.first);
            return (data, size.aspectRatio);
          }
        }
      }
    } catch (e) {
      log(e.toString(), name: 'getHomeBanner');
    }
    return ([] as List<String>, 1.0);
  }

  static Future<bool> uploadTransactionDetails({
    required String fileName,
    required String filePath,
    required String amount,
    required String userId,
  }) async {
    try {
      final headers = {
        'Authorization': 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
      };
      final data = FormData.fromMap({
        'user_id': userId,
        'image': [await MultipartFile.fromFile(filePath, filename: fileName)],
        'transfer_type': 'deposit',
        'type': "mobile",
        'amount': amount,
        'note': 'deposit request'
      });
      final response = await dio.request(
        '${APIConstants.baseUrl}app/transaction/create',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is! Map) {
          return false;
        }
        if ((response.data as Map).containsKey("status")) {
          if (((response.data as Map)['status'].toString()) == "success") {
            return true;
          }
          toast(response.data['message']?.toString() ?? "");
          return false;
        }
        return true;
      }
    } on DioException catch (e) {
      toast(e.response?.data['message'].toString() ?? "");
      log(e.response?.data['message'], name: 'postSendSMS');
    }
    return false;
  }
}

Future<Size> calculateImageDimension(String url) {
  Completer<Size> completer = Completer();
  Image image = Image.network(
    url,
    errorBuilder: (context, error, stackTrace) {
      return const SizedBox();
    },
  );
  image.image.resolve(const ImageConfiguration()).addListener(
    ImageStreamListener(
      (ImageInfo image, bool synchronousCall) {
        var myImage = image.image;
        Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
        completer.complete(size);
      },
    ),
  );
  return completer.future;
}
