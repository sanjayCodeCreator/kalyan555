import 'dart:developer';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/features/gali_desawar/gali_desawar_api.dart';
import 'package:sm_project/features/gali_desawar/model/select_game_model_list.dart';
import 'package:sm_project/utils/filecollection.dart';

final selectGameNotifierProvider =
    AsyncNotifierProvider<SelectGameNotifier, SelectGameNotifierModel?>(() {
  return SelectGameNotifier();
});

class SelectGameNotifier extends AsyncNotifier<SelectGameNotifierModel?> {
  final SelectGameNotifierModel _outputMode =
      SelectGameNotifierModel(gameId: "", gameList: SelectGameMarketList());

  void getDropDownAllMarket(String? query) async {
    try {
      EasyLoading.show(status: 'Loading...');
      _outputMode.gameList = await GaliDesawarApis.getGaliDishawarAllMarket(query);
      if (_outputMode.gameList?.status == "success") {
        EasyLoading.dismiss();
      } else if (_outputMode.gameList?.status == "failure") {
        EasyLoading.dismiss();
        toast(_outputMode.gameList?.message ?? '');
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'getAllMarketModel');
    }
    state = AsyncData(_outputMode);
  }

  updateGameId(String id) {
    _outputMode.gameId = id;
  }

  void onRefreshGaliDishwarDiamond(BuildContext context, String query) async {
    try {
      await Future.delayed(Duration.zero, () {
        getDropDownAllMarket(query);
        ref
            .read(homeNotifierProvider.notifier)
            .getParticularPlayerModel(context);
      });
    } catch (e) {
      log("$e");
    }
  }

  @override
  SelectGameNotifierModel? build() {
    // getDropDownAllMarket(query);
    return _outputMode;
  }
}

class SelectGameNotifierModel {
  String? gameId;
  SelectGameMarketList? gameList;
  SelectGameNotifierModel({
    this.gameId,
    this.gameList,
  });
}
