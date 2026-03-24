import 'dart:convert';
import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/get_setting_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/kalyan_morning_notifier.dart';
import 'package:sm_project/features/home/main_screen.dart';
import 'package:sm_project/features/starline/starline_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

import '../../../controller/model/single_digit_model.dart';

final singleDigitNewNotifierProvider = AsyncNotifierProvider.autoDispose<
    SingleDigitNewNotifier, SingleDigitNewMode>(() {
  return SingleDigitNewNotifier();
});

class SingleDigitNewMode {
  final userParticularPlayer = UserParticularPlayer.getParticularUserData();
  String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
  int? startDigit = 0;

  List<SelectedSingleDigitNewModel> selectedNumberList = [];
  int? totalSelectedNumber = 0;
  int? totalPoints = 0;
  int? leftPoints;

  String? openDigit;
  String? closeDigit;

  GetSettingModel? getSettingModel = GetSettingModel();

  List<SingleDigitNewModel> singleDigitNewModel = [
    SingleDigitNewModel(value: TextEditingController()),
    SingleDigitNewModel(value: TextEditingController()),
    SingleDigitNewModel(value: TextEditingController()),
    SingleDigitNewModel(value: TextEditingController()),
    SingleDigitNewModel(value: TextEditingController()),
    SingleDigitNewModel(value: TextEditingController()),
    SingleDigitNewModel(value: TextEditingController()),
    SingleDigitNewModel(value: TextEditingController()),
    SingleDigitNewModel(value: TextEditingController()),
    SingleDigitNewModel(value: TextEditingController()),
  ];
}

