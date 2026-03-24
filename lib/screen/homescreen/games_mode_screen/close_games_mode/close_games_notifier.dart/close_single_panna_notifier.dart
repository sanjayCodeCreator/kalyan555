// import 'dart:developer';

// import 'package:intl/intl.dart';
// import 'package:sm_project/controller/local/user_particular_player.dart';
// import 'package:sm_project/controller/model/get_setting_model.dart';
// import 'package:sm_project/controller/model/single_digit_model.dart';
// import 'package:sm_project/utils/filecollection.dart';

// final closeSinglePannaNotifierProvider = AsyncNotifierProvider.autoDispose<
//     CloseSinglePannaNotifier, CloseSinglePannaMode>(() {
//   return CloseSinglePannaNotifier();
// });

// class CloseSinglePannaMode {
//   final userParticularPlayer = UserParticularPlayer.getParticularUserData();
//   String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
//   int? startDigit = 1;

//   List<SelectedSinglePannaModel> SelectedNumberList = [];
//   int? totalSelectedNumber = 0;
//   int? totalPoints = 0;
//   int? leftPoints;

//   GetSettingModel? getSettingModel = GetSettingModel();

//   List<SinglePannaModel> singlePannaModel = [
//     SinglePannaModel(value: TextEditingController()),
//     SinglePannaModel(value: TextEditingController()),
//     SinglePannaModel(value: TextEditingController()),
//     SinglePannaModel(value: TextEditingController()),
//     SinglePannaModel(value: TextEditingController()),
//     SinglePannaModel(value: TextEditingController()),
//     SinglePannaModel(value: TextEditingController()),
//     SinglePannaModel(value: TextEditingController()),
//     SinglePannaModel(value: TextEditingController()),
//     SinglePannaModel(value: TextEditingController()),
//   ];

//   List<SinglePannaModel> getSinglePannaModel() {
//     switch (startDigit) {
//       case 1:
//         return dynamicPoints01;
//       case 2:
//         return dynamicPoints02;
//       case 3:
//         return dynamicPoints03;
//       case 4:
//         return dynamicPoints04;
//       case 5:
//         return dynamicPoints05;
//       case 6:
//         return dynamicPoints06;
//       case 7:
//         return dynamicPoints07;
//       case 8:
//         return dynamicPoints08;
//       default:
//         return dynamicPoints01;
//     }
//   }

//   // Single Pana 01

//   List<SinglePannaModel> dynamicPoints01 = [
//     SinglePannaModel(value: TextEditingController(), points: '120'),
//     SinglePannaModel(value: TextEditingController(), points: '123'),
//     SinglePannaModel(value: TextEditingController(), points: '124'),
//     SinglePannaModel(value: TextEditingController(), points: '125'),
//     SinglePannaModel(value: TextEditingController(), points: '126'),
//     SinglePannaModel(value: TextEditingController(), points: '127'),
//     SinglePannaModel(value: TextEditingController(), points: '128'),
//     SinglePannaModel(value: TextEditingController(), points: '129'),
//     SinglePannaModel(value: TextEditingController(), points: '130'),
//     SinglePannaModel(value: TextEditingController(), points: '134'),
//     SinglePannaModel(value: TextEditingController(), points: '135'),
//     SinglePannaModel(value: TextEditingController(), points: '136'),
//     SinglePannaModel(value: TextEditingController(), points: '137'),
//     SinglePannaModel(value: TextEditingController(), points: '138'),
//     SinglePannaModel(value: TextEditingController(), points: '139'),
//     SinglePannaModel(value: TextEditingController(), points: '140'),
//     SinglePannaModel(value: TextEditingController(), points: '145'),
//     SinglePannaModel(value: TextEditingController(), points: '146'),
//     SinglePannaModel(value: TextEditingController(), points: '147'),
//     SinglePannaModel(value: TextEditingController(), points: '148'),
//     SinglePannaModel(value: TextEditingController(), points: '149'),
//     SinglePannaModel(value: TextEditingController(), points: '150'),
//     SinglePannaModel(value: TextEditingController(), points: '156'),
//     SinglePannaModel(value: TextEditingController(), points: '157'),
//     SinglePannaModel(value: TextEditingController(), points: '158'),
//     SinglePannaModel(value: TextEditingController(), points: '159'),
//     SinglePannaModel(value: TextEditingController(), points: '160'),
//     SinglePannaModel(value: TextEditingController(), points: '167'),
//     SinglePannaModel(value: TextEditingController(), points: '168'),
//     SinglePannaModel(value: TextEditingController(), points: '169'),
//     SinglePannaModel(value: TextEditingController(), points: '170'),
//     SinglePannaModel(value: TextEditingController(), points: '178'),
//     SinglePannaModel(value: TextEditingController(), points: '179'),
//     SinglePannaModel(value: TextEditingController(), points: '180'),
//     SinglePannaModel(value: TextEditingController(), points: '189'),
//     SinglePannaModel(value: TextEditingController(), points: '190'),
//   ];

