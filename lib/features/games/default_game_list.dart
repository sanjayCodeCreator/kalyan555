import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/features/games/design2/double_panna_design2.dart';
import 'package:sm_project/features/games/design2/dp_motor.dart';
import 'package:sm_project/features/games/design2/jodi_digit_design2.dart';
import 'package:sm_project/features/games/design2/single_panna_design2.dart';
import 'package:sm_project/features/games/design2/sp_motor.dart';
import 'package:sm_project/features/games/design2/tp_motor.dart';
import 'package:sm_project/features/games/double_panna_bulk/double_panna_bulk_screen.dart';
import 'package:sm_project/features/games/dp_motor_game/dp_motor_game_screen.dart';
import 'package:sm_project/features/games/full_sangam/full_sangam.dart';
import 'package:sm_project/features/games/half_sangam/half_sangam.dart';
import 'package:sm_project/features/games/jodi_bulk/jodi_bulk_screen.dart';
import 'package:sm_project/features/games/odd_even/odd_even_screen.dart';
import 'package:sm_project/features/games/red_jodi/red_jodi.dart';
import 'package:sm_project/features/games/single_digit/single_digit_new.dart';
import 'package:sm_project/features/games/single_digit_bulk/single_digit_bulk_screen.dart';
import 'package:sm_project/features/games/single_panna_bulk/single_panna_bulk_screen.dart';
import 'package:sm_project/features/games/sp_motor_game/sp_motor_game_screen.dart';
import 'package:sm_project/features/games/triple_panna/triple_panna.dart';
import 'package:sm_project/features/games/triple_panna_bulk/triple_panna_bulk_screen.dart';
import 'package:sm_project/features/starline/starline_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

List<Map> defaultGamelist(BuildContext context, WidgetRef ref, String tag,
        String marketId, String marketName) =>
    [
      {
        'image': "assets/images/singledigit.png",
        'text': 'Single Digit',
        'number': '0,1,2,3,...',
        'click': () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SingleDigitNew(
                    tag: tag,
                    marketId: marketId,
                    marketName: marketName,
                  )));
        }
      },
      {
        'image': "assets/images/singledigitbulk.png",
        'text': 'Single Digit Bulk',
        'number': '0,1,2,3,...',
        'click': () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SingleDigitBulkScreen(
                    tag: tag,
                    id: marketId,
                    name: marketName,
                  )));
        }
      },
      if (!(ref.watch(starlineNotifierProvider)))
        {
          'image': "assets/images/jodidigit.png",
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
      if (!(ref.watch(starlineNotifierProvider)))
        {
          'image': "assets/images/jodidigitbulk.png",
          'text': 'Jodi Digit Bulk',
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
                builder: (context) => JodiBulkScreen(
                  tag: tag,
                  id: marketId,
                  name: marketName,
                ),
              ),
            );
          }
        },
      {
        'image': "assets/images/singlepanna.png",
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
        'image': "assets/images/singlepannabulk.png",
        'text': 'Single Panna Bulk',
        'number': '123,478,150,...',
        'click': () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => SinglePannaBulkScreen(
                    tag: tag,
                    id: marketId,
                    name: marketName,
                  )));
        }
      },
      {
        'image': "assets/images/doublepanna.png",
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
      {
        'image': "assets/images/doublepannabulk.png",
        'text': 'Double Panna',
        'number': '112,223,445,556,....',
        'click': () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => DoublePanaBulkScreen(
                    tag: tag,
                    id: marketId,
                    name: marketName,
                  )));
        }
      },
      {
        'image': "assets/images/triplepanna.png",
        'text': 'Triple Panna',
        'number': '000,111,555,....',
        'click': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TriplePanna(
                tag: tag,
                marketId: marketId,
                marketName: marketName,
              ),
            ),
          );
        }
      },
      {
        'image': "assets/images/triplepannabulk.png",
        'text': 'Triple Panna Bulk',
        'number': '000,111,555,....',
        'click': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TriplePanaBulkScreen(
                tag: tag,
                id: marketId,
                name: marketName,
              ),
            ),
          );
        }
      },
      if (!(ref.watch(starlineNotifierProvider)))
        {
          'image': "assets/images/halfsangam.png",
          'text': 'Half Sangam',
          'number': '000,111,555,...',
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
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HalfSangam(
                      tag: tag,
                      marketId: marketId,
                      marketName: marketName,
                    )));
          }
        },
      if (!(ref.watch(starlineNotifierProvider)))
        {
          'image': "assets/images/fullsangam.png",
          'text': 'Full Sangam',
          'number': '128,137,146,...',
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

            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => FullSangam(
                      tag: tag,
                      marketId: marketId,
                      marketName: marketName,
                    )));
          }
        },
      if (!(ref.watch(starlineNotifierProvider)))
        {
          'image': "assets/images/redbracket.png",
          'text': 'Red Bracket',
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
                builder: (context) => RedJodiScreen(
                  tag: tag,
                  id: marketId,
                  name: marketName,
                ),
              ),
            );
          }
        },
      {
        'image': "assets/images/oddeven.png",
        'text': 'Odd Even',
        'number': '0,1,2,3,...',
        'click': () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => OddEvenScreen(
                    tag: tag,
                    id: marketId,
                    name: marketName,
                  )));
        }
      },
      if (!(ref.watch(starlineNotifierProvider)))
        {
          'image': "assets/images/spmotor.png",
          'text': 'SP Motor',
          'number': '00,12,15,55,98,...',
          'click': () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SpMotorGameScreen(
                  tag: tag,
                  id: marketId,
                  name: marketName,
                ),
              ),
            );
          }
        },
      if (!(ref.watch(starlineNotifierProvider)))
        {
          'image': "assets/images/dpmotor.png",
          'text': 'DP Motor',
          'number': '00,12,15,55,98,...',
          'click': () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DpMotorGameScreen(
                  tag: tag,
                  id: marketId,
                  name: marketName,
                ),
              ),
            );
          }
        },
      if (!(ref.watch(starlineNotifierProvider)))
        {
          'image': "assets/images/sp.png",
          'text': 'SP',
          'number': '00,12,15,55,98,...',
          'click': () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SpMotor(
                  tag: tag,
                  marketId: marketId,
                  marketName: marketName,
                ),
              ),
            );
          }
        },
      if (!(ref.watch(starlineNotifierProvider)))
        {
          'image': "assets/images/dp.png",
          'text': 'DP',
          'number': '00,12,15,55,98,...',
          'click': () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DPMotor(
                  tag: tag,
                  marketId: marketId,
                  marketName: marketName,
                ),
              ),
            );
          }
        },
      if (!(ref.watch(starlineNotifierProvider)))
        {
          'image': "assets/images/tp.png",
          'text': 'TP',
          'number': '00,12,15,55,98,...',
          'click': () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TpMotor(
                  tag: tag,
                  marketId: marketId,
                  marketName: marketName,
                ),
              ),
            );
          }
        },
    ].toList();
