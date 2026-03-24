import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sm_project/utils/app_utils.dart';

final kalyanMorningNotifierProvider =
    AsyncNotifierProvider.autoDispose<KalyanMorningNotifier, KalyanMorningMode>(
        () {
  return KalyanMorningNotifier();
});

class KalyanMorningMode {
  String formattedDate = DateFormat('kk:mm:ss').format(DateTime.now());
  bool isClose = true;
}

class KalyanMorningNotifier
    extends AutoDisposeAsyncNotifier<KalyanMorningMode> {
  final KalyanMorningMode _outputMode = KalyanMorningMode();

  Future<void> getPermission() async {
    await AppUtils.handleCameraAndMic(Permission.notification);
    await AppUtils.handleCameraAndMic(Permission.audio);
    await AppUtils.handleCameraAndMic(Permission.mediaLibrary);
  }

  void changeOpenClose({required bool isClose}) async {
    _outputMode.isClose = isClose;
    state = AsyncData(_outputMode);
  }

  void isOpenSet() {
    _outputMode.isClose = true;
    state = AsyncData(_outputMode);
  }

  @override
  build() {
    return _outputMode;
  }
}
