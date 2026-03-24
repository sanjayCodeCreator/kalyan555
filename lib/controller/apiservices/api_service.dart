import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:sm_project/controller/apiservices/api_constant.dart';
import 'package:sm_project/controller/apiservices/dio_client.dart';
import 'package:sm_project/controller/apiservices/notice_model.dart';
import 'package:sm_project/controller/model/allow_notification_model.dart';
import 'package:sm_project/controller/model/contact_us_model.dart';
import 'package:sm_project/controller/model/create_transaction_model.dart';
import 'package:sm_project/controller/model/demo_rank/today_winners_model.dart';
import 'package:sm_project/controller/model/get_all_market_model.dart';
import 'package:sm_project/controller/model/get_bids_history_model.dart';
import 'package:sm_project/controller/model/get_particular_player_model.dart';
import 'package:sm_project/controller/model/get_setting_model.dart';
import 'package:sm_project/controller/model/login_model.dart';
import 'package:sm_project/controller/model/main_market_result_model.dart';
import 'package:sm_project/controller/model/mpin_login_model.dart';
import 'package:sm_project/controller/model/profile_update_model.dart';
// import 'package:sm_project/controller/model/referral_record_model.dart';
import 'package:sm_project/controller/model/register_model.dart';
import 'package:sm_project/controller/model/sendsms_model.dart';
import 'package:sm_project/controller/model/single_digit_model.dart';
import 'package:sm_project/controller/model/transaction_history_model.dart';
import 'package:sm_project/payment/smepay/model/sme_pay_start_response.dart';
import 'package:sm_project/utils/filecollection.dart';

class ApiService {
  // Handle token expiration by clearing user data and navigating to login
  // Handle token expiration by clearing user data and navigating to login
  void _handleTokenExpiration() async {
    EasyLoading.dismiss();
    // Navigate to login screen using global navigator key

    LoginModel? loginModel = await ApiService().postLoginUser({
      'mobile': Prefs.getString(PrefNames.mobileNumber) ?? '',
      'password': Prefs.getString(PrefNames.password) ?? '',
    });

    await Prefs.setString(
        PrefNames.accessToken, loginModel?.tokenData?.token ?? '');

    toast('Token Refreshed');
  }

  // Register user
  Future<RegisterModel?> postRegisterUser(Map<String, String> body) async {
    try {
      log("🚀 REGISTER API STARTED", name: "REGISTER_FLOW");

      final url = '${APIConstants.baseUrl}auth/signup';
      log("🌍 URL: $url", name: "REGISTER_FLOW");
      log("📦 BODY: $body", name: "REGISTER_FLOW");

      final response = await dio.post(
        url,
        data: body,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      log("✅ RESPONSE RECEIVED", name: "REGISTER_FLOW");
      log("📊 STATUS CODE: ${response.statusCode}", name: "REGISTER_FLOW");
      log("📩 RESPONSE DATA: ${response.data}", name: "REGISTER_FLOW");

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("🧩 PARSING RESPONSE", name: "REGISTER_FLOW");

        final registerData = RegisterModel.fromJson(response.data);

        log("🎯 PARSED MODEL: $registerData", name: "REGISTER_FLOW");
        return registerData;
      } else {
        log("⚠️ UNEXPECTED STATUS", name: "REGISTER_FLOW");
        return RegisterModel(message: "Something went wrong");
      }
    } on DioException catch (e) {
      log("❌ DIO ERROR OCCURRED", name: "REGISTER_FLOW");
      log("🧨 ERROR MESSAGE: ${e.message}", name: "REGISTER_FLOW");
      log("📡 ERROR TYPE: ${e.type}", name: "REGISTER_FLOW");
      log("📩 ERROR RESPONSE: ${e.response?.data}", name: "REGISTER_FLOW");
      log("📊 ERROR STATUS: ${e.response?.statusCode} Message-->${e.response?.data?['message']}", name: "REGISTER_FLOW");

      toast(e.response?.data?['message']?? "Network Error");
    } catch (e) {
      log("🔥 UNKNOWN ERROR: $e", name: "REGISTER_FLOW");
    }

    log("⛔ REGISTER API RETURNING NULL", name: "REGISTER_FLOW");
    return null;
  }

