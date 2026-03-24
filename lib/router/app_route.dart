// bool isUserLogin = Prefs.getBool(PrefNames.isLogin) ?? false;

import 'package:sm_project/Quiz/screens/category_screen.dart';
import 'package:sm_project/Quiz/screens/question_screen.dart';
import 'package:sm_project/Quiz/screens/start_quiz.dart';
import 'package:sm_project/features/card_jackpot/card_jackpot_router.dart';
import 'package:sm_project/features/chat/chat_screen.dart';
import 'package:sm_project/features/drawer/drawer_router.dart';
import 'package:sm_project/features/games/kalyan_morning.dart';
// import 'package:sm_project/screen/homescreen/games_mode_screen/open_games_mode/open_games/choice_pana_sp_dp.dart';
// import 'package:sm_project/screen/homescreen/games_mode_screen/open_games_mode/open_games/double_panna.dart';
// import 'package:sm_project/screen/homescreen/games_mode_screen/open_games_mode/open_games/dp_motor.dart';
// import 'package:sm_project/screen/homescreen/games_mode_screen/open_games_mode/open_games/full_sangam.dart';
// import 'package:sm_project/screen/homescreen/games_mode_screen/open_games_mode/open_games/half_sangam.dart';
// import 'package:sm_project/screen/homescreen/games_mode_screen/open_games_mode/open_games/jodi_digit.dart';
// import 'package:sm_project/screen/homescreen/games_mode_screen/open_games_mode/open_games/single_digit.dart';
// import 'package:sm_project/screen/homescreen/games_mode_screen/open_games_mode/open_games/single_panna.dart';
// import 'package:sm_project/screen/homescreen/games_mode_screen/open_games_mode/open_games/sp_dp_tp.dart';
// import 'package:sm_project/screen/homescreen/games_mode_screen/open_games_mode/open_games/sp_motor.dart';
// import 'package:sm_project/screen/homescreen/games_mode_screen/open_games_mode/open_games/triple_panna.dart';
import 'package:sm_project/features/home/bids_history_screen.dart';
import 'package:sm_project/features/home/bids_win_history.dart';
import 'package:sm_project/features/home/home_router.dart';
import 'package:sm_project/features/home/transaction_history_screen.dart';
import 'package:sm_project/features/profile/profile_screen.dart';
import 'package:sm_project/features/splash_screen.dart';
import 'package:sm_project/features/starline/starline_router.dart';
import 'package:sm_project/main.dart';
import 'package:sm_project/screen/auth/forgot_password/screen/create_new_password.dart';
import 'package:sm_project/screen/auth/forgot_password/screen/forgot_mpin.dart';
import 'package:sm_project/screen/auth/forgot_password/screen/forgot_password.dart';
import 'package:sm_project/screen/auth/forgot_password/screen/otp_forgot_password.dart';
import 'package:sm_project/screen/auth/initial_screen.dart';
import 'package:sm_project/screen/auth/login_screen.dart';
import 'package:sm_project/screen/auth/otp_verify_screen.dart';
import 'package:sm_project/screen/auth/register_screen.dart';
import 'package:sm_project/screen/homescreen/setting/setting.dart';
import 'package:sm_project/utils/filecollection.dart';

import '../Quiz/model/category.dart';
import '../features/home/main_screen.dart';

bool isUserLogin = Prefs.getBool(PrefNames.isLogin) ?? false;

CustomTransitionPage buildPageWithDefaultTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  Offset? begin,
}) {
  return CustomTransitionPage<T>(
    fullscreenDialog: true,
    transitionDuration: const Duration(seconds: 1),
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
          alwaysIncludeSemantics: true, opacity: animation, child: child);

      // SlideTransition(
      //   position: Tween<Offset>(
      //     begin: const Offset(0, 1.0),
      //     end: Offset.fromDirection(0, 1.0),
      //   ).animate(animation),
      //   child: child,
      // );
    },
  );
}

String getInitialRoute() {
  // if () {
  //   return RouteNames.splashScreen;
  // } else {
  return RouteNames.splashScreen;
  // }
}

