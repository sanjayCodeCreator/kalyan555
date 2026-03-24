import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/Quiz/utils/prefs_service.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/features/drawer/drawer_router.dart';
import 'package:sm_project/features/gali_desawar/gali_desawar_bid_history.dart';
import 'package:sm_project/features/gali_desawar/gali_desawar_bid_win_history.dart';
import 'package:sm_project/features/home/home_router.dart';
import 'package:sm_project/utils/filecollection.dart';

import '../../Quiz/selectedanswers_provider.dart';
import '../../utils/customization.dart';

class XDrawer extends StatelessWidget {
  const XDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [whiteBackgroundColor, whiteBackgroundColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          child: Consumer(builder: (context, ref, child) {
            final refWatch = ref.watch(homeNotifierProvider);
            final refRead = ref.read(homeNotifierProvider.notifier);
            return Column(
              children: [
                // Profile Header
                _buildProfileHeader(refWatch, darkBlue),

                // Menu Items List
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: whiteBackgroundColor,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildMenuItem(
                          context: context,
                          icon: Icons.home_outlined,
                          title: "Home",
                          onTap: () {
                            context.pushNamed(RouteNames.mainScreen);
                          },
                        ),
                        // _buildMenuItem(
                        //   context: context,
                        //   icon: Icons.insert_chart_outlined_rounded,
                        //   title: "Charts",
                        //   onTap: () {
                        //     context.pushNamed(HomePath.marketResultHistory);
                        //   },
                        // ),
                        if (refWatch.value?.getParticularPlayerModel?.data
                                ?.betting ==
                            true) ...[
                          _buildMenuItem(
                            context: context,
                            icon: Icons.account_balance_wallet_outlined,
                            title: "Funds",
                            onTap: () {
                              context.pushNamed(HomePath.deposit);
                            },
                          ),
                          // _buildMenuItem(
                          //   context: context,
                          //   icon: Icons.receipt_long_outlined,
                          //   title: "Main Market Bid History",
                          //   onTap: () {
                          //     context.pushNamed(RouteNames.bids);
                          //   },
                          // ),
                          // _buildMenuItem(
                          //   context: context,
                          //   icon: Icons.receipt_long_outlined,
                          //   title: "Main Market Win History",
                          //   onTap: () {
                          //     context.pushNamed(RouteNames.winbids);
                          //   },
                          // ),
                          // _buildMenuItem(
                          //   context: context,
                          //   icon: Icons.receipt_long_outlined,
                          //   title: "Gali Desawar Bid History",
                          //   onTap: () {
                          //     Navigator.push(context, MaterialPageRoute(
                          //       builder: (context) {
                          //         return const GaliDesawarBidHistoryScreen(
                          //           tag: "galidisawar",
                          //         );
                          //       },
                          //     ));
                          //   },
                          // ),
                          // _buildMenuItem(
                          //   context: context,
                          //   icon: Icons.receipt_long_outlined,
                          //   title: "Gali Desawar Win History",
                          //   onTap: () {
                          //     Navigator.push(context, MaterialPageRoute(
                          //       builder: (context) {
                          //         return const GaliDesawarBidWinHistoryScreen(
                          //           tag: "galidisawar",
                          //         );
                          //       },
                          //     ));
                          //   },
                          // ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.menu_book_outlined,
                            title: "Passbook",
                            onTap: () {
                              context.pushNamed(RouteNames.transactionHistory);
                            },
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.info_outline_rounded,
                            title: "How To Play",
                            onTap: () => context.push(DrawerPath.howToPlay),
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.chat_bubble_outline_rounded,
                            title: "Chat With Support",
                            onTap: () => context.push(DrawerPath.support),
                          ),
                          _buildMenuItem(
                            context: context,
                            icon: Icons.star_border_rounded,
                            title: "Game Rates",
                            onTap: () =>
                                context.pushNamed(DrawerPath.ratesScreen),
                          ),
                        ],
                        _buildMenuItem(
                          context: context,
                          icon: Icons.notifications_none_rounded,
                          title: "Notifications",
                          onTap: () {
                            context.pushNamed(HomePath.notifications);
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.lock_outline_rounded,
                          title: "Generate MPIN",
                          onTap: () =>
                              context.pushNamed(RouteNames.forgotMpinPassword),
                        ),

                        _buildMenuItem(
                          context: context,
                          icon: Icons.settings_outlined,
                          title: "Setting",
                          onTap: () =>
                              context.pushNamed(RouteNames.settingScreen),
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.share_outlined,
                          title: "Share Application",
                          onTap: () {
                            refRead.appPlayStoreLauncher(Uri(
                              scheme: 'https',
                              host: 'play.google.com',
                              path: 'store/apps/details',
                              queryParameters: {
                                'id': 'com.mira567mr.mr567mirarr',
                                'hl': 'en_IN',
                                'gl': 'US',
                              },
                            ));
                          },
                        ),
                        _buildMenuItem(
                          context: context,
                          icon: Icons.logout_rounded,
                          title: "Logout",
                          onTap: () {
                            /// Quiz data reset
                            ref.read(selectedAnswersProvider.notifier).restart();

                            /// Agar aur providers hain to unko bhi reset karo
                            ref.invalidate(questionsProvider);
                            ref.invalidate(selectedSubCategoryProvider);
                            ref.invalidate(selectedCategoryProvider);

                            /// Local storage clear (agar use kar rahe ho)
                            PrefsService.clearAll(); // ya specific keys delete karo
                            refRead.logout(context);
                          }),
                      ],
                    ),
                  ),
                ),

                // Version
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, top: 6),
                  child: Text(
                    "${Customization.appname} v1.0",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AsyncValue<dynamic> refWatch, Color darkBlue) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: darkBlue,
                width: 2.5,
              ),
            ),
            child: Center(
              child: Text(
                ((refWatch.value?.getParticularPlayerModel?.data?.userName ??
                            'U')
                        .trim()
                        .isEmpty
                    ? 'U'
                    : (refWatch.value?.getParticularPlayerModel?.data
                                ?.userName ??
                            'U')
                        .trim()[0]
                        .toUpperCase()),
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  refWatch.value?.getParticularPlayerModel?.data?.userName ??
                      "User",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  refWatch.value?.getParticularPlayerModel?.data?.mobile ?? "",
                  style: GoogleFonts.poppins(
                    color: Colors.black.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section divider removed to match the simplified list design.

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              Icon(icon, color: Colors.black87, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // trailing chevron removed for cleaner look like the reference design
            ],
          ),
        ),
      ),
    );
  }

  // Bottom button section removed; simple version label is shown instead.
}
