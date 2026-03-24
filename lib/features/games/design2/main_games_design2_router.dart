import 'package:go_router/go_router.dart';
import 'package:sm_project/features/games/design2/jodi_digit_design2.dart';
import 'package:sm_project/features/games/design2/sp_dp_tp_design2.dart';
import 'package:sm_project/features/games/double_panna/double_panna.dart';
import 'package:sm_project/features/games/full_sangam/full_sangam.dart';
import 'package:sm_project/features/games/half_sangam/half_sangam.dart';
import 'package:sm_project/features/games/kalyan_morning.dart';
import 'package:sm_project/features/games/single_panna/single_panna.dart';
import 'package:sm_project/features/games/triple_panna/triple_panna.dart';

class MainGamesDesignPath2 {
  static const String singleDigit = '/singleDigit2';
  static const String kalyanMorning = '/kalyanMorning2';
  static const String singlePanna = '/singlePanna2';
  static const String doublePanna = '/doublePanna2';
  static const String halfSangam = '/halfSangam2';
  static const String fullSangam = '/fullSangam2';
  static const String spDpTp = '/spDpTp2';
  static const String choicePanaSPDP = '/choicePanaSPDP2';
  static const String spMotor = '/spMotor2';
  static const String dpMotor = '/dpMotor2';
  static const String triplePanna = '/triplePanna2';
  static const String jodiDigit = '/jodiDigit2';
}

final List<RouteBase> mainGamesDesign2Router = [
  GoRoute(
      path: MainGamesDesignPath2.kalyanMorning,
      name: MainGamesDesignPath2.kalyanMorning,
      builder: (context, state) {
        return const KalyanMorning();
      }),
  GoRoute(
      path: MainGamesDesignPath2.singlePanna,
      name: MainGamesDesignPath2.singlePanna,
      builder: (context, state) {
        return const SinglePanna();
      }),
  GoRoute(
      path: MainGamesDesignPath2.doublePanna,
      name: MainGamesDesignPath2.doublePanna,
      builder: (context, state) {
        return const DoublePanna();
      }),
  GoRoute(
      path: MainGamesDesignPath2.halfSangam,
      name: MainGamesDesignPath2.halfSangam,
      builder: (context, state) {
        return const HalfSangam();
      }),
  GoRoute(
      path: MainGamesDesignPath2.fullSangam,
      name: MainGamesDesignPath2.fullSangam,
      builder: (context, state) {
        return const FullSangam();
      }),
  GoRoute(
      path: MainGamesDesignPath2.triplePanna,
      name: MainGamesDesignPath2.triplePanna,
      builder: (context, state) {
        return const TriplePanna();
      }),
  GoRoute(
    path: MainGamesDesignPath2.jodiDigit,
    name: MainGamesDesignPath2.jodiDigit,
    builder: (context, state) {
      return const JodiDigitDesign2();
    },
  ),
  GoRoute(
    path: MainGamesDesignPath2.spDpTp,
    name: MainGamesDesignPath2.spDpTp,
    builder: (context, state) {
      return const SPDPTPDesign2();
    },
  ),
];
