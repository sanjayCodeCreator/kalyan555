import 'package:sm_project/features/gali_desawar/model/select_game_model_list.dart';
import 'package:sm_project/utils/filecollection.dart';

final galiDesawarGameModelNotifierProvider =
    AsyncNotifierProvider<GaliDesawarGameModeNotifier, GaliDesawarGameMode>(() {
  return GaliDesawarGameModeNotifier();
});

class GaliDesawarGameModel {
  SelectGameMarketList? selectGameMarketList = SelectGameMarketList();
}

class GaliDesawarGameModeNotifier extends AsyncNotifier<GaliDesawarGameMode> {
  GaliDesawarGameMode currentGameMode = GaliDesawarGameMode.openPlay;

  updateGameMode(GaliDesawarGameMode mode) {
    currentGameMode = mode;
    state = AsyncData(currentGameMode);
  }

  @override
  build() {
    return currentGameMode;
  }
}

enum GaliDesawarGameMode { openPlay, jantri, cross }