// // Single Pana 02
//   List<SinglePannaModel> dynamicPoints02 = [
//     SinglePannaModel(value: TextEditingController(), points: '230'),
//     SinglePannaModel(value: TextEditingController(), points: '234'),
//     SinglePannaModel(value: TextEditingController(), points: '235'),
//     SinglePannaModel(value: TextEditingController(), points: '236'),
//     SinglePannaModel(value: TextEditingController(), points: '237'),
//     SinglePannaModel(value: TextEditingController(), points: '238'),
//     SinglePannaModel(value: TextEditingController(), points: '239'),
//     SinglePannaModel(value: TextEditingController(), points: '240'),
//     SinglePannaModel(value: TextEditingController(), points: '245'),
//     SinglePannaModel(value: TextEditingController(), points: '246'),
//     SinglePannaModel(value: TextEditingController(), points: '247'),
//     SinglePannaModel(value: TextEditingController(), points: '248'),
//     SinglePannaModel(value: TextEditingController(), points: '249'),
//     SinglePannaModel(value: TextEditingController(), points: '250'),
//     SinglePannaModel(value: TextEditingController(), points: '256'),
//     SinglePannaModel(value: TextEditingController(), points: '257'),
//     SinglePannaModel(value: TextEditingController(), points: '258'),
//     SinglePannaModel(value: TextEditingController(), points: '259'),
//     SinglePannaModel(value: TextEditingController(), points: '260'),
//     SinglePannaModel(value: TextEditingController(), points: '267'),
//     SinglePannaModel(value: TextEditingController(), points: '268'),
//     SinglePannaModel(value: TextEditingController(), points: '269'),
//     SinglePannaModel(value: TextEditingController(), points: '270'),
//     SinglePannaModel(value: TextEditingController(), points: '278'),
//     SinglePannaModel(value: TextEditingController(), points: '279'),
//     SinglePannaModel(value: TextEditingController(), points: '280'),
//     SinglePannaModel(value: TextEditingController(), points: '289'),
//     SinglePannaModel(value: TextEditingController(), points: '290'),
//   ];

// // Single Pana 03
//   List<SinglePannaModel> dynamicPoints03 = [
//     SinglePannaModel(value: TextEditingController(), points: '340'),
//     SinglePannaModel(value: TextEditingController(), points: '345'),
//     SinglePannaModel(value: TextEditingController(), points: '346'),
//     SinglePannaModel(value: TextEditingController(), points: '347'),
//     SinglePannaModel(value: TextEditingController(), points: '348'),
//     SinglePannaModel(value: TextEditingController(), points: '349'),
//     SinglePannaModel(value: TextEditingController(), points: '350'),
//     SinglePannaModel(value: TextEditingController(), points: '356'),
//     SinglePannaModel(value: TextEditingController(), points: '357'),
//     SinglePannaModel(value: TextEditingController(), points: '358'),
//     SinglePannaModel(value: TextEditingController(), points: '359'),
//     SinglePannaModel(value: TextEditingController(), points: '360'),
//     SinglePannaModel(value: TextEditingController(), points: '367'),
//     SinglePannaModel(value: TextEditingController(), points: '368'),
//     SinglePannaModel(value: TextEditingController(), points: '369'),
//     SinglePannaModel(value: TextEditingController(), points: '370'),
//     SinglePannaModel(value: TextEditingController(), points: '378'),
//     SinglePannaModel(value: TextEditingController(), points: '379'),
//     SinglePannaModel(value: TextEditingController(), points: '380'),
//     SinglePannaModel(value: TextEditingController(), points: '389'),
//     SinglePannaModel(value: TextEditingController(), points: '390'),
//   ];

