import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/get_setting_model.dart';
import 'package:sm_project/controller/model/single_digit_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/features/games/double_panna/double_panna_digit.dart';
import 'package:sm_project/features/games/kalyan_morning_notifier.dart';
import 'package:sm_project/features/home/main_screen.dart';
import 'package:sm_project/features/starline/starline_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

final doublePannaNotifierProvider =
    AsyncNotifierProvider.autoDispose<DoublePannaNotifier, DoublePannaMode>(() {
  return DoublePannaNotifier();
});

class DoublePannaMode {
  var userParticularPlayer = UserParticularPlayer.getParticularUserData();
  String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
  int? startDigit = 1;
  TextEditingController enteredPoints = TextEditingController(text: "");
  TextEditingController enteredNumber = TextEditingController(text: "");

  List<SelectedDoublePannaModel> selectedNumberList = [];
  int? totalSelectedNumber = 0;
  int? totalPoints = 0;
  int? leftPoints;

  GetSettingModel? getSettingModel = GetSettingModel();

  List<DoublePannaModel> doublePannaModel = [
    DoublePannaModel(value: TextEditingController()),
    DoublePannaModel(value: TextEditingController()),
    DoublePannaModel(value: TextEditingController()),
    DoublePannaModel(value: TextEditingController()),
    DoublePannaModel(value: TextEditingController()),
    DoublePannaModel(value: TextEditingController()),
    DoublePannaModel(value: TextEditingController()),
    DoublePannaModel(value: TextEditingController()),
    DoublePannaModel(value: TextEditingController()),
    DoublePannaModel(value: TextEditingController()),
  ];

  List<DoublePannaModel> getdoublePannaModel() {
    switch (startDigit) {
      case 1:
        return dynamicPoints01;
      case 2:
        return dynamicPoints02;
      case 3:
        return dynamicPoints03;
      case 4:
        return dynamicPoints04;
      case 5:
        return dynamicPoints05;
      case 6:
        return dynamicPoints06;
      case 7:
        return dynamicPoints07;
      case 8:
        return dynamicPoints08;
      case 9:
        return dynamicPoints09;
      default:
        return dynamicPoints01;
    }
  }

  // Double digit 01
  List<DoublePannaModel> dynamicPoints01 = [
    DoublePannaModel(value: TextEditingController(), points: '100'),
    DoublePannaModel(value: TextEditingController(), points: '110'),
    DoublePannaModel(value: TextEditingController(), points: '112'),
    DoublePannaModel(value: TextEditingController(), points: '113'),
    DoublePannaModel(value: TextEditingController(), points: '114'),
    DoublePannaModel(value: TextEditingController(), points: '115'),
    DoublePannaModel(value: TextEditingController(), points: '116'),
    DoublePannaModel(value: TextEditingController(), points: '117'),
    DoublePannaModel(value: TextEditingController(), points: '118'),
    DoublePannaModel(value: TextEditingController(), points: '119'),
    DoublePannaModel(value: TextEditingController(), points: '122'),
    DoublePannaModel(value: TextEditingController(), points: '133'),
    DoublePannaModel(value: TextEditingController(), points: '144'),
    DoublePannaModel(value: TextEditingController(), points: '155'),
    DoublePannaModel(value: TextEditingController(), points: '166'),
    DoublePannaModel(value: TextEditingController(), points: '177'),
    DoublePannaModel(value: TextEditingController(), points: '188'),
    DoublePannaModel(value: TextEditingController(), points: '199'),
  ];

  // Double digit 02
  List<DoublePannaModel> dynamicPoints02 = [
    DoublePannaModel(value: TextEditingController(), points: '200'),
    DoublePannaModel(value: TextEditingController(), points: '220'),
    DoublePannaModel(value: TextEditingController(), points: '223'),
    DoublePannaModel(value: TextEditingController(), points: '224'),
    DoublePannaModel(value: TextEditingController(), points: '225'),
    DoublePannaModel(value: TextEditingController(), points: '226'),
    DoublePannaModel(value: TextEditingController(), points: '227'),
    DoublePannaModel(value: TextEditingController(), points: '228'),
    DoublePannaModel(value: TextEditingController(), points: '229'),
    DoublePannaModel(value: TextEditingController(), points: '233'),
    DoublePannaModel(value: TextEditingController(), points: '244'),
    DoublePannaModel(value: TextEditingController(), points: '255'),
    DoublePannaModel(value: TextEditingController(), points: '266'),
    DoublePannaModel(value: TextEditingController(), points: '277'),
    DoublePannaModel(value: TextEditingController(), points: '288'),
    DoublePannaModel(value: TextEditingController(), points: '299'),
  ];

