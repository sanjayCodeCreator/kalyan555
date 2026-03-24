import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/theme.dart';
import '../domain/models/all_bets_model.dart';
import '../providers/aviator_round_provider.dart';

class AllBets extends ConsumerStatefulWidget {
  const AllBets({super.key});

  @override
  ConsumerState<AllBets> createState() => _AllBetsState();
}

class _AllBetsState extends ConsumerState<AllBets> {
  final int _currentPage = 0;
  static const int _itemsPerPage = 50;
  AllBetsModel? _bets;

  List<dynamic> _getCurrentPageBets() {
    final betsAsync = _bets;
    if (betsAsync == null || betsAsync.bets.isEmpty) return [];
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = min(startIndex + _itemsPerPage, betsAsync.bets.length);
    return betsAsync.bets.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    final betsAsync = ref.watch(aviatorBetsNotifierProvider);
    _bets = betsAsync;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.aviatorTertiaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.aviatorFifteenthColor, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL BETS: ${betsAsync?.count ?? 0}',
                style: Theme.of(context).textTheme.aviatorBodyLargePrimary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'User',
                    style: Theme.of(
                      context,
                    ).textTheme.aviatorBodyMediumSecondary,
                  ),
                ),
                const SizedBox(width: 35),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Bet',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.aviatorBodyMediumSecondary,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Mult.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.aviatorBodyMediumSecondary,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Cash out',
                    textAlign: TextAlign.end,
                    style: Theme.of(
                      context,
                    ).textTheme.aviatorBodyMediumSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _getCurrentPageBets().isEmpty
              ? Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: Text(
                    'No bets yet',
                    style: Theme.of(context).textTheme.aviatorBodyMediumFourth,
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _getCurrentPageBets().length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    bool isHighlighted =
                        (_currentPage * _itemsPerPage + index) == 0 ||
                            (_currentPage * _itemsPerPage + index) == 1;
                    Color? bgColor = isHighlighted
                        ? AppColors.aviatorTwentyFirstColor
                        : AppColors.aviatorThirtyNineColor;
                    final bets = _getCurrentPageBets()[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: bgColor, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            // 👤 Avatar
                            Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: AppColors.aviatorTertiaryColor,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // 📌 User
                            Expanded(
                              flex: 2,
                              child: Text(
                                bets?.user.userName ?? '',
                                style: Theme.of(
                                  context,
                                ).textTheme.aviatorbodySmallFourthBold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // 📌 Bet
                            Expanded(
                              flex: 1,
                              child: Text(
                                bets?.stake.toString() ?? '',
                                textAlign: TextAlign.center,
                                style: Theme.of(
                                  context,
                                ).textTheme.aviatorbodySmallFourthBold,
                              ),
                            ),

                            // 📌 Mult
                            Expanded(
                              flex: 1,
                              child: Text(
                                bets?.cashoutAt.toString() ?? '',
                                textAlign: TextAlign.center,
                                style: Theme.of(
                                  context,
                                ).textTheme.aviatorbodySmallFourthBold,
                              ),
                            ),

                            // 📌 Cashout
                            Expanded(
                              flex: 1,
                              child: Text(
                                bets?.payout.toStringAsFixed(2) ?? '',
                                textAlign: TextAlign.end,
                                style: Theme.of(
                                  context,
                                ).textTheme.aviatorbodySmallFifth,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
