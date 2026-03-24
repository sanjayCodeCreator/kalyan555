import 'package:sm_project/utils/filecollection.dart';

final jackpotHistorySwitchNotifierProvider =
    NotifierProvider<JackpotHistorySwitchNotifier, String>(() {
  return JackpotHistorySwitchNotifier();
});

class JackpotHistorySwitchNotifier extends Notifier<String> {
  String currentSelected = "Game History";

  updateSelection(String selectedMode) {
    currentSelected = selectedMode;
    state = currentSelected;
  }

  @override
  build() {
    return currentSelected;
  }
}
