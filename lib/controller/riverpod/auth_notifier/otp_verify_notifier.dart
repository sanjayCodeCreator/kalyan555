import 'dart:developer';

import 'package:sm_project/controller/model/login_model.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

final otpVerifyNotifierProvider =
    AsyncNotifierProvider.autoDispose<OTPNotifier, OTPMode>(() {
  return OTPNotifier();
});

class OTPMode {
  final TextEditingController otpController = TextEditingController();

  //VerifyOTP
  final StopWatchTimer stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: StopWatchTimer.getMilliSecFromSecond(120));
}

class OTPNotifier extends AutoDisposeAsyncNotifier<OTPMode> {
  final OTPMode _outputMode = OTPMode();

  // Verify OTP
  void verifyOTPSms(
      BuildContext context, String mobileNumber, String password) async {
    try {
      EasyLoading.show(status: 'Loading...');
      Prefs.setString(PrefNames.mobileNumber, mobileNumber);
      Map<String, dynamic> verifyBody = {
        'mobile': mobileNumber,
        'otp': _outputMode.otpController.text,
      };
      log(verifyBody.toString());
      LoginModel? response = await ApiService().postVerifySMS(verifyBody);
      if (response?.status == "success") {
        Prefs.setString(
            PrefNames.accessToken, response?.tokenData?.token ?? '');
        // Login user
        Map<String, String> loginBody = {
          'mobile': mobileNumber,
          'password': password
        };

        LoginModel? loginModel = await ApiService().postLoginUser(loginBody);
        if (loginModel?.status == "success") {
          Prefs.setBool(PrefNames.isLogin, true);
          EasyLoading.dismiss();
          if (context.mounted) {
            context.go(RouteNames.mainScreen);
          }
        } else if (loginModel?.status == "failure") {
          EasyLoading.dismiss();
          toast(loginModel?.message ?? '');
        }
      } else {
        EasyLoading.dismiss();
        toast(response?.message ?? '');
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'sendSms');
    }
  }

  // Resend Code
  void resendOTP(BuildContext context, String mobile) async {
    try {
      EasyLoading.show(status: 'Loading...');
      // Send OTP
      bool? sendSMSModel = await ApiService().postSendSMS(mobile);
      if (sendSMSModel) {
        Prefs.setString(PrefNames.mobileNumber, mobile);
        EasyLoading.dismiss();
      } else {
        EasyLoading.dismiss();
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'resent OTP');
    }
  }

  @override
  build() {
    return _outputMode;
  }
}
