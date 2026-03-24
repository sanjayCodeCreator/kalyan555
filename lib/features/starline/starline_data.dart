import 'dart:developer';

import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/controller/model/get_all_market_model.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/features/games/kalyan_morning.dart';
import 'package:sm_project/features/starline/starline_notifier.dart';
import 'package:sm_project/utils/app_utils.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:vibration/vibration.dart';

class StarlineData extends StatefulWidget {
  const StarlineData({super.key});

  @override
  State<StarlineData> createState() => _StarlineDataState();
}

class _StarlineDataState extends State<StarlineData> {
  playTap({
    required AsyncValue<HomeScreenMode> refWatch,
    required HomeScreenNotifier refRead,
    required Data? myMarketData,
    required WidgetRef ref,
  }) {
    Vibration.vibrate(duration: 300, amplitude: 100);
    if (myMarketData?.marketStatus == false) {
      toast(context: context, 'Holiday!!!, Market is close.');
      return;
    }
    if (refWatch.value?.getParticularPlayerModel?.data?.betting == false) {
      toast(context: context, 'Please contact to admin');
    } else if (refRead.isTimePassed(myMarketData?.openTime ?? '')) {
      toast(context: context, 'Market is close for today');
    } else {
      log(myMarketData?.toString() ?? '', name: 'myMarketData 11');
      refRead.isTimePassed(myMarketData?.openTime ?? '');
      ref.read(starlineNotifierProvider.notifier).changeStarlineStatus(true);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => KalyanMorning(
                tag: myMarketData?.tag ?? '',
                marketId: myMarketData?.sId ?? '',
                marketName: myMarketData?.name ?? '',
                gameName: '',
                currentTime: refWatch
                        .value?.getParticularPlayerModel?.data?.mpin
                        .toString() ??
                    '',
              )));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGold = Color(0xFFD4A648);
    const accentGold = Color(0xFFF5D77A);
    const cardTop = Color(0xFF151823);
    const cardBottom = Color(0xFF11131C);

    return Consumer(builder: (context, ref, _) {
      final refWatch = ref.watch(homeNotifierProvider);
      final refRead = ref.read(homeNotifierProvider.notifier);

      final markets = refWatch.value?.getAllMarketModel?.data
              ?.where((element) =>
                  element.tag == "starline" && (element.status ?? false))
              .toList() ??
          [];

      if (markets.isEmpty) {
        return const Center(
            child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("No Starline Market"),
        ));
      }
      return Padding(
        padding: EdgeInsets.only(
          bottom: markets.length < 3 ? 160 : 16,
        ),
        child: GridView.builder(
          itemCount: markets.length,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisExtent: 142,
          ),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final myMarketData = markets[index];
            final isClosed = refRead.isTimePassed(myMarketData.openTime ?? '');

            return Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () {
                    playTap(
                        myMarketData: myMarketData,
                        refRead: refRead,
                        refWatch: refWatch,
                        ref: ref);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [cardTop, cardBottom],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: primaryGold.withOpacity(0.28)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 22,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: primaryGold.withOpacity(0.14),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    convert24HrTo12Hr(
                                        myMarketData.openTime ?? ''),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _StatusChip(
                              isClosed: isClosed,
                              primaryGold: primaryGold,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Consumer(builder: (context, ref, child) {
                              return InkWell(
                                onTap: () {
                                  ref
                                      .read(homeNotifierProvider.notifier)
                                      .launchStarlineCalendarView();
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        primaryGold.withOpacity(0.16),
                                        accentGold.withOpacity(0.10),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: primaryGold.withOpacity(0.25),
                                    ),
                                  ),
                                  child: Image.asset(
                                    calendarLogo,
                                    width: 28,
                                    height: 28,
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Result',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    refRead.starlineresults(
                                        myMarketData.openPanna ?? '',
                                        myMarketData.openDigit ?? ''),
                                    style: GoogleFonts.poppins(
                                      color: isClosed
                                          ? Colors.redAccent
                                          : primaryGold,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            );
          },
        ),
      );
    });
  }
}

class _StatusChip extends StatelessWidget {
  final bool isClosed;
  final Color primaryGold;

  const _StatusChip({
    required this.isClosed,
    required this.primaryGold,
  });

  @override
  Widget build(BuildContext context) {
    final label = isClosed ? 'Closed' : 'Play Now';
    final bgColor = isClosed ? Colors.redAccent : Colors.green;
    return Container(
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: primaryGold.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
