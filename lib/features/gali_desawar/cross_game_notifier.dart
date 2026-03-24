import 'dart:developer';

import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/gali_desawar/gali_desawar_api.dart';
import 'package:sm_project/features/gali_desawar/is_stop_gali_game_execution.dart';
import 'package:sm_project/features/gali_desawar/model/select_game_model_list.dart';
import 'package:sm_project/utils/filecollection.dart';

final crossGameNotifierProvider =
    AsyncNotifierProvider<CrossGameNotifier, CrossGameNotifierModel>(() {
  return CrossGameNotifier();
});

class CrossGameNotifier extends AsyncNotifier<CrossGameNotifierModel> {
  CrossGameNotifierModel crossGameData = CrossGameNotifierModel(
    number: TextEditingController(text: ""),
    numberAmount: TextEditingController(text: ""),
    selectedNumber: [],
  );

  submitData(
      {required BuildContext context,
      required String? tag,
      required GaliDeswarGameData? gameData}) async {
    if (isStopGaliDesawarGameExecution(gameData: gameData)) {
      return;
    }
    EasyLoading.show(status: 'Loading...');
    final userParticularPlayer = await ApiService().getParticularUserData();
    final walletAmount = userParticularPlayer?.data?.wallet ?? 0;
    if (walletAmount < crossGameData.totalAmount) {
      EasyLoading.dismiss();
      toast("Insufficient Balance");
      return;
    }
    List<Map<String, dynamic>> data = [];
    final marketId = gameData?.sId;
    await ref
        .read(getParticularPlayerNotifierProvider.notifier)
        .getParticularPlayerModel();
    for (final number in crossGameData.selectedNumber) {
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
        "market_id": marketId
      });
    }
    try {
      log(data.toList().toString().toString());
      final playGameAllMarketModel =
          await GaliDesawarApis.postDishawarPlayGameMarket(data.toList());
      if (playGameAllMarketModel?.status == "success") {
        EasyLoading.dismiss();
        AudioPlayer().play(AssetSource(bidsSound));
        clearAll();
        if (context.mounted) {
          context.pushReplacement(RouteNames.homeScreen);
          ref
              .read(getParticularPlayerNotifierProvider.notifier)
              .getParticularPlayerModel(context: context);
        }
        toast(playGameAllMarketModel?.message ?? '');
      } else if (playGameAllMarketModel?.status == "failure") {
        EasyLoading.dismiss();
        toast(playGameAllMarketModel?.message ?? '');
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'getAllMarketModel');
    }
    state = AsyncData(crossGameData);
  }

  clearAll() {
    crossGameData.totalAmount = 0;
    crossGameData.number.clear();
    crossGameData.numberAmount.clear();
    crossGameData.selectedNumber.clear();
    calculateTotalAmount();
    state = AsyncData(crossGameData);
  }

  toggleNumberWithoutJoda() {
    crossGameData.isNumberWithoutJoda = !crossGameData.isNumberWithoutJoda;
    calculateTotalAmount();
    state = AsyncData(crossGameData);
  }

  calculateTotalAmount() {
    crossGameData.number.text =
        crossGameData.number.text.split('').toSet().toList().join();
    if (crossGameData.number.text.length == 1) {
      return;
    }
    int numberAmount = int.tryParse(crossGameData.numberAmount.text) ?? 0;
    int totalAmount = numberAmount;
    if (crossGameData.isNumberWithoutJoda) {
      totalAmount = totalAmount * 2;
    }
    crossGameData.totalAmount = totalAmount;
    crossGameLogic();
    state = AsyncData(crossGameData);
  }

  removeSelectedNumber(int index) {
    crossGameData.selectedNumber.removeAt(index);
    afterRemovingTotalAmount();
    state = AsyncData(crossGameData);
  }

  afterRemovingTotalAmount() {
    int totalAmount = 0;
    for (var element in crossGameData.selectedNumber) {
      totalAmount += element.betAmount;
    }
    crossGameData.totalAmount = totalAmount;
  }

  crossGameLogic() {
    crossGameData.selectedNumber.clear();
    if (crossGameData.totalAmount != 0) {
      crossGameData.showCard = true;
    } else {
      crossGameData.showCard = false;
    }
    if (crossGameData.number.text.isEmpty) {
      return;
    }
    final listOfNumber = crossGameData.number.text.split('');
    crossGameData.totalAmount = 0;
    for (String number in listOfNumber) {
      for (String number2 in listOfNumber) {
        if (number == number2 && crossGameData.isNumberWithoutJoda) {
          continue;
        }
        crossGameData.selectedNumber.add(SelectedNumbers(
            betAmount: int.tryParse(crossGameData.numberAmount.text) ?? 0,
            betNumber: number + number2));
        crossGameData.totalAmount +=
            int.tryParse(crossGameData.numberAmount.text) ?? 0;
      }
    }
  }

  @override
  build() {
    return crossGameData;
  }
}

class CrossGameNotifierModel {
  final String? gameName;
  final TextEditingController number;
  final TextEditingController numberAmount;
  int totalAmount;
  bool isNumberWithoutJoda;
  bool showCard;
  List<SelectedNumbers> selectedNumber;
  CrossGameNotifierModel({
    this.gameName,
    required this.number,
    required this.numberAmount,
    this.totalAmount = 0,
    this.isNumberWithoutJoda = false,
    this.showCard = false,
    required this.selectedNumber,
  });
}

class SelectedNumbers {
  final String betNumber;
  final int betAmount;
  SelectedNumbers({
    this.betAmount = 0,
    this.betNumber = "",
  });
}
