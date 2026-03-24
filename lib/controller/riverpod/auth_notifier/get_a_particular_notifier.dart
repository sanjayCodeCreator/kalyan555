import 'dart:developer';

import 'package:sm_project/controller/model/get_particular_player_model.dart';
import 'package:sm_project/utils/filecollection.dart';

final getParticularPlayerNotifierProvider =
    AsyncNotifierProvider<GetParticularPlayerNotifier, GetParticularPlayerMode>(
        () {
  return GetParticularPlayerNotifier();
});

class GetParticularPlayerMode {
  GetParticularPlayerModel? getParticularPlayerModel =
      GetParticularPlayerModel();
}

class GetParticularPlayerNotifier
   
    extends AsyncNotifier<GetParticularPlayerMode> {
  final GetParticularPlayerMode _getParticularPlayer =
      GetParticularPlayerMode();

  // Get Particular PlayerId user

  Future<void> getParticularPlayerModel({BuildContext? context}) async {
    try {
      EasyLoading.show(status: 'Loading...');
      _getParticularPlayer.getParticularPlayerModel =
          await ApiService().getParticularUserData();
      if (_getParticularPlayer.getParticularPlayerModel?.status == "success") {
        EasyLoading.dismiss();
      } else if (_getParticularPlayer.getParticularPlayerModel?.status ==
          "failure") {
        EasyLoading.dismiss();
        // toast(loginModel?.message ?? '');
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'getParticularPlayerModel');
    }
    state = AsyncData(_getParticularPlayer);
  }

  // Logout
  void logout(BuildContext context) {
    Prefs.clear();
    context.pushNamed(RouteNames.logInScreen);
  }

  @override
  build() {
    return _getParticularPlayer;
  }
}
