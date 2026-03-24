// ignore_for_file: file_names

import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/theme.dart';
import '../domain/models/bet_request.dart';
import '../providers/aviator_round_provider.dart';
import '../providers/bet_provider.dart';
import '../providers/bet_reponse_provider.dart';
import '../providers/cashout_provider.dart';
import '../providers/user_provider.dart';
import '../service/aviator_bet_cache_service.dart';
import 'bet_container_.dart';

class CustomBetButton extends ConsumerStatefulWidget {
  final int index;
  final TextEditingController amountController;
  final TextEditingController? switchController;
  final AutoPlayState? autoPlayState;
  final Function(int, double)? onAutoPlayUpdate;
  final VoidCallback? onAutoPlayStop;
  final bool Function(double, double)? shouldContinueAutoPlay;
  final VoidCallback? onBetPlaced;
  final VoidCallback? onBetFinished;
  final Function(String)? onValidationError;

  const CustomBetButton({
    super.key,
    required this.index,
    required this.amountController,
    this.switchController,
    this.autoPlayState,
    this.onAutoPlayUpdate,
    this.onAutoPlayStop,
    this.shouldContinueAutoPlay,
    this.onBetPlaced,
    this.onBetFinished,
    this.onValidationError,
  });

  @override
  ConsumerState<CustomBetButton> createState() => _CustomBetButtonState();
}

class _CustomBetButtonState extends ConsumerState<CustomBetButton> {
  bool hasPlacedBet = false;
  bool hasAutoCashedOut = false;
  String? lastRoundId;
  double? lastMultiplier;
  bool _isPlacingBet = false; // Flag to prevent duplicate bet placement

  // Queued bet state when user taps during RUNNING
  bool _hasQueuedBet = false;
  String? _queuedAmountText;

  double? _queuedAutoCashoutValue;
  double? _pendingWinAmount;

  final _cacheService = AviatorBetCacheService();
  bool _hasCheckedCache = false;

  String? getUserId() {
    // Use aviator userProvider which wraps main app's user data
    final userData = ref.read(userProvider);
    return userData.valueOrNull?.id;
  }

  void _handleRoundCrash() {
    // If autoplay is active and we crashed (lost the bet), update win amount
    if (widget.autoPlayState != null &&
        widget.autoPlayState!.settings != null) {
      widget.onAutoPlayUpdate?.call(
        widget.autoPlayState!.roundsPlayed,
        0.0, // No win on crash
      );

      // Check if should continue autoplay after crash
      final user = ref.read(userProvider);
      user.maybeWhen(
        data: (userModel) {
          final currentWallet = userModel.wallet;
          if (widget.shouldContinueAutoPlay != null &&
              !widget.shouldContinueAutoPlay!(currentWallet, 0.0)) {
            widget.onAutoPlayStop?.call();
          }
        },
        orElse: () {},
      );
    }
  }

  void _handleAutoPlayContinuation() {
    if (widget.autoPlayState == null ||
        widget.autoPlayState!.settings == null) {
      return;
    }

    final user = ref.read(userProvider);
    user.maybeWhen(
      data: (userModel) {
        final currentWallet = userModel.wallet;
        final lastWinAmount = widget.autoPlayState!.lastWinAmount;

        // Check if should continue autoplay
        if (widget.shouldContinueAutoPlay != null &&
            widget.shouldContinueAutoPlay!(currentWallet, lastWinAmount)) {
          // Automatically place next bet
          _placeBet();
        } else {
          // Stop autoplay
          widget.onAutoPlayStop?.call();
        }
      },
      orElse: () {},
    );
  }

  void _startAutoPlayBetting() {
    // This method is called when autoplay is first started
    // Place the initial bet immediately if conditions allow
    final round = ref.read(aviatorRoundNotifierProvider);
    if (round != null && round.state == 'pending') {
      _placeBet();
    }
  }

