import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/features/games/design2/double_panna_design2.dart';
import 'package:sm_project/features/games/design2/jodi_digit_design2.dart';
import 'package:sm_project/features/games/design2/single_panna_design2.dart';
import 'package:sm_project/features/games/design2/sp_dp_tp_design2.dart';
import 'package:sm_project/features/starline/starline_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

List<Map> design2Gamelist(BuildContext context, WidgetRef ref, String tag,
        String marketId, String marketName) =>
    [
      if (!(ref.watch(starlineNotifierProvider)))
        {
          'image': jodiDigitLogo,
          'text': 'Jodi Digit',
          'number': '00,12,15,55,98,...',
          'click': () {
            final refReadHome = ref.read(homeNotifierProvider.notifier);
            final refWatchHome = ref.watch(homeNotifierProvider);
            final myMarketData = refWatchHome.value?.getAllMarketModel?.data
                ?.where((element) => element.sId == marketId)
                .toList()
                .first;
            if (refReadHome.isTimePassed(myMarketData?.openTime ?? '')) {
              toast(
                  context: context, 'Game is only available before open time.');
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => JodiDigitDesign2(
                  tag: tag,
                  marketId: marketId,
                  marketName: marketName,
                ),
              ),
            );
          }
        },
      {
        'image': kalyanSinglePanelLogo,
        'text': 'Single Panna',
        'number': '123,478,150,...',
        'click': () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SinglePannaDesign2(
                    tag: tag,
                    marketId: marketId,
                    marketName: marketName,
                  )));
        }
      },
      {
        'image': kalyanDoublePanelLogo,
        'text': 'Double Panna',
        'number': '112,223,445,556,....',
        'click': () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DoublePannaDesign2(
                    tag: tag,
                    marketId: marketId,
                    marketName: marketName,
                  )));
        }
      },
      if (!(ref.watch(starlineNotifierProvider)))
        {
          'image': jodiDigitLogo,
          'text': 'SPDPTP',
          'number': '00,12,15,55,98,...',
          'click': () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SPDPTPDesign2(
                  tag: tag,
                  marketId: marketId,
                  marketName: marketName,
                ),
              ),
            );
          }
        },
    ].toList();