  // Double digit 03
  List<DoublePannaModel> dynamicPoints03 = [
    DoublePannaModel(value: TextEditingController(), points: '300'),
    DoublePannaModel(value: TextEditingController(), points: '330'),
    DoublePannaModel(value: TextEditingController(), points: '334'),
    DoublePannaModel(value: TextEditingController(), points: '335'),
    DoublePannaModel(value: TextEditingController(), points: '336'),
    DoublePannaModel(value: TextEditingController(), points: '337'),
    DoublePannaModel(value: TextEditingController(), points: '338'),
    DoublePannaModel(value: TextEditingController(), points: '339'),
    DoublePannaModel(value: TextEditingController(), points: '344'),
    DoublePannaModel(value: TextEditingController(), points: '355'),
    DoublePannaModel(value: TextEditingController(), points: '366'),
    DoublePannaModel(value: TextEditingController(), points: '377'),
    DoublePannaModel(value: TextEditingController(), points: '388'),
    DoublePannaModel(value: TextEditingController(), points: '399'),
  ];

  // Double digit 04
  List<DoublePannaModel> dynamicPoints04 = [
    DoublePannaModel(value: TextEditingController(), points: '400'),
    DoublePannaModel(value: TextEditingController(), points: '440'),
    DoublePannaModel(value: TextEditingController(), points: '445'),
    DoublePannaModel(value: TextEditingController(), points: '446'),
    DoublePannaModel(value: TextEditingController(), points: '447'),
    DoublePannaModel(value: TextEditingController(), points: '448'),
    DoublePannaModel(value: TextEditingController(), points: '449'),
    DoublePannaModel(value: TextEditingController(), points: '455'),
    DoublePannaModel(value: TextEditingController(), points: '466'),
    DoublePannaModel(value: TextEditingController(), points: '477'),
    DoublePannaModel(value: TextEditingController(), points: '488'),
    DoublePannaModel(value: TextEditingController(), points: '499'),
  ];

  // Double digit 05
  List<DoublePannaModel> dynamicPoints05 = [
    DoublePannaModel(value: TextEditingController(), points: '500'),
    DoublePannaModel(value: TextEditingController(), points: '550'),
    DoublePannaModel(value: TextEditingController(), points: '556'),
    DoublePannaModel(value: TextEditingController(), points: '557'),
    DoublePannaModel(value: TextEditingController(), points: '558'),
    DoublePannaModel(value: TextEditingController(), points: '559'),
    DoublePannaModel(value: TextEditingController(), points: '566'),
    DoublePannaModel(value: TextEditingController(), points: '577'),
    DoublePannaModel(value: TextEditingController(), points: '588'),
    DoublePannaModel(value: TextEditingController(), points: '599'),
  ];

  // Double digit 06
  List<DoublePannaModel> dynamicPoints06 = [
    DoublePannaModel(value: TextEditingController(), points: '600'),
    DoublePannaModel(value: TextEditingController(), points: '660'),
    DoublePannaModel(value: TextEditingController(), points: '667'),
    DoublePannaModel(value: TextEditingController(), points: '668'),
    DoublePannaModel(value: TextEditingController(), points: '669'),
    DoublePannaModel(value: TextEditingController(), points: '677'),
    DoublePannaModel(value: TextEditingController(), points: '688'),
    DoublePannaModel(value: TextEditingController(), points: '699')
  ];

  // Double digit 07
  List<DoublePannaModel> dynamicPoints07 = [
    DoublePannaModel(value: TextEditingController(), points: '700'),
    DoublePannaModel(value: TextEditingController(), points: '770'),
    DoublePannaModel(value: TextEditingController(), points: '778'),
    DoublePannaModel(value: TextEditingController(), points: '779'),
    DoublePannaModel(value: TextEditingController(), points: '788'),
    DoublePannaModel(value: TextEditingController(), points: '799'),
  ];

  // Double digit 08
  List<DoublePannaModel> dynamicPoints08 = [
    DoublePannaModel(value: TextEditingController(), points: '800'),
    DoublePannaModel(value: TextEditingController(), points: '880'),
    DoublePannaModel(value: TextEditingController(), points: '889'),
    DoublePannaModel(value: TextEditingController(), points: '899'),
  ];

  // Double digit 09
  List<DoublePannaModel> dynamicPoints09 = [
    DoublePannaModel(value: TextEditingController(), points: '900'),
    DoublePannaModel(value: TextEditingController(), points: '990'),
  ];
}

class DoublePannaNotifier extends AutoDisposeAsyncNotifier<DoublePannaMode> {
  final DoublePannaMode _outputMode = DoublePannaMode();

  void updateEnteredPoints(String point) {
    _outputMode.enteredPoints.text = point;
  }

  void updateEnteredNumber(String value) {
    _outputMode.enteredNumber.text = value;
  }

  void setStartDigit(int number) {
    for (int i = 0; i < _outputMode.getdoublePannaModel().length; i++) {
      _outputMode.getdoublePannaModel()[i].value?.text = '';
    }
    _outputMode.startDigit = number;
    state = AsyncData(_outputMode);
  }