class SingleDigitNewNotifier
    extends AutoDisposeAsyncNotifier<SingleDigitNewMode> {
  final SingleDigitNewMode _outputMode = SingleDigitNewMode();

  void setStartDigit(int number) {
    for (int i = 0; i < _outputMode.singleDigitNewModel.length; i++) {
      _outputMode.singleDigitNewModel[i].value?.text = '';
      _outputMode.singleDigitNewModel[i].points = '';
    }
    _outputMode.startDigit = number;
    state = AsyncData(_outputMode);
  }

  void addPoints(BuildContext context) async {
    try {
      FocusScope.of(context).unfocus();
      EasyLoading.show(status: 'Loading...');
      _outputMode.getSettingModel = await ApiService().getSettingModel();
      int totalAddPoints = 0;
      for (var element in _outputMode.singleDigitNewModel) {
        if (element.value?.text.trim() != '') {
          totalAddPoints = int.parse(element.value?.text ?? '0');
        }
      }
      EasyLoading.dismiss();

      if (totalAddPoints == 0) {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(context: context, 'Invalid enter number');
        }

        return;
      } else if ((_outputMode.leftPoints ?? -1) < totalAddPoints ||
          totalAddPoints == 0) {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(context: context, 'Wallet Amount is Low');
        }
        return;
      } else if ((_outputMode.getSettingModel?.data?.betting?.min ?? 0) >
              totalAddPoints ||
          (_outputMode.getSettingModel?.data?.betting?.max ?? 0) <
              totalAddPoints) {
        EasyLoading.dismiss();
        clearSelectedNumberList();
        if (context.mounted) {
          toast(
              context: context,
              'Minimum bet amount is ${_outputMode.getSettingModel?.data?.betting?.min} and Maximum bet amount is ${_outputMode.getSettingModel?.data?.betting?.max}');
        }
        return;
      }

      if (_outputMode.singleDigitNewModel.isNotEmpty) {
        for (var element in _outputMode.singleDigitNewModel) {
          if (element.value?.text.trim() != '') {
            _outputMode.selectedNumberList.add(
              SelectedSingleDigitNewModel(
                points: element.points,
                value: element.value?.text,
                session:
                    (ref.watch(kalyanMorningNotifierProvider).value?.isClose ??
                            false)
                        ? "close"
                        : "open",
              ),
            );
          }
        }
        EasyLoading.dismiss();
        totalAll();
      } else {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(context: context, 'Please select number and add points');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'SingleDigitNewModel');
    }

    EasyLoading.dismiss();
    clearSelectedNumberList();
    state = AsyncData(_outputMode);
  }

  void removePoints(BuildContext context, int index) {
    if (_outputMode.selectedNumberList != []) {
      _outputMode.selectedNumberList
          .remove(_outputMode.selectedNumberList.elementAt(index));

      totalAll();
    } else {
      toast(context: context, 'Please select number and add points');
    }
    state = AsyncData(_outputMode);
  }

  // Delete All
  void deleteAll(BuildContext context) {
    if (_outputMode.selectedNumberList != []) {
      _outputMode.selectedNumberList.clear();
      // _outputMode.singleDigitList.clear();
      totalAll();
    } else {
      toast(context: context, 'Please select number and add points');
    }

    state = AsyncData(_outputMode);
  }

  // clear selectedNumberList
  void clearSelectedNumberList() {
    for (int i = 0; i < _outputMode.singleDigitNewModel.length; i++) {
      _outputMode.singleDigitNewModel[i].value?.text = '';
      _outputMode.singleDigitNewModel[i].points = '';
    }
    state = AsyncData(_outputMode);
  }

  void clearConfirmNumberList() {
    _outputMode.selectedNumberList.clear();
    state = AsyncData(_outputMode);
  }

  void onSubmitConfirm(
      BuildContext context, String tag, String marketId) async {
    if (_outputMode.selectedNumberList.isNotEmpty) {
      try {
        EasyLoading.show(status: 'Loading...');
        await ref
            .read(getParticularPlayerNotifierProvider.notifier)
            .getParticularPlayerModel();
        List<Map<String, dynamic>> jsonDataArray = [
          for (int i = 0; i < _outputMode.selectedNumberList.length; i++)
            {
              "user_id": ref
                      .watch(getParticularPlayerNotifierProvider)
                      .value
                      ?.getParticularPlayerModel
                      ?.data
                      ?.sId ??
                  "",
              "session": ref.watch(starlineNotifierProvider)
                  ? "open"
                  : _outputMode.selectedNumberList[i].session,
              "tag": tag,
              if (ref.watch(starlineNotifierProvider) ||
                  _outputMode.selectedNumberList[i].session == "open")
                "open_digit": ref.watch(starlineNotifierProvider)
                    ? _outputMode.selectedNumberList[i].points
                    : _outputMode.selectedNumberList[i].session == "open"
                        ? _outputMode.selectedNumberList[i].points
                        : "-",
              if (ref.watch(starlineNotifierProvider) ||
                  _outputMode.selectedNumberList[i].session == "close")
                "close_digit": ref.watch(starlineNotifierProvider)
                    ? "-"
                    : _outputMode.selectedNumberList[i].session == "open"
                        ? "-"
                        : _outputMode.selectedNumberList[i].points,
              "points":
                  int.parse(_outputMode.selectedNumberList[i].value.toString()),
              "game_mode": "single-digit",
              "market_id": marketId,
            },
        ];

        log(jsonDataArray.toList().map((e) => jsonEncode(e)).toString(),
            name: 'SingleDigitNewModel');
        PlayGameAllMarketModel? singleDigitNewModel =
            await ApiService().postPlayGameAllMarket(jsonDataArray.toList());
        if (singleDigitNewModel?.status == "success") {
          clearConfirmNumberList();
          AudioPlayer().play(AssetSource(bidsSound));
          EasyLoading.dismiss();
          if (context.mounted) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MainScreen()));
          }
        } else if (singleDigitNewModel?.status == "failure") {
          clearConfirmNumberList();
          EasyLoading.dismiss();
          if (context.mounted) {
            toast(context: context, singleDigitNewModel?.message ?? '');
          }
        }
      } catch (e) {
        EasyLoading.dismiss();
        log(e.toString(), name: 'SingleDigitNewModel');
      }
    } else {
      toast(context: context, 'Please select number and add points');
    }
  }

  // function total Number
  void totalAll() {
    _outputMode.totalPoints = _outputMode.selectedNumberList
        .fold(0, (a, b) => a! + int.parse(b.value!));
    _outputMode.totalSelectedNumber = _outputMode.selectedNumberList.length;

    _outputMode.leftPoints =
        (_outputMode.userParticularPlayer?.wallet)! - _outputMode.totalPoints!;

    state = AsyncData(_outputMode);
  }

  @override
  build() {
    _outputMode.leftPoints = _outputMode.userParticularPlayer?.wallet ?? 0;
    return _outputMode;
  }
}

class SingleDigitNewModel {
  TextEditingController? value;
  String? points;
  SingleDigitNewModel({this.points, this.value});
}

class SelectedSingleDigitNewModel {
  String? value;
  String? points;
  String? session;
  SelectedSingleDigitNewModel({this.session, this.points, this.value});
}
