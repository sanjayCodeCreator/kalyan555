import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/theme.dart';
import '../providers/top_bets_provider.dart';

class DayWidget extends ConsumerStatefulWidget {
  const DayWidget({super.key});

  @override
  ConsumerState<DayWidget> createState() => _DayWidgetState();
}

class _DayWidgetState extends ConsumerState<DayWidget> {
  @override
  void initState() {
    super.initState();
    // Fetch top bets on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(topBetsNotifierProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final topBetsAsync = ref.watch(topBetsNotifierProvider);
    return SizedBox(
      height: 400, // Fixed height for the container
      child: topBetsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.aviatorTwentyEighthColor,
          ),
        ),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (topBetsModel) {
          if (topBetsModel.data.isEmpty) {
            return Center(
              child: Text(
                'No data available',
                style: Theme.of(context).textTheme.aviatorBodyMediumFourth,
              ),
            );
          }

          // Filter bets to show only today's bets
          final today = DateTime.now();
          final todayStart = DateTime(today.year, today.month, today.day);
          final todayEnd = todayStart.add(const Duration(days: 1));

          final todaysBets = topBetsModel.data.where((bet) {
            if (bet.createdAt == null) return false;
            try {
              final betDate = DateTime.parse(bet.createdAt!);
              return betDate.isAfter(todayStart) && betDate.isBefore(todayEnd);
            } catch (e) {
              return false;
            }
          }).toList();

          if (todaysBets.isEmpty) {
            return Center(
              child: Text(
                'No bets for today',
                style: Theme.of(context).textTheme.aviatorBodyMediumFourth,
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: false, // Allow scrolling within the container
            //  clipBehavior: Clip.none,
            padding: EdgeInsets.zero,
            itemCount: todaysBets.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 6);
            },
            itemBuilder: (context, index) {
              final topBet = todaysBets[index];
              String formatNum(num? value) =>
                  value?.toStringAsFixed(2) ?? '0.00';
              return Container(
                height: 71,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.aviatorThirtyNineColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.aviatorFifteenthColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          topBet.userId?.userName ?? '',
                          style: Theme.of(
                            context,
                          ).textTheme.aviatorBodyMediumFourthBold,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Cash out:  ',
                              style: Theme.of(
                                context,
                              ).textTheme.aviatorBodyMediumSecondary,
                            ),
                            //! container for cash out- 100
                            Container(
                              height: 24,
                              width: 73,
                              padding: const EdgeInsets.only(
                                top: 4,
                                bottom: 4,
                                left: 8,
                                right: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.aviatorThirtyFiveColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  topBet.cashoutAt.toString(),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.aviatorbodySmallPrimaryBold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              '         Win:  ',
                              style: Theme.of(
                                context,
                              ).textTheme.aviatorBodyMediumSecondary,
                            ),
                            //! container for win- 100
                            Container(
                              height: 24,
                              width: 73,
                              padding: const EdgeInsets.only(
                                top: 4,
                                bottom: 4,
                                left: 8,
                                right: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.aviatorTwentiethColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Center(
                                child: Text(
                                  formatNum(topBet.payout),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.aviatorBodyMediumFourthBold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
