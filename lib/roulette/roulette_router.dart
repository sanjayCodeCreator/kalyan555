import 'package:go_router/go_router.dart';
import 'package:sm_project/roulette/roulette_screen.dart';

class RoulettePath {
  static const roulette = "/roulette";
}

final List<RouteBase> rouletteRouter = [
  GoRoute(
    path: RoulettePath.roulette,
    name: RoulettePath.roulette,
    builder: (context, state) {
      return const RouletteScreen();
    },
  ),
];
