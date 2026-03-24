import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';

import '../core/constants/app_colors.dart';

class WalletContainer extends ConsumerStatefulWidget {
  const WalletContainer({super.key});

  @override
  ConsumerState<WalletContainer> createState() => _WalletContainerState();
}

class _WalletContainerState extends ConsumerState<WalletContainer> {
  @override
  void initState() {
    super.initState();
    // Trigger fetch on init if data is not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = ref.read(getParticularPlayerNotifierProvider);
      userState.whenOrNull(
        data: (data) {
          if (data.getParticularPlayerModel?.data == null) {
            ref
                .read(getParticularPlayerNotifierProvider.notifier)
                .getParticularPlayerModel();
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the main app's user provider for wallet balance
    final userState = ref.watch(getParticularPlayerNotifierProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.aviatorSecondaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.aviatorFifteenthColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: AppColors.aviatorTertiaryColor,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Wallet',
                style: TextStyle(
                  color: AppColors.aviatorTertiaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              userState.when(
                data: (data) {
                  final wallet =
                      data.getParticularPlayerModel?.data?.wallet ?? 0;
                  return Text(
                    '₹ ${wallet.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.aviatorFifthColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
                loading: () => const Text(
                  '₹ ...',
                  style: TextStyle(
                    color: AppColors.aviatorFifthColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                error: (_, __) => const Text(
                  '₹ 0.00',
                  style: TextStyle(
                    color: AppColors.aviatorFifthColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  // Refresh user data to update wallet
                  ref
                      .read(getParticularPlayerNotifierProvider.notifier)
                      .getParticularPlayerModel();
                },
                child: const Icon(
                  Icons.refresh,
                  color: AppColors.aviatorTertiaryColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