  Future<void> _restoreCachedBet(String currentRoundId) async {
    log('🔍 _restoreCachedBet called for round: $currentRoundId');
    final cachedBet = await _cacheService.getBet(widget.index);
    log('📦 Cached bet found: ${cachedBet?.toJson()}');

    if (cachedBet != null) {
      log(
        '🧐 Comparing cached roundId: ${cachedBet.roundId} with current: $currentRoundId',
      );
      if (cachedBet.roundId == currentRoundId) {
        log('✅ Round IDs match! Restoring bet...');
        if (!mounted) {
          log('❌ Widget not mounted, aborting restore');
          return;
        }

        // Restore state
        ref
            .read(betResponseProvider.notifier)
            .setBetResponse(widget.index, cachedBet);
        ref.read(betStateProvider.notifier).placeBet(widget.index);

        setState(() {
          hasPlacedBet = true;
        });
        widget.onBetPlaced?.call(); // Notify parent to disable inputs
        log(
          '♻️ Restored cached bet for round $currentRoundId. hasPlacedBet set to true.',
        );
      } else {
        // Old bet, clear it
        log(
          '🧹 Cached bet is from old round (${cachedBet.roundId}). Clearing cache.',
        );
        await _cacheService.clearBet(widget.index);
      }
    } else {
      log('📭 No cached bet found for index ${widget.index}');
    }
  }

  Future<void> _placeBet({
    String? amountOverride,
    double? autoCashoutOverride,
  }) async {
    // Prevent duplicate bet placement
    if (_isPlacingBet || hasPlacedBet) return;

    _isPlacingBet = true;

    try {
      final round = ref.watch(aviatorRoundNotifierProvider);
      final betService = ref.read(betServiceProvider);
      final userId = getUserId();

      if (userId == null || round == null) return;

      // Only place bet during PREPARE; queued bets will call this when the
      // next round is in PREPARE state.
      if (round.state != 'pending') {
        log('⚠️ Skipping bet placement, invalid round state: ${round.state}');
        return;
      }

      // Determine stake / auto cashout source: queued override vs controllers
      late final String amountText;
      double? autoCashoutValue;

      if (amountOverride != null || autoCashoutOverride != null) {
        amountText = (amountOverride ?? '').trim();
        autoCashoutValue = autoCashoutOverride;
      } else {
        final controllerAmountText = widget.amountController.text.trim();
        final autoCashoutText = widget.switchController?.text.trim() ?? '';

        int? val = int.tryParse(controllerAmountText);
        if (val != null && val < 10) {
          widget.amountController.text = "10";
          amountText = "10";
        } else {
          amountText = controllerAmountText;
        }

        autoCashoutValue = autoCashoutText.isNotEmpty
            ? double.tryParse(autoCashoutText)
            : null;
      }

      if (amountText.isEmpty) {
        log('⚠️ Bet amount is empty');
        return;
      }

      // Check for empty or invalid auto cashout if enabled
      if (widget.switchController != null) {
        final text = widget.switchController!.text.trim();
        final val = double.tryParse(text) ?? 0.0;
        if (text.isEmpty || val < 1.10) {
          widget.switchController!.text = "1.10";
          autoCashoutValue = 1.10;
        }
      }

      final roundId = round.roundId;
      final seq = round.seq;

      final newBet = await betService.placeBet(
        BetRequest(
          roundId: roundId!,
          userId: userId,
          seq: int.parse(seq.toString()),
          stake: int.parse(amountText),
          betIndex: widget.index,
          autoCashout: autoCashoutValue,
        ),
      );

      ref
          .read(betResponseProvider.notifier)
          .setBetResponse(widget.index, newBet);
      ref.read(betStateProvider.notifier).placeBet(widget.index);

      // Update wallet after placing bet
      final currentUser = ref.read(userProvider);
      currentUser.maybeWhen(
        data: (userModel) {
          final newWallet = userModel.wallet - newBet.stake;
          ref.read(userNotifierProvider.notifier).refresh();
          ref.read(walletBalanceProvider.notifier).updateBalance(newWallet);
        },
        orElse: () {},
      );

      // Save to cache
      log('💾 Saving bet to cache: ${newBet.id}');
      await _cacheService.saveBet(widget.index, newBet);

      setState(() {
        hasPlacedBet = true;
      });

      widget.onBetPlaced?.call();

      // Increment rounds played for autoplay
      if (widget.autoPlayState != null) {
        widget.onAutoPlayUpdate?.call(
          widget.autoPlayState!.roundsPlayed + 1,
          0.0,
        );
      }

      log('✅ Bet placed successfully: ${newBet.stake}');
    } on DioException catch (e) {
      // If server says "You already have a bet", we should treat it as success (recover state)
      // or at least not show an error snackbar, and try to sync the bet.
      final errorMsg = e.response?.data?['message'] ?? 'Bet failed';

      if (e.response?.statusCode == 400 &&
          errorMsg.toString().contains('already have a bet')) {
        log(
          '⚠️ Server says bet already exists. Attempting to recover/sync state.',
        );

        // We assume the bet WAS placed successfully.
        // Ideally we should fetch the bet details from server here if we don't have them.
        // For now, we can try to restore from cache again or assume current params are active.
        // But "newBet" is null here.

        // Let's set hasPlacedBet = true to show "WAITING" or "CASHOUT" so user doesn't double click.
        setState(() {
          hasPlacedBet = true;
        });

        // If we have cached bet for this round, restore it now to be safe
        final roundId = ref.read(aviatorRoundNotifierProvider)?.roundId;
        if (roundId != null) {
          _restoreCachedBet(roundId);
        }
      } else {
        log('❌ Error placing bet: $errorMsg');
        _customSnackBar(context, errorMsg);
      }
    } catch (e) {
      log('❌ Error placing bet: $e');
      _customSnackBar(context, 'Something went wrong. Please try again.');
    } finally {
      _isPlacingBet = false;
    }
  }

