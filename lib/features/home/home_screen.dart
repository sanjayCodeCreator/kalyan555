import 'dart:developer';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sm_project/controller/model/login_model.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/controller/riverpod/today_winners_notifier.dart';
import 'package:sm_project/features/aviator/screen/aviator_game_screen.dart';
import 'package:sm_project/features/chat/chat_screen.dart';
import 'package:sm_project/features/gali_desawar/gali_desawar_screen.dart';
import 'package:sm_project/features/games/kalyan_morning.dart';
import 'package:sm_project/features/home/chart_screen.dart';
import 'package:sm_project/features/home/get_setting_notifier.dart';
import 'package:sm_project/features/home/home_banner.dart';
import 'package:sm_project/features/home/notification_screen.dart';
import 'package:sm_project/features/reusubility_widget/background_wrapper.dart';
import 'package:sm_project/features/starline/starline_notifier.dart';
import 'package:sm_project/features/starline/starline_screen.dart';
import 'package:sm_project/features/withdrawal_deposit_leaderboard/vertical_leaderboard_text.dart';
import 'package:sm_project/local_game_zones/features/select_game/select_game_screen.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:vibration/vibration.dart';

import '../../utils/customization.dart';
import '../drawer/x_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  final LoginModel? userData = UserData.geUserData();
  final RefreshController _refreshController = RefreshController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    ref.read(homeNotifierProvider.notifier).getAllMarket(context);
    ref.read(getSettingNotifierProvider.notifier).getSettingModel();
    ref.read(homeNotifierProvider.notifier).getParticularPlayerModel(context);
    ref.read(todayWinnersNotifierProvider.notifier).getTodayWinners();
    debugPrint(userData?.tokenData?.token?.toString() ?? '');
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   ref.read(starlineNotifierProvider.notifier).changeStarlineStatus(false);
    // });
    // UpdateChecker.checkForUpdate();

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   Future.delayed(const Duration(seconds: 1), () {
    //     if (!mounted) return;
    //     _checkForAppUpdate();
    //   });
    // });

    // Initialize animation controller for ADD MONEY button blinking
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _opacityAnimation =
        Tween<double>(begin: 1.0, end: 0.6).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // void _checkForAppUpdate() {
  //   if (!mounted) return;
  //   final settingState = ref.read(getSettingNotifierProvider);

  //   settingState.when(
  //     data: (data) {
  //       if (data.getSettingModel != null) {
  //         ref
  //             .read(homeNotifierProvider.notifier)
  //             .checkAppVersion(context, data.getSettingModel!);
  //       } else {
  //         log('SettingModel is null, cannot check for updates',
  //             name: 'Version Check');
  //       }
  //     },
  //     loading: () {
  //       log('Settings are still loading, cannot check for updates',
  //           name: 'Version Check');
  //     },
  //     error: (error, stack) {
  //       log('Settings error, cannot check for updates: $error',
  //           name: 'Version Check');
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final refWatch = ref.watch(homeNotifierProvider);
    final refRead = ref.read(homeNotifierProvider.notifier);
    final getSetting = ref.watch(getSettingNotifierProvider);

    // New vibrant color scheme - matching login/register screens
    const primaryColor = Color(0xFF6366F1);

    final isBetting = refWatch.value?.getParticularPlayerModel?.data?.betting;
    if (isBetting == null) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: CircularProgressIndicator()),
        ],
      );
    }
    // else if (isBetting == false) {
    //   return const SelectGameScreen();
    // }

    return BackgroundWrapper(
        child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: const Color(0xffeeeeee),
            appBar: refWatch.value?.getParticularPlayerModel?.data?.betting == true ?  AppBar(
                backgroundColor: darkBlue,
                elevation: 0,
                centerTitle: true,
                shape: const Border(
                  bottom: BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                leading: InkWell(
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(
                        Icons.menu_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    )),
                title: Text('${Customization.appname}',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                actions: [
                  Visibility(
                      visible: refWatch
                              .value?.getParticularPlayerModel?.data?.betting ==
                          true,
                      child: InkWell(
                          onTap: () {
                            context.pushNamed(RouteNames.deposit);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(children: [
                              const Icon(
                                Icons.currency_rupee_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                  refWatch.value?.getParticularPlayerModel?.data
                                          ?.wallet
                                          .toString() ??
                                      '0',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white))
                            ]),
                          ))),
                  const SizedBox(width: 12),
                  Visibility(
                    visible: refWatch
                            .value?.getParticularPlayerModel?.data?.betting ==
                        true,
                    child: InkWell(
                      onTap: () {
                        ref
                            .read(homeNotifierProvider.notifier)
                            .onRefresh(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  )
                ]) : null,
            drawer: const XDrawer(),
            body: SafeArea(
                child: Column(children: [
              // Today's Winners ticker-like strip
                   Consumer(
                builder: (context, ref, child) {
                  final winnersAsync = ref.watch(todayWinnersNotifierProvider);

                  return winnersAsync.when(
                    data: (winnersData) {
                      if (winnersData.data == null ||
                          winnersData.data!.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      // Build winners text
                      String winnersText = '';
                      for (var market in winnersData.data!) {
                        if (market.winners != null) {
                          for (var winner in market.winners!) {
                            String formattedAmount =
                                _formatIndianCurrency(winner.win ?? 0);
                            winnersText +=
                                'Rank ${winner.position}- ${winner.userName} won ₹$formattedAmount in ${market.marketName}.   ';
                          }
                        }
                      }

                      if (winnersText.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        height: 30,
                        width: double.infinity,
                        color: const Color(0xFF27717a),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Marquee(
                          text: winnersText,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          scrollAxis: Axis.horizontal,
                          blankSpace: 40.0,
                          velocity: 30.0,
                          startPadding: 30.0,
                          accelerationDuration:
                              const Duration(milliseconds: 300),
                          decelerationDuration:
                              const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (error, stack) => const SizedBox.shrink(),
                  );
                },
              ),
              const SizedBox(height: 8),

                  refWatch.value?.getParticularPlayerModel?.data?.betting == true ?  const TextCycleWidget()  : SizedBox.shrink(),

              const SizedBox(height: 2),

              const HomeBannerComponent(),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Column(
                      children: [Column(
                        children: [
                          const SizedBox(height: 12),
                          // Top Row
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 7.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Whatsapp Button - This will take full width if the other two are removed
                               (( refWatch.value?.getParticularPlayerModel?.data?.betting ?? false ) ) ?
                               Expanded(
                                 child: InkWell(
                                   onTap: () async {
                                     HapticFeedback.selectionClick();
                                     context.pushNamed(RouteNames.chatScreen);
                                     // await ref.read(getSettingNotifierProvider.notifier).getSettingModel();
                                     // final setting = ref.read(getSettingNotifierProvider).value?.getSettingModel?.data;
                                     // refRead.launchWhatsapp(setting?.whatsapp ?? "");
                                   },
                                   child: Container(
                                     height: 80,
                                     decoration: BoxDecoration(
                                       color: darkBlue.withOpacity(0.7),
                                       borderRadius: BorderRadius.circular(12),
                                       border: Border.all(
                                         color: const Color(0xFFD9BC4C),
                                         width: 1.5,
                                       ),
                                     ),
                                     child: Column(
                                       mainAxisAlignment: MainAxisAlignment.center,

                                       spacing: 2,
                                       children: [
                                         // Image.asset(
                                         //   'assets/images/whatsapp.png',
                                         //   width: 28,
                                         //   height: 28,
                                         // ),
                                         Icon(Icons.support_agent, size: 28,),
                                         const SizedBox(height: 6),
                                         Text(
                                           'Support Chat',
                                           style: GoogleFonts.poppins(
                                             color: Colors.black,
                                             fontSize: 11,
                                             fontWeight: FontWeight.w500,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ),
                               ):Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      HapticFeedback.selectionClick();
                                      context.pushNamed(RouteNames.chatScreen);
                                      // await ref.read(getSettingNotifierProvider.notifier).getSettingModel();
                                      // final setting = ref.read(getSettingNotifierProvider).value?.getSettingModel?.data;
                                      // refRead.launchWhatsapp(setting?.whatsapp ?? "");
                                    },
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: darkBlue.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFD9BC4C),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center
                                        ,
                                        spacing: 2,
                                        children: [
                                          const SizedBox(width: 20,),
                                          // Image.asset(
                                          //   'assets/images/whatsapp.png',
                                          //   width: 28,
                                          //   height: 28,
                                          // ),
                                          const Icon(Icons.support_agent, size: 28,)
 ,                                         const SizedBox(height: 6, width: 6,),
                                          Text(
                                            'SUPPORT CHAT',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )

                                ,

                                // Conditional Buttons: only added if betting is enabled
                                if (refWatch.value?.getParticularPlayerModel?.data?.betting ?? false) ...[
                                  const SizedBox(width: 5),
                                  // Add Points Button
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        context.pushNamed(RouteNames.deposit);
                                      },
                                      child: Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: darkBlue.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFFD9BC4C),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/add_money.png',
                                              width: 32,
                                              height: 32,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Add Points',
                                              style: GoogleFonts.poppins(
                                                color: Colors.black,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  // Withdraw Button
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        context.pushNamed(RouteNames.withdrawal);
                                      },
                                      child: Container(
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: darkBlue.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFFD9BC4C),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/images/withdrawal2.png',
                                              width: 26,
                                              height: 26,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Withdraw',
                                              style: GoogleFonts.poppins(
                                                color: Colors.black,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Bottom Row - Play StarLine, Gali Disawar
                          // Wrapped in a collection IF so the entire Row disappears if betting is disabled
                          if (refWatch.value?.getParticularPlayerModel?.data?.betting ?? false) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        ref.read(starlineNotifierProvider.notifier).changeStarlineStatus(true);
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const StarlineScreen()));
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: darkBlue.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFD9BC4C), width: 1.5),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.star, size: 24, color: Colors.yellow),
                                            const SizedBox(width: 8),
                                            Text('Play StarLine', style: GoogleFonts.poppins(
                                                color:                         Colors.black,

                                                 fontSize: 14, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const GaliDesawarScreen()));
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: darkBlue.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFD9BC4C), width: 1.5),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset('assets/images/gali.png', width: 24, height: 24),
                                            const SizedBox(width: 8),
                                            Text('Gali Disawar', style: GoogleFonts.poppins(                                              color: Colors.black
                                                , fontSize: 14, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],

                          // Aviator Button
                          // if ((getSetting.value?.getSettingModel?.data?.aviator?.active ?? false) &&
                          //     (getSetting.value?.getSettingModel?.data?.aviator?.maintenance != true) &&
                          //     (refWatch.value?.getParticularPlayerModel?.data?.betting ?? false))
                          //   Padding(
                          //     padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          //     child: InkWell(
                          //       onTap: () {
                          //         HapticFeedback.selectionClick();
                          //         Navigator.push(context, MaterialPageRoute(builder: (context) => const AviatorGameScreen()));
                          //       },
                          //       child: Container(
                          //         height: 50,
                          //         decoration: BoxDecoration(
                          //           gradient: const LinearGradient(
                          //             colors: [Color(0xFF1A1A2E), Color(0xFF000000)],
                          //             begin: Alignment.topLeft,
                          //             end: Alignment.bottomRight,
                          //           ),
                          //           borderRadius: BorderRadius.circular(12),
                          //           border: Border.all(color: const Color(0xFFE53935), width: 1.5),
                          //           boxShadow: [
                          //             BoxShadow(
                          //               color: const Color(0xFFE53935).withOpacity(0.25),
                          //               blurRadius: 8,
                          //               offset: const Offset(0, 2),
                          //             ),
                          //           ],
                          //         ),
                          //         child: Row(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           children: [
                          //             SvgPicture.asset('assets/aviator/aviator_plane.svg', width: 28, height: 28),
                          //             const SizedBox(width: 10),
                          //             Text('Play Aviator', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          //           ],
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                        ],
                      ),
                        if (refWatch.value?.getAllMarketModel?.data?.isEmpty ??
                            true) ...{
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(primaryColor),
                              ),
                            ),
                          )
                        } else ...{
                          if (refWatch.value?.getParticularPlayerModel?.data
                                  ?.betting ==
                              null) ...{
                            const SizedBox()
                          } else ...{
                            // market list
                            Expanded(
                              child: CustomRefreshIndicator(
                                onRefresh: () async {
                                  refRead.onRefresh(context);
                                },
                                builder: (context, widget, controller) {
                                  return CustomMaterialIndicator(
                                    onRefresh: () async {
                                      refRead.onRefresh(context);
                                    },
                                    indicatorBuilder: (context, controller) {
                                      return Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
                                          color: primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.refresh_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      );
                                    },
                                    controller: controller,
                                    child: widget,
                                  );
                                },
                                child: ListView.builder(
                                    itemCount: refWatch
                                            .value?.getAllMarketModel?.data
                                            ?.where((e) => e.tag == "main")
                                            .length ??
                                        0,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    // itemBuilder: (context, index) {
                                    //   final myMarketData = refWatch
                                    //       .value?.getAllMarketModel?.data
                                    //       ?.where((e) => e.tag == "main")
                                    //       .toList()[index];
                                    //
                                    //   return myMarketData?.tag != 'starline' &&
                                    //           myMarketData?.status == true
                                    //       ? Column(
                                    //           crossAxisAlignment:
                                    //               CrossAxisAlignment.start,
                                    //           children: [
                                    //             InkWell(
                                    //               onTap: () {
                                    //                 if (myMarketData
                                    //                         ?.marketStatus ==
                                    //                     false) {
                                    //                   refRead
                                    //                       .updateContainerSize(
                                    //                           index);
                                    //                   Vibration.vibrate(
                                    //                       duration: 800,
                                    //                       amplitude: 84);
                                    //                   toast(
                                    //                       context: context,
                                    //                       'Holiday!!!, Market is close.');
                                    //                   return;
                                    //                 }
                                    //                 if (refWatch
                                    //                         .value
                                    //                         ?.getParticularPlayerModel
                                    //                         ?.data
                                    //                         ?.betting ==
                                    //                     false) {
                                    //                   refRead
                                    //                       .updateContainerSize(
                                    //                           index);
                                    //                   Vibration.vibrate(
                                    //                       duration: 800,
                                    //                       amplitude: 84);
                                    //                   toast(
                                    //                       'Please contact to admin');
                                    //                 } else if (refRead
                                    //                     .isTimePassed(myMarketData
                                    //                             ?.closeTime ??
                                    //                         '')) {
                                    //                   refRead
                                    //                       .updateContainerSize(
                                    //                           index);
                                    //                   Vibration.vibrate(
                                    //                       duration: 800,
                                    //                       amplitude: 100);
                                    //                   toast(
                                    //                       'Betting is Closed for Today');
                                    //                 } else {
                                    //                   HapticFeedback
                                    //                       .selectionClick();
                                    //                   ref
                                    //                       .read(
                                    //                           starlineNotifierProvider
                                    //                               .notifier)
                                    //                       .changeStarlineStatus(
                                    //                           false);
                                    //                   refRead.isTimePassed(
                                    //                       myMarketData
                                    //                               ?.openTime ??
                                    //                           '');
                                    //                   Navigator.of(context)
                                    //                       .push(
                                    //                     MaterialPageRoute(
                                    //                       builder: (context) =>
                                    //                           KalyanMorning(
                                    //                         tag: myMarketData
                                    //                                 ?.tag ??
                                    //                             '',
                                    //                         marketId:
                                    //                             myMarketData
                                    //                                     ?.sId ??
                                    //                                 '',
                                    //                         marketName:
                                    //                             myMarketData
                                    //                                     ?.name ??
                                    //                                 '',
                                    //                         gameName: '',
                                    //                         currentTime: refWatch
                                    //                                 .value
                                    //                                 ?.getParticularPlayerModel
                                    //                                 ?.data
                                    //                                 ?.mpin
                                    //                                 .toString() ??
                                    //                             '',
                                    //                         balance: refWatch
                                    //                                 .value
                                    //                                 ?.getParticularPlayerModel
                                    //                                 ?.data
                                    //                                 ?.wallet
                                    //                                 .toString() ??
                                    //                             '0',
                                    //                       ),
                                    //                     ),
                                    //                   );
                                    //                 }
                                    //               },
                                    //               child: AnimatedContainer(
                                    //                 onEnd: () {
                                    //                   refRead
                                    //                       .updateEndContainerSize(
                                    //                           index);
                                    //                 },
                                    //                 duration: const Duration(
                                    //                     milliseconds: 1500),
                                    //                 margin: const EdgeInsets
                                    //                     .symmetric(
                                    //                     horizontal: 5,
                                    //                     vertical: 4),
                                    //                 child: Container(
                                    //                   width:
                                    //                       MediaQuery.of(context)
                                    //                               .size
                                    //                               .width -
                                    //                           4,
                                    //                   decoration: BoxDecoration(
                                    //                     border: Border.all(
                                    //                         color: const Color(
                                    //                             0xFFD9BC4C),
                                    //                         width: 1.5),
                                    //                     color: darkBlue,
                                    //                     borderRadius:
                                    //                         BorderRadius
                                    //                             .circular(12),
                                    //                   ),
                                    //                   padding: const EdgeInsets
                                    //                       .symmetric(
                                    //                       horizontal: 10,
                                    //                       vertical: 12),
                                    //                   child: Row(
                                    //                     crossAxisAlignment:
                                    //                         CrossAxisAlignment
                                    //                             .center,
                                    //                     mainAxisAlignment:
                                    //                         MainAxisAlignment
                                    //                             .spaceBetween,
                                    //                     children: [
                                    //                       // Chart icon on left
                                    //                       InkWell(
                                    //                         onTap: () {
                                    //                           Navigator.push(
                                    //                             context,
                                    //                             MaterialPageRoute(
                                    //                               builder:
                                    //                                   (context) =>
                                    //                                       ChartScreen(
                                    //                                 marketId:
                                    //                                     myMarketData?.sId ??
                                    //                                         '',
                                    //                                 marketName:
                                    //                                     myMarketData?.name ??
                                    //                                         '',
                                    //                               ),
                                    //                             ),
                                    //                           );
                                    //                         },
                                    //                         child: Padding(
                                    //                           padding:
                                    //                               const EdgeInsets
                                    //                                   .all(2.0),
                                    //                           child:
                                    //                               Image.asset(
                                    //                             'assets/images/chart.png',
                                    //                             width: 40,
                                    //                             height: 40,
                                    //                           ),
                                    //                         ),
                                    //                       ),
                                    //                       const SizedBox(
                                    //                           width: 15),
                                    //
                                    //                       // Middle content
                                    //                       Column(
                                    //                         crossAxisAlignment:
                                    //                             CrossAxisAlignment
                                    //                                 .center,
                                    //                         mainAxisAlignment:
                                    //                             MainAxisAlignment
                                    //                                 .center,
                                    //                         children: [
                                    //                           // Timings row - Open and Close
                                    //                           Row(
                                    //                             mainAxisAlignment:
                                    //                                 MainAxisAlignment
                                    //                                     .spaceBetween,
                                    //                             children: [
                                    //                               Text(
                                    //                                 'Open: ${myMarketData?.openTime ?? ''}',
                                    //                                 style: GoogleFonts
                                    //                                     .poppins(
                                    //                                   color: Colors
                                    //                                       .white,
                                    //                                   fontSize:
                                    //                                       13,
                                    //                                   fontWeight:
                                    //                                       FontWeight
                                    //                                           .w500,
                                    //                                 ),
                                    //                               ),
                                    //                               const SizedBox(
                                    //                                   width:
                                    //                                       10),
                                    //                               Text(
                                    //                                 'Close: ${myMarketData?.closeTime ?? ''}',
                                    //                                 style: GoogleFonts
                                    //                                     .poppins(
                                    //                                   color: Colors
                                    //                                       .white,
                                    //                                   fontSize:
                                    //                                       13,
                                    //                                   fontWeight:
                                    //                                       FontWeight
                                    //                                           .w500,
                                    //                                 ),
                                    //                               ),
                                    //                             ],
                                    //                           ),
                                    //                           const SizedBox(
                                    //                               height: 3),
                                    //                           // Market name
                                    //                           Text(
                                    //                             myMarketData
                                    //                                     ?.name
                                    //                                     ?.toUpperCase() ??
                                    //                                 'MARKET',
                                    //                             style:
                                    //                                 GoogleFonts
                                    //                                     .poppins(
                                    //                               color: Colors
                                    //                                   .white,
                                    //                               fontSize: 16,
                                    //                               fontWeight:
                                    //                                   FontWeight
                                    //                                       .bold,
                                    //                               letterSpacing:
                                    //                                   0.5,
                                    //                             ),
                                    //                           ),
                                    //                           const SizedBox(
                                    //                               height: 4),
                                    //                           // Result numbers in gold/yellow
                                    //                           Text(
                                    //                             refRead.results(
                                    //                                 myMarketData?.openPanna ??
                                    //                                     '',
                                    //                                 myMarketData?.openDigit ??
                                    //                                     '',
                                    //                                 myMarketData
                                    //                                         ?.closeDigit ??
                                    //                                     '',
                                    //                                 myMarketData
                                    //                                         ?.closePanna ??
                                    //                                     ''),
                                    //                             style:
                                    //                                 GoogleFonts
                                    //                                     .poppins(
                                    //                               color: const Color(
                                    //                                   0xFF857B5F),
                                    //                               fontSize: 16,
                                    //                               fontWeight:
                                    //                                   FontWeight
                                    //                                       .bold,
                                    //                             ),
                                    //                           ),
                                    //                           const SizedBox(
                                    //                               height: 6),
                                    //                           // Status text in red
                                    //                           Text(
                                    //                             (myMarketData?.marketStatus ==
                                    //                                         false ||
                                    //                                     refRead.isTimePassed(myMarketData?.closeTime ??
                                    //                                         ''))
                                    //                                 ? 'CLOSE FOR TODAY'
                                    //                                 : refWatch
                                    //                                 .value?.getParticularPlayerModel?.data?.betting ==
                                    //                                 true ? 'RUNNING TODAY' : 'OPEN CHART',
                                    //                             style:
                                    //                                 GoogleFonts
                                    //                                     .poppins(
                                    //                               color: myMarketData?.marketStatus ==
                                    //                                           false ||
                                    //                                       refRead.isTimePassed(myMarketData?.closeTime ??
                                    //                                           '')
                                    //                                   ? Colors
                                    //                                       .red
                                    //                                   : Colors
                                    //                                       .green,
                                    //                               fontSize: 12,
                                    //                               fontWeight:
                                    //                                   FontWeight
                                    //                                       .bold,
                                    //                               letterSpacing:
                                    //                                   0.5,
                                    //                             ),
                                    //                           ),
                                    //                         ],
                                    //                       ),
                                    //                       ( refWatch.value?.getParticularPlayerModel?.data
                                    //                           ?.betting ?? false) ?  const SizedBox(
                                    //                           width: 20) : const SizedBox.shrink(),
                                    //
                                    //
                                    //                       // Circular pause button on right
                                    //                      ( refWatch.value?.getParticularPlayerModel?.data
                                    //                           ?.betting ?? false) ?      Column(
                                    //                         mainAxisAlignment:
                                    //                             MainAxisAlignment
                                    //                                 .center,
                                    //                         children: [
                                    //                           Image.asset(
                                    //                             (myMarketData?.marketStatus ==
                                    //                                         false ||
                                    //                                     refRead.isTimePassed(myMarketData?.closeTime ??
                                    //                                         ''))
                                    //                                 ? 'assets/images/pause.png'
                                    //                                 : 'assets/images/play.png',
                                    //                             width: 46,
                                    //                           ),
                                    //                         ],
                                    //                       )   : const SizedBox(
                                    //   width: 80),
                                    //                     ],
                                    //                   ),
                                    //                 ),
                                    //               ),
                                    //             )
                                    //           ],
                                    //         )
                                    //       : const SizedBox();
                                    // }
                                  itemBuilder: (context, index) {
                                    final markets = refWatch.value?.getAllMarketModel?.data
                                        ?.where((e) => e.tag == "main")
                                        .toList();

                                    final myMarketData = markets?[index];

                                    // Filter out unwanted tags or inactive statuses
                                    if (myMarketData?.tag == 'starline' || myMarketData?.status != true) {
                                      return const SizedBox();
                                    }

                                    final betting = refWatch.value?.getParticularPlayerModel?.data?.betting ?? false;

                                    final marketClosed = myMarketData?.marketStatus == false ||
                                        refRead.isTimePassed(myMarketData?.closeTime ?? '');

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (myMarketData?.marketStatus == false) {
                                              refRead.updateContainerSize(index);
                                              Vibration.vibrate(duration: 800, amplitude: 84);
                                              toast(context: context, 'Holiday!!!, Market is close.');
                                              return;
                                            }

                                            if (!betting) {
                                              refRead.updateContainerSize(index);
                                              Vibration.vibrate(duration: 800, amplitude: 84);
                                              toast('Please contact to admin');
                                              return;
                                            }

                                            if (refRead.isTimePassed(myMarketData?.closeTime ?? '')) {
                                              refRead.updateContainerSize(index);
                                              Vibration.vibrate(duration: 800, amplitude: 100);
                                              toast('Betting is Closed for Today');
                                              return;
                                            }

                                            HapticFeedback.selectionClick();

                                            ref.read(starlineNotifierProvider.notifier).changeStarlineStatus(false);

                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) => KalyanMorning(
                                                  tag: myMarketData?.tag ?? '',
                                                  marketId: myMarketData?.sId ?? '',
                                                  marketName: myMarketData?.name ?? '',
                                                  gameName: '',
                                                  currentTime: refWatch.value?.getParticularPlayerModel?.data?.mpin.toString() ?? '',
                                                  balance: refWatch.value?.getParticularPlayerModel?.data?.wallet.toString() ?? '0',
                                                ),
                                              ),
                                            );
                                          },
                                          child: AnimatedContainer(
                                            onEnd: () {
                                              refRead.updateEndContainerSize(index);
                                            },
                                            duration: const Duration(milliseconds: 1500),
                                            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color(0xFFD9BC4C),
                                                width: 1.5,
                                              ),
                                              color: darkBlue.withAlpha(20),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                /// MAIN CONTENT AREA
                                                Expanded(
                                                  child: Column(
                                                    // Dynamic alignment based on betting status
                                                    crossAxisAlignment: betting ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                                                    children: [
                                                      /// MARKET NAME
                                                      Text(
                                                        myMarketData?.name?.toUpperCase() ?? 'MARKET',
                                                        style: GoogleFonts.poppins(
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),

                                                      const SizedBox(height: 4),

                                                      /// RESULT ROW
                                                      Row(
                                                        // Centering the results if betting is off
                                                        mainAxisAlignment: betting ? MainAxisAlignment.start : MainAxisAlignment.center,
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                                            decoration: BoxDecoration(
                                                              border: Border.all(
                                                                color: const Color(0xFF857B5F),
                                                              ),
                                                              borderRadius: BorderRadius.circular(5),
                                                            ),
                                                            child: Text(
                                                              refRead.results(
                                                                myMarketData?.openPanna ?? '',
                                                                myMarketData?.openDigit ?? '',
                                                                myMarketData?.closeDigit ?? '',
                                                                myMarketData?.closePanna ?? '',
                                                              ),
                                                              style: GoogleFonts.poppins(
                                                                color: const Color(0xFF857B5F),
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),

                                                          const SizedBox(width: 20),

                                                          /// VIEW CHART
                                                          Flexible(
                                                            child: InkWell(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) => ChartScreen(
                                                                      marketId: myMarketData?.sId ?? '',
                                                                      marketName: myMarketData?.name ?? '',
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Container(
                                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                    color: Colors.grey,
                                                                    width: 1,
                                                                  ),
                                                                  borderRadius: BorderRadius.circular(5),
                                                                ),
                                                                child: Text(
                                                                  "View Chart",
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: GoogleFonts.poppins(
                                                                    color: const Color(0xFF857B5F),
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(height: 6),

                                                      /// OPEN CLOSE CONTAINER
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green.withOpacity(0.12),
                                                          borderRadius: BorderRadius.circular(8),
                                                          border: Border.all(
                                                            color: Colors.green.withOpacity(0.35),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            /// OPEN TIME
                                                            RichText(
                                                              text: TextSpan(
                                                                style: GoogleFonts.poppins(fontSize: 13),
                                                                children: [
                                                                  const TextSpan(
                                                                    text: 'Open: ',
                                                                    style: TextStyle(
                                                                      color: Colors.black54,
                                                                      fontWeight: FontWeight.w600,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: myMarketData?.openTime ?? '',
                                                                    style: const TextStyle(
                                                                      color: Colors.green,
                                                                      fontWeight: FontWeight.w700,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),

                                                            const SizedBox(width: 10),

                                                            Container(
                                                              height: 16,
                                                              width: 1,
                                                              color: Colors.black26,
                                                            ),

                                                            const SizedBox(width: 10),

                                                            /// CLOSE TIME
                                                            RichText(
                                                              text: TextSpan(
                                                                style: GoogleFonts.poppins(fontSize: 13),
                                                                children: [
                                                                  const TextSpan(
                                                                    text: 'Close: ',
                                                                    style: TextStyle(
                                                                      color: Colors.black54,
                                                                      fontWeight: FontWeight.w600,
                                                                    ),
                                                                  ),
                                                                  TextSpan(
                                                                    text: myMarketData?.closeTime ?? '',
                                                                    style: const TextStyle(
                                                                      color: Colors.red,
                                                                      fontWeight: FontWeight.w700,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                /// RIGHT STATUS (Only shows if betting is enabled)
                                                if (betting) ...[
                                                  const SizedBox(width: 10),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Image.asset(
                                                        marketClosed ? 'assets/images/pause.png' : 'assets/images/play.png',
                                                        width: 46,
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: marketClosed ? redColor : Colors.green,
                                                            width: 2,
                                                          ),
                                                          borderRadius: BorderRadius.circular(25),
                                                        ),
                                                        child: Text(
                                                          marketClosed ? 'CLOSED' : 'RUNNING',
                                                          style: GoogleFonts.poppins(
                                                            color: marketClosed ? Colors.red : Colors.green,
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                    ),
                              ),
                            ),
                          }
                        }
                      ],
                    )),
              ),
            ]))));
  }

  Widget container(String? icon, String? text) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(icon ?? '', width: 55, height: 55),
          const SizedBox(height: 6),
          Text(
            text ?? '',
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showRulesDialog(BuildContext context, WidgetRef ref) {
    // Ensure we have the latest rules data
    ref.read(getSettingNotifierProvider.notifier).getSettingModel();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer(
          builder: (context, ref, child) {
            final rulesData = ref.watch(getSettingNotifierProvider);

            return AlertDialog(
              titlePadding: const EdgeInsets.all(20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Rules",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: darkBlue,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref
                          .read(getSettingNotifierProvider.notifier)
                          .getSettingModel();
                    },
                    icon: Icon(Icons.refresh_rounded, color: darkBlue),
                  ),
                ],
              ),
              content: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  minHeight: 200,
                ),
                child: rulesData.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(darkBlue),
                        ),
                      )
                    : rulesData.hasError
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: Color(0xFFEF4444), size: 48),
                                const SizedBox(height: 16),
                                Text(
                                  "Failed to load rules",
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFFEF4444),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                rulesData.value?.getSettingModel?.data?.rules ??
                                    'No rules available',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  height: 1.5,
                                  color: textColor,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Close",
                    style: GoogleFonts.poppins(
                      color: darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper function to format currency in Indian format
  String _formatIndianCurrency(int amount) {
    String amountStr = amount.toString();
    String result = '';
    int count = 0;

    // Process from right to left
    for (int i = amountStr.length - 1; i >= 0; i--) {
      if (count != 0 && count % 2 == 0 && count <= 3) {
        result = ',$result';
      } else if (count > 3 && (count - 3) % 2 == 0) {
        result = ',$result';
      }
      result = amountStr[i] + result;
      count++;
    }

    return result;
  }
}
