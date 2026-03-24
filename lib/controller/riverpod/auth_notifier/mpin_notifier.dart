import 'dart:developer';

import 'package:sm_project/controller/model/mpin_login_model.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:url_launcher/url_launcher.dart';

final mpinNotifierProvider =
    AsyncNotifierProvider.autoDispose<MpinNotifier, MpinMode>(() {
  return MpinNotifier();
});

class MpinMode {
  final TextEditingController mpinController = TextEditingController();
}

class MpinNotifier extends AutoDisposeAsyncNotifier<MpinMode> {
  final MpinMode _outputMode = MpinMode();

  // Login user

  void getMpinLogin(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Loading...');
      Map<String, String> loginBody = {
        'mobile': Prefs.getString(PrefNames.mobileNumber) ?? '',
        'mpin': _outputMode.mpinController.text,
      };
      log(loginBody.toString());
      MPINLogin? loginModel = await ApiService().postLoginMPIN(loginBody);
      if (loginModel?.status == "success") {
        Prefs.setString(PrefNames.accessToken, loginModel?.accessToken ?? '');
        Prefs.setBool(PrefNames.isLogin, true);
        EasyLoading.dismiss();
        if (context.mounted) {
          context.pushReplacementNamed(RouteNames.homeScreen);
        }
      } else if (loginModel?.status == "failure") {
        EasyLoading.dismiss();
        toast(loginModel?.message ?? '');
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'mpinModel');
    }
  }

  void launchPrivacyPolicy() async {
    String url =
        "https://www.termsfeed.com/live/e59c3fe2-7934-4653-b684-1df267ad2f11";
    try {
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault)) {}
    } on Exception {
      EasyLoading.showError('Telegram is not installed.');
    }
  }

  @override
  build() {
    return _outputMode;
  }
}
