import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/theme.dart';
import '../providers/aviator_round_provider.dart';
import '../providers/recent_rounds_provider.dart';
import '../service/aviator_bet_cache_service.dart';
import '../widget/all_bets.dart';
import '../widget/aviator_buttons.dart';
import '../widget/aviator_flight_animation.dart';
import '../widget/bet_container_.dart';
import '../widget/custom_tab_bar.dart';
import '../widget/my_bets.dart';
import '../widget/top.dart';
import '../widget/wallet_container.dart';

class AviatorGameScreen extends ConsumerStatefulWidget {
  const AviatorGameScreen({super.key});

  @override
  ConsumerState<AviatorGameScreen> createState() => _AviatorGameScreenState();
}

class _AviatorGameScreenState extends ConsumerState<AviatorGameScreen> {
  int _containerCount = 1;
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recentRoundsServiceProvider).startListening();
    });
  }

  bool _hasCheckedCache = false;

  @override
  void dispose() {
    super.dispose();
  }

  void _checkCachedBets(String currentRoundId) async {
    if (_hasCheckedCache) return;
    _hasCheckedCache =
        true; // Mark as checked immediately to prevent duplicate calls

    final cacheService = AviatorBetCacheService();
    final bet2 = await cacheService.getBet(2);

    if (bet2 != null && mounted) {
      // Check if the bet is for the current round
      if (bet2.roundId == currentRoundId) {
        setState(() {
          _containerCount = 2; // Show second container
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(aviatorDisconnectProvider, (previous, next) {
      // Only execute if there's an actual disconnect event
      if (next.hasValue) {
        _messengerKey.currentState?.clearSnackBars();
        ref.read(aviatorFlushbarListProvider.notifier).dismissAll();
      }
    });

    final roundState = ref.watch(aviatorStateProvider);
    final roundId = roundState.when(
      data: (round) => round.roundId ?? '',
      error: (error, st) => error.toString(),
      loading: () => '',
    );

    // Check cached bets once we have a valid roundId
    if (roundId.isNotEmpty && !_hasCheckedCache) {
      _checkCachedBets(roundId);
    }

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const WalletContainer(),
                    const SizedBox(height: 16),
                    const AviatorButtons(),
                    const SizedBox(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Round Id: $roundId',
                          style: Theme.of(
                            context,
                          ).textTheme.aviatorbodySmallPrimary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    const AviatorFlightAnimation(),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _containerCount,
                      itemBuilder: (context, index) {
                        return BetContainer(
                          index: index + 1,
                          showAddButton: index == _containerCount - 1,
                          onAddPressed: () => setState(() => _containerCount++),
                          showRemoveButton: _containerCount > 1 &&
                              index == _containerCount - 1,
                          onRemovePressed: () =>
                              setState(() => _containerCount--),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 16);
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTabBar(
                      tabs: const ['All Bets', 'My Bets', 'Top'],
                      backgroundColor: AppColors.aviatorTwentiethColor,
                      borderRadius: 52,
                      borderWidth: 1,
                      borderColor: AppColors.aviatorFifteenthColor,
                      selectedTabColor: AppColors.aviatorFifteenthColor,
                      unselectedTextColor: AppColors.aviatorTertiaryColor,
                      tabViews: const [AllBets(), MyBets(), Top()],
                    ),
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
