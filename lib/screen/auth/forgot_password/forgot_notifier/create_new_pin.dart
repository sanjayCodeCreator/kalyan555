import 'dart:developer';
import 'package:sm_project/controller/model/sendsms_model.dart';
import 'package:sm_project/screen/auth/forgot_password/screen/pin_set_successful.dart';
import 'package:sm_project/utils/filecollection.dart';

final createNewPinNotifierProvider =
    AsyncNotifierProvider.autoDispose<CreateNewPinNotifier, CreateNewPinMode>(
        () {
  return CreateNewPinNotifier();
});

class CreateNewPinMode {
  // Create New Password
  final TextEditingController pinCreateController = TextEditingController();
  final TextEditingController confirmPinCreateController =
      TextEditingController();
}

class CreateNewPinNotifier extends AutoDisposeAsyncNotifier<CreateNewPinMode> {
  final CreateNewPinMode _outputMode = CreateNewPinMode();

  // Create New Pin
  void createNewPin(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Loading...');

      Map<String, dynamic> verifyBody = {
        'mobile': Prefs.getString(PrefNames.mobileNumber),
        'mpin': _outputMode.confirmPinCreateController.text,
      };
      log(verifyBody.toString());
      SendSMSModel? response = await ApiService().createNewPin(verifyBody);
      if (response?.status == "success") {
        EasyLoading.dismiss();
        if (context.mounted) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const PinSetSuccessful()));
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
