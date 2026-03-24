import 'dart:async';

import 'package:flutter/services.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/features/games/double_panna/double_panna_notifier.dart';
import 'package:sm_project/features/games/full_sangam/full_sangam_notifier.dart';
import 'package:sm_project/features/games/half_sangam/half_sangam_notifier.dart';
import 'package:sm_project/features/games/jodi_digit/jodi_digit_notifier.dart';
import 'package:sm_project/features/games/kalyan_morning_notifier.dart';
import 'package:sm_project/features/games/single_digit/single_digit_new_notifier.dart';
import 'package:sm_project/features/games/single_panna/single_panna_notifier.dart';
import 'package:sm_project/features/games/sp_dp_tp/sp_dp_tp_notifier.dart';
import 'package:sm_project/features/games/triple_panna/triple_panna_notifier.dart';
import 'package:sm_project/features/starline/starline_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class OpenCloseComponent extends ConsumerStatefulWidget {
  final String marketId;
  const OpenCloseComponent({required this.marketId, super.key});

  @override
  ConsumerState<OpenCloseComponent> createState() => _OpenCloseComponentState();
}

class _OpenCloseComponentState extends ConsumerState<OpenCloseComponent> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref
          .read(kalyanMorningNotifierProvider.notifier)
          .changeOpenClose(isClose: true);
      final refWatchHome = ref.watch(homeNotifierProvider);
      final myMarketData = refWatchHome.value?.getAllMarketModel?.data
          ?.where((element) => element.sId == widget.marketId)
          .toList()
          .first;
      final refReadHome = ref.read(homeNotifierProvider.notifier);
      if (!refReadHome.isTimePassed(myMarketData?.openTime ?? '')) {
        ref
            .read(kalyanMorningNotifierProvider.notifier)
            .changeOpenClose(isClose: false);
      }
    });
    if (timer == null) {
      if (!(timer?.isActive ?? false)) {
        timer = Timer.periodic(const Duration(seconds: 1), callEverySec);
      }
    }
  }

  void callEverySec(timer) {
    if (ref.context.mounted) {
      final refWatchHome = ref.watch(homeNotifierProvider);
      final myMarketData = refWatchHome.value?.getAllMarketModel?.data
          ?.where((element) => element.sId == widget.marketId)
          .toList()
          .first;
      final refReadHome = ref.read(homeNotifierProvider.notifier);
      if (refReadHome.isTimePassed(myMarketData?.openTime ?? '')) {
        ref.read(singleDigitNewNotifierProvider.notifier).deleteAll(context);
        if (context.mounted) {
          ref.read(jodiDigitNotifierProvider.notifier).deleteAll(context);
          ref.read(singlePannaNotifierProvider.notifier).deleteAll(context);
          ref.read(doublePannaNotifierProvider.notifier).deleteAll(context);
          ref.read(triplePannaNotifierProvider.notifier).deleteAll(context);
          ref.read(halfSangamNotifierProvider.notifier).deleteAll(context);
          ref.read(fullSangamNotifierProvider.notifier).deleteAll(context);
          ref.read(spdptpNotifierProvider.notifier).deleteAll(context);
        }
        ref
            .read(kalyanMorningNotifierProvider.notifier)
            .changeOpenClose(isClose: true);
        timer?.cancel();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final isStartline = ref.watch(starlineNotifierProvider);
      if (isStartline) {
        return const SizedBox();
      }
      final refRead = ref.read(kalyanMorningNotifierProvider.notifier);
      final refWatch = ref.watch(kalyanMorningNotifierProvider);
      final refReadHome = ref.read(homeNotifierProvider.notifier);
      final refWatchHome = ref.watch(homeNotifierProvider);
      final myMarketData = refWatchHome.value?.getAllMarketModel?.data
          ?.where((element) => element.sId == widget.marketId)
          .toList()
          .first;
      final isOpenActive =
          refReadHome.isTimePassed(myMarketData?.openTime ?? '') == false;
      final isCloseActive =
          refReadHome.isTimePassed(myMarketData?.openTime ?? '');
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isOpenActive ? 1.0 : 0.5,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: isOpenActive
                          ? () {
                              HapticFeedback.selectionClick();
                              if (refReadHome
                                  .isTimePassed(myMarketData?.openTime ?? '')) {
                                toast(
                                    context: context,
                                    'You can not play this game now');
                              } else {
                                refRead.changeOpenClose(isClose: false);
                              }
                            }
                          : null,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 6),
                        decoration: BoxDecoration(
                          gradient: refWatch.value?.isClose ?? false
                              ? LinearGradient(colors: [
                                  whiteBackgroundColor,
                                  Colors.grey[200]!
                                ])
                              : LinearGradient(colors: [
                                  Colors.green[400]!,
                                  Colors.green[700]!
                                ]),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              refWatch.value?.isClose == false
                                  ? Icons.lock_open
                                  : Icons.lock_outline,
                              color: refWatch.value?.isClose == false
                                  ? whiteBackgroundColor
                                  : textColor,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text('Open',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: refWatch.value?.isClose == false
                                      ? whiteBackgroundColor
                                      : textColor,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: 1.0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        if (refReadHome
                            .isTimePassed(myMarketData?.openTime ?? '')) {
                          toast(
                              context: context,
                              'You can not play this game now');
                        } else {
                          refRead.changeOpenClose(isClose: true);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 6),
                        decoration: BoxDecoration(
                          gradient: refWatch.value?.isClose ?? false
                              ? LinearGradient(colors: [
                                  Colors.green[400]!,
                                  Colors.green[700]!
                                ])
                              : LinearGradient(colors: [
                                  Colors.grey[400]!,
                                  Colors.grey[600]!
                                ]),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              refWatch.value?.isClose == true
                                  ? Icons.lock
                                  : Icons.lock_outline,
                              color: refWatch.value?.isClose == true
                                  ? whiteBackgroundColor
                                  : textColor,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Close',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: refWatch.value?.isClose == true
                                    ? whiteBackgroundColor
                                    : textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    });
  }
}
