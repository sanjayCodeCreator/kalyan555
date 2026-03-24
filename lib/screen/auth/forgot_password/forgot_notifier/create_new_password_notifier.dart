import 'dart:developer';
import 'package:sm_project/controller/model/sendsms_model.dart';
import 'package:sm_project/utils/filecollection.dart';

final createPasswordNotifierProvider = AsyncNotifierProvider.autoDispose<
    CreatePasswordNotifier, CreatePasswordMode>(() {
  return CreatePasswordNotifier();
});

class CreatePasswordMode {
  // Create New Password
  final TextEditingController passwordCreateController =
      TextEditingController();
  final TextEditingController confirmPasswordCreateController =
      TextEditingController();
}

class CreatePasswordNotifier
    extends AutoDisposeAsyncNotifier<CreatePasswordMode> {
  final CreatePasswordMode _outputMode = CreatePasswordMode();

  // Create New Password
  void createPassword(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Loading...');

      Map<String, dynamic> verifyBody = {
        'mobile': Prefs.getString(PrefNames.mobileNumber),
        'password': _outputMode.confirmPasswordCreateController.text,
      };
      log(verifyBody.toString());
      log("XC");
      SendSMSModel? response = await ApiService().createPassword(verifyBody);
      if (response?.status == "success") {
        EasyLoading.dismiss();
        if (context.mounted) {
          context.pushReplacementNamed(RouteNames.logInScreen);
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
