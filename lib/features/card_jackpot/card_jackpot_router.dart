import 'package:go_router/go_router.dart';
import 'package:sm_project/features/card_jackpot/card_jackpot_screen.dart';

class CardJackpotPath {
  static const cardJackpot = "/card-jackpot";
}

final List<RouteBase> cardJackpotRouter = [
  GoRoute(
    path: CardJackpotPath.cardJackpot,
    name: CardJackpotPath.cardJackpot,
    builder: (context, state) {
      return const CardJackpotScreen();
    },
  ),
];