  // Send SMS
  Future<bool> postSendSMS(String? mobileNumber) async {
    try {
      final response = await dio.post('${APIConstants.baseUrl}auth/send',
          data: {'mobile': mobileNumber ?? ''});

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == "success") {
          return true;
        }
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message']?.toString() ?? "";
      toast(message);
      log(e.response?.data?['message'], name: 'postSendSMS');
    }
    return false;
  }

  // Verify OTP
  Future<LoginModel?> postVerifySMS(Map<String, dynamic> body) async {
    try {
      final response = await dio.post('${APIConstants.baseUrl}auth/verify',
          options: Options(headers: {
            "Accept": "application/json",
          }, followRedirects: false, maxRedirects: 0),
          data: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        log(json.encode(response.data), name: 'verifyAPI');
        final sendSmsData = LoginModel.fromJson(response.data);

        return sendSmsData;
      } else {
        return LoginModel(status: "failure", message: "Something went wrong");
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message']?.toString() ?? "";
      toast(message);
      log(e.response?.data?['message'], name: 'postVerifySMS');
    }
    return null;
  }

  // Need Help Contact Us

  Future<ContactUsModel?> getNeedHelpUser() async {
    try {
      final response = await dio
          .get('${APIConstants.baseUrl}${APIConstants.contactPublicLinks}');

      if (response.statusCode == 200) {
        // log(json.encode(response.data), name: 'register api');
        final registerData = ContactUsModel.fromJson(response.data);

        return registerData;
      } else {
        return ContactUsModel(status: "failure");
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message']?.toString() ?? "";
      toast(message);
      log(e.response?.data?['message'], name: 'register');
    }
    return ContactUsModel(status: "failure");
  }

  // Create Password
  Future<SendSMSModel?> createPassword(Map<String, dynamic> body) async {
    const tag = "createPasswordApi";

    try {
      log("chala1", name: tag);
      log("URL: ${APIConstants.baseUrl}app/users/changepass", name: tag);

      final response = await dio.post(
        '${APIConstants.baseUrl}app/users/${APIConstants.createPasswordApi}',
        options: Options(
          headers: {
            "Accept": "application/json",
            "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
          },
          followRedirects: false,
          maxRedirects: 0,
        ),
        data: body,
      );
      log("URL: ${APIConstants.baseUrl}user/${APIConstants.createPasswordApi}}", name: tag);
      log("chala2", name: tag);

      if (response.statusCode == 200) {
        log(json.encode(response.data), name: tag);

        final sendSmsData = SendSMSModel.fromJson(response.data);
        return sendSmsData;
      } else {
        log("Unexpected statusCode: ${response.statusCode}", name: tag);
        return SendSMSModel(status: "failure", message: "Something went wrong");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 410 ||
          e.response?.statusCode == 440) {
        log("Token expired", name: tag);
        _handleTokenExpiration();
      } else {
        final message = e.message ?? "";
        toast(message);

        log("Error message: $message", name: tag);
        log("Error response: ${e.response?.data}", name: tag);
      }
    }

    return SendSMSModel(status: "failure", message: "Something went wrong");
  }
  // Create New Mpin

  Future<SendSMSModel?> createNewPin(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(
          '${APIConstants.baseUrl}user/${APIConstants.createNewPinApi}',
          options: Options(headers: {
            "Accept": "application/json",
            "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
          }, followRedirects: false, maxRedirects: 0),
          data: body);

      if (response.statusCode == 200) {
        log(json.encode(response.data), name: 'createNewPinApi');
        final sendSmsData = SendSMSModel.fromJson(response.data);

        return sendSmsData;
      } else {
        return SendSMSModel(status: "failure", message: "Something went wrong");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 410 ||
          e.response?.statusCode == 440) {
        _handleTokenExpiration();
      } else {
        final message = e.response?.data?['message']?.toString() ?? "";
        toast(message);
        log(e.response?.data?['message'], name: 'register');
      }
    }
    return SendSMSModel(status: "failure", message: "Something went wrong");
  }

  // Change Password
  Future<SendSMSModel?> changePassword(Map<String, dynamic> body) async {
    try {
      final response =
          await dio.post('${APIConstants.baseUrl}app/users/changepass',
              options: Options(headers: {
                "Accept": "application/json",
                "authorization":
                    'Bearer ${Prefs.getString(PrefNames.accessToken)}',
              }, followRedirects: false, maxRedirects: 0),
              data: body);

      if (response.statusCode == 200) {
        log(json.encode(response.data), name: 'createPasswordApi');
        final sendSmsData = SendSMSModel.fromJson(response.data);

        return sendSmsData;
      } else {
        return SendSMSModel(status: "failure", message: "Something went wrong");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 410 ||
          e.response?.statusCode == 440) {
        _handleTokenExpiration();
      } else {
        final message = e.response?.data?['message']?.toString() ?? "";
        toast(message);
        log(e.response?.data?['message'], name: 'register');
      }
    }
    return SendSMSModel(status: "failure", message: "Something went wrong");
  }

  // Login user
  Future<LoginModel?> postLoginUser(Map<String, String> body) async {
    try {
      final response = await dio.post('${APIConstants.baseUrl}auth/loginpass',
          options: Options(headers: {
            "Accept": "application/json",
            "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
          }, followRedirects: false, maxRedirects: 0),
          data: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final loginModel = LoginModel.fromJson(response.data);
        if (loginModel.status == "success") {
          await Prefs.setString(PrefNames.userData, jsonEncode(loginModel));
        }
        log(json.encode(response.data), name: 'postLoginUser api');

        return loginModel;
      } else {
        return LoginModel(status: "failure", message: "Something went wrong");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 410 ||
          e.response?.statusCode == 440) {
        _handleTokenExpiration();
      } else {
        final message = e.response?.data?['message']?.toString() ?? "";
        toast(message);
        log(e.response?.data?['message'], name: 'register');
      }
    }
    return LoginModel(status: "failure", message: "Something went wrong");
  }

  // Login user
  Future<MPINLogin?> postLoginMPIN(Map<String, String> body) async {
    try {
      final response = await dio.post(
          '${APIConstants.baseUrl}auth/user/${APIConstants.loginMpinApi}',
          options: Options(headers: {
            "Accept": "application/json",
            "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
          }, followRedirects: false, maxRedirects: 0),
          data: body);

      if (response.statusCode == 200) {
        final loginModel = MPINLogin.fromJson(response.data);
        if (loginModel.status == "success") {
          Prefs.setString(PrefNames.userData, jsonEncode(loginModel));
        }
        log(json.encode(response.data), name: 'postLoginMPIN api');

        return loginModel;
      } else {
        return MPINLogin(status: "failure", message: "Something went wrong");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 410 ||
          e.response?.statusCode == 440) {
        _handleTokenExpiration();
      } else {
        final message = e.response?.data?['message']?.toString() ?? "";
        toast(message);
        log(e.response?.data?['message'], name: 'register');
      }
    }
    return MPINLogin(status: "failure", message: "Something went wrong");
  }

  // Get Particular user data
  Future<GetParticularPlayerModel?> getParticularUserData() async {
    try {
      final userData = UserData.geUserData();

      log("${Prefs.getString(PrefNames.accessToken)}", name: "Token");

      final response = await dio.get(
        '${APIConstants.baseUrl}app/users/get/${userData?.data?.id ?? ""}',
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
        }, followRedirects: false, maxRedirects: 0),
      );

      if (response.statusCode == 200) {
        final getParticularPlayerModel =
            GetParticularPlayerModel.fromJson(response.data);
        if (getParticularPlayerModel.status == "success") {
          Prefs.setString(PrefNames.userParticularPlayer,
              jsonEncode(getParticularPlayerModel.data));
        }

        log(json.encode(response.data), name: 'GetParticularPlayerModel api');

        return getParticularPlayerModel;
      } else {
        // return GetParticularPlayerModel(status: "false", message: "Something went wrong");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 410 ||
          e.response?.statusCode == 440) {
        _handleTokenExpiration();
      } else {
        final message = e.response?.data?['message']?.toString() ?? "";
        toast(message);
        log(e.response?.data?['message'], name: 'register');
      }
    }
    return null;
    // return GetParticularPlayerModel(status: "false", message: "Something went wrong");
  }

  // Get All Market
  Future<GetAllMarketModel?> getAllMarket({required String tag}) async {
    try {
      log("${Prefs.getString(PrefNames.accessToken)}", name: "Token");
      final response = await dio.get(
        '${APIConstants.baseUrl}app/market/all',
        // queryParameters: {
        //   'tag': tag,
        // },
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
        }, followRedirects: false, maxRedirects: 0),
      );

      if (response.statusCode == 200) {
        final getAllMarketModel = GetAllMarketModel.fromJson(response.data);

        log(json.encode(response.data), name: 'GetAllMarketModel api');

        return getAllMarketModel;
      } else {
        toast("Something went wrong");
        //  return GetAllMarketModel(status: "false", message: "Something went wrong");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 503) {
        toast("Maintenance Mode");
      } else if (e.response?.statusCode == 503) {
        toast("Maintenance Mode");
      } else if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 410 ||
          e.response?.statusCode == 440) {
        _handleTokenExpiration();
      } else {
        final message = e.response?.data?['message']?.toString() ?? "";
        toast(message);
        log(e.response?.data?['message'], name: '.*');
      }
    }
    return null;
    // return GetAllMarketModel(status: "false", message: "Something went wrong");
  }

  // Post play Game for all market
  Future<PlayGameAllMarketModel?> postPlayGameAllMarket(
      List<Map<String, dynamic>> body) async {
    const tag = "postPlayGameAllMarket"; // ✅ single tag

    log("REQUEST BODY: $body", name: tag);

    try {
      final url = '${APIConstants.baseUrl}app/bet/create';
      log("URL: $url", name: tag);

      final response = await dio.post(
        url,
        options: Options(
          headers: {
            "Accept": "application/json",
            "authorization":
            'Bearer ${Prefs.getString(PrefNames.accessToken)}',
          },
          followRedirects: false,
          maxRedirects: 0,
        ),
        data: body,
      );

      log("STATUS CODE: ${response.statusCode}", name: tag);

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("RESPONSE: ${json.encode(response.data)}", name: tag);

        final playGameAllMarketModel =
        PlayGameAllMarketModel.fromJson(response.data);

        return playGameAllMarketModel;
      } else {
        log("UNEXPECTED STATUS: ${response.statusCode}", name: tag);

        return PlayGameAllMarketModel(
            status: "false", message: "Something went wrong");
      }
    } on DioException catch (e) {
      log("ERROR STATUS: ${e.response?.statusCode}", name: tag);
      log("ERROR RESPONSE: ${e.response?.data}", name: tag);
      log("ERROR MESSAGE: ${e.message}", name: tag);

      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 410 ||
          e.response?.statusCode == 440) {
        log("TOKEN EXPIRED", name: tag);
        _handleTokenExpiration();
      } else {
        final message = e.response?.data?['message']?.toString() ?? "";
        toast(message);
      }
    }

    return PlayGameAllMarketModel(
        status: "false", message: "Something went wrong");
  }
  // Setting Get
  Future<GetSettingModel?> getSettingModel() async {
    try {
      final response = await dio.get(
        '${APIConstants.baseUrl}app/setting/get',
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
        }, followRedirects: false, maxRedirects: 0),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final getSettingModel = GetSettingModel.fromJson(response.data);

        log(json.encode(response.data), name: 'getSettingModel api');

        return getSettingModel;
      } else {
        return GetSettingModel(status: "false", data: null);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 410 ||
          e.response?.statusCode == 440) {
        _handleTokenExpiration();
      } else {
        final message = e.response?.data?['message']?.toString() ?? "";
        toast(message);
        log(e.response?.data?['message'], name: 'register');
      }
    }
    return GetSettingModel(status: "false", data: null);
  }

  // Post Profile Update
  Future<ProfileUpdateModel?> postProfileUpdate(
      Map<String, dynamic> body) async {
    try {
      final response = await dio.put('${APIConstants.baseUrl}app/users/update',
          options: Options(headers: {
            "Accept": "application/json",
            "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
          }, followRedirects: false, maxRedirects: 0),
          data: body);

      if (response.statusCode == 200) {
        final playGameAllMarketModel =
            ProfileUpdateModel.fromJson(response.data);

        log(json.encode(response.data), name: 'profile api');

        return playGameAllMarketModel;
      } else {
        return ProfileUpdateModel(
            status: "false", message: "Something went wrong");
      }
    } catch (e) {
      log(e.toString(), name: 'profileUpdateModel');
    }
    return ProfileUpdateModel(status: "false", message: "Something went wrong");
  }

  // Create Transaction
  Future<CreateTransactionModel?> postCreateTransaction(
      Map<String, dynamic> body) async {
    try {
      final formData = FormData.fromMap(body);

      final response = await dio.post(
        '${APIConstants.baseUrl}app/transaction/create',
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
        }, followRedirects: false, maxRedirects: 0),
        data: formData,
      );

      if (response.statusCode == 200) {
        final createTransactionModel =
            CreateTransactionModel.fromJson(response.data);
        log(json.encode(response.data), name: 'postCreateTransaction api');

        return createTransactionModel;
      } else {
        return CreateTransactionModel(
            status: "false", message: "Something went wrong");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 410 ||
          e.response?.statusCode == 440) {
        _handleTokenExpiration();
      } else {
        final message = e.response?.data?['message']?.toString() ?? "";
        toast(message);
        log(e.response?.data?['message'], name: 'register');
      }
    }
    return CreateTransactionModel(
        status: "false", message: "Something went wrong");
  }

  // View History Transaction
  Future<TransactionHistoryModel?> getBidsHistoryTransaction() async {
    try {
      // Include user_id param similar to Bids History
      final userData = UserData.geUserData();
      final userId = userData?.data?.id ?? '';
      final sep = APIConstants.getTransactionHistory.contains('?') ? '&' : '?';
      final url =
          '${APIConstants.baseUrl}app/transaction/${APIConstants.getTransactionHistory}${sep}user_id=$userId';

      final response = await dio.get(url,
          options: Options(headers: {
            "Accept": "application/json",
            "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
          }, followRedirects: false, maxRedirects: 0));

      if (response.statusCode == 200) {
        final transactionHistoryModel =
            TransactionHistoryModel.fromJson(response.data);

        log(json.encode(response.data), name: 'transactionHistoryModel api');

        return transactionHistoryModel;
      } else {
        return TransactionHistoryModel(status: "false");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 410 ||
          e.response?.statusCode == 440) {
        _handleTokenExpiration();
      } else {
        final message = e.response?.data?['message']?.toString() ?? "";
        toast(message);
        log(e.response?.data?['message'], name: 'register');
      }
    }
    return TransactionHistoryModel(status: "false");
  }

  // Allow Notification
  Future<AllowNotificationModel?> postAllowNotification(
      Map<String, bool> body) async {
    try {
      final response = await dio.post(
          '${APIConstants.baseUrl}user/${APIConstants.allowNotification}',
          options: Options(headers: {
            "Accept": "application/json",
            "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
          }, followRedirects: false, maxRedirects: 0),
          data: body);

      if (response.statusCode == 200) {
        final allowNotificationModel =
            AllowNotificationModel.fromJson(response.data);

        log(json.encode(response.data), name: 'allowNotificationModel api');

        return allowNotificationModel;
      } else {
        return AllowNotificationModel(
            status: "false", message: "Something went wrong");
      }
    } catch (e) {
      log(e.toString(), name: 'allowNotificationModel');
    }
    return AllowNotificationModel(
        status: "false", message: "Something went wrong");
  }

  // Get Bids History
  // query example: ?user_id=67b07287b48cb642b3525f25&tag=global&from=YYYY-MM-DDT00:00:00.000Z&to=YYYY-MM-DDT23:59:59.999Z
  Future<GetBidsHistoryModel?> getBidsHistory(String query) async {
    try {
      final access = Prefs.getString(PrefNames.accessToken);
      log("$access", name: "Token");

      // Ensure query formatting
      final String q = (query.isNotEmpty && query.startsWith('?'))
          ? query
          : (query.isNotEmpty ? '?$query' : '');

      final url = '${APIConstants.baseUrl}app/bet/get$q';

      // Per new API, use GET not POST
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            "Accept": "application/json",
            "authorization": 'Bearer $access',
          },
          followRedirects: false,
          maxRedirects: 0,
        ),
      );

      if (response.statusCode == 200) {
        final model = GetBidsHistoryModel.fromJson(response.data);
        log(json.encode(response.data), name: 'getBidsHistory api');
        return model;
      } else {
        return GetBidsHistoryModel(status: "failure");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 410 ||
          e.response?.statusCode == 440) {
        _handleTokenExpiration();
      } else {
        final message = e.response?.data?['message']?.toString() ?? "";
        toast(message);
        log(e.response?.data?.toString() ?? e.message ?? "",
            name: 'getBidsHistory');
      }
    }
    return GetBidsHistoryModel(status: "failure");
  }

  // Get All Notices
  Future<NoticeListModel?> getAllNotices() async {
    try {
      final response = await dio.get(
        '${APIConstants.baseUrl}app/notification/get',
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
        }, followRedirects: false, maxRedirects: 0),
      );

      if (response.statusCode == 200) {
        final noticeListModel = NoticeListModel.fromJson(response.data);
        log(json.encode(response.data), name: 'getAllNotices api');
        return noticeListModel;
      } else {
        return NoticeListModel(
            status: "failure", message: "Something went wrong");
      }
    } catch (e) {
      log(e.toString(), name: 'getAllNotices');
    }
    return NoticeListModel(status: "failure", message: "Something went wrong");
  }

  // Get UPI Transaction History
  Future<TransactionHistoryModel?> getUpiTransactionHistory({
    int skip = 0,
    int count = 10,
    String? userId,
    String? transferType,
  }) async {
    try {
      // skip -> page index, count -> items per page
      final String query =
          'user_id=$userId&transfer_type=$transferType&skip=$skip&count=$count';

      final response = await dio.get(
        '${APIConstants.baseUrl}app/transaction/get?$query',
        options: Options(
          headers: {
            "Accept": "application/json",
            "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
          },
          followRedirects: false,
          maxRedirects: 0,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final transactionHistoryModel =
            TransactionHistoryModel.fromJson(response.data);
        log(json.encode(response.data), name: 'getUpiTransactionHistory api');
        return transactionHistoryModel;
      } else {
        return TransactionHistoryModel(status: "false");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 410 ||
          e.response?.statusCode == 440) {
        _handleTokenExpiration();
      } else {
        final message = e.response?.data?['message']?.toString() ?? "";
        toast(message);
        log(e.response?.data?['message'], name: 'getUpiTransactionHistory');
      }
    }
    return TransactionHistoryModel(status: "false");
  }

  // Get QR Transaction History
  Future<TransactionHistoryModel?> getQrTransactionHistory({
    DateTime? fromDate,
    DateTime? toDate,
    int skip = 0,
    int count = 10,
  }) async {
    try {
      final userData = UserData.geUserData();
      // Basic required params
      final buffer = StringBuffer();
      buffer.write('user_id=${userData?.data?.id ?? ''}&transfer_type=deposit');
      buffer.write('&skip=$skip&count=$count');

      // // If date filters provided and backend supports, append (kept ISO format)
      // if (fromDate != null) {
      //   buffer.write('&from_date=${fromDate.toIso8601String()}');
      // }
      // if (toDate != null) {
      //   buffer.write('&to_date=${toDate.toIso8601String()}');
      // }

      final String query = buffer.toString();

      final response = await dio.get(
        '${APIConstants.baseUrl}app/transaction/get?$query',
        options: Options(
          headers: {
            "Accept": "application/json",
            "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
          },
          followRedirects: false,
          maxRedirects: 0,
        ),
      );

      if (response.statusCode == 200) {
        final transactionHistoryModel =
            TransactionHistoryModel.fromJson(response.data);
        log(json.encode(response.data), name: 'getQrTransactionHistory api');
        return transactionHistoryModel;
      } else {
        return TransactionHistoryModel(status: "false");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 410 ||
          e.response?.statusCode == 440) {
        _handleTokenExpiration();
      } else {
        final message = e.response?.data?['message']?.toString() ?? "";
        toast(message);
        log(e.response?.data?['message'], name: 'getUpiTransactionHistory');
      }
    }
    return TransactionHistoryModel(status: "false");
  }

  // Get Withdrawal Transaction History
  Future<TransactionHistoryModel?> getWithdrawalTransactionHistory({
    int skip = 0,
    int count = 10,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final userData = UserData.geUserData();
      // final now = DateTime.now();
      // final today = fromDate ?? DateTime(now.year, now.month, now.day);
      // final todayEnd =
      //     toDate ?? DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

      // Align with bids history: use user_id instead of user
      // Pagination params similar to UPI history (skip = page index, count = page size)
      final String query =
          'user_id=${userData?.data?.id ?? ''}&transfer_type=withdrawal&skip=$skip&count=$count';

      final response = await dio.get(
        '${APIConstants.baseUrl}app/transaction/get?$query',
        options: Options(headers: {
          "Accept": "application/json",
          "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
        }, followRedirects: false, maxRedirects: 0),
      );

      if (response.statusCode == 200) {
        final transactionHistoryModel =
            TransactionHistoryModel.fromJson(response.data);
        log(json.encode(response.data),
            name: 'getWithdrawalTransactionHistory api');
        return transactionHistoryModel;
      } else {
        return TransactionHistoryModel(status: "false");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 410 ||
          e.response?.statusCode == 440) {
        _handleTokenExpiration();
      } else {
        final message = e.response?.data?['message']?.toString() ?? "";
        toast(message);
        log(e.response?.data?['message'], name: 'getUpiTransactionHistory');
      }
    }
    return TransactionHistoryModel(status: "false");
  }

  // Popup Notice (external base URL – no auth required)
  Future<Map<String, dynamic>?> getPopupNotice() async {
    try {
      final response = await dio.get(
        '${APIConstants.baseUrl}app/notice/get',
        options: Options(
          headers: {
            "Accept": "application/json",
            "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
          },
          followRedirects: false,
          maxRedirects: 0,
        ),
      );
      if (response.statusCode == 200) {
        log(json.encode(response.data), name: 'getPopupNotice api');
        return Map<String, dynamic>.from(response.data);
      }
    } on DioException catch (e) {
      log(e.response?.data.toString() ?? e.message ?? '',
          name: 'getPopupNotice');
    } catch (e) {
      log(e.toString(), name: 'getPopupNotice');
    }
    return null;
  }

  // SME Pay: Start Transaction
  Future<SmePayStartResponse?> startSmePayTransaction({
    required String amount,
    required String orderId,
    required String userId,
  }) async {
    try {
      final body = {
        "user_id": userId,
        "amount": amount,
        "order_id": orderId,
      };
      final response = await dio.post(
        '${APIConstants.baseUrl}app/${APIConstants.smePayStart}',
        options: Options(
          headers: {
            "Accept": "application/json",
            "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
            "Content-Type": "application/json",
          },
          followRedirects: false,
          maxRedirects: 0,
        ),
        data: body,
      );
      if (response.statusCode == 200) {
        return SmePayStartResponse.fromJson(
            response.data as Map<String, dynamic>);
      }
    } catch (e) {
      log(e.toString(), name: 'startSmePayTransaction');
    }
    return null;
  }

  // Get Market Results
  Future<GetMarketResultsModel?> getMainMarketResults({
    required String marketId,
  }) async {
    try {
      final response = await dio.get(
        '${APIConstants.baseUrl}public/result',
        queryParameters: {
          'tag': "main",
          'market_id': marketId,
        },
        options: Options(
          headers: {
            "Accept": "application/json",
          },
          followRedirects: false,
          maxRedirects: 0,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("Raw API Response: ${json.encode(response.data)}",
            name: 'getMarketResults api');
        final getMarketResultsModel =
            GetMarketResultsModel.fromJson(response.data);
        log("Parsed Model: ${getMarketResultsModel.toJson()}",
            name: 'getMarketResults api');
        return getMarketResultsModel;
      } else {
        return GetMarketResultsModel(
            status: "failure", message: "Something went wrong");
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message']?.toString() ?? "";
      toast(message);
      log(e.response?.data?['message'], name: 'getMarketResults');
    }
    return GetMarketResultsModel(
        status: "failure", message: "Something went wrong");
  }

  // Get Today's Winners
  Future<TodayWinnersModel?> getTodayWinners() async {
    try {
      final response = await dio.get(
        '${APIConstants.baseUrl}app/market/${APIConstants.getTodayWinners}',
        options: Options(
          headers: {
            "Accept": "application/json",
            "authorization": 'Bearer ${Prefs.getString(PrefNames.accessToken)}',
          },
          followRedirects: false,
          maxRedirects: 0,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log(json.encode(response.data), name: 'getTodayWinners api');
        final todayWinnersModel = TodayWinnersModel.fromJson(response.data);
        return todayWinnersModel;
      } else {
        return TodayWinnersModel(status: "failure");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 410 ||
          e.response?.statusCode == 440) {
        _handleTokenExpiration();
      } else {
        final message = e.response?.data?['message']?.toString() ?? "";
        toast(message);
        log(e.response?.data?['message'], name: 'getTodayWinners');
      }
    }
    return TodayWinnersModel(status: "failure");
  }
}
