import 'package:go_router/go_router.dart';
import 'package:sm_project/features/drawer/change_password.dart';
import 'package:sm_project/features/drawer/how_to_play.dart';
import 'package:sm_project/features/drawer/information.dart';
import 'package:sm_project/features/drawer/submit_idea.dart';
import 'package:sm_project/features/drawer/support.dart';
import 'package:sm_project/features/home/rates_screen.dart';

class DrawerPath {
  static const howToPlay = "/how-to-play";
  static const submitYourIdea = "/submit-your-idea";
  static const information = "/information";
  static const support = "/support";
  static const changePassword = "/changePassword";
  static const String ratesScreen = '/ratesScreen';
}

final List<RouteBase> drawerRouter = [
  GoRoute(
      path: DrawerPath.howToPlay,
      name: DrawerPath.howToPlay,
      builder: (context, state) {
        return const HowToPlayScreen();
      }),
  GoRoute(
    path: DrawerPath.submitYourIdea,
    name: DrawerPath.submitYourIdea,
    builder: (context, state) {
      return const SubmitIdeaScreen();
    },
  ),
  GoRoute(
    path: DrawerPath.information,
    name: DrawerPath.information,
    builder: (context, state) {
      return const Information();
    },
  ),
  GoRoute(
    path: DrawerPath.support,
    name: DrawerPath.support,
    builder: (context, state) {
      return const Support();
    },
  ),
  GoRoute(
    path: DrawerPath.changePassword,
    name: DrawerPath.changePassword,
    builder: (context, state) {
      return ChangePassword();
    },
  ),
  GoRoute(
    path: DrawerPath.ratesScreen,
    name: DrawerPath.ratesScreen,
    builder: (context, state) {
      return const RatesScreen();
    },
  ),
];