// // Single Pana 04
//   List<SinglePannaModel> dynamicPoints04 = [
//     SinglePannaModel(value: TextEditingController(), points: '450'),
//     SinglePannaModel(value: TextEditingController(), points: '456'),
//     SinglePannaModel(value: TextEditingController(), points: '457'),
//     SinglePannaModel(value: TextEditingController(), points: '458'),
//     SinglePannaModel(value: TextEditingController(), points: '459'),
//     SinglePannaModel(value: TextEditingController(), points: '460'),
//     SinglePannaModel(value: TextEditingController(), points: '467'),
//     SinglePannaModel(value: TextEditingController(), points: '468'),
//     SinglePannaModel(value: TextEditingController(), points: '469'),
//     SinglePannaModel(value: TextEditingController(), points: '470'),
//     SinglePannaModel(value: TextEditingController(), points: '478'),
//     SinglePannaModel(value: TextEditingController(), points: '479'),
//     SinglePannaModel(value: TextEditingController(), points: '480'),
//     SinglePannaModel(value: TextEditingController(), points: '489'),
//     SinglePannaModel(value: TextEditingController(), points: '490'),
//   ];

// // Single Pana 05
//   List<SinglePannaModel> dynamicPoints05 = [
//     SinglePannaModel(value: TextEditingController(), points: '560'),
//     SinglePannaModel(value: TextEditingController(), points: '567'),
//     SinglePannaModel(value: TextEditingController(), points: '568'),
//     SinglePannaModel(value: TextEditingController(), points: '569'),
//     SinglePannaModel(value: TextEditingController(), points: '570'),
//     SinglePannaModel(value: TextEditingController(), points: '578'),
//     SinglePannaModel(value: TextEditingController(), points: '579'),
//     SinglePannaModel(value: TextEditingController(), points: '580'),
//     SinglePannaModel(value: TextEditingController(), points: '589'),
//     SinglePannaModel(value: TextEditingController(), points: '590'),
//   ];

// // Single Pana 06
//   List<SinglePannaModel> dynamicPoints06 = [
//     SinglePannaModel(value: TextEditingController(), points: '670'),
//     SinglePannaModel(value: TextEditingController(), points: '678'),
//     SinglePannaModel(value: TextEditingController(), points: '679'),
//     SinglePannaModel(value: TextEditingController(), points: '680'),
//     SinglePannaModel(value: TextEditingController(), points: '689'),
//     SinglePannaModel(value: TextEditingController(), points: '690'),
//   ];

// // Single Pana 07
//   List<SinglePannaModel> dynamicPoints07 = [
//     SinglePannaModel(value: TextEditingController(), points: '780'),
//     SinglePannaModel(value: TextEditingController(), points: '789'),
//     SinglePannaModel(value: TextEditingController(), points: '790'),
//   ];

// // Single Pana 08
//   List<SinglePannaModel> dynamicPoints08 = [
//     SinglePannaModel(value: TextEditingController(), points: '890'),
//   ];
// }

// class CloseSinglePannaNotifier
//     extends AutoDisposeAsyncNotifier<CloseSinglePannaMode> {
//   final CloseSinglePannaMode _outputMode = CloseSinglePannaMode();

//   void setStartDigit(int number) {
//     for (int i = 0; i < _outputMode.getSinglePannaModel().length; i++) {
//       _outputMode.getSinglePannaModel()[i].value?.text = '';
//     }
//     _outputMode.startDigit = number;
//     state = AsyncData(_outputMode);
//   }

//   void addPoints() async {
//     try {
//       EasyLoading.show(status: 'Loading...');
//       _outputMode.getSettingModel = await ApiService().getSettingModel();

//       int totalAddPoints = 0;
//       _outputMode.getSinglePannaModel().forEach((element) {
//         if (element.value?.text.trim() != '') {
//           totalAddPoints = int.parse(element.value?.text ?? '0');
//         }
//       });
//       if (totalAddPoints == 0) {
//         EasyLoading.dismiss();
//         toast('Invalid enter number');
//         return;
//       } else if ((_outputMode.leftPoints ?? -1) < totalAddPoints ||
//           totalAddPoints == 0) {
//         EasyLoading.dismiss();
//         toast('Wallet Amount is Low');
//         return;
//       } else if ((_outputMode.getSettingModel?.data?.betting?.min ?? 0) >
//               totalAddPoints ||
//           (_outputMode.getSettingModel?.data?.betting?.max ?? 0) <
//               totalAddPoints) {
//         EasyLoading.dismiss();
//         clearSelectedNumberList();
//         toast(
//             'Minimum bet amount is ${_outputMode.getSettingModel?.data?.betting?.min} and Maximum bet amount is ${_outputMode.getSettingModel?.data?.betting?.max}');
//         return;
//       }
//       if (_outputMode.singlePannaModel.isNotEmpty) {
//         _outputMode.getSinglePannaModel().forEach((element) {
//           if (element.value?.text.trim() != '') {
//             _outputMode.SelectedNumberList.add(SelectedSinglePannaModel(
//                 points: element.points, value: element.value?.text));
//           }
//         });
//         totalAll();
//         EasyLoading.dismiss();
//       } else {
//         EasyLoading.dismiss();
//         toast('Please select number and add points');
//       }
//     } catch (e) {
//       EasyLoading.dismiss();
//       log(e.toString(), name: 'single-pana');
//     }

