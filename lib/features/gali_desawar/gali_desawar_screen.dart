import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/features/drawer/how_to_play.dart';
import 'package:sm_project/features/drawer/x_drawer.dart';
import 'package:sm_project/features/gali_desawar/gali_desawar_bid_history.dart';
import 'package:sm_project/features/gali_desawar/gali_desawar_bid_win_history.dart';
import 'package:sm_project/features/gali_desawar/gali_desawar_data_component.dart';
import 'package:sm_project/features/gali_desawar/select_game_notifier.dart';
import 'package:sm_project/features/home/deposit_funds.dart';
import 'package:sm_project/features/home/get_setting_notifier.dart';
import 'package:sm_project/features/home/home_banner.dart';
import 'package:sm_project/features/home/in_app_update.dart';
import 'package:sm_project/features/home/notification_screen.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:vibration/vibration.dart';

class GaliDesawarScreen extends ConsumerStatefulWidget {
  const GaliDesawarScreen({super.key});

  @override
  ConsumerState<GaliDesawarScreen> createState() => GaliDesawarScreenState();
}

class GaliDesawarScreenState extends ConsumerState<GaliDesawarScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Animation controllers for Deposit button
  late AnimationController _depositAnimationController;
  late Animation<double> _depositGlowAnimation;
  late Animation<double> _depositBounceAnimation;
  late Animation<double> _depositIconScaleAnimation;

  // UI helpers (no business logic)
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10, top: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: darkBlue.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.92),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.25,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _panelDecoration({
    required Color primaryGold,
    required Color panelTop,
    required Color panelBottom,
    double radius = 14,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [panelTop, panelBottom],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: primaryGold.withOpacity(0.6),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
          offset: const Offset(0, 8),
          blurRadius: 18,
        ),
        BoxShadow(
          color: primaryGold.withOpacity(0.15),
          offset: const Offset(0, 6),
          blurRadius: 12,
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required VoidCallback onTap,
    required Widget leading,
    required Widget title,
    required Color primaryGold,
    required Color panelTop,
    required Color panelBottom,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: _panelDecoration(
          primaryGold: primaryGold,
          panelTop: panelTop,
          panelBottom: panelBottom,
          radius: 14,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 10),
            Flexible(child: title),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    ref
        .read(selectGameNotifierProvider.notifier)
        .getDropDownAllMarket('?tag=galidisawar');
    ref.read(homeNotifierProvider.notifier).getParticularPlayerModel(context);
    UpdateChecker.checkForUpdate();

    // Initialize Deposit button animations
    _depositAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _depositGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _depositAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _depositBounceAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _depositAnimationController,
        curve: Curves.bounceInOut,
      ),
    );

    _depositIconScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _depositAnimationController,
        curve: Curves.elasticInOut,
      ),
    );
  }

  @override
  void dispose() {
    _depositAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final refWatch = ref.watch(homeNotifierProvider);
    final refRead = ref.read(homeNotifierProvider.notifier);
    final primaryGold = darkBlue;
    final accentGold = darkBlue;
    const darkSurface = Color(0xFF0B0B0F);
    const deepSurface = Color(0xFF08080C);
    const panelTop = Color(0xFF0E0F14);
    const panelBottom = Color(0xFF141720);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 15, 12, 11),
      drawer: const XDrawer(),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [deepSurface, darkSurface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: InkWell(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(leadingLogo,
                    height: 30, width: 30, color: Colors.white),
              )),
          title: Text('Gali Desawar',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          actions: [
            Visibility(
                visible:
                    refWatch.value?.getParticularPlayerModel?.data?.betting ==
                        true,
                child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const Deposit();
                        },
                      ));
                    },
                    child: Row(children: [
                      Image.asset(
                        walletLogo,
                        height: 24,
                        width: 24,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                          refWatch.value?.getParticularPlayerModel?.data?.wallet
                                  .toString() ??
                              '0',
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white))
                    ]))),
            const SizedBox(width: 12),
            Visibility(
              visible:
                  refWatch.value?.getParticularPlayerModel?.data?.betting ==
                      true,
              child: InkWell(
                onTap: () {
                  ref.read(homeNotifierProvider.notifier).onRefresh(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationScreen()));
                },
                child: const Icon(
                  Icons.notifications_on,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              width: 16,
            )
          ]),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [deepSurface, darkSurface, Color(0xFF0D0D11)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: CustomRefreshIndicator(
            onRefresh: () async {
              ref
                  .read(selectGameNotifierProvider.notifier)
                  .onRefreshGaliDishwarDiamond(context, '?tag=galidisawar');
            },
            builder: (context, widget, controller) {
              return CustomMaterialIndicator(
                onRefresh: () async {
                  ref
                      .read(selectGameNotifierProvider.notifier)
                      .onRefreshGaliDishwarDiamond(context, '?tag=galidisawar');
                },
                indicatorBuilder: (context, controller) {
                  return Icon(
                    Icons.cached,
                    color: primaryGold,
                    size: 30,
                  );
                },
                controller: controller,
                child: widget,
              );
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const HomeBannerComponent(),
                  SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            _sectionTitle('Wallet Actions'),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: SizedBox(
                                height: 53,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Visibility(
                                        visible: (refWatch
                                                .value
                                                ?.getParticularPlayerModel
                                                ?.data
                                                ?.betting ??
                                            false),
                                        child: AnimatedBuilder(
                                          animation:
                                              _depositAnimationController,
                                          builder: (context, child) {
                                            return InkWell(
                                              onTap: () {
                                                HapticFeedback.selectionClick();
                                                context.pushNamed(
                                                    RouteNames.deposit);
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                height: 53,
                                                transform: Matrix4.identity()
                                                  ..scale(
                                                      _depositBounceAnimation
                                                          .value),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color.lerp(
                                                        primaryGold,
                                                        accentGold,
                                                        _depositGlowAnimation
                                                            .value,
                                                      )!,
                                                      Color.lerp(
                                                        panelTop,
                                                        primaryGold,
                                                        _depositGlowAnimation
                                                            .value,
                                                      )!,
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  border: Border.all(
                                                    color: primaryGold
                                                        .withOpacity(0.65),
                                                    width: 1.2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.3),
                                                      offset:
                                                          const Offset(0, 6),
                                                      blurRadius: 14 +
                                                          (_depositGlowAnimation
                                                                  .value *
                                                              6),
                                                    ),
                                                    BoxShadow(
                                                      color: primaryGold
                                                          .withOpacity(0.25 +
                                                              (_depositGlowAnimation
                                                                      .value *
                                                                  0.2)),
                                                      offset:
                                                          const Offset(0, 6),
                                                      blurRadius: 14,
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    AnimatedBuilder(
                                                      animation:
                                                          _depositAnimationController,
                                                      builder:
                                                          (context, child) {
                                                        return Transform.scale(
                                                          scale:
                                                              _depositIconScaleAnimation
                                                                  .value,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: [
                                                                  Colors.white
                                                                      .withOpacity(
                                                                          0.8),
                                                                  Colors.white
                                                                      .withOpacity(
                                                                          0.4),
                                                                ],
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                              ),
                                                            ),
                                                            child: const Icon(
                                                              Icons
                                                                  .add_circle_outline,
                                                              color:
                                                                  Colors.black,
                                                              size: 24,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ShaderMask(
                                                      shaderCallback:
                                                          (bounds) =>
                                                              LinearGradient(
                                                        colors: [
                                                          Colors.white,
                                                          Color.lerp(
                                                            Colors.white,
                                                            const Color(
                                                                0xFFFFF176),
                                                            _depositGlowAnimation
                                                                .value,
                                                          )!,
                                                        ],
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                      ).createShader(bounds),
                                                      child: Text(
                                                        'DEPOSIT',
                                                        style:
                                                            GoogleFonts.rubik(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Visibility(
                                        visible: (refWatch
                                                .value
                                                ?.getParticularPlayerModel
                                                ?.data
                                                ?.betting ??
                                            false),
                                        child: InkWell(
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            context.pushNamed(
                                                RouteNames.withdrawal);
                                          },
                                          child: Container(
                                            height: 53,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [panelTop, panelBottom],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: primaryGold
                                                    .withOpacity(0.65),
                                                width: 1.2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  offset: const Offset(0, 6),
                                                  blurRadius: 14,
                                                ),
                                                BoxShadow(
                                                  color: primaryGold
                                                      .withOpacity(0.2),
                                                  offset: const Offset(0, 5),
                                                  blurRadius: 12,
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.remove_circle_outline,
                                                  color: accentGold,
                                                  size: 22,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'WITHDRAW',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // const SizedBox(height: 15),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        _sectionTitle('History'),
                        Row(children: [
                          Expanded(
                              child: InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return const GaliDesawarBidHistoryScreen(
                                    tag: "galidisawar",
                                  );
                                },
                              ));
                            },
                            child: Container(
                              height: 54,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryGold,
                                      Color.lerp(panelTop, accentGold, 0.35)!,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                      color: primaryGold.withOpacity(0.8)),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 14,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color: primaryGold.withOpacity(0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    bidHistory,
                                    height: 18,
                                    width: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Bid History',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )),
                          const SizedBox(width: 10),
                          Expanded(
                              child: InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return const GaliDesawarBidWinHistoryScreen(
                                    tag: "galidisawar",
                                  );
                                },
                              ));
                            },
                            child: Container(
                              height: 54,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryGold,
                                      Color.lerp(panelTop, accentGold, 0.35)!,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(
                                      color: primaryGold.withOpacity(0.8)),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 14,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color: primaryGold.withOpacity(0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    ),
                                  ]),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    winHistory,
                                    height: 18,
                                    width: 18,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Win History',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ]),
                        const SizedBox(height: 20),
                        const GaliDesawarDataComponent(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
