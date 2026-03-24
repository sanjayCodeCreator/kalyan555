import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/get_setting_model.dart';
import 'package:sm_project/controller/model/single_digit_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/home/main_screen.dart';
import 'package:sm_project/utils/filecollection.dart';

final fullSangamNotifierProvider =
    AsyncNotifierProvider.autoDispose<FullSangamNotifier, FullSangamMode>(() {
  return FullSangamNotifier();
});

class FullSangamMode {
  final userParticularPlayer = UserParticularPlayer.getParticularUserData();
  String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
  int? startDigit = 1;

  int? totalSelectedNumber = 0;
  int? totalOpenDigit = 0;
  int? totalClosePoints = 0;
  int? totalPoints = 0;
  int? leftPoints;

  TextEditingController? openPanaController = TextEditingController();
  TextEditingController? closePanaController = TextEditingController();
  TextEditingController? pointsController = TextEditingController();

  List<String> selectedOpenList = [];
  List<String> selectedCloseList = [];
  List<String> selectedPointsList = [];

  GetSettingModel? getSettingModel = GetSettingModel();
  final FocusNode openfocusNode = FocusNode();
  final FocusNode closefocusNode = FocusNode();
  final GlobalKey autocompleteKey = GlobalKey();

  List<String> pana = [
    //single Pana
    '120',
    '123',
    '124',
    '125',
    '126',
    '127',
    '128',
    '129',
    '130',
    '134',
    '135',
    '136',
    '137',
    '138',
    '139',
    '140',
    '145',
    '146',
    '147',
    '148',
    '149',
    '150',
    '156',
    '157',
    '158',
    '159',
    '160',
    '167',
    '168',
    '169',
    '170',
    '178',
    '179',
    '180',
    '189',
    '190',
    '230',
    '234',
    '235',
    '236',
    '237',
    '238',
    '239',
    '240',
    '245',
    '246',
    '247',
    '248',
    '249',
    '250',
    '256',
    '257',
    '258',
    '259',
    '260',
    '267',
    '268',
    '269',
    '270',
    '278',
    '279',
    '280',
    '289',
    '290',
    '340',
    '345',
    '346',
    '347',
    '348',
    '349',
    '350',
    '356',
    '357',
    '358',
    '359',
    '360',
    '367',
    '368',
    '369',
    '370',
    '378',
    '379',
    '380',
    '389',
    '390',
    '450',
    '456',
    '457',
    '458',
    '459',
    '460',
    '467',
    '468',
    '469',
    '470',
    '478',
    '479',
    '480',
    '489',
    '490',
    '560',
    '567',
    '568',
    '569',
    '570',
    '578',
    '579',
    '580',
    '589',
    '590',
    '670',
    '678',
    '679',
    '680',
    '689',
    '690',
    '780',
    '789',
    '790',
    '890',

    //Double Pana

    "100",
    "110",
    "112",
    "113",
    "114",
    "115",
    '116',
    '117',
    '118',
    '119',
    '122',
    '133',
    '144',
    '155',
    '166',
    '177',
    '188',
    '199',
    '200',
    '220',
    '223',
    '224',
    '225',
    '226',
    '227',
    '228',
    '229',
    '233',
    '244',
    '255',
    '266',
    '277',
    '288',
    '299',
    '300',
    '330',
    '334',
    '335',
    '336',
    '337',
    '338',
    '339',
    '344',
    '355',
    '366',
    '377',
    '388',
    '399',
    '400',
    '440',
    '445',
    '446',
    '447',
    '448',
    '449',
    '455',
    '466',
    '477',
    '488',
    '499',
    '500',
    '550',
    '556',
    '557',
    '558',
    '559',
    '566',
    '577',
    '588',
    '599',
    '600',
    '660',
    '667',
    '668',
    '669',
    '677',
    '688',
    '699',
    '700',
    '770',
    '778',
    '779',
    '788',
    '799',
    '800',
    '880',
    '889',
    '899',
    '900',
    '990',
    //Triple Pana
    '000',
    '111',
    '222',
    '333',
    '444',
    '555',
    '666',
    '777',
    '888',
    '999',
  ];
}

class FullSangamNotifier extends AutoDisposeAsyncNotifier<FullSangamMode> {
  final FullSangamMode _outputMode = FullSangamMode();

