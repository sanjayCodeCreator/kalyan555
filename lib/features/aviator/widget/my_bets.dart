import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_images.dart';
import '../core/theme/theme.dart';
import '../core/widgets/custom_elevated_button.dart';
import '../providers/bet_history_provider.dart';

class MyBets extends ConsumerStatefulWidget {
  const MyBets({super.key});

  @override
  ConsumerState<MyBets> createState() => _MyBetsState();
}

class _MyBetsState extends ConsumerState<MyBets> {
  bool _isPreviousHand = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(betHistoryProvider.notifier).fetchBetHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final betHistoryAsync = ref.watch(betHistoryProvider);
    return betHistoryAsync.when(
      loading: () => Container(
        height: 400,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.aviatorTertiaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.aviatorTwentyEighthColor,
          ),
        ),
      ),
      error: (error, stack) => Container(
        height: 400,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.aviatorFourteenthColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: AppColors.aviatorTertiaryColor),
          ),
        ),
      ),
      data: (betHistory) {
        if (betHistory.data.isEmpty) {
          return Container(
            height: 400,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.aviatorTertiaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                'No bets found',
                style: Theme.of(context).textTheme.aviatorBodyLargePrimary,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(betHistoryProvider.notifier).refresh();
          },
          color: AppColors.aviatorTwentyEighthColor,
          backgroundColor: AppColors.aviatorTertiaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              height: 400,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.aviatorTertiaryColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.aviatorFifteenthColor,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL BETS: ${betHistory.data.length}',
                        style:
                            Theme.of(context).textTheme.aviatorBodyLargePrimary,
                      ),
                      //! Switch for PREVIOUS HAND
                      CustomElevatedButton(
                        width: 125,
                        height: 28,
                        padding: const EdgeInsets.only(
                          left: 7,
                          right: 7,
                          top: 5,
                          bottom: 4,
                        ),
                        borderColor:
                            (_isPreviousHand || betHistory.data.length >= 50)
                                ? AppColors.aviatorThirtyEightColor
                                : AppColors.aviatorThirtyEightColor
                                    .withOpacity(0.3),
                        borderRadius: 30,
                        backgroundColor: (_isPreviousHand ||
                                betHistory.data.length >= 50)
                            ? AppColors.aviatorTwentiethColor
                            : AppColors.aviatorTwentiethColor.withOpacity(0.3),
                        onPressed:
                            (_isPreviousHand || betHistory.data.length >= 50)
                                ? () {
                                    setState(() {
                                      _isPreviousHand = !_isPreviousHand;
                                    });
                                    if (_isPreviousHand) {
                                      ref
                                          .read(betHistoryProvider.notifier)
                                          .refresh();
                                    } else {
                                      ref
                                          .read(betHistoryProvider.notifier)
                                          .refresh();
                                    }
                                  }
                                : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              child: Image.asset(
                                AppImages.previousHand,
                                height: 20,
                                width: 20,
                                color: AppColors.aviatorSixthColor,
                              ),
                            ),
                            Text(
                              _isPreviousHand
                                  ? 'Current hand'
                                  : 'Previous hand',
                              style: Theme.of(
                                context,
                              ).textTheme.aviatorBodyMediumFourth,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 1,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Date',
                              style: Theme.of(
                                context,
                              ).textTheme.aviatorBodyMediumSecondary,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Bet, INR',
                              style: Theme.of(
                                context,
                              ).textTheme.aviatorBodyMediumSecondary,
                            ),
                          ),
                          Text(
                            'X',
                            style: Theme.of(
                              context,
                            ).textTheme.aviatorBodyMediumSecondary,
                          ),
                          const SizedBox(width: 28),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Cashout INR',
                              style: Theme.of(
                                context,
                              ).textTheme.aviatorBodyMediumSecondary,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '',
                              style: Theme.of(
                                context,
                              ).textTheme.aviatorBodyMediumSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        clipBehavior: Clip.none,
                        padding: EdgeInsets.zero,
                        itemCount: betHistory.data.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final bet = betHistory.data[index];
                          String formatNum(num? value) =>
                              value?.toStringAsFixed(2) ?? '0.00';

                          // Format multiplier - show cashoutAt for won bets, round's crashAt for lost bets
                          String getMultiplier() {
                            if (bet.status == 'won' && bet.cashoutAt > 0) {
                              return '${bet.cashoutAt.toStringAsFixed(2)}x';
                            } else if (bet.status == 'lost') {
                              // Show the round's crash point for lost bets
                              return '${bet.roundId.crashAt.toStringAsFixed(2)}x';
                            } else if (bet.cashoutAt > 0) {
                              return '${bet.cashoutAt.toStringAsFixed(2)}x';
                            }
                            return '-';
                          }

                          // Background color based on bet status
                          Color? bgColor = bet.status == 'lost'
                              ? AppColors.aviatorThirtyEightColor
                              : AppColors.aviatorTwentyFirstColor;

                          return Container(
                            width: double.infinity,
                            height: 66,
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: bgColor, width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  // 📌 Date
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          DateFormat('HH:mm').format(
                                            bet.placedAt.add(
                                              const Duration(
                                                  hours: 5, minutes: 30),
                                            ),
                                          ),
                                          style: Theme.of(
                                            context,
                                          )
                                              .textTheme
                                              .aviatorBodyMediumFourthBold,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          DateFormat('dd-MM-yyyy').format(
                                            bet.placedAt.add(
                                              const Duration(
                                                  hours: 5, minutes: 30),
                                            ),
                                          ),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.aviatorbodySmallThird,
                                          //  overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 📌 Bet, INR
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      bet.stake.toString(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.aviatorBodyMediumFourthBold,
                                    ),
                                  ),

                                  // 📌 X (Multiplier)
                                  Container(
                                    height: 28,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: AppColors.aviatorThirtyFiveColor,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Center(
                                      child: Text(
                                        getMultiplier(),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.aviatorbodySmallPrimaryBold,
                                      ),
                                    ),
                                  ),

                                  // 📌 Cashout
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      formatNum(bet.payout),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.aviatorBodyMediumFourthBold,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Image.asset(
                                          'assets/images/shield.png',
                                          height: 22,
                                          width: 22,
                                        ),
                                        Icon(
                                          FontAwesomeIcons.comment,
                                          size: 20,
                                          color:
                                              AppColors.aviatorSixteenthColor,
                                        ),
                                      ],
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
