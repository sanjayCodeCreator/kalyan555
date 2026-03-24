import 'dart:developer';
import 'package:sm_project/controller/model/sendsms_model.dart';
import 'package:sm_project/utils/filecollection.dart';

final changePasswordNotifierProvider = AsyncNotifierProvider.autoDispose<
    ChangePasswordNotifier, ChangePasswordMode>(() {
  return ChangePasswordNotifier();
});

class ChangePasswordMode {
  // Create New Password
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  bool obsecureText = false;
}

class ChangePasswordNotifier
    extends AutoDisposeAsyncNotifier<ChangePasswordMode> {
  final ChangePasswordMode _outputMode = ChangePasswordMode();

  //Obsecure
  void changeObsecureText() {
    _outputMode.obsecureText = !_outputMode.obsecureText;
    state = AsyncData(_outputMode);
  }

  // Create New Password
  void changePassword(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Loading...');

      Map<String, dynamic> verifyBody = {
        'mobile': Prefs.getString(PrefNames.mobileNumber),
        'password': _outputMode.newPasswordController.text,
        'old_password': _outputMode.oldPasswordController.text
      };
      log(verifyBody.toString());
      SendSMSModel? response = await ApiService().changePassword(verifyBody);
      if (response?.status == "success") {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast('Password changed successfully');
          context.pushReplacementNamed(RouteNames.homeScreen);
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
