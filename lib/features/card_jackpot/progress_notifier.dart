import 'dart:async';

import 'package:sm_project/utils/filecollection.dart';

final retryProgressNotifierProvider =
    NotifierProvider<RetryProgressNotifier, double>(() {
  return RetryProgressNotifier();
});

class RetryProgressNotifier extends Notifier<double> {
  double angle = 0;
  Timer? timer;

  runSpin() {
    if (timer == null) {
      timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        angle += 1;
        state = angle;
      });
      return;
    }
    if (timer != null && !(timer!.isActive)) {
      timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        angle += 2;
        state = angle;
      });
    }
  }

  @override
  double build() {
    return angle;
  }
}
