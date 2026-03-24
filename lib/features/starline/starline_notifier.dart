import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sm_project/utils/colors.dart';

final starlineNotifierProvider = NotifierProvider<StarlineNotifier, bool>(() {
  return StarlineNotifier();
});

class StarlineNotifier extends Notifier<bool> {
  bool isStarline = false;

  void changeStarlineStatus(bool status) {
    if (status) {
      lightGreyColor = scaffoldBackgroundColor;
    } else {
      lightGreyColor = scaffoldBackgroundColor;
    }
    isStarline = status;
    state = isStarline;
  }

  @override
  build() {
    return isStarline;
  }
}
