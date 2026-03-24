import 'dart:developer';

import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/gali_desawar/gali_desawar_api.dart';
import 'package:sm_project/features/gali_desawar/is_stop_gali_game_execution.dart';
import 'package:sm_project/features/gali_desawar/model/select_game_model_list.dart';
import 'package:sm_project/utils/filecollection.dart';

final jantriNotifierProvider =
    AsyncNotifierProvider<JantriNotifier, JantriNotifierModel>(() {
  return JantriNotifier();
});

class JantriNotifier extends AsyncNotifier<JantriNotifierModel> {
  JantriNotifierModel jantriData = JantriNotifierModel(
    selectedNumbers: [],
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
    if (walletAmount < jantriData.totalAmount) {
      EasyLoading.dismiss();
      toast("Insufficient Balance");
      return;
    }

    await ref
        .read(getParticularPlayerNotifierProvider.notifier)
        .getParticularPlayerModel();
    List<Map<String, dynamic>> data = [];
    final marketId = gameData?.sId ?? "";
    for (final number in jantriData.selectedNumbers) {
      if (number.isHarupNo && number.isHarupAndar) {
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
          "market_id": marketId
        });
        continue;
      }
      if (number.isHarupNo && !number.isHarupAndar) {
        data.add({
          "user_id": ref
                  .watch(getParticularPlayerNotifierProvider)
                  .value
                  ?.getParticularPlayerModel
                  ?.data
                  ?.sId ??
              "",
          "tag": tag,
          "close_digit": number.betNumber,
          "points": number.betAmount,
          "game_mode": "right-digit",
          "market_id": marketId
        });
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
    state = AsyncData(jantriData);
  }

  clearAll() {
    jantriData.totalAmount = 0;
    jantriData.selectedNumbers.clear();
    calculateTotalAmount();
    state = AsyncData(jantriData);
  }

  updateData(
      {required String betNumber,
      required String betAmount,
      bool isHarupAndar = false,
      bool isHarupNo = false}) {
    final result = jantriData.selectedNumbers.where(
        (e) => e.betNumber == betNumber && e.isHarupAndar == isHarupAndar);

    if (result.isEmpty) {
      jantriData.selectedNumbers.add(SelectedNumbers(
          betAmount: int.tryParse(betAmount) ?? 0,
          betNumber: betNumber,
          isHarupAndar: isHarupAndar,
          isHarupNo: isHarupNo));
    } else {
      jantriData.selectedNumbers
          .where(
              (e) => e.betNumber == betNumber && e.isHarupAndar == isHarupAndar)
          .first
          .betAmount = int.tryParse(betAmount) ?? 0;
    }
    jantriData.selectedNumbers = jantriData.selectedNumbers.toSet().toList();
    calculateTotalAmount();
  }

  calculateTotalAmount() {
    int totalAmount = 0;
    for (final element in jantriData.selectedNumbers) {
      totalAmount += element.betAmount;
    }
    jantriData.totalAmount = totalAmount;
    state = AsyncData(jantriData);
  }

  @override
  build() {
    return jantriData;
  }
}

class JantriNotifierModel {
  final String? gameName;
  List<SelectedNumbers> selectedNumbers;
  int totalAmount;
  JantriNotifierModel({
    this.gameName,
    required this.selectedNumbers,
    this.totalAmount = 0,
  });
}

class SelectedNumbers {
  final String betNumber;
  int betAmount;
  final bool isHarupAndar;
  final bool isHarupNo;
  SelectedNumbers({
    this.betAmount = 0,
    this.betNumber = "",
    this.isHarupAndar = false,
    this.isHarupNo = false,
  });

  // == equality

  @override
  bool operator ==(Object other) {
    return other is SelectedNumbers &&
        other.betNumber == betNumber &&
        other.isHarupAndar == isHarupAndar;
  }

  @override
  int get hashCode => betNumber.hashCode;
}
