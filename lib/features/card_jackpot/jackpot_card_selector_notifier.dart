import 'package:sm_project/utils/filecollection.dart';

final jackpotCardSelectorNotifierProvider =
    AsyncNotifierProvider.autoDispose<JackpotCardSelectorNotifier, String>(() {
  return JackpotCardSelectorNotifier();
});

class JackpotCardSelectorNotifier extends AutoDisposeAsyncNotifier<String> {
  String currentSelectedCard = "Hearts";

  updateCardSelection(String cardName) {
    currentSelectedCard = cardName;
    state = AsyncData(currentSelectedCard);
  }

  @override
  build() {
    return currentSelectedCard;
  }
}
