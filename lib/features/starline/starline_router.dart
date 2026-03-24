import 'package:go_router/go_router.dart';
import 'package:sm_project/features/starline/starline_bid_history.dart';
import 'package:sm_project/features/starline/starline_screen.dart';
import 'package:sm_project/features/starline/starline_win_history.dart';
import 'package:sm_project/features/starline/starline_result_history_screen.dart';

class StarlinePath {
  static const starline = "/starline";
  static const starlineBidHistory = "/starline-bid-history";
  static const starlineBidWinHistory = "/starline-bid-win-history";
  static const starlineResultHistory = "/starline-result-history";
}

final List<RouteBase> starlineRouter = [
  GoRoute(
    path: StarlinePath.starline,
    name: StarlinePath.starline,
    builder: (context, state) {
      return const StarlineScreen();
    },
  ),
  GoRoute(
    path: StarlinePath.starlineBidHistory,
    name: StarlinePath.starlineBidHistory,
    builder: (context, state) {
      return const StarlineBidHistoryScreen();
    },
  ),
  GoRoute(
    path: StarlinePath.starlineBidWinHistory,
    name: StarlinePath.starlineBidWinHistory,
    builder: (context, state) {
      return const StarlineBidWinHistoryScreen();
    },
  ),
  GoRoute(
    path: StarlinePath.starlineResultHistory,
    name: StarlinePath.starlineResultHistory,
    builder: (context, state) {
      return const StarlineResultHistoryScreen();
    },
  ),
];
