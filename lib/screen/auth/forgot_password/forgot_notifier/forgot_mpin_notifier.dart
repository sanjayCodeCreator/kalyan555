import 'dart:developer';
import 'package:sm_project/controller/model/login_model.dart';
import 'package:sm_project/controller/model/sendsms_model.dart';
import 'package:sm_project/screen/auth/forgot_password/screen/create_new_pin.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../screen/otp_forgot_pin.dart';

final forgotMPINNotifierProvider =
    AsyncNotifierProvider.autoDispose<ForgotMpinNotifier, ForgotMPINMode>(() {
  return ForgotMpinNotifier();
});

class ForgotMPINMode {
  final TextEditingController mobileNumbController = TextEditingController();
  final TextEditingController forgotOTPController = TextEditingController();

  final StopWatchTimer stopWatchTimer = StopWatchTimer(
      mode: StopWatchMode.countDown,
      presetMillisecond: StopWatchTimer.getMilliSecFromSecond(120));

  // Create New Password
  final TextEditingController passwordCreateController =
      TextEditingController();
  final TextEditingController confirmPasswordCreateController =
      TextEditingController();
}

class ForgotMpinNotifier extends AutoDisposeAsyncNotifier<ForgotMPINMode> {
  final ForgotMPINMode _outputMode = ForgotMPINMode();

  void postForgotMpIn(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Loading...');

      // Send OTP
      bool sendSMSModel =
          await ApiService().postSendSMS(_outputMode.mobileNumbController.text);
      if (sendSMSModel) {
       
        Prefs.setString(
            PrefNames.mobileNumber, _outputMode.mobileNumbController.text);

        EasyLoading.dismiss();
        if (context.mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => OTPFogotPin(
                      mobile: _outputMode.mobileNumbController.text)));
        }
      } else {
        EasyLoading.dismiss();
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'registerApi');
    }
  }

  // Forgot OTP MPIN Verify
  void verifyOTPSms(BuildContext context, String mobileNumber) async {
    try {
      EasyLoading.show(status: 'Loading...');
      Prefs.setString(PrefNames.mobileNumber, mobileNumber);
      Map<String, dynamic> verifyBody = {
        'mobile': mobileNumber,
        'otp': _outputMode.forgotOTPController.text,
      };
      log(verifyBody.toString());
      LoginModel? response = await ApiService().postVerifySMS(verifyBody);
      if (response?.status == "success") {
        await Prefs.setString(
            PrefNames.accessToken, response?.tokenData?.token ?? '');
        EasyLoading.dismiss();
        if (context.mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => CreateNewPin(
                      mobileNumber: _outputMode.mobileNumbController.text)));
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

  // Create New Password
  void createPassword(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Loading...');

      Map<String, dynamic> verifyBody = {
        'mobile': Prefs.getString(PrefNames.mobileNumber),
        'password': _outputMode.confirmPasswordCreateController.text,
      };
      log(verifyBody.toString());
      SendSMSModel? response = await ApiService().createPassword(verifyBody);
      if (response?.status == "success") {
        EasyLoading.dismiss();
        if (context.mounted) {
          context.pushReplacementNamed(RouteNames.mpinPassword);
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

  @override
  build() {
    return _outputMode;
  }
}
