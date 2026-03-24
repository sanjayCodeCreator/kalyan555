import 'dart:developer';

import 'package:sm_project/controller/model/single_digit_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/gali_desawar/gali_desawar_api.dart';
import 'package:sm_project/features/gali_desawar/is_stop_gali_game_execution.dart';
import 'package:sm_project/features/gali_desawar/model/select_game_model_list.dart';
import 'package:sm_project/utils/filecollection.dart';

final openPlayNotifierProvider =
    AsyncNotifierProvider<OpenPlayNotifier, OpenPlayNotifierModel>(() {
  return OpenPlayNotifier();
});

class OpenPlayNotifier extends AsyncNotifier<OpenPlayNotifierModel> {
  OpenPlayNotifierModel openPlayData = OpenPlayNotifierModel(
      number: TextEditingController(text: ""),
      numberAmount: TextEditingController(text: ""),
      harup: TextEditingController(text: ""),
      harupAmount: TextEditingController(text: ""),
      selectedNumber: []);

  void submitData(BuildContext context, String tag,
      {required GaliDeswarGameData? gameData}) async {
    if (isStopGaliDesawarGameExecution(gameData: gameData)) {
      return;
    }
    EasyLoading.show(status: 'Loading...');
    final userParticularPlayer = await ApiService().getParticularUserData();
    final walletAmount = userParticularPlayer?.data?.wallet ?? 0;
    if (walletAmount < openPlayData.totalAmount) {
      EasyLoading.dismiss();
      toast("Insufficient Balance");
      return;
    }
    List<Map<String, dynamic>> data = [];
    final marketID = gameData?.sId ?? "";

    await ref
        .read(getParticularPlayerNotifierProvider.notifier)
        .getParticularPlayerModel();

    for (final number in openPlayData.selectedNumber) {
      if (number.isHarupNumber) {
        if (openPlayData.isHarupAndar) {
          data.add({
            "user_id": ref
                    .watch(getParticularPlayerNotifierProvider)
                    .value
                    ?.getParticularPlayerModel
                    ?.data
                    ?.sId ??
                "",
            "tag": tag,
            "open_digit": number.betNumber,
            "points": number.betAmount,
            "game_mode": "left-digit",
            "market_id": marketID
          });
        }
        if (openPlayData.isHarupBahar) {
          data.add({
            "user_id": ref
                    .watch(getParticularPlayerNotifierProvider)
                    .value
                    ?.getParticularPlayerModel
                    ?.data
                    ?.sId ??
                "",
            "tag": tag,
            'close_digit': number.betNumber,
            "points": number.betAmount,
            "game_mode": "right-digit",
            "market_id": marketID
          });
        }
        continue;
      }
      data.add({
        "user_id": ref
                .watch(getParticularPlayerNotifierProvider)
                .value
                ?.getParticularPlayerModel
                ?.data
                ?.sId ??
            "",
        "tag": tag,
        "open_digit": number.betNumber[0],
        'close_digit': number.betNumber[1],
        "points": number.betAmount,
        "game_mode": "jodi-digit",
        "market_id": marketID
      });
    }
    try {
      log(data.toList().toString().toString(), name: 'getAllMarketModel');

      openPlayData.playGameAllMarketModel =
          await GaliDesawarApis.postDishawarPlayGameMarket(data.toList());

      if (openPlayData.playGameAllMarketModel?.status == "success") {
        EasyLoading.dismiss();
        clearAll();
        AudioPlayer().play(AssetSource(bidsSound));
        if (context.mounted) {
          context.pushReplacement(RouteNames.homeScreen);
          ref
              .read(getParticularPlayerNotifierProvider.notifier)
              .getParticularPlayerModel(context: context);
        }
        toast(openPlayData.playGameAllMarketModel?.message ?? '');
      } else if (openPlayData.playGameAllMarketModel?.status == "failure") {
        EasyLoading.dismiss();
        toast(openPlayData.playGameAllMarketModel?.message ?? '');
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'getAllMarketModel');
    }
    state = AsyncData(openPlayData);
  }

  clearAll() {
    openPlayData.harup.clear();
    openPlayData.totalAmount = 0;
    openPlayData.harupAmount.clear();
    openPlayData.selectedNumber.clear();
    openPlayData.numberAmount.clear();
    openPlayData.number.clear();
    openPlayData.isHarupAndar = false;
    openPlayData.isHarupBahar = false;
    openPlayData.isNumberWithPalti = false;
    calculateTotalAmount();
    state = AsyncData(openPlayData);
  }

