import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/get_setting_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/features/games/jodi_digit/jodi_digit_list.dart';
import 'package:sm_project/features/home/main_screen.dart';
import 'package:sm_project/utils/filecollection.dart';

import '../../../controller/model/single_digit_model.dart';

final jodiDigitNotifierProvider =
    AsyncNotifierProvider.autoDispose<JodiDigitNotifier, JodiDigitMode>(() {
  return JodiDigitNotifier();
});

class JodiDigitMode {
  var userParticularPlayer = UserParticularPlayer.getParticularUserData();
  String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
  int? startDigit = 0;
  TextEditingController enteredPoints = TextEditingController(text: "");
  TextEditingController enteredNumber = TextEditingController(text: "");

  List<SelectedJodiModel> selectedNumberList = [];
  int? totalSelectedNumber = 0;
  int? totalPoints = 0;
  int? leftPoints;

  String? openDigit;
  String? closeDigit;

  GetSettingModel? getSettingModel = GetSettingModel();

  List<JodiDigitModel> jodiModel = [
    JodiDigitModel(value: TextEditingController()),
    JodiDigitModel(value: TextEditingController()),
    JodiDigitModel(value: TextEditingController()),
    JodiDigitModel(value: TextEditingController()),
    JodiDigitModel(value: TextEditingController()),
    JodiDigitModel(value: TextEditingController()),
    JodiDigitModel(value: TextEditingController()),
    JodiDigitModel(value: TextEditingController()),
    JodiDigitModel(value: TextEditingController()),
    JodiDigitModel(value: TextEditingController()),
  ];
}

class JodiDigitNotifier extends AutoDisposeAsyncNotifier<JodiDigitMode> {
  final JodiDigitMode _outputMode = JodiDigitMode();

  void updateEnteredPoints(String point) {
    _outputMode.enteredPoints.text = point;
  }

  void updateEnteredNumber(String value) {
    _outputMode.enteredNumber.text = value;
  }

  void setStartDigit(int number) {
    for (int i = 0; i < _outputMode.jodiModel.length; i++) {
      _outputMode.jodiModel[i].value?.text = '';
      _outputMode.jodiModel[i].points = '';
    }
    _outputMode.startDigit = number;
    state = AsyncData(_outputMode);
  }

  void addPoints(BuildContext context) async {
    try {
      FocusScope.of(context).unfocus();
      if (true) {
        if (!jodiDigitList.contains(_outputMode.enteredNumber.text)) {
          toast(context: context, "Jodi Number is Incorrect");
          return;
        }
      }
      EasyLoading.show(status: 'Loading...');
      _outputMode.getSettingModel = await ApiService().getSettingModel();
      int totalAddPoints = 0;

      // Design2 Change;
      totalAddPoints = _outputMode.enteredPoints.text.isEmpty
          ? 0
          : int.tryParse(_outputMode.enteredPoints.text) ?? 0;
      _outputMode.jodiModel.first = JodiDigitModel(
          value: TextEditingController(text: _outputMode.enteredPoints.text),
          points: _outputMode.enteredNumber.text);

      for (final element in _outputMode.jodiModel) {
        if (element.value?.text.trim().isNotEmpty ?? false) {
          totalAddPoints = int.tryParse(element.value?.text ?? '0') ?? 0;
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
      if (_outputMode.jodiModel
          .every((element) => element.points?.isEmpty ?? false)) {}
      if (_outputMode.jodiModel.isNotEmpty) {
        for (var element in _outputMode.jodiModel) {
          if (element.value?.text.trim() != '') {
            _outputMode.selectedNumberList.add(SelectedJodiModel(
                points: element.points, value: element.value?.text));
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
      log(e.toString(), name: 'jodiDigitModel');
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
    _outputMode.enteredNumber.clear();
    _outputMode.enteredPoints.clear();
    for (int i = 0; i < _outputMode.jodiModel.length; i++) {
      _outputMode.jodiModel[i].value?.text = '';
      _outputMode.jodiModel[i].points = '';
    }
    state = AsyncData(_outputMode);
  }

  void clearConfirmNumberList() {
    _outputMode.selectedNumberList.clear();
    totalAll();
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
              "session": "close",
              "tag": tag,
              "open_digit": _outputMode.selectedNumberList[i].points
                  ?.substring(0, 1)
                  .toString(),
              "close_digit": _outputMode.selectedNumberList[i].points
                  ?.substring(1, 2)
                  .toString(),
              "open_panna": "-",
              "close_panna": "-",
              "points":
                  int.parse(_outputMode.selectedNumberList[i].value.toString()),
              "game_mode": "double-digit",
              "market_id": marketId,
            },
        ];

        log(jsonDataArray.toList().toString(), name: 'jodiDigitModel');
        PlayGameAllMarketModel? jodiDigitModel =
            await ApiService().postPlayGameAllMarket(jsonDataArray.toList());
        if (jodiDigitModel?.status == "success") {
          if (context.mounted) {
            await ref
                .read(homeNotifierProvider.notifier)
                .getParticularPlayerModel(context);
            _outputMode.userParticularPlayer =
                UserParticularPlayer.getParticularUserData();
            _outputMode.leftPoints = _outputMode.userParticularPlayer?.wallet;
          }
          clearConfirmNumberList();
          AudioPlayer().play(AssetSource(bidsSound));
          EasyLoading.dismiss();
          if (context.mounted) {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MainScreen()));
          }
        } else if (jodiDigitModel?.status == "failure") {
          clearConfirmNumberList();
          EasyLoading.dismiss();
          if (context.mounted) {
            toast(context: context, jodiDigitModel?.message ?? '');
          }
        }
      } catch (e) {
        EasyLoading.dismiss();
        log(e.toString(), name: 'jodiDigitModel');
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

class JodiDigitModel {
  TextEditingController? value;
  String? points;
  JodiDigitModel({this.points, this.value});
}

class SelectedJodiModel {
  String? value;
  String? points;
  SelectedJodiModel({this.points, this.value});
}
