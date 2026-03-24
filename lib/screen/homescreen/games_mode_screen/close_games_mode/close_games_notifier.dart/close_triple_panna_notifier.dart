// import 'dart:developer';

// import 'package:intl/intl.dart';
// import 'package:sm_project/controller/local/user_particular_player.dart';
// import 'package:sm_project/controller/model/get_setting_model.dart';
// import 'package:sm_project/controller/model/single_digit_model.dart';
// import 'package:sm_project/utils/filecollection.dart';

// final closetriplePannaNotifierProvider = AsyncNotifierProvider.autoDispose<
//     CloseTriplePannaNotifier, CloseTriplePannaMode>(() {
//   return CloseTriplePannaNotifier();
// });

// class CloseTriplePannaMode {
//   final userParticularPlayer = UserParticularPlayer.getParticularUserData();
//   String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
//   int? startDigit = 1;

//   List<SelectedTriplePannaModel> SelectedNumberList = [];
//   int? totalSelectedNumber = 0;
//   int? totalPoints = 0;
//   int? leftPoints;

//   GetSettingModel? getSettingModel = GetSettingModel();

//   List<TriplePannaModel> triplePannaModel = [
//     TriplePannaModel(value: TextEditingController()),
//     TriplePannaModel(value: TextEditingController()),
//     TriplePannaModel(value: TextEditingController()),
//     TriplePannaModel(value: TextEditingController()),
//     TriplePannaModel(value: TextEditingController()),
//     TriplePannaModel(value: TextEditingController()),
//     TriplePannaModel(value: TextEditingController()),
//     TriplePannaModel(value: TextEditingController()),
//     TriplePannaModel(value: TextEditingController()),
//     TriplePannaModel(value: TextEditingController()),
//   ];

//   List<TriplePannaModel> numbers = [
//     TriplePannaModel(value: TextEditingController(), points: '000'),
//     TriplePannaModel(value: TextEditingController(), points: '666'),
//     TriplePannaModel(value: TextEditingController(), points: '111'),
//     TriplePannaModel(value: TextEditingController(), points: '777'),
//     TriplePannaModel(value: TextEditingController(), points: '222'),
//     TriplePannaModel(value: TextEditingController(), points: '888'),
//     TriplePannaModel(value: TextEditingController(), points: '333'),
//     TriplePannaModel(value: TextEditingController(), points: '999'),
//     TriplePannaModel(value: TextEditingController(), points: '444'),
//     TriplePannaModel(value: TextEditingController(), points: '555'),
//   ];
// }

// class CloseTriplePannaNotifier
//     extends AutoDisposeAsyncNotifier<CloseTriplePannaMode> {
//   final CloseTriplePannaMode _outputMode = CloseTriplePannaMode();

//   void addPoints() async {
//     try {
//       EasyLoading.show(status: 'Loading...');
//       _outputMode.getSettingModel = await ApiService().getSettingModel();
//       int totalAddPoints = 0;
//       _outputMode.numbers.forEach((element) {
//         if (element.value?.text.trim() != '') {
//           totalAddPoints = int.parse(element.value?.text ?? '0');
//         }
//       });
//       EasyLoading.dismiss();
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

//       if (_outputMode.numbers.isNotEmpty) {
//         _outputMode.numbers.forEach((element) {
//           if (element.value?.text.trim() != '') {
//             _outputMode.SelectedNumberList.add(SelectedTriplePannaModel(
//                 points: element.points, value: element.value?.text));
//           }
//         });
//         EasyLoading.dismiss();
//         totalAll();
//       } else {
//         EasyLoading.dismiss();
//         toast('Please select number and add points');
//       }
//     } catch (e) {
//       EasyLoading.dismiss();
//       log(e.toString(), name: 'triple-pana');
//     }

//     EasyLoading.dismiss();
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

//   // // // clear SelectedNumberList
//   void clearSelectedNumberList() {
//     for (int i = 0; i < _outputMode.numbers.length; i++) {
//       _outputMode.numbers[i].value?.text = '';
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
//               "game_mode": "triple-pana",
//               "market": marketId
//             },
//         ];

//         log(jsonDataArray.toList().toString(), name: 'triple-pana');
//         PlayGameAllMarketModel? singlePanaModel =
//             await ApiService().postPlayGameAllMarket(jsonDataArray.toList());
//         if (singlePanaModel?.status == "success") {
//           AudioPlayer().play(AssetSource(bidsSound));
//           clearConfirmNumberList();
//           EasyLoading.dismiss();
//           context.pushReplacementNamed(RouteNames.homeScreen);
//           toast(singlePanaModel?.message ?? '');
//         } else if (singlePanaModel?.status == "failure") {
//           clearConfirmNumberList();
//           EasyLoading.dismiss();
//           toast(singlePanaModel?.message ?? '');
//         }
//       } catch (e) {
//         EasyLoading.dismiss();
//         log(e.toString(), name: 'triple-pana');
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

// class TriplePannaModel {
//   TextEditingController? value;
//   String? points;
//   TriplePannaModel({this.points, this.value});
// }

// class SelectedTriplePannaModel {
//   String? value;
//   String? points;
//   SelectedTriplePannaModel({this.points, this.value});
// }
