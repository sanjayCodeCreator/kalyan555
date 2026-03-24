import 'dart:developer';

import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/get_particular_player_model.dart';
import 'package:sm_project/controller/model/profile_update_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

final savedBankNotifierProvider =
    AsyncNotifierProvider.autoDispose<SavedBankNotifier, SavedBankMode>(() {
  return SavedBankNotifier();
});

class SavedBankMode {
  // Create New Password
  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController acountNumberController = TextEditingController();
  final TextEditingController reAcountNumberController =
      TextEditingController();
  bool obsecureText = false;
}

class SavedBankNotifier extends AutoDisposeAsyncNotifier<SavedBankMode> {
  final SavedBankMode _outputMode = SavedBankMode();

  //Obsecure
  void changeObsecureText() {
    _outputMode.obsecureText = !_outputMode.obsecureText;
    state = AsyncData(_outputMode);
  }

  // Create New Password
  void savedBank(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Loading...');

      Map<String, dynamic> verifyBody = {
        "id": ref
                .watch(getParticularPlayerNotifierProvider)
                .value
                ?.getParticularPlayerModel
                ?.data
                ?.sId ??
            "",
        'account_holder_name': _outputMode.accountHolderController.text,
        'account_no': _outputMode.acountNumberController.text,
        'ifsc_code': _outputMode.ifscController.text,
        'bank_name': _outputMode.bankNameController.text
      };
      log(verifyBody.toString());
      ProfileUpdateModel? response =
          await ApiService().postProfileUpdate(verifyBody);
      if (response?.status == "success") {
        ref
            .read(homeNotifierProvider.notifier)
            .getParticularPlayerModel(context)
            .then((value) {
          EasyLoading.dismiss();
          setData();
        });
        EasyLoading.dismiss();
        if (context.mounted) {
          toast('Bank account added successfully');
          context.pop();
          // context.pushReplacementNamed(RouteNames.homeScreen);
        }
      } else {
        EasyLoading.dismiss();
        toast(response?.message ?? '');
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'sendSms');
    }
    EasyLoading.dismiss();
  }

  void setData() {
    final Data? userDgetParticularUserData =
        UserParticularPlayer.getParticularUserData();
    _outputMode.bankNameController.text =
        userDgetParticularUserData?.bankName ?? '';
    _outputMode.accountHolderController.text =
        userDgetParticularUserData?.accountHolderName ?? '';
    _outputMode.acountNumberController.text =
        userDgetParticularUserData?.accountNo ?? '';
    _outputMode.ifscController.text =
        userDgetParticularUserData?.ifscCode ?? '';
    EasyLoading.dismiss();
  }

  @override
  build() {
    return _outputMode;
  }
}
