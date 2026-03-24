// import 'dart:developer';

// import 'package:intl/intl.dart';
// import 'package:sm_project/controller/local/user_particular_player.dart';
// import 'package:sm_project/controller/model/get_setting_model.dart';
// import 'package:sm_project/features/games/kalyan_morning_notifier.dart';
// import 'package:sm_project/features/reusubility_widget/x_dialog.dart';
// import 'package:sm_project/features/starline/starline_notifier.dart';
// import 'package:sm_project/utils/filecollection.dart';
// import '../../../controller/model/single_digit_model.dart';

// final singleDigitNotifierProvider =
//     AsyncNotifierProvider.autoDispose<SingleDigitNotifier, SingleDigitMode>(() {
//   return SingleDigitNotifier();
// });

// class SingleDigitMode {
//   final userParticularPlayer = UserParticularPlayer.getParticularUserData();
//   String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
//   int? startDigit = 0;
//   TextEditingController addPointsController = TextEditingController();

//   List<int> singleDigitList = [];
//   List<int> selectedNumberList = [];
//   int? totalSelectedNumber = 0;
//   int? totalPoints = 0;
//   int? leftPoints;
//   List<String> isClosed = [];

//   GetSettingModel? getSettingModel = GetSettingModel();
// }

// class SingleDigitNotifier extends AutoDisposeAsyncNotifier<SingleDigitMode> {
//   final SingleDigitMode _outputMode = SingleDigitMode();

//   void setStartDigit(int number) {
//     _outputMode.startDigit = number;
//     state = AsyncData(_outputMode);
//   }

//   void addPoints(BuildContext context) async {
//     try {
//       EasyLoading.show(status: 'Loading...');
//       _outputMode.getSettingModel = await ApiService().getSettingModel();
//       int totalAddPoints = 0;
//       if (_outputMode.addPointsController.text.trim() != '') {
//         totalAddPoints = int.parse(_outputMode.addPointsController.text);
//       }
//       if (totalAddPoints == 0) {
//         EasyLoading.dismiss();
//         if (context.mounted) {
//           toast(context: context, 'Invalid enter number');
//         }

//         return;
//       } else if ((_outputMode.leftPoints ?? -1) < totalAddPoints ||
//           totalAddPoints == 0) {
//         EasyLoading.dismiss();
//         if (context.mounted) {
//           toast(context: context, 'Wallet Amount is Low');
//         }
//         return;
//       } else if ((_outputMode.getSettingModel?.data?.betting?.min ?? 0) >
//               totalAddPoints ||
//           (_outputMode.getSettingModel?.data?.betting?.max ?? 0) <
//               totalAddPoints) {
//         EasyLoading.dismiss();
//         if (context.mounted) {
//           toast(
//               context: context,
//               'Minimum bet amount is ${_outputMode.getSettingModel?.data?.betting?.min} and Maximum bet amount is ${_outputMode.getSettingModel?.data?.betting?.max}');
//         }
//         return;
//       }
//       if (_outputMode.startDigit != null &&
//           _outputMode.addPointsController.text.isNotEmpty) {
//         _outputMode.selectedNumberList
//             .add(int.parse(_outputMode.startDigit.toString()));
//         _outputMode.singleDigitList
//             .add(int.parse(_outputMode.addPointsController.text));
//         _outputMode.isClosed.add(
//             ref.watch(kalyanMorningNotifierProvider).value?.isClose ?? false
//                 ? "close"
//                 : "open");

//         if (context.mounted) {
//           totalAll(context);
//         }
//         EasyLoading.dismiss();
//       } else {
//         EasyLoading.dismiss();
//         if (context.mounted) {
//           toast(context: context, 'Please select number and add points');
//         }
//       }
//     } catch (e) {
//       EasyLoading.dismiss();
//       log(e.toString(), name: 'singleDigitModel');
//     }
//     log(_outputMode.isClosed.toString(), name: 'isClosed');
//     EasyLoading.dismiss();
//     clearAll();
//     state = AsyncData(_outputMode);
//   }

//   void removePoints(BuildContext context, int index) {
//     if (_outputMode.selectedNumberList != []) {
//       _outputMode.selectedNumberList
//           .remove(_outputMode.selectedNumberList[index]);
//       _outputMode.singleDigitList.remove(_outputMode.singleDigitList[index]);
//       _outputMode.isClosed.remove(_outputMode.isClosed[index]);

