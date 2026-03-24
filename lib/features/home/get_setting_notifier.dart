import 'dart:convert';
import 'dart:developer';

import 'package:sm_project/controller/model/get_setting_model.dart';
import 'package:sm_project/utils/filecollection.dart';

final getSettingNotifierProvider =
    AsyncNotifierProvider.autoDispose<GetSettingNotifier, GetSettingMode>(() {
  return GetSettingNotifier();
});

class GetSettingMode {
  GetSettingModel? getSettingModel = GetSettingModel();
}

class GetSettingNotifier extends AutoDisposeAsyncNotifier<GetSettingMode> {
  final GetSettingMode _getSetting = GetSettingMode();

  // Get app settings from API
  Future<void> getSettingModel() async {
    try {
      EasyLoading.show(status: 'Loading...');
      _getSetting.getSettingModel = await ApiService().getSettingModel();
      log(json.encode(_getSetting.getSettingModel));
      if (_getSetting.getSettingModel?.status == "success") {
        EasyLoading.dismiss();
      } else if (_getSetting.getSettingModel?.status == "failure") {
        EasyLoading.dismiss();
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'getSettingModel');
    }
    state = AsyncData(_getSetting);
  }

  @override
  build() {
    getSettingModel();
    return _getSetting;
  }
}
