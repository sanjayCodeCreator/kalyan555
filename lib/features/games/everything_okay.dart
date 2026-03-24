import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/features/reusubility_widget/x_dialog.dart';
import 'package:sm_project/utils/filecollection.dart';

bool isStopGameExecution(
    {required BuildContext context,
    required WidgetRef ref,
    required String marketId,
    required String gameName}) {
  final refWatchHome = ref.watch(homeNotifierProvider);
  final myMarketData = refWatchHome.value?.getAllMarketModel?.data
      ?.where((element) => element.sId == marketId)
      .toList()
      .first;
  final refRead = ref.read(homeNotifierProvider.notifier);
  if (myMarketData?.marketStatus == false) {
    xdialog(
      context: context,
      title: "Info",
      content: "Holiday!!!, Market is close.",
      onPressed: () {
        context.pushReplacementNamed(RouteNames.homeScreen);
      },
    );
    return true;
  }

  if (refRead.isTimePassed(myMarketData?.openTime ?? '') &&
      (gameName == "Jodi Digit" ||
          gameName == "Half Sangam" ||
          gameName == "Full Sangam" ||
          gameName == "Red Jodi")) {
    toast(context: context, 'Game is only available before open time.');
    return true;
  }

  if (refRead.isTimePassed(myMarketData?.closeTime ?? '')) {
    xdialog(
      context: context,
      title: "Info",
      content: "Market is close for today.",
      onPressed: () {
        context.pushReplacementNamed(RouteNames.homeScreen);
      },
    );
    return true;
  }

  return false;
}