  @override
  void didUpdateWidget(CustomBetButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoPlayState != widget.autoPlayState) {
      if (mounted) {
        if (widget.autoPlayState != null &&
            widget.autoPlayState!.settings != null &&
            ref.read(aviatorRoundNotifierProvider)?.state == 'pending' &&
            !hasPlacedBet) {
          _startAutoPlayBetting();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final round = ref.watch(aviatorRoundNotifierProvider);
    final tick = ref.watch(aviatorTickProvider);
    // Watch user provider to ensure we rebuild when user data (wallet) is available
    ref.watch(userProvider);

    // Listen for crash to reset bet state immediately
    ref.listen(aviatorRoundNotifierProvider, (previous, next) {
      if (next?.state == 'crashed' && previous?.state != 'crashed') {
        if (_pendingWinAmount != null) {
          final currentUser = ref.read(userProvider);
          currentUser.maybeWhen(
            data: (userModel) {
              final newWallet = userModel.wallet + _pendingWinAmount!;
              ref.read(userNotifierProvider.notifier).refresh();
              ref.read(walletBalanceProvider.notifier).updateBalance(newWallet);
            },
            orElse: () {},
          );
          _pendingWinAmount = null;
        }

        if (hasPlacedBet) {
          setState(() {
            hasPlacedBet = false;
          });
          widget.onBetFinished?.call();
        }
      }
    });

    // Reset hasPlacedBet if a new round starts
    if (round != null && round.roundId != lastRoundId) {
      log('🔄 Round changed: $lastRoundId -> ${round.roundId}');

      // If lastRoundId is not null, it means we are transitioning from a previous known round.
      // We should clear the cache found for that previous round.
      if (lastRoundId != null) {
        log('🧹 Clearing cache for previous round: $lastRoundId');
        _cacheService.clearBet(widget.index);

        // Unconditionally notify that bet is finished (resetting UI in parent)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onBetFinished?.call();
        });

        if (round.state == 'crashed') {
          _handleRoundCrash();
        }
      } else {
        log(
          '🆕 First load (lastRoundId was null). Keeping cache for restoration.',
        );
      }

      hasPlacedBet = false;
      hasAutoCashedOut = false;
      lastMultiplier = null;
      lastRoundId = round.roundId;

      // Handle autoplay continuation after round reset
      if (widget.autoPlayState != null &&
          widget.autoPlayState!.settings != null) {
        _handleAutoPlayContinuation();
      }

      // If user queued a bet while the previous round was RUNNING,
      // automatically place it at the start of the next PREPARE phase.
      if (_hasQueuedBet && round.state == 'pending') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _placeBet(
            amountOverride: _queuedAmountText,
            autoCashoutOverride: _queuedAutoCashoutValue,
          );
          if (mounted) {
            setState(() {
              _hasQueuedBet = false;
              _queuedAmountText = null;
              _queuedAutoCashoutValue = null;
            });
          }
        });
      }
    }

    // Check if autoplay was just started and place first bet
    if (widget.autoPlayState != null &&
        widget.autoPlayState!.settings != null &&
        widget.autoPlayState!.roundsPlayed == 0 &&
        !hasPlacedBet &&
        round != null &&
        round.state == 'pending') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startAutoPlayBetting();
      });
    }

    // Restore cache logic
    if (!_hasCheckedCache && round != null && round.roundId != null) {
      log('⚡ Initial cache check triggered for round ${round.roundId}');
      _hasCheckedCache = true;
      _restoreCachedBet(round.roundId!);
    }

    final bet = ref.watch(betResponseProvider)[widget.index];
    // log('👀 Build check - hasPlacedBet: $hasPlacedBet, isWaiting: $isWaitingForRound, isCashout: $isCashoutButton, Bet: ${bet?.id}');

    // Handle waiting state between placing bet and running
    final isWaitingForRound = hasPlacedBet && round?.state == 'pending';
    final isCashoutButton = hasPlacedBet && round?.state == 'running';

    // Auto Cashout logic
    if (isCashoutButton && bet != null && bet.autoCashout != null) {
      tick.whenData((tickData) async {
        final multiplier =
            double.tryParse(tickData.multiplier.toString()) ?? 0.0;

        // Only trigger cashout once when crossing the threshold
        if (!hasAutoCashedOut &&
            multiplier > bet.autoCashout! &&
            (lastMultiplier == null || lastMultiplier! <= bet.autoCashout!)) {
          lastMultiplier = multiplier;
          hasAutoCashedOut = true;

          try {
            final cashoutService = ref.read(cashoutServiceProvider);
            // Send the exact autoCashout value the user set, not the current multiplier
            final cashout = await cashoutService
                .cashout(bet.id, round!.roundId!, multiplier: bet.autoCashout);
            await _cacheService.clearBet(widget.index);
            final autoCashoutAt = cashout.cashoutAt;

            log("✅ Auto Cashout triggered at $autoCashoutAt X");

            // Update wallet after auto cashout
            final currentUser = ref.read(userProvider);
            currentUser.maybeWhen(
              data: (userModel) {
                final winAmount = autoCashoutAt! * bet.stake;
                final newWallet = userModel.wallet + winAmount;
                // Delay updates until crash
                _pendingWinAmount = winAmount;
                // ref.read(userProvider.notifier).updateWallet(newWallet);
                // ref.read(walletBalanceProvider.notifier).updateBalance(newWallet);

                // Update autoplay state
                if (widget.autoPlayState != null) {
                  widget.onAutoPlayUpdate?.call(
                    widget.autoPlayState!.roundsPlayed,
                    winAmount,
                  );

                  // Check if should continue autoplay
                  if (widget.shouldContinueAutoPlay != null &&
                      !widget.shouldContinueAutoPlay!(newWallet, winAmount)) {
                    widget.onAutoPlayStop?.call();
                  } else {
                    // Continue autoplay - next bet will be placed when round resets
                  }
                }
              },
              orElse: () {},
            );

            if (mounted) {
              setState(() {
                hasPlacedBet = false;
              });
              widget.onBetFinished?.call();
            }

            // Show Flushbar
            _successFlushbar(
              context: context,
              message1: "Auto Cashed Out!\n",
              multiplier: '${autoCashoutAt?.toStringAsFixed(2) ?? "-"}x',
              message2: 'Win INR\n',
              winAmount: (cashout.payout ?? (autoCashoutAt! * bet.stake))
                  .toStringAsFixed(2),
            );
          } catch (e) {
            log("❌ Auto Cashout failed: $e");
            // Don't reset hasAutoCashedOut - bet state may have already changed
            // Only reset hasPlacedBet to clean up UI
            if (mounted) {
              setState(() {
                hasPlacedBet = false;
              });
              widget.onBetFinished?.call();
            }
          }
        }

        lastMultiplier = multiplier;
      });
    }

    final isQueuedBet = !hasPlacedBet && _hasQueuedBet;

    final currentMultiplier = tick.maybeWhen(
      data: (tickData) {
        final value = tickData.multiplier;
        if (value is num) {
          return double.tryParse(value.toString()) ?? 1.0;
        }
        if (value is String) return double.tryParse(value) ?? 1.0;
        return 1.0;
      },
      orElse: () => 1.0,
    );

    final buttonText = !hasPlacedBet
        ? (isQueuedBet ? "WAITING" : "BET")
        : isCashoutButton
            ? "CASHOUT"
            : isWaitingForRound
                ? "WAITING"
                : "BET";

    final enabled = !hasPlacedBet || isCashoutButton;

    return SizedBox(
      height: 108,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (!hasPlacedBet) {
              if (_hasQueuedBet) {
                // queued bet uses the same color as WAITING state
                return AppColors.aviatorTwentySixthColor;
              }
              return AppColors.aviatorEighteenthColor; // initial Place Bet
            } else if (hasPlacedBet && round?.state == 'running') {
              return AppColors.aviatorSeventeenthColor; // CASHOUT
            } else if (round?.state == 'crashed') {
              return AppColors.aviatorSeventeenthColor;
            } else {
              return AppColors
                  .aviatorTwentySixthColor; // Bet placed but waiting
            }
          }),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          ),
          minimumSize: MaterialStateProperty.all(const Size(55, 30)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: enabled
            ? () async {
                // Place Bet or cancel queued bet
                if (!hasPlacedBet && round != null) {
                  if (_hasQueuedBet) {
                    // Cancel the queued bet
                    setState(() {
                      _hasQueuedBet = false;
                      _queuedAmountText = null;
                      _queuedAutoCashoutValue = null;
                    });
                    widget.onBetFinished?.call();
                    _customSnackBar(context, 'Pending bet cancelled.');
                    return;
                  }

                  if (round.state == 'running') {
                    // Queue bet for the next round instead of rejecting
                    String amountText = widget.amountController.text.trim();
                    int? val = int.tryParse(amountText);
                    if (val != null && val < 10) {
                      widget.amountController.text = "10";
                      amountText = "10";
                    }

                    final autoCashoutText =
                        widget.switchController?.text.trim() ?? '';

                    if (amountText.isEmpty) {
                      _customSnackBar(context, 'Please enter an amount to bet');
                      return;
                    }

                    final autoCashoutValue = autoCashoutText.isNotEmpty
                        ? double.tryParse(autoCashoutText)
                        : null;

                    setState(() {
                      _hasQueuedBet = true;
                      _queuedAmountText = amountText;
                      _queuedAutoCashoutValue = autoCashoutValue;
                    });
                    widget.onBetPlaced?.call();

                    _customSnackBar(
                      context,
                      'Your bet has been added to the next round.',
                    );
                  } else {
                    await _placeBet();
                  }
                }
                // Cashout
                else if (isCashoutButton && bet != null) {
                  final cashoutService = ref.read(cashoutServiceProvider);
                  final multiplier = tick.maybeWhen(
                    data: (tick) {
                      final value = tick.multiplier;
                      if (value is num) {
                        return double.tryParse(value.toString()) ?? 0.0;
                      }
                      if (value is String) return double.tryParse(value) ?? 0.0;
                      return 0.0;
                    },
                    orElse: () => 0.0,
                  );
                  // Auto Cashout check
                  if (!hasAutoCashedOut &&
                      bet.autoCashout != null &&
                      multiplier >= bet.autoCashout!) {
                    hasAutoCashedOut = true; // mark as done
                    //   final cashoutService = ref.read(cashoutServiceProvider);

                    // try {
                    //   final response = await cashoutService.cashout(
                    //     id: bet.id,
                    //     cashOutAt: multiplier,
                    //   );
                    //   log(
                    //     "✅ Auto Cashout triggered at ${response.cashoutAt} X",
                    //   );
                    //   setState(() {
                    //     hasPlacedBet = false; // reset button if needed
                    //   });
                    // } catch (e) {
                    //   log("❌ Auto Cashout failed: $e");
                    // }
                  }

                  try {
                    log(
                      "📤 Cashout request: id=${bet.id}, cashOutAt=$multiplier",
                    );

                    // Small delay to ensure multiplier is stable
                    //      await Future.delayed(const Duration(milliseconds: 50));
                    final response = await cashoutService.cashout(
                        bet.id, round!.roundId!,
                        multiplier: multiplier);
                    if (mounted) {
                      setState(() {
                        hasPlacedBet = false;
                      });
                      widget.onBetFinished?.call();
                    }

                    final cashoutAt = response.cashoutAt;
                    final actualPayout = response.payout ?? 0.0;
                    await _cacheService.clearBet(widget.index);
                    log('✅ CashoutAt: $cashoutAt X, Payout: $actualPayout');

                    // Update wallet after cashout
                    final currentUser = ref.read(userProvider);
                    currentUser.maybeWhen(
                      data: (userModel) {
                        // Use actual payout from server, not calculated value
                        final winAmount = actualPayout;
                        // Delay updates until crash
                        _pendingWinAmount = winAmount;

                        // Update autoplay state for manual cashout
                        if (widget.autoPlayState != null) {
                          widget.onAutoPlayUpdate?.call(
                            widget.autoPlayState!.roundsPlayed,
                            winAmount,
                          );
                        }
                      },
                      orElse: () {},
                    );

                    // Show Flushbar
                    _successFlushbar(
                      context: context,
                      message1: "Cashed Out!\n",
                      multiplier: '${cashoutAt?.toStringAsFixed(2) ?? "-"}x',
                      message2: 'Win INR\n',
                      winAmount: actualPayout.toStringAsFixed(2),
                    );
                  } catch (e, st) {
                    log("❌ Cashout error: $e\n$st");
                  }
                }
              }
            : null,
        child: isQueuedBet
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.aviatorHeadlineSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Wait for next round',
                    style: Theme.of(context).textTheme.aviatorbodySmallPrimary,
                  ),
                ],
              )
            : isCashoutButton && bet != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CASHOUT',
                        style: Theme.of(context).textTheme.aviatorHeadlineSmall,
                      ),
                      Text(
                        "₹${(currentMultiplier * bet.stake).toStringAsFixed(2)}",
                        style: Theme.of(context)
                            .textTheme
                            .aviatorHeadlineSmall
                            .copyWith(
                                fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                : Text(
                    buttonText,
                    style: Theme.of(context).textTheme.aviatorHeadlineSmall,
                  ),
      ),
    );
  }

  // Success Flushbar
  void _successFlushbar({
    required BuildContext context,
    required String message1,
    required String multiplier,
    required String message2,
    required String winAmount,
  }) {
    final flushbar = Flushbar(
      messageText: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: message1,
                      style: TextStyle(
                        color: AppColors.aviatorSixteenthColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: multiplier,
                      style: const TextStyle(
                        color: AppColors.aviatorTertiaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: AppColors.aviatorEighteenthColor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: message2,
                        style: TextStyle(
                          color: AppColors.aviatorSixteenthColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: winAmount,
                        style: const TextStyle(
                          color: AppColors.aviatorTertiaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
      backgroundColor: AppColors.aviatorTwentySeventhColor,
      margin: const EdgeInsets.all(2.0),
      borderWidth: 2,
      borderColor: AppColors.aviatorEighteenthColor,
      duration: const Duration(seconds: 5),
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      borderRadius: BorderRadius.circular(50),
      animationDuration: const Duration(seconds: 1),
      maxWidth: 300,
    );
    ref.read(aviatorFlushbarListProvider.notifier).add(flushbar);
    flushbar.show(context);
  }

  // Custom SnackBar
  void _customSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.aviatorTwentySixthColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