final appRoute = GoRouter(
    initialLocation: getInitialRoute(),
    navigatorKey: navigatorKey,
    routes: [
      GoRoute(
          path: RouteNames.splashScreen,
          name: RouteNames.splashScreen,
          builder: (context, state) {
            return const SplashScreen();
          }),
      GoRoute(
          path: RouteNames.initial,
          name: RouteNames.initial,
          builder: (context, state) {
            return const InitialScreen();
          }),
      GoRoute(
          path: RouteNames.registerScreen,
          name: RouteNames.registerScreen,
          builder: (context, state) {
            return RegisterScreen();
          }),

      GoRoute(
          path: RouteNames.forgotPassword,
          name: RouteNames.forgotPassword,
          builder: (context, state) {
            return ForgotPassword();
          }),

      GoRoute(
          path: '/otp/:mobile',
          name: RouteNames.otpforgotPassword,
          builder: (context, state) {
            return OTPForgotVerify(
              mobile: state.pathParameters['mobile'] ?? '',
            );
          }),

      GoRoute(
          path: RouteNames.createPassword,
          name: RouteNames.createPassword,
          builder: (context, state) {
            return CreateNewPassword();
          }),

      GoRoute(
          path: RouteNames.forgotMpinPassword,
          name: RouteNames.forgotMpinPassword,
          builder: (context, state) {
            return ForgotMpin();
          }),

      GoRoute(
          path: RouteNames.logInScreen,
          name: RouteNames.logInScreen,
          builder: (context, state) {
            return LoginScreen();
          }),
      GoRoute(
          path: '/otp/:mobile/:password',
          name: RouteNames.otpScreen,
          builder: (context, state) {
            return OTPVerifyScreen(
              mobile: state.pathParameters['mobile'] ?? '',
              password: state.pathParameters['password'] ?? '',
            );
          }),

      // GoRoute(
      //     path: RouteNames.mpinPassword,
      //     name: RouteNames.mpinPassword,
      //     builder: (context, state) {
      //       return const MPin();
      //     }),

      GoRoute(
          path: RouteNames.bids,
          name: RouteNames.bids,
          builder: (context, state) {
            return const BidHistoryScreen();
          }),

      GoRoute(
          path: RouteNames.winbids,
          name: RouteNames.winbids,
          builder: (context, state) {
            return const BidWinHistoryScreen();
          }),

      GoRoute(
          path: RouteNames.kalyanMorning,
          name: RouteNames.kalyanMorning,
          builder: (context, state) {
            return const KalyanMorning();
          }),

      // GoRoute(
      //     path: RouteNames.kalyanOpenCrossJodi,
      //     name: RouteNames.kalyanOpenCrossJodi,
      //     builder: (context, state) {
      //       return const KalyanOpenCrossJodi();
      //     }),
      // GoRoute(
      //     path: RouteNames.singleDigit,
      //     name: RouteNames.singleDigit,
      //     builder: (context, state) {
      //       return const SingleDigit();
      //     }),
      // GoRoute(
      //     path: RouteNames.singlePanna,
      //     name: RouteNames.singlePanna,
      //     builder: (context, state) {
      //       return const SinglePanna();
      //     }),

      // GoRoute(
      //     path: RouteNames.doublePanna,
      //     name: RouteNames.doublePanna,
      //     builder: (context, state) {
      //       return const DoublePanna();
      //     }),

      // GoRoute(
      //     path: RouteNames.halfSangam,
      //     name: RouteNames.halfSangam,
      //     builder: (context, state) {
      //       return const HalfSangam();
      //     }),

      // GoRoute(
      //     path: RouteNames.fullSangam,
      //     name: RouteNames.fullSangam,
      //     builder: (context, state) {
      //       return const FullSangam();
      //     }),

      // GoRoute(
      //     path: RouteNames.triplePanna,
      //     name: RouteNames.triplePanna,
      //     builder: (context, state) {
      //       return const TriplePanna();
      //     }),
      // GoRoute(
      //     path: RouteNames.jodiDigit,
      //     name: RouteNames.jodiDigit,
      //     builder: (context, state) {
      //       return const JodiDigit();
      //     }),
      // GoRoute(
      //     path: RouteNames.spDpTp,
      //     name: RouteNames.spDpTp,
      //     builder: (context, state) {
      //       return const SPDPTP();
      //     }),

      // GoRoute(
      //     path: RouteNames.choicePanaSPDP,
      //     name: RouteNames.choicePanaSPDP,
      //     builder: (context, state) {
      //       return const ChoicePanaSPDP();
      //     }),

      // GoRoute(
      //     path: RouteNames.spMotor,
      //     name: RouteNames.spMotor,
      //     builder: (context, state) {
      //       return const SPMotor();
      //     }),

      // GoRoute(
      //     path: RouteNames.dpMotor,
      //     name: RouteNames.dpMotor,
      //     builder: (context, state) {
      //       return const DPMotor();
      //     }),
      GoRoute(
          path: RouteNames.settingScreen,
          name: RouteNames.settingScreen,
          builder: (context, state) {
            return const Setting();
          }),
      GoRoute(
          path: RouteNames.profileScreen,
          name: RouteNames.profileScreen,
          builder: (context, state) {
            return const ProfileScreen();
          }),
      GoRoute(
          path: RouteNames.transactionHistory,
          name: RouteNames.transactionHistory,
          builder: (context, state) {
            return const TransactionHistory();
          }),
      GoRoute(
        path: RouteNames.mainScreen, // or whatever path you prefer
        name: RouteNames.mainScreen,
        builder: (context, state) => const MainScreen(), // Replace with your actual Widget name
      ),
      GoRoute(
        path: RouteNames.startQuiz, // or whatever path you prefer
        name: RouteNames.startQuiz,
        builder: (context, state) => const StartQuizScreen(), // Replace with your actual Widget name
      ),
      GoRoute(
        path: RouteNames.questionscreen, // or whatever path you prefer
        name: RouteNames.questionscreen,
        builder: (context, state) => const QuestionScreen(), // Replace with your actual Widget name
      ),
      GoRoute(
        path: RouteNames.categoryQuiz, // or whatever path you prefer
        name: RouteNames.categoryQuiz,
        builder: (context, state) => const CategoryScreen(), // Replace with your actual Widget name
      ),
      GoRoute(
        path: RouteNames.subcategoryQuiz,
        name: RouteNames.subcategoryQuiz,
        builder: (context, state) {
          final category = state.extra as CategoryModel;
          return SubCategoryScreen(category: category);
        },
      ),
      GoRoute(
        path: RouteNames.resultscreen, // or whatever path you prefer
        name: RouteNames.resultscreen,
        builder: (context, state) => const ResultScreen(), // Replace with your actual Widget name
      ),
      GoRoute(
        path: RouteNames.chatScreen, // or whatever path you prefer
        name: RouteNames.chatScreen,
        builder: (context, state) => const ChatScreen(), // Replace with your actual Widget name
      ),
      ...cardJackpotRouter,
      ...drawerRouter,
      ...starlineRouter,
      ...homeRouter,
      // Quiz routes
    ]);