  void addPoints(BuildContext context) async {
    try {
      FocusScope.of(context).unfocus();
      EasyLoading.show(status: 'Loading...');
      _outputMode.getSettingModel = await ApiService().getSettingModel();

      int totalAddPoints = 0;

      if (_outputMode.pointsController!.text.trim() != '') {
        totalAddPoints = int.parse(_outputMode.pointsController!.text);
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
        clearAddNumberList();
        if (context.mounted) {
          toast(
              context: context,
              'Minimum bet amount is ${_outputMode.getSettingModel?.data?.betting?.min} and Maximum bet amount is ${_outputMode.getSettingModel?.data?.betting?.max}');
        }
        return;
      }

      if (!(_outputMode.pana.contains(_outputMode.openPanaController?.text))) {
        if (context.mounted) {
          toast(context: context, "Open Pana number is invalid.");
        }
        EasyLoading.dismiss();
        return;
      }
      if (!(_outputMode.pana.contains(_outputMode.closePanaController?.text))) {
        if (context.mounted) {
          toast(context: context, "Close Pana number is invalid.");
        }
        EasyLoading.dismiss();
        return;
      }

      if (_outputMode.openPanaController!.text.isNotEmpty &&
          _outputMode.closePanaController!.text.isNotEmpty &&
          _outputMode.pointsController!.text.isNotEmpty) {
        _outputMode.selectedOpenList.add(_outputMode.openPanaController!.text);
        _outputMode.selectedCloseList
            .add(_outputMode.closePanaController!.text);
        _outputMode.selectedPointsList.add(_outputMode.pointsController!.text);

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
      log(e.toString(), name: 'half-sangam');
    }
    EasyLoading.dismiss();
    clearAddNumberList();
    state = AsyncData(_outputMode);
  }

  void removePoints(BuildContext context, int index) {
    try {
      if (_outputMode.selectedCloseList != []) {
        _outputMode.selectedOpenList
            .remove(_outputMode.selectedOpenList.elementAt(index));
        _outputMode.selectedCloseList
            .remove(_outputMode.selectedCloseList.elementAt(index));
        _outputMode.selectedPointsList
            .remove(_outputMode.selectedPointsList.elementAt(index));

        totalAll();
      } else {
        toast(context: context, 'Please select number and add points');
      }
    } catch (e) {
      log(e.toString(), name: 'half-sangam');
    }

    state = AsyncData(_outputMode);
  }

  // Delete All
  void deleteAll(BuildContext context) {
    try {
      if (_outputMode.selectedPointsList != [] &&
          _outputMode.selectedCloseList != [] &&
          _outputMode.selectedOpenList != []) {
        _outputMode.selectedOpenList.clear();
        _outputMode.selectedCloseList.clear();
        _outputMode.selectedPointsList.clear();
        totalAll();
      } else {
        toast(context: context, 'Please select number and add points');
      }
    } catch (e) {
      log(e.toString(), name: 'half-sangam');
    }
    state = AsyncData(_outputMode);
  }

  // clear SelectedNumberList
  void clearAddNumberList() {
    try {
      _outputMode.openPanaController?.text = '';
      _outputMode.closePanaController?.text = '';
      _outputMode.pointsController?.text = '';
    } catch (e) {
      log(e.toString(), name: 'half-sangam');
    }
    state = AsyncData(_outputMode);
  }

  void clearConfirmNumberList() {
    try {
      _outputMode.selectedOpenList.clear();
      _outputMode.selectedCloseList.clear();
      _outputMode.selectedPointsList.clear();
    } catch (e) {
      log(e.toString(), name: 'half-sangam');
    }
    state = AsyncData(_outputMode);
  }

  void onSubmitConfirm(
      BuildContext context, String tag, String marketId) async {
    if (_outputMode.selectedOpenList.isNotEmpty &&
        _outputMode.selectedCloseList.isNotEmpty &&
        _outputMode.selectedPointsList.isNotEmpty) {
      try {
        EasyLoading.show(status: 'Loading...');
        List<Map<String, dynamic>> jsonDataArray = [
          for (int i = 0; i < _outputMode.selectedCloseList.length; i++)
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
              "open_digit": "-",
              "close_digit": "-",
              "open_panna": _outputMode.selectedOpenList[i].toString(),
              "close_panna": _outputMode.selectedCloseList[i].toString(),
              "points": int.parse(_outputMode.selectedPointsList[i].toString()),
              "game_mode": "full-sangam",
              "market_id": marketId,
            },
        ];

        log(jsonDataArray.toList().toString(), name: 'full-sangam');
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
        log(e.toString(), name: 'full-sangam');
      }
    } else {
      toast(context: context, 'Please select number and add points');
    }
  }

  // function total Number
  void totalAll() {
    _outputMode.totalOpenDigit = _outputMode.selectedOpenList.length;
    _outputMode.totalClosePoints = _outputMode.selectedCloseList.length;
    _outputMode.totalPoints =
        _outputMode.selectedPointsList.fold(0, (a, b) => a! + int.parse(b));

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

class HalfSangamModel {
  TextEditingController? value;
  String? points;
  HalfSangamModel({this.points, this.value});
}

class SelectedHalfSangamModel {
  String? value;
  String? points;
  SelectedHalfSangamModel({this.points, this.value});
}