//       // addPoints();
//       totalAll(context);
//     } else {
//       toast(context: context, 'Please select number and add points');
//     }

//     state = AsyncData(_outputMode);
//   }

//   // Delete All
//   void deleteAll(BuildContext context) {
//     if (_outputMode.selectedNumberList != []) {
//       _outputMode.selectedNumberList.clear();
//       _outputMode.singleDigitList.clear();
//       _outputMode.isClosed.clear();
//       totalAll(context);
//     } else {
//       toast(context: context, 'Please select number and add points');
//     }

//     state = AsyncData(_outputMode);
//   }

//   void clearAll() {
//     _outputMode.startDigit = null;
//     _outputMode.addPointsController.clear();
//     // _outputMode.isClosed.clear();
//     state = AsyncData(_outputMode);
//   }

//   // clear selectedNumberList
//   void clearSelectedNumberList() {
//     _outputMode.startDigit = null;
//     _outputMode.selectedNumberList.clear();
//     _outputMode.singleDigitList.clear();
//     _outputMode.isClosed.clear();
//     state = AsyncData(_outputMode);
//   }

//   void onSubmitConfirm(
//       BuildContext context, String tag, String marketId) async {
//     if (_outputMode.selectedNumberList.isNotEmpty &&
//         _outputMode.singleDigitList.isNotEmpty) {
//       try {
//         EasyLoading.show(status: 'Loading...');


//         List<Map<String, dynamic>> jsonDataArray = [
//           for (int i = 0; i < _outputMode.singleDigitList.length; i++)
//             {
//               "session": ref.watch(starlineNotifierProvider)
//                   ? "open"
//                   : _outputMode.isClosed[i],
//               "tag": tag,
//               "open_digit":
//                   (ref.watch(kalyanMorningNotifierProvider).value?.isClose ??
//                           false)
//                       ? "-"
//                       : _outputMode.selectedNumberList[i].toString(),
//               "close_digit":
//                   (ref.watch(kalyanMorningNotifierProvider).value?.isClose ??
//                           false)
//                       ? _outputMode.selectedNumberList[i].toString()
//                       : "-",
//               "open_panna": "-",
//               "close_panna": "-",
//               "points": _outputMode.singleDigitList[i].toString(),
//               "game_mode": "single-digit",
//               "market": marketId,
//             },
//         ];
//         log(jsonDataArray.toList().toString(), name: 'singleDigitModel');
//         PlayGameAllMarketModel? singleDigitModel =
//             await ApiService().postPlayGameAllMarket(jsonDataArray.toList());
//         if (singleDigitModel?.status == "success") {
//           clearSelectedNumberList();
//           AudioPlayer().play(AssetSource(bidsSound));

//           EasyLoading.dismiss();
//           if (context.mounted) {
//             xdialog(
//               context: context,
//               title: "Success",
//               content: singleDigitModel?.message ?? '',
//               onPressed: () {
//                 context.pushReplacementNamed(RouteNames.homeScreen);
//               },
//             );
//           }
//         } else if (singleDigitModel?.status == "failure") {
//           EasyLoading.dismiss();
//           if (context.mounted) {
//             toast(context: context, singleDigitModel?.message ?? '');
//           }
//         }
//       } catch (e) {
//         EasyLoading.dismiss();
//         log(e.toString(), name: 'singleDigitModel');
//       }
//     } else {
//       toast(context: context, 'Please select number and add points');
//     }
//   }

//   // function total Number
//   void totalAll(BuildContext context) {
//     if (_outputMode.leftPoints! == 0 || _outputMode.leftPoints! > 0) {
//       _outputMode.totalSelectedNumber = _outputMode.selectedNumberList.length;

//       _outputMode.totalPoints =
//           _outputMode.singleDigitList.fold(0, (a, b) => a! + b);

//       _outputMode.leftPoints = (_outputMode.userParticularPlayer?.wallet)! -
//           _outputMode.totalPoints!;
//       // print(_outputMode.leftPoints);
//     } else {
//       toast(context: context, 'Wallet is empty');
//     }

//     state = AsyncData(_outputMode);
//   }

//   @override
//   build() {
//     _outputMode.leftPoints = _outputMode.userParticularPlayer?.wallet ?? 0;
//     return _outputMode;
//   }
// }
