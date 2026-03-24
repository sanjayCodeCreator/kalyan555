import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/get_setting_model.dart';
import 'package:sm_project/controller/model/single_digit_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/games/kalyan_morning_notifier.dart';
import 'package:sm_project/features/home/main_screen.dart';
import 'package:sm_project/features/starline/starline_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

final triplePannaNotifierProvider =
    AsyncNotifierProvider.autoDispose<TriplePannaNotifier, TriplePannaMode>(() {
  return TriplePannaNotifier();
});

class TriplePannaMode {
  final userParticularPlayer = UserParticularPlayer.getParticularUserData();
  String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
  int? startDigit = 1;

  List<SelectedTriplePannaModel> selectedNumberList = [];
  int? totalSelectedNumber = 0;
  int? totalPoints = 0;
  int? leftPoints;

  GetSettingModel? getSettingModel = GetSettingModel();

  List<TriplePannaModel> triplePannaModel = [
    TriplePannaModel(value: TextEditingController()),
    TriplePannaModel(value: TextEditingController()),
    TriplePannaModel(value: TextEditingController()),
    TriplePannaModel(value: TextEditingController()),
    TriplePannaModel(value: TextEditingController()),
    TriplePannaModel(value: TextEditingController()),
    TriplePannaModel(value: TextEditingController()),
    TriplePannaModel(value: TextEditingController()),
    TriplePannaModel(value: TextEditingController()),
    TriplePannaModel(value: TextEditingController()),
  ];

  List<TriplePannaModel> numbers = [
    TriplePannaModel(value: TextEditingController(), points: '000'),
    TriplePannaModel(value: TextEditingController(), points: '666'),
    TriplePannaModel(value: TextEditingController(), points: '111'),
    TriplePannaModel(value: TextEditingController(), points: '777'),
    TriplePannaModel(value: TextEditingController(), points: '222'),
    TriplePannaModel(value: TextEditingController(), points: '888'),
    TriplePannaModel(value: TextEditingController(), points: '333'),
    TriplePannaModel(value: TextEditingController(), points: '999'),
    TriplePannaModel(value: TextEditingController(), points: '444'),
    TriplePannaModel(value: TextEditingController(), points: '555'),
  ];
}

class TriplePannaNotifier extends AutoDisposeAsyncNotifier<TriplePannaMode> {
  final TriplePannaMode _outputMode = TriplePannaMode();

  void addPoints(BuildContext context) async {
    try {
      FocusScope.of(context).unfocus();
      EasyLoading.show(status: 'Loading...');
      _outputMode.getSettingModel = await ApiService().getSettingModel();
      int totalAddPoints = 0;
      for (var element in _outputMode.numbers) {
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

      if (_outputMode.numbers.isNotEmpty) {
        for (var element in _outputMode.numbers) {
          if (element.value?.text.trim() != '') {
            _outputMode.selectedNumberList.add(SelectedTriplePannaModel(
                points: element.points,
                value: element.value?.text,
                isClosed:
                    (ref.watch(kalyanMorningNotifierProvider).value?.isClose ??
                        false)));
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
      log(e.toString(), name: 'triple-pana');
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
      totalAll();
    } else {
      toast(context: context, 'Please select number and add points');
    }
    state = AsyncData(_outputMode);
  }

  // // // clear selectedNumberList
  void clearSelectedNumberList() {
    for (int i = 0; i < _outputMode.numbers.length; i++) {
      _outputMode.numbers[i].value?.text = '';
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
                  : _outputMode.selectedNumberList[i].isClosed ?? false
                      ? "close"
                      : "open",
              "tag": tag,
              "open_digit": "-",
              "close_digit": "-",
              "open_panna": ref.watch(starlineNotifierProvider)
                  ? (_outputMode.selectedNumberList[i].points ?? '-')
                  : _outputMode.selectedNumberList[i].isClosed ?? false
                      ? "-"
                      : _outputMode.selectedNumberList[i].points ?? '-',
              "close_panna": ref.watch(starlineNotifierProvider)
                  ? "-"
                  : _outputMode.selectedNumberList[i].isClosed ?? false
                      ? _outputMode.selectedNumberList[i].points ?? '-'
                      : "-",
              "points":
                  int.parse(_outputMode.selectedNumberList[i].value.toString()),
              "game_mode": "triple-panna",
              "market_id": marketId
            },
        ];

        log(jsonDataArray.toList().toString(), name: 'triple-pana');
        PlayGameAllMarketModel? singlePanaModel =
            await ApiService().postPlayGameAllMarket(jsonDataArray.toList());
        if (singlePanaModel?.status == "success") {
          AudioPlayer().play(AssetSource(bidsSound));
          clearConfirmNumberList();
          EasyLoading.dismiss();
          if (context.mounted) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MainScreen()));
          }
        } else if (singlePanaModel?.status == "failure") {
          clearConfirmNumberList();
          EasyLoading.dismiss();
          if (context.mounted) {
            toast(context: context, singlePanaModel?.message ?? '');
          }
        }
      } catch (e) {
        EasyLoading.dismiss();
        log(e.toString(), name: 'triple-pana');
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

class TriplePannaModel {
  TextEditingController? value;
  String? points;
  TriplePannaModel({this.points, this.value});
}

class SelectedTriplePannaModel {
  String? value;
  String? points;
  bool? isClosed;
  SelectedTriplePannaModel({this.points, this.value, this.isClosed});
}
