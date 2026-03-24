import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sm_project/controller/model/login_model.dart';
import 'package:sm_project/controller/model/register_model.dart';
import 'package:sm_project/utils/filecollection.dart';

final registerNotifierProvider =
    AsyncNotifierProvider.autoDispose<RegisterNotifier, RegisterMode>(() {
  return RegisterNotifier();
});

class RegisterMode {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController mobileNumbController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  // final TextEditingController referralController = TextEditingController();
}

class RegisterNotifier extends AutoDisposeAsyncNotifier<RegisterMode> {
  final RegisterMode _outputMode = RegisterMode();

  // Register user

  void getRegister(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Loading...');
      String token = '';

      try {
        token = await FirebaseMessaging.instance.getToken() ?? '';
      } catch (e) {
        log(e.toString(), name: 'getToken');
      }

      Map<String, String> registerBody = {
        'user_name': _outputMode.userNameController.text,
        'mobile': _outputMode.mobileNumbController.text,
        // 'referral_code': _outputMode.referralController.text,
        'fcm': token,
        'password': _outputMode.passwordController.text,
      };
      log(registerBody.toString());

      RegisterModel? registerModel =
          await ApiService().postRegisterUser(registerBody);
      if (registerModel?.message == "signup") {
        log('check data');
        // Send OTP
        bool? sendSMSModel = await ApiService()
            .postSendSMS(_outputMode.mobileNumbController.text);
        if (sendSMSModel) {
          await Prefs.setString(
              PrefNames.mobileNumber, _outputMode.mobileNumbController.text);
          EasyLoading.dismiss();
          if (context.mounted) {
            context.goNamed(RouteNames.otpScreen, pathParameters: {
              'mobile': _outputMode.mobileNumbController.text,
              'password': _outputMode.passwordController.text
            });
          }
        } else {
          EasyLoading.dismiss();
        }
      } else {
        EasyLoading.dismiss();
        if (registerModel?.message == "User already present") {
          if (context.mounted) {
            getLogin(context);
          }
        } else {
          EasyLoading.dismiss();
          toast(registerModel?.message ?? '');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'registerApi');
    }
    EasyLoading.dismiss();
  }

  void getLogin(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Loading...');
      Map<String, String> loginBody = {
        'mobile': _outputMode.mobileNumbController.text,
        'password': _outputMode.passwordController.text,
      };
      log(loginBody.toString());

      LoginModel? loginModel = await ApiService().postLoginUser(loginBody);
      if (loginModel?.status == "success" &&
          loginModel?.data?.verified == false) {
        Prefs.setString(
            PrefNames.accessToken, loginModel?.tokenData?.token ?? '');
        Prefs.setString(
          PrefNames.mobileNumber,
          _outputMode.mobileNumbController.text,
        );
        bool? sendSMSModel = await ApiService()
            .postSendSMS(_outputMode.mobileNumbController.text);
        if (sendSMSModel) {
          Prefs.setString(
              PrefNames.mobileNumber, _outputMode.mobileNumbController.text);
          EasyLoading.dismiss();
          if (context.mounted) {
            context.pushNamed(RouteNames.otpScreen, pathParameters: {
              'mobile': _outputMode.mobileNumbController.text,
              'password': _outputMode.passwordController.text
            });
          }
        } else {
          EasyLoading.dismiss();
        }
      } else if (loginModel?.status == "success" &&
          loginModel?.data?.verified == true) {
        Prefs.setString(
            PrefNames.accessToken, loginModel?.tokenData?.token ?? '');
        Prefs.setString(
          PrefNames.mobileNumber,
          _outputMode.mobileNumbController.text,
        );
        Prefs.setBool(PrefNames.isLogin, true);

        EasyLoading.dismiss();
        context.go(RouteNames.homeScreen);
      } else if (loginModel?.status == "failure") {
        EasyLoading.dismiss();
        toast(context: context, loginModel?.message ?? '');
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'loginModel');
    }
  }

  @override
  build() {
    return _outputMode;
  }
}
