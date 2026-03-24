import 'dart:developer';
import 'package:sm_project/controller/model/get_setting_model.dart';
import 'package:sm_project/features/gali_desawar/gali_desawar_api.dart';
import 'package:sm_project/features/gali_desawar/model/select_game_model_list.dart';
import 'package:sm_project/features/gali_desawar/notifier/model/get_all_result_model.dart';
import 'package:sm_project/utils/filecollection.dart';

final resultRulesNotifierProvider =
    AsyncNotifierProvider.autoDispose<ResultRulesNotifier, ResultRulesMode>(() {
  return ResultRulesNotifier();
});

class ResultRulesMode {
  GetSettingModel? getSettingModel = GetSettingModel();
  SelectGameMarketList? selectGameMarketList = SelectGameMarketList();

  GetAllResultModel? getAllResultModel = GetAllResultModel();
  DateTime? fromDate;
  bool isVisible = false;
}

class ResultRulesNotifier extends AutoDisposeAsyncNotifier<ResultRulesMode> {
  final ResultRulesMode _outputMode = ResultRulesMode();

  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (isFromDate) {
        _outputMode.fromDate = picked;
        _outputMode.isVisible = true;

        // getResultModel(
        //     '?tag=galidisawar&from=${ref.watch(resultRulesNotifierProvider).value?.fromDate == null ? "" : ref.watch(resultRulesNotifierProvider).value?.fromDate?.year.toString()}-${ref.watch(resultRulesNotifierProvider).value?.fromDate == null ? "" : fromMonth}-${ref.watch(resultRulesNotifierProvider).value?.fromDate == null ? "" : fromDate}T00:00:00.000Z');
      }
    }
    state = AsyncData(_outputMode);
  }

  // Result
  void getResultModel(String query) async {
    _outputMode.isVisible = false;
    try {
      EasyLoading.show(status: 'Loading...');
      log(query);
      _outputMode.getAllResultModel =
          await GaliDesawarApis.getDishawarResult(query);
      _outputMode.getSettingModel = await ApiService().getSettingModel();
      if (_outputMode.getAllResultModel?.status == "success") {
        EasyLoading.dismiss();

        if (_outputMode.getAllResultModel?.data?.isEmpty ?? false) {
          EasyLoading.dismiss();
          toast('No Result Found');
        }
      } else if (_outputMode.getAllResultModel?.status == "failure") {
        EasyLoading.dismiss();
        toast('Something went wrong');
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'getDishawarResultProvider');
    }
    EasyLoading.dismiss();
    state = AsyncData(_outputMode);
  }

  @override
  build() {
    return _outputMode;
  }
}