  toggleNumberWithPalti() {
    openPlayData.isNumberWithPalti = !openPlayData.isNumberWithPalti;
    calculateTotalAmount();
    state = AsyncData(openPlayData);
  }

  toggleHarupAndar() {
    openPlayData.isHarupAndar = !openPlayData.isHarupAndar;
    calculateTotalAmount();
    state = AsyncData(openPlayData);
  }

  toggleHarupBahar() {
    openPlayData.isHarupBahar = !openPlayData.isHarupBahar;
    calculateTotalAmount();
    state = AsyncData(openPlayData);
  }

  calculateTotalAmount() {
    openPlayData.totalAmount = 0;
    openPlayData.selectedNumber.clear();
    numberLogic();
    openGameHarupLogic();
    log(openPlayData.totalAmount.toString());
    for (final num in openPlayData.selectedNumber) {
      openPlayData.totalAmount += num.betAmount;
    }
    state = AsyncData(openPlayData);
  }

  List<String> splitPairs(String s) {
    List<String> result = [];
    for (int i = 0; i < s.length; i += 2) {
      if (i + 1 < s.length) {
        result.add(s.substring(i, i + 2));
      }
    }
    return result;
  }

  numberLogic() {
    if (openPlayData.number.text.isEmpty) {
      return;
    }
    if (openPlayData.numberAmount.text.isEmpty) {
      return;
    }
    List<String> numbers = splitPairs(openPlayData.number.text);
    numbers = numbers.toSet().toList();
    for (String number in numbers) {
      openPlayData.selectedNumber.add(SelectedNumbers(
          betAmount: int.tryParse(openPlayData.numberAmount.text) ?? 0,
          betNumber: number,
          isHarupNumber: false));
      if (openPlayData.isNumberWithPalti) {
        openPlayData.selectedNumber.add(SelectedNumbers(
            betAmount: int.tryParse(openPlayData.numberAmount.text) ?? 0,
            betNumber: number.reversed(),
            isHarupNumber: false));
      }
    }
  }

  openGameHarupLogic() {
    openPlayData.harup.text =
        openPlayData.harup.text.split('').toSet().toList().join();
    if (openPlayData.harup.text.isEmpty) {
      return;
    }
    if (!(openPlayData.isHarupAndar) && !(openPlayData.isHarupBahar)) {
      return;
    }
    final listOfNumber = openPlayData.harup.text.split('');
    for (String number in listOfNumber) {
      openPlayData.selectedNumber.add(SelectedNumbers(
          betAmount: openPlayData.isHarupAndar && openPlayData.isHarupBahar
              ? (int.tryParse(openPlayData.harupAmount.text) ?? 0) * 2
              : int.tryParse(openPlayData.harupAmount.text) ?? 0,
          betNumber: number));
    }
  }

  removeSelectedNumber(int index) {
    openPlayData.selectedNumber.removeAt(index);
    afterRemovingTotalAmount();
    state = AsyncData(openPlayData);
  }

  afterRemovingTotalAmount() {
    int totalAmount = 0;
    for (final element in openPlayData.selectedNumber) {
      totalAmount += element.betAmount;
    }
    openPlayData.totalAmount = totalAmount;
  }

  @override
  build() {
    return openPlayData;
  }
}

class OpenPlayNotifierModel {
  final TextEditingController number;
  final TextEditingController numberAmount;
  final TextEditingController harup;
  final TextEditingController harupAmount;
  int totalAmount;
  bool isNumberWithPalti;
  bool isHarupAndar;
  bool isHarupBahar;
  int? withPatti;
  int? selectedHarupNumberList;
  int? withHarupAndarPatti;
  int? withHarupBaharPatti;
  int? withHarupFirstNumber;
  int? withHarupTwoNumber;
  PlayGameAllMarketModel? playGameAllMarketModel = PlayGameAllMarketModel();
  List<SelectedNumbers> selectedNumber;

  OpenPlayNotifierModel({
    required this.number,
    required this.numberAmount,
    required this.harup,
    required this.harupAmount,
    this.totalAmount = 0,
    this.isNumberWithPalti = false,
    this.isHarupAndar = false,
    this.isHarupBahar = false,
    this.withPatti,
    required this.selectedNumber,
  });
}

class SelectedNumbers {
  final String betNumber;
  final int betAmount;
  final bool isHarupNumber;
  SelectedNumbers({
    this.betAmount = 0,
    this.betNumber = "",
    this.isHarupNumber = true,
  });
}

extension StringExtensions on String? {
  String reversed() {
    var res = "";
    for (int i = this!.length - 1; i >= 0; --i) {
      res += this![i];
    }
    return res;
  }
}
