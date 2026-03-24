import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/features/home/get_setting_notifier.dart';
import 'package:sm_project/features/starline/starline_data.dart';
import 'package:sm_project/features/starline/starline_notifier.dart';
import 'package:sm_project/features/starline/starline_router.dart';
import 'package:sm_project/utils/filecollection.dart';

class StarlineScreen extends ConsumerWidget {
  const StarlineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refRead = ref.read(homeNotifierProvider.notifier);
    final primaryGold = darkBlue;
    final accentGold = darkBlue;
    const darkSurface = Color(0xFF0B0B0F);
    const deepSurface = Color(0xFF08080C);
    const panelTop = Color(0xFF0E0F14);
    const panelBottom = Color(0xFF141720);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        ref.read(starlineNotifierProvider.notifier).changeStarlineStatus(false);
        if (context.canPop()) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: darkSurface,
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
                refRead.onRefresh(context);
              },
              builder: (context, widget, controller) {
                return CustomMaterialIndicator(
                  onRefresh: () async {
                    refRead.onRefresh(context);
                  },
                  indicatorBuilder: (context, controller) {
                    return Icon(
                      Icons.cached,
                      color: primaryGold,
                      size: 28,
                    );
                  },
                  controller: controller,
                  child: widget,
                );
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppBarWidget(title: 'Starline'),
                    const SizedBox(height: 12),
                    Text(
                      'Play the Starline markets with live rates and quick access to your bids.',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Consumer(builder: (context, ref, child) {
                      final refWatch =
                          ref.watch(getSettingNotifierProvider).value;
                      final starlineRates =
                          refWatch?.getSettingModel?.data?.rates?.starline;
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [panelTop, panelBottom],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border:
                              Border.all(color: primaryGold.withOpacity(0.35)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.45),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: primaryGold.withOpacity(0.12),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        primaryGold.withOpacity(0.18),
                                        accentGold.withOpacity(0.10),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: primaryGold.withOpacity(0.35),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.star_rate_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Starline Rates',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _RateRow(
                              title: 'Single Digit',
                              value:
                                  "${starlineRates?.singleDigit1 ?? ""} - ${starlineRates?.singleDigit2 ?? ""}",
                              primaryGold: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            _RateRow(
                              title: 'Single Panna',
                              value:
                                  "${starlineRates?.singlePanna1 ?? ""} - ${starlineRates?.singlePanna2 ?? ""}",
                              primaryGold: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            _RateRow(
                              title: 'Double Panna',
                              value:
                                  "${starlineRates?.doublePanna1 ?? ""} - ${starlineRates?.doublePanna2 ?? ""}",
                              primaryGold: Colors.white,
                            ),
                            const SizedBox(height: 10),
                            _RateRow(
                              title: 'Triple Panna',
                              value:
                                  "${starlineRates?.tripplePanna1 ?? ""} - ${starlineRates?.tripplePanna2 ?? ""}",
                              primaryGold: Colors.white,
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _GradientButton(
                            onTap: () {
                              context.push(StarlinePath.starlineBidHistory);
                            },
                            icon: bidHistory,
                            label: 'Bid History',
                            primaryGold: primaryGold,
                            accentGold: accentGold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _GradientButton(
                            onTap: () {
                              context.push(StarlinePath.starlineBidWinHistory);
                            },
                            icon: winHistory,
                            label: 'Win History',
                            primaryGold: primaryGold,
                            accentGold: accentGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const StarlineData(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  final String title;
  final String value;
  final Color primaryGold;

  const _RateRow({
    required this.title,
    required this.value,
    required this.primaryGold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.grey[300],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: primaryGold,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback onTap;
  final String icon;
  final String label;
  final Color primaryGold;
  final Color accentGold;

  const _GradientButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.primaryGold,
    required this.accentGold,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryGold, accentGold],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: primaryGold.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, height: 22, width: 22, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