//     clearSelectedNumberList();
//     state = AsyncData(_outputMode);
//   }

//   void removePoints(int index) {
//     if (_outputMode.SelectedNumberList != []) {
//       _outputMode.SelectedNumberList.remove(
//           _outputMode.SelectedNumberList.elementAt(index));

//       totalAll();
//       print(_outputMode.SelectedNumberList);
//     } else {
//       toast('Please select number and add points');
//     }
//     state = AsyncData(_outputMode);
//   }

//   // Delete All
//   void deleteAll() {
//     if (_outputMode.SelectedNumberList != []) {
//       _outputMode.SelectedNumberList.clear();
//       totalAll();
//     } else {
//       toast('Please select number and add points');
//     }
//     state = AsyncData(_outputMode);
//   }

//   // clear SelectedNumberList
//   void clearSelectedNumberList() {
//     for (int i = 0; i < _outputMode.getSinglePannaModel().length; i++) {
//       _outputMode.getSinglePannaModel()[i].value?.text = '';
//     }
//     state = AsyncData(_outputMode);
//   }

//   void clearConfirmNumberList() {
//     _outputMode.SelectedNumberList.clear();
//     state = AsyncData(_outputMode);
//   }

//   void onSubmitConfirm(
//       BuildContext context, String tag, String marketId) async {
//     if (_outputMode.SelectedNumberList.isNotEmpty) {
//       try {
//         EasyLoading.show(status: 'Loading...');
//         List<Map<String, dynamic>> jsonDataArray = [
//           for (int i = 0; i < _outputMode.SelectedNumberList.length; i++)
//             {
//               "session": "close",
//               "tag": tag,
//               "open_digit": "",
//               "close_digit": "",
//               "open_panna": "",
//               "close_panna": _outputMode.SelectedNumberList[i].points ?? '',
//               "points": _outputMode.SelectedNumberList[i].value.toString(),
//               "game_mode": "single-pana",
//               "market": marketId,
//             },
//         ];

//         log(jsonDataArray.toList().toString(), name: 'single-pana');
//         PlayGameAllMarketModel? singlePanaModel =
//             await ApiService().postPlayGameAllMarket(jsonDataArray.toList());
//         if (singlePanaModel?.status == "success") {
//           AudioPlayer().play(AssetSource(bidsSound));
//           clearConfirmNumberList();
//           EasyLoading.dismiss();
//         context.pushReplacementNamed(RouteNames.homeScreen);
//           toast(singlePanaModel?.message ?? '');
//         } else if (singlePanaModel?.status == "failure") {
//           clearConfirmNumberList();
//           EasyLoading.dismiss();
//           toast(singlePanaModel?.message ?? '');
//         }
//       } catch (e) {
//         EasyLoading.dismiss();
//         log(e.toString(), name: 'single-pana');
//       }
//     } else {
//       toast('Please select number and add points');
//     }
//   }

//   // function total Number
//   void totalAll() {
//     _outputMode.totalPoints = _outputMode.SelectedNumberList.fold(
//         0, (a, b) => a! + int.parse(b.value!));
//     _outputMode.totalSelectedNumber = _outputMode.SelectedNumberList.fold(
//         0, (a, b) => a! + int.parse(b.points!));

//     _outputMode.leftPoints =
//         (_outputMode.userParticularPlayer?.wallet)! - _outputMode.totalPoints!;

//     state = AsyncData(_outputMode);
//   }

//   @override
//   build() {
//     _outputMode.leftPoints = _outputMode.userParticularPlayer?.wallet ?? 0;
//     return _outputMode;
//   }
// }

// class SinglePannaModel {
//   TextEditingController? value;
//   String? points;
//   SinglePannaModel({this.points, this.value});
// }

// class SelectedSinglePannaModel {
//   String? value;
//   String? points;
//   SelectedSinglePannaModel({this.points, this.value});
// }
