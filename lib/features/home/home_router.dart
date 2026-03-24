import 'package:go_router/go_router.dart';
import 'package:sm_project/features/home/deposit_funds.dart';
import 'package:sm_project/features/home/home_screen.dart';
import 'package:sm_project/features/home/main_screen.dart';
import 'package:sm_project/features/home/withdrawal_screen.dart';
import 'package:sm_project/features/home/my_bids_screen.dart';
import 'package:sm_project/features/home/market_result_history_screen.dart';
import 'package:sm_project/features/home/notification_screen.dart';

class HomePath {
  static const String homeScreen = '/homeScreen';
  static const String deposit = '/deposit';
  static const String withdrawal = '/withdrawal';
  static const String myBids = '/my-bids';
  static const String marketResultHistory = '/market-result-history';
  static const String notifications = '/notifications';
}

final List<RouteBase> homeRouter = [
  GoRoute(
    path: HomePath.homeScreen,
    name: HomePath.homeScreen,
    builder: (context, state) {
      return const HomeScreen();
    },
  ),
  GoRoute(
      path: HomePath.deposit,
      name: HomePath.deposit,
      builder: (context, state) {
        return const Deposit();
      }),
  GoRoute(
      path: HomePath.withdrawal,
      name: HomePath.withdrawal,
      builder: (context, state) {
        return const Withdrawal();
      }),
  GoRoute(
      path: HomePath.myBids,
      name: HomePath.myBids,
      builder: (context, state) {
        return const MyBidsScreen();
      }),
  GoRoute(
      path: HomePath.marketResultHistory,
      name: HomePath.marketResultHistory,
      builder: (context, state) {
        return const MarketResultHistoryScreen();
      }),
  GoRoute(
      path: HomePath.notifications,
      name: HomePath.notifications,
      builder: (context, state) {
        return const NotificationScreen();
      }),
];
