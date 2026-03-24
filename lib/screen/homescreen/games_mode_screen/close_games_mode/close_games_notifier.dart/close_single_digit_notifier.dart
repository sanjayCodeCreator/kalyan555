// import 'dart:developer';

// import 'package:intl/intl.dart';
// import 'package:sm_project/controller/local/user_particular_player.dart';
// import 'package:sm_project/controller/model/get_setting_model.dart';
// import 'package:sm_project/controller/model/single_digit_model.dart';
// import 'package:sm_project/utils/filecollection.dart';

// final closeSingleDigitNotifierProvider =
//     AsyncNotifierProvider.autoDispose<CloseSingleDigitNotifier, CloseSingleDigitMode>(() {
//   return CloseSingleDigitNotifier();
// });

// class CloseSingleDigitMode {
//   final userParticularPlayer = UserParticularPlayer.getParticularUserData();
//   String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
//   int? startDigit = 0;
//   TextEditingController addPointsController = TextEditingController();

//   List<int> singleDigitList = [];
//   List<int> SelectedNumberList = [];
//   int? totalSelectedNumber = 0;
//   int? totalPoints = 0;
//   int? leftPoints;

//   GetSettingModel? getSettingModel = GetSettingModel();
// }

// class CloseSingleDigitNotifier extends AutoDisposeAsyncNotifier<CloseSingleDigitMode> {
//   final CloseSingleDigitMode _outputMode = CloseSingleDigitMode();

//   void setStartDigit(int number) {
//     _outputMode.startDigit = number;
//     state = AsyncData(_outputMode);
//   }

//   void addPoints() async {
//     try {
//       EasyLoading.show(status: 'Loading...');
//       _outputMode.getSettingModel = await ApiService().getSettingModel();
//       int totalAddPoints = 0;
//       if (_outputMode.addPointsController.text.trim() != '') {
//         totalAddPoints = int.parse(_outputMode.addPointsController.text);
//       }

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

//         toast(
//             'Minimum bet amount is ${_outputMode.getSettingModel?.data?.betting?.min} and Maximum bet amount is ${_outputMode.getSettingModel?.data?.betting?.max}');
//         return;
//       }
//       if (_outputMode.startDigit != null &&
//           _outputMode.addPointsController.text.isNotEmpty) {
//         _outputMode.SelectedNumberList.add(
//             int.parse(_outputMode.startDigit.toString()));
//         _outputMode.singleDigitList
//             .add(int.parse(_outputMode.addPointsController.text));

//         print(_outputMode.SelectedNumberList);
//         print(_outputMode.singleDigitList);
//         totalAll();
//         EasyLoading.dismiss();
//       } else {
//         EasyLoading.dismiss();
//         toast('Please select number and add points');
//       }
//     } catch (e) {
//       EasyLoading.dismiss();
//       log(e.toString(), name: 'singleDigitModel');
//     }
//     EasyLoading.dismiss();
//     clearAll();
//     state = AsyncData(_outputMode);
//   }

//   void removePoints(int index) {
//     if (_outputMode.SelectedNumberList != []) {
//       _outputMode.SelectedNumberList.remove(
//           _outputMode.SelectedNumberList[index]);
//       _outputMode.singleDigitList.remove(_outputMode.singleDigitList[index]);

//       // addPoints();
//       totalAll();
//       print(_outputMode.SelectedNumberList);
//       print(_outputMode.singleDigitList);
//     } else {
//       toast('Please select number and add points');
//     }

//     state = AsyncData(_outputMode);
//   }

//   // Delete All
//   void deleteAll() {
//     if (_outputMode.SelectedNumberList != []) {
//       _outputMode.SelectedNumberList.clear();
//       _outputMode.singleDigitList.clear();
//       totalAll();
//     } else {
//       toast('Please select number and add points');
//     }

//     state = AsyncData(_outputMode);
//   }

//   void clearAll() {
//     _outputMode.startDigit = null;
//     _outputMode.addPointsController.clear();
//     state = AsyncData(_outputMode);
//   }

//   // clear SelectedNumberList
//   void clearSelectedNumberList() {
//     _outputMode.startDigit = null;
//     _outputMode.SelectedNumberList.clear();
//     _outputMode.singleDigitList.clear();
//     state = AsyncData(_outputMode);
//   }

//   void onSubmitConfirm(
//       BuildContext context, String tag, String marketId) async {
//     if (_outputMode.SelectedNumberList.isNotEmpty &&
//         _outputMode.singleDigitList.isNotEmpty) {
//       try {
//         EasyLoading.show(status: 'Loading...');

//         List<Map<String, dynamic>> jsonDataArray = [
//           for (int i = 0; i < _outputMode.singleDigitList.length; i++)
//             {
//               "session": "close",
//               "tag": tag,
//               "open_digit": "",
//               "close_digit": _outputMode.SelectedNumberList[i].toString(),
//               "open_panna": "",
//               "close_panna": "",
//               "points": _outputMode.singleDigitList[i].toString(),
//               "game_mode": "single-digit",
//               "market": marketId,
//             },
//         ];
//         log(jsonDataArray.toList().toString(), name: 'singleDigitModel');
//         PlayGameAllMarketModel? singleDigitModel =
//             await ApiService().postPlayGameAllMarket(jsonDataArray.toList());
//         if (singleDigitModel?.status == "success") {
//           AudioPlayer().play(AssetSource(bidsSound));
//           clearSelectedNumberList();
//           EasyLoading.dismiss();
//           context.pushReplacementNamed(RouteNames.homeScreen);
//           toast(singleDigitModel?.message ?? '');
//         } else if (singleDigitModel?.status == "failure") {
//           EasyLoading.dismiss();
//           toast(singleDigitModel?.message ?? '');
//         }
//       } catch (e) {
//         EasyLoading.dismiss();
//         log(e.toString(), name: 'singleDigitModel');
//       }
//     } else {
//       toast('Please select number and add points');
//     }
//   }

//   // function total Number
//   void totalAll() {
//     if (_outputMode.leftPoints! == 0 || _outputMode.leftPoints! > 0) {
//       _outputMode.totalSelectedNumber =
//           _outputMode.SelectedNumberList.fold(0, (a, b) => a! + b);

//       _outputMode.totalPoints =
//           _outputMode.singleDigitList.fold(0, (a, b) => a! + b);

//       _outputMode.leftPoints = (_outputMode.userParticularPlayer?.wallet)! -
//           _outputMode.totalPoints!;
//       // print(_outputMode.leftPoints);
//     } else {
//       toast('Wallet is empty');
//     }

//     state = AsyncData(_outputMode);
//   }

//   @override
//   build() {
//     _outputMode.leftPoints = _outputMode.userParticularPlayer?.wallet ?? 0;
//     return _outputMode;
//   }
// }
