import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/services.dart';
import 'package:sm_project/controller/apiservices/api_constant.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/features/gali_desawar/market_selected_screen.dart';
import 'package:sm_project/features/gali_desawar/select_game_notifier.dart';
import 'package:sm_project/utils/app_utils.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

class GaliDesawarDataComponent extends StatelessWidget {
  const GaliDesawarDataComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return CustomRefreshIndicator(
        onRefresh: () async {
          ref
              .read(selectGameNotifierProvider.notifier)
              .getDropDownAllMarket('?tag=galidisawar');
          ref
              .read(getParticularPlayerNotifierProvider.notifier)
              .getParticularPlayerModel(context: context);
        },
        builder: (context, widget, controller) {
          return CustomMaterialIndicator(
            onRefresh: () async {
              ref
                  .read(selectGameNotifierProvider.notifier)
                  .getDropDownAllMarket('?tag=galidisawar');
              ref
                  .read(getParticularPlayerNotifierProvider.notifier)
                  .getParticularPlayerModel(context: context);
            },
            indicatorBuilder: (context, controller) {
              return const Icon(
                Icons.cached,
                color: Colors.blue,
                size: 30,
              );
            },
            controller: controller,
            child: widget,
          );
        },
        child: Consumer(builder: (context, ref, child) {
          final refMarketData = ref.watch(selectGameNotifierProvider).value;
          final refWatch = ref.watch(homeNotifierProvider);
          final refRead = ref.read(homeNotifierProvider.notifier);
          return ListView.builder(
              itemCount: refMarketData?.gameList?.data
                      ?.where((e) => e.status ?? false)
                      .length ??
                  0,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final game = refMarketData?.gameList?.data
                    ?.where((e) => e.status ?? false)
                    .toList()[index];
                return Column(children: [
                  InkWell(
                    onTap: () {
                      if (game?.marketStatus == false) {
                        Vibration.vibrate(duration: 2000, amplitude: 84);
                        toast(
                            context: context, 'Holiday!!!, Market is closed.');
                        return;
                      }
                      if (refRead.isTimePassed(game?.closeTime ?? '')) {
                        Vibration.vibrate(duration: 2000, amplitude: 84);
                        toast(context: context, 'Market is closed.');
                        return;
                      }
                      if (refWatch.value?.getParticularPlayerModel?.data
                                  ?.betting ==
                              false ||
                          refWatch.value?.getParticularPlayerModel?.data
                                  ?.status ==
                              false) {
                        Vibration.vibrate(duration: 2000, amplitude: 84);
                        toast('Please contact to admin');
                        return;
                      }
                      Vibration.vibrate(duration: 2000, amplitude: 84);
                      HapticFeedback.selectionClick();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GaliMarketSelectedScreen(
                                    gameData: game,
                                    tag: game?.tag ?? '',
                                  )));
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  String url =
                                      "${APIConstants.websiteUrl}gali-chart.html?market=${game?.sId ?? ''}";
                                  launchUrl(
                                    Uri.parse(url),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: Image.asset(
                                    "assets/images/chart.png",
                                    width: 55,
                                    height: 55,
                                  ),
                                ),
                              ),
                              Column(children: [
                                Text(game?.name ?? '',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600)),
                                Text(
                                    (game?.openDigit == "-"
                                            ? 'X'
                                            : game?.openDigit ?? 'X') +
                                        ("-") +
                                        (game?.closeDigit == "-"
                                            ? 'X'
                                            : game?.closeDigit ?? 'X'),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(
                                    'Close Time: ${convert24HrTo12Hr(game?.closeTime ?? '')}',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black)),
                              ]),
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(0),
                                  child: Image.asset(
                                      (game?.marketStatus == false)
                                          ? "assets/images/pause.png"
                                          : refRead.isTimePassed(
                                                  game?.closeTime ?? '')
                                              ? "assets/images/pause.png"
                                              : "assets/images/play.png",
                                      width: 32,
                                      height: 32))
                            ]),
                        const Divider(),
                        Text(
                          (game?.marketStatus == false)
                              ? 'Market is Closed'
                              : refRead.isTimePassed(game?.closeTime ?? '')
                                  ? "Market is Closed"
                                  : "Market is Open",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: (game?.marketStatus == false)
                                  ? Colors.red
                                  : refRead.isTimePassed(game?.closeTime ?? '')
                                      ? Colors.red
                                      : Colors.green,
                              shadows: const [
                                Shadow(
                                  color: Colors.white,
                                  offset: Offset(2, 2),
                                )
                              ]),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 20),
                ]);
              });
        }),
      );
    });
  }
}
