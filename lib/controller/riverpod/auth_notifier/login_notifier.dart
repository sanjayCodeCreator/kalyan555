// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sm_project/controller/model/login_model.dart';
import 'package:sm_project/screen/push_notification.dart/firebase_messaging.dart';
import 'package:sm_project/utils/filecollection.dart';

import '../../../screen/push_notification.dart/push_notification_api.dart';

final loginNotifierProvider =
    AsyncNotifierProvider.autoDispose<LoginNotifier, LoginMode>(() {
  return LoginNotifier();
});

class LoginMode {
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
}

class LoginNotifier extends AutoDisposeAsyncNotifier<LoginMode> {
  final LoginMode _outputMode = LoginMode();

  // Login user

  void getLogin(BuildContext context) async {
    const tag = "getLogin"; // ✅ single tag

    try {
      EasyLoading.show(status: 'Loading...');

      Map<String, String> loginBody = {
        'mobile': _outputMode.mobileNumberController.text,
        'password': _outputMode.passwordController.text,
      };

      log("REQUEST BODY: $loginBody", name: tag);

      LoginModel? loginModel =
      await ApiService().postLoginUser(loginBody);

      log("API RESPONSE: ${loginModel?.toJson()}", name: tag);
      log("STATUS: ${loginModel?.status}", name: tag);

      if (loginModel?.status == "success") {
        log("LOGIN SUCCESS", name: tag);

        Prefs.setString(
            PrefNames.accessToken, loginModel?.tokenData?.token ?? '');
        log("TOKEN SAVED: ${loginModel?.tokenData?.token}", name: tag);

        await Prefs.setString(PrefNames.userData, jsonEncode(loginModel));
        Prefs.setString(
          PrefNames.mobileNumber,
          _outputMode.mobileNumberController.text,
        );
        Prefs.setBool(PrefNames.isLogin, true);

        final savedFcm = Prefs.getString(PrefNames.fcmToken);
        log("FCM TOKEN: $savedFcm", name: tag);

        if (savedFcm != null && savedFcm != "-") {
          log("UPDATING FCM TOKEN", name: tag);
          PushNotificationApi.updateFCMToken(savedFcm);
        }

        EasyLoading.dismiss();
        log("NAVIGATE TO MAIN SCREEN", name: tag);

        context.go(RouteNames.mainScreen);
      } else if (loginModel?.status == "failure") {
        log("LOGIN FAILED: ${loginModel?.message}", name: tag);

        EasyLoading.dismiss();
        toast(context: context, loginModel?.message ?? '');
      }
    } catch (e) {
      EasyLoading.dismiss();
      log("EXCEPTION: $e", name: tag);
    }
  }
  @override
  build() {
    return _outputMode;
  }
}