  void addPoints(BuildContext context) async {
    FocusScope.of(context).unfocus();
    try {
      FocusScope.of(context).unfocus();
      if (true) {
        if (!doublePannaList.contains(_outputMode.enteredNumber.text)) {
          toast(context: context, "Panna Number is Incorrect");
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
      _outputMode.doublePannaModel.first = DoublePannaModel(
          value: TextEditingController(text: _outputMode.enteredPoints.text),
          points: _outputMode.enteredNumber.text);
      if (true) {
        for (var element in _outputMode.doublePannaModel) {
          if (element.value?.text.trim() != '') {
            totalAddPoints = int.parse(element.value?.text ?? '0');
          }
        }
      } else {
        _outputMode.getdoublePannaModel().forEach((element) {
          if (element.value?.text.trim() != '') {
            totalAddPoints = int.parse(element.value?.text ?? '0');
          }
        });
      }
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
        if (context.mounted) {
          toast(
              context: context,
              'Minimum bet amount is ${_outputMode.getSettingModel?.data?.betting?.min} and Maximum bet amount is ${_outputMode.getSettingModel?.data?.betting?.max}');
        }
        return;
      }
      if (true) {
        if (_outputMode.doublePannaModel.isNotEmpty) {
          for (var element in _outputMode.doublePannaModel) {
            if (element.value?.text.trim() != '') {
              _outputMode.selectedNumberList.add(SelectedDoublePannaModel(
                  points: element.points, value: element.value?.text));
            }
          }
          totalAll();
          EasyLoading.dismiss();
        } else {
          EasyLoading.dismiss();
          if (context.mounted) {
            toast(context: context, 'Please select number and add points');
          }
        }
      } else if (_outputMode.getdoublePannaModel().isNotEmpty) {
        _outputMode.getdoublePannaModel().forEach((element) {
          if (element.value?.text.trim() != '') {
            _outputMode.selectedNumberList.add(SelectedDoublePannaModel(
                points: element.points, value: element.value?.text));
          }
        });
        totalAll();
        EasyLoading.dismiss();
      } else {
        EasyLoading.dismiss();
        if (context.mounted) {
          toast(context: context, 'Please select number and add points');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'double-pana');
    }

    clearselectedNumberList();
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

  // // Delete All
  void deleteAll(BuildContext context) {
    if (_outputMode.selectedNumberList != []) {
      _outputMode.selectedNumberList.clear();
      totalAll();
    } else {
      toast(context: context, 'Please select number and add points');
    }
    state = AsyncData(_outputMode);
  }

  // // clear selectedNumberList
  void clearselectedNumberList() {
    if (true) {
      _outputMode.enteredNumber.clear();
      _outputMode.enteredPoints.clear();
      for (int i = 0; i < _outputMode.doublePannaModel.length; i++) {
        _outputMode.doublePannaModel[i].value?.text = '';
      }
    } else {
      for (int i = 0; i < _outputMode.getdoublePannaModel().length; i++) {
        _outputMode.getdoublePannaModel()[i].value?.text = '';
      }
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
              "session": ref.watch(starlineNotifierProvider)
                  ? "open"
                  : (ref.watch(kalyanMorningNotifierProvider).value?.isClose ??
                          false)
                      ? "close"
                      : "open",
              "tag": tag,
              "open_digit": "-",
              "close_digit": "-",
              "open_panna": ref.watch(starlineNotifierProvider)
                  ? (_outputMode.selectedNumberList[i].points ?? '')
                  : (ref.watch(kalyanMorningNotifierProvider).value?.isClose ??
                          false)
                      ? "-"
                      : _outputMode.selectedNumberList[i].points ?? '-',
              "close_panna": ref.watch(starlineNotifierProvider)
                  ? "-"
                  : (ref.watch(kalyanMorningNotifierProvider).value?.isClose ??
                          false)
                      ? _outputMode.selectedNumberList[i].points ?? '-'
                      : "-",
              "points":
                  int.parse(_outputMode.selectedNumberList[i].value.toString()),
              "game_mode": "double-panna",
              "market_id": marketId,
            },
        ];

        log(jsonDataArray.toList().toString(), name: 'double-pana');
        PlayGameAllMarketModel? singlePanaModel =
            await ApiService().postPlayGameAllMarket(jsonDataArray.toList());
        if (singlePanaModel?.status == "success") {
          AudioPlayer().play(AssetSource(bidsSound));
          if (context.mounted) {
            await ref
                .read(homeNotifierProvider.notifier)
                .getParticularPlayerModel(context);
            _outputMode.userParticularPlayer =
                UserParticularPlayer.getParticularUserData();
            _outputMode.leftPoints = _outputMode.userParticularPlayer?.wallet;
          }
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
        log(e.toString(), name: 'double-pana');
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

class DoublePannaModel {
  TextEditingController? value;
  String? points;
  DoublePannaModel({this.points, this.value});
}

class SelectedDoublePannaModel {
  String? value;
  String? points;
  SelectedDoublePannaModel({this.points, this.value});
}
