import 'dart:math';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/theme.dart';
import '../core/widgets/custom_elevated_button.dart';
import '../providers/aviator_round_provider.dart';
import '../providers/user_provider.dart';
import '../service/aviator_bet_cache_service.dart';
import 'auto_play_widget.dart';
import 'custom_bet_button .dart';

class AutoPlayState {
  final AutoPlaySettings? settings;
  final int roundsPlayed;
  final double initialWallet;
  final double lastWinAmount;

  AutoPlayState({
    this.settings,
    this.roundsPlayed = 0,
    this.initialWallet = 0.0,
    this.lastWinAmount = 0.0,
  });

  AutoPlayState copyWith({
    AutoPlaySettings? settings,
    int? roundsPlayed,
    double? initialWallet,
    double? lastWinAmount,
  }) {
    return AutoPlayState(
      settings: settings ?? this.settings,
      roundsPlayed: roundsPlayed ?? this.roundsPlayed,
      initialWallet: initialWallet ?? this.initialWallet,
      lastWinAmount: lastWinAmount ?? this.lastWinAmount,
    );
  }
}

class BetContainer extends ConsumerStatefulWidget {
  final int index;
  final bool showAddButton;
  final VoidCallback? onAddPressed;
  final bool showRemoveButton;
  final VoidCallback? onRemovePressed;

  const BetContainer({
    super.key,
    required this.index,
    this.showAddButton = false,
    this.onAddPressed,
    this.showRemoveButton = false,
    this.onRemovePressed,
  });

  @override
  ConsumerState<BetContainer> createState() => _BetContainerState();
}

class _BetContainerState extends ConsumerState<BetContainer> {
  final _switchController = TextEditingController();
  int _selectedValue = 0;
  bool _isSwitched = false;
  final _amountController = TextEditingController();
  final _autoAmountController = TextEditingController();
  late FocusNode _amountFocusNode;
  late FocusNode _autoAmountFocusNode;

  final _cacheService = AviatorBetCacheService();

  AutoPlayState _autoPlayState = AutoPlayState();
  bool _manualBetActive = false;
  String? _autoCashoutError;

  String? getUserId() {
    // Use aviator userProvider which wraps main app's user data
    final userData = ref.read(userProvider);
    return userData.valueOrNull?.id;
  }

  void _setAmount(String value) {
    setState(() {
      TextEditingController controller =
          _selectedValue == 0 ? _amountController : _autoAmountController;
      int current = int.tryParse(controller.text) ?? 10;
      int add = int.tryParse(value) ?? 0;
      controller.text = (current + add).clamp(10, 1000).toString();
    });
  }

  void _startAutoPlay(AutoPlaySettings settings) {
    final user = ref.read(userProvider);
    user.maybeWhen(
      data: (userModel) {
        setState(() {
          _autoPlayState = AutoPlayState(
            settings: settings,
            roundsPlayed: 0,
            initialWallet: userModel.wallet,
            lastWinAmount: 0.0,
          );
        });
        _saveAutoPlayState();
        // Place the first bet immediately
        _placeFirstAutoBet();
      },
      orElse: () {},
    );
  }

  void _placeFirstAutoBet() {
    // Trigger the first bet placement for autoplay
    // This will be handled by the CustomBetButton's autoplay logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The CustomBetButton will handle placing the first bet when autoplay starts
    });
  }

  void _stopAutoPlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _autoPlayState = AutoPlayState();
        });
      }
      _cacheService.clearAutoPlayState(widget.index);
    });
  }

  bool _shouldContinueAutoPlay(double currentWallet, double winAmount) {
    if (_autoPlayState.settings == null) return false;

    final settings = _autoPlayState.settings!;
    final roundsPlayed = _autoPlayState.roundsPlayed;
    final maxRounds = int.tryParse(settings.selectedRounds ?? '0') ?? 0;

    // Check if max rounds reached
    if (maxRounds > 0 && roundsPlayed >= maxRounds) return false;

    // Check cash decrease condition
    if (settings.stopIfCashDecreases) {
      final decrease = _autoPlayState.initialWallet - currentWallet;
      if (decrease >= settings.decrementAmount) return false;
    }

    // Check cash increase condition
    if (settings.stopIfCashIncreases) {
      final increase = currentWallet - _autoPlayState.initialWallet;
      if (increase >= settings.incrementAmount) return false;
    }

    // Check single win exceeds condition
    if (settings.stopIfSingleWinExceeds &&
        winAmount >= settings.exceedsAmount) {
      return false;
    }

    return true;
  }

  void _increment() {
    TextEditingController controller =
        _selectedValue == 0 ? _amountController : _autoAmountController;
    int value = int.tryParse(controller.text) ?? 10;
    controller.text = min(value + 1, 1000).toString();
  }

  void _decrement() {
    TextEditingController controller =
        _selectedValue == 0 ? _amountController : _autoAmountController;
    int value = int.tryParse(controller.text) ?? 10;
    if (value > 10) {
      controller.text = (value - 1).toString();
    }
  }

  @override
  void dispose() {
    _cacheService.clearAutoPlayState(widget.index);
    _amountFocusNode.dispose();
    _autoAmountFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _amountController.text = 10.toString();
    _autoAmountController.text = 10.toString();
    _switchController.text = "1.10";
    _amountFocusNode = FocusNode();
    _autoAmountFocusNode = FocusNode();
    _amountFocusNode.addListener(
      () => _onFocusChange(_amountFocusNode, _amountController),
    );
    _autoAmountFocusNode.addListener(
      () => _onFocusChange(_autoAmountFocusNode, _autoAmountController),
    );
    super.initState();
    _restoreAutoPlayState();
  }

  void _onFocusChange(FocusNode focusNode, TextEditingController controller) {
    if (focusNode.hasFocus) {
      controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: controller.text.length,
      );
    } else {
      if (controller.text.isEmpty) {
        controller.text = "10";
      } else {
        int? value = int.tryParse(controller.text);
        if (value == null || value < 10) {
          controller.text = "10";
        }
      }
    }
  }

  Future<void> _restoreAutoPlayState() async {
    final cachedState = await _cacheService.getAutoPlayState(widget.index);
    if (cachedState != null) {
      if (!mounted) return;
      setState(() {
        _autoPlayState = AutoPlayState(
          settings: AutoPlaySettings(
            selectedRounds: cachedState['selectedRounds'],
            stopIfCashDecreases: cachedState['stopIfCashDecreases'] ?? false,
            decrementAmount: cachedState['decrementAmount'] ?? 0.0,
            stopIfCashIncreases: cachedState['stopIfCashIncreases'] ?? false,
            incrementAmount: cachedState['incrementAmount'] ?? 0.0,
            stopIfSingleWinExceeds:
                cachedState['stopIfSingleWinExceeds'] ?? false,
            exceedsAmount: cachedState['exceedsAmount'] ?? 0.0,
            autoCashout: cachedState['autoCashout'],
          ),
          roundsPlayed: cachedState['roundsPlayed'] ?? 0,
          initialWallet: cachedState['initialWallet'] ?? 0.0,
          lastWinAmount: cachedState['lastWinAmount'] ?? 0.0,
        );
        // Restore bet amount if available
        if (cachedState['autoAmount'] != null) {
          _autoAmountController.text = cachedState['autoAmount'];
        }
        // Restore manual/auto switch state if relevant, though logic suggests we are in auto mode if state exists
        if (cachedState['selectedValue'] != null) {
          _selectedValue = cachedState['selectedValue'];
        }
      });
    }
  }

  Future<void> _saveAutoPlayState() async {
    if (_autoPlayState.settings == null) return;
    final settings = _autoPlayState.settings!;
    final state = {
      'selectedRounds': settings.selectedRounds,
      'stopIfCashDecreases': settings.stopIfCashDecreases,
      'decrementAmount': settings.decrementAmount,
      'stopIfCashIncreases': settings.stopIfCashIncreases,
      'incrementAmount': settings.incrementAmount,
      'stopIfSingleWinExceeds': settings.stopIfSingleWinExceeds,
      'exceedsAmount': settings.exceedsAmount,
      'autoCashout': settings.autoCashout,
      'roundsPlayed': _autoPlayState.roundsPlayed,
      'initialWallet': _autoPlayState.initialWallet,
      'lastWinAmount': _autoPlayState.lastWinAmount,
      'autoAmount': _autoAmountController.text,
      'selectedValue': _selectedValue,
    };
    await _cacheService.saveAutoPlayState(widget.index, state);
  }

  @override
  Widget build(BuildContext context) {
    //!------BET CONTAINER------
    ref.listen(aviatorDisconnectProvider, (previous, next) {
      _stopAutoPlay();
    });
    return AnimatedContainer(
      duration: const Duration(milliseconds: 0),
      height: _selectedValue == 0 ? 210 : 258,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.aviatorTwentiethColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.aviatorFifteenthColor, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: SizedBox(width: 0, height: 0)),
              SizedBox(
                width: 191,
                height: 28,
                //! SWITCH
                child: _buildSwitch(),
              ),
              if (widget.showRemoveButton)
                CustomElevatedButton(
                  hasBorder: true,
                  borderColor:
                      (_manualBetActive || _autoPlayState.settings != null)
                          ? AppColors.aviatorFourtyColor.withOpacity(0.5)
                          : AppColors.aviatorFourtyColor,
                  backgroundColor: AppColors.aviatorTwentiethColor,
                  padding: const EdgeInsets.all(2),
                  height: 22,
                  width: 22,
                  onPressed:
                      (_manualBetActive || _autoPlayState.settings != null)
                          ? null
                          : widget.onRemovePressed,
                  child: Icon(
                    Icons.remove,
                    size: 18.33,
                    color: (_manualBetActive || _autoPlayState.settings != null)
                        ? AppColors.aviatorFourtyColor.withOpacity(0.5)
                        : AppColors.aviatorFourtyColor,
                  ),
                )
              else if (widget.showAddButton)
                CustomElevatedButton(
                  hasBorder: true,
                  borderColor: AppColors.aviatorFourtyColor,
                  backgroundColor: AppColors.aviatorTwentiethColor,
                  padding: const EdgeInsets.all(2),
                  height: 22,
                  width: 22,
                  onPressed: widget.onAddPressed,
                  child: const Icon(
                    Icons.add,
                    size: 18.33,
                    color: AppColors.aviatorFourtyColor,
                  ),
                )
              else
                const SizedBox(width: 22, height: 22),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            child: Center(
              child: _selectedValue == 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 16),
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  //! container for Amount, + & - button
                                  _buildAmountTextField(
                                    context,
                                    _amountController,
                                    !_manualBetActive,
                                    _amountFocusNode,
                                  ),

                                  const SizedBox(height: 10),
                                  //! BUTTON FOR ₹10 & ₹20
                                  Row(
                                    children: [
                                      _quickAmountButton(
                                        context,
                                        '₹10',
                                        '10',
                                        !_manualBetActive,
                                      ),
                                      const SizedBox(width: 6),
                                      _quickAmountButton(
                                        context,
                                        '₹20',
                                        '20',
                                        !_manualBetActive,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  //! BUTTON FOR ₹50 & ₹100
                                  Row(
                                    children: [
                                      _quickAmountButton(
                                        context,
                                        '₹50',
                                        '50',
                                        !_manualBetActive,
                                      ),
                                      const SizedBox(width: 6),
                                      _quickAmountButton(
                                        context,
                                        '₹100',
                                        '100',
                                        !_manualBetActive,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        //  SizedBox(width: 20),
                        //! Manual BUTTON FOR BET
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [Expanded(child: _manualBetButton())],
                          ),
                        ),
                      ],
                    )
                  //!      ----------------------  AUTO---------------------------------
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: 16),
                        Expanded(
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  //! CONTAINER FOR AMOUNT, + & - button in AUTo
                                  _buildAmountTextField(
                                    context,
                                    _autoAmountController,
                                    !_manualBetActive,
                                    _autoAmountFocusNode,
                                  ),

                                  const SizedBox(height: 10),
                                  //!Auto BUTTON FOR AMOUNT 10 & 20
                                  Row(
                                    children: [
                                      _quickAmountButton(
                                        context,
                                        '₹10',
                                        '10',
                                        !_manualBetActive,
                                      ),
                                      const SizedBox(width: 6),
                                      _quickAmountButton(
                                        context,
                                        '₹20',
                                        '20',
                                        !_manualBetActive,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  //!Auto BUTTON FOR AMOUNT 50 &100
                                  Row(
                                    children: [
                                      _quickAmountButton(
                                        context,
                                        '₹50',
                                        '50',
                                        !_manualBetActive,
                                      ),
                                      const SizedBox(width: 6),
                                      _quickAmountButton(
                                        context,
                                        '₹100',
                                        '100',
                                        !_manualBetActive,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        //  SizedBox(width: 20),
                        //!Auto BUTTON FOR BET---------------------------------------------------
                        Expanded(child: _autoBetButton()),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          //! AUTOPLAY Button
          if (_selectedValue == 1)
            Row(
              children: [
                //! AUTOPLAY button
                _buildAutoplayButton(context),
                // const SizedBox(width: 16),
                const Spacer(),

                //! section (Auto Cash Out + Switch + TextField)
                _buildAutoCashOutRow(context),
              ],
            ),
        ],
      ),
    );
  }

  //!Switch
  Widget _buildSwitch() {
    return IgnorePointer(
      ignoring: _manualBetActive,
      child: Opacity(
        opacity: _manualBetActive ? 0.5 : 1.0,
        child: CustomSlidingSegmentedControl<int>(
          initialValue: _selectedValue,
          children: {
            0: Text(
              'Bet',
              style: Theme.of(context).textTheme.aviatorBodyMediumPrimary,
            ),
            1: Text(
              'Auto',
              style: Theme.of(context).textTheme.aviatorBodyMediumPrimary,
            ),
          },

          decoration: BoxDecoration(
            color: AppColors.aviatorTwentiethColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.aviatorFifteenthColor,
              width: 1,
            ),
          ),

          thumbDecoration: BoxDecoration(
            color: AppColors.aviatorFifteenthColor,
            borderRadius: BorderRadius.circular(30),
          ),

          // ⭐ CONTROL SHAPE & EFFECT HERE ⭐
          customSegmentSettings: CustomSegmentSettings(
            borderRadius: BorderRadius.circular(30), // shape of ripple
            splashColor: Colors.transparent, // remove ripple color
            highlightColor: Colors.transparent, // remove highlight
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),

          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          onValueChanged: (v) {
            setState(() => _selectedValue = v);
          },
        ),
      ),
    );
  }

  //!Auto BUTTON FOR AMOUNT
  Widget _buildAmountTextField(
    BuildContext context,
    TextEditingController controller,
    bool enabled,
    FocusNode focusNode,
  ) {
    return SizedBox(
      width: 140,
      height: 36,
      child: TextField(
        focusNode: focusNode,
        onTap: () {
          if (controller.text == '10') {
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            );
          }
        },
        enableInteractiveSelection: false,
        enabled: enabled,
        controller: controller,
        cursorColor: AppColors.aviatorSixteenthColor,
        cursorHeight: 20,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.aviatorHeadlineSmall,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          int? num = int.tryParse(value);
          if (num != null) {
            if (num > 1000) {
              controller.text = '1000';
              controller.selection = TextSelection.collapsed(
                offset: controller.text.length,
              );
            }
          }
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 2,
            horizontal: 8,
          ),
          // hintText: "1.00",
          hintStyle: Theme.of(context).textTheme.aviatorHeadlineSmallSecond,
          filled: true,
          fillColor: AppColors.aviatorTwentiethColor,
          enabledBorder: _borderStyle(),
          disabledBorder: _borderStyle(),
          focusedBorder: _borderStyle(),
          suffixIcon: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              final int val = int.tryParse(value.text) ?? 10;
              final bool canDecrement = enabled && val > 10;
              final bool canIncrement = enabled && val < 1000;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIconButton(Icons.remove, _decrement, canDecrement),
                  const SizedBox(width: 4),
                  _buildIconButton(Icons.add, _increment, canIncrement),
                  const SizedBox(width: 4),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _borderStyle() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(52),
      borderSide: BorderSide(color: AppColors.aviatorFifteenthColor),
    );
  }

  //! IconButton
  Widget _buildIconButton(IconData icon, VoidCallback onPressed, bool enabled) {
    return IgnorePointer(
      ignoring: !enabled,
      child: CustomElevatedButton(
        hasBorder: false,
        backgroundColor: AppColors.aviatorFifteenthColor,
        padding: const EdgeInsets.all(2),
        height: 22,
        width: 22,
        onPressed: enabled ? onPressed : () {},
        child: Icon(
          icon,
          size: 18.33,
          color: enabled ? AppColors.aviatorTertiaryColor : Colors.transparent,
        ),
      ),
    );
  }

  //!Quick Amount Button
  Widget _quickAmountButton(
    BuildContext context,
    String label,
    String value,
    bool enabled,
  ) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: CustomElevatedButton(
        onPressed: enabled ? () => _setAmount(value) : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        borderColor: const Color(0XFFAA99FD).withOpacity(.2),
        backgroundColor: const Color(0XFF222222).withOpacity(.04),
        borderRadius: 30,
        height: 28,
        elevation: 0,
        child: Text(
          label,
          style: Theme.of(context).textTheme.aviatorBodyMediumFifth,
        ),
      ),
    );
  }

  //!AUTOPLAY
  Widget _buildAutoplayButton(BuildContext context) {
    final isAutoPlayActive = _autoPlayState.settings != null;
    final maxRounds = _autoPlayState.settings?.selectedRounds != null
        ? int.tryParse(_autoPlayState.settings!.selectedRounds!) ?? 0
        : 0;
    final currentRound = _autoPlayState.roundsPlayed;

    final isDisabled = _manualBetActive && !isAutoPlayActive;

    return Flexible(
      flex: 2,
      child: CustomElevatedButton(
        onPressed: isDisabled
            ? null
            : () async {
                if (isAutoPlayActive) {
                  // Stop autoplay
                  _stopAutoPlay();
                } else {
                  // Start autoplay - show dialog with callback
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AutoPlayWidget(
                        onStart: (settings) {
                          _startAutoPlay(settings);
                        },
                      );
                    },
                  );
                }
              },
        padding: const EdgeInsets.symmetric(horizontal: 12),
        borderRadius: 52,
        backgroundColor: isDisabled
            ? AppColors.aviatorTwentiethColor
            : (isAutoPlayActive
                ? AppColors.aviatorTwentySixthColor
                : AppColors.aviatorTwentyNinthColor),
        hasBorder: true,
        height: 28,
        borderColor: AppColors.aviatorNineteenthColor,
        child: Text(
          isDisabled
              ? 'AUTOPLAY'
              : (isAutoPlayActive
                  ? 'STOP ($currentRound/${maxRounds > 0 ? maxRounds : '∞'})'
                  : 'AUTOPLAY'),
          style: Theme.of(context).textTheme.aviatorbodySmallPrimary,
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }

  //!AUTO CASH OUT
  Widget _buildAutoCashOutRow(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Row(
        children: [
          // Label
          Expanded(
            child: Text(
              'Auto Cash Out',
              style: Theme.of(context).textTheme.aviatorbodySmallPrimary,
            ),
          ),
          // Switch
          Expanded(
            child: Transform.scale(
              scale: 0.65,
              child: Switch(
                value: _isSwitched,
                activeColor: AppColors.aviatorTertiaryColor,
                inactiveThumbColor: AppColors.aviatorTertiaryColor,
                activeTrackColor: AppColors.aviatorEighteenthColor,
                inactiveTrackColor: AppColors.aviatorFourteenthColor,
                onChanged: _manualBetActive
                    ? null
                    : (value) => setState(() => _isSwitched = value),
              ),
            ),
          ),
          // TextField
          Expanded(
            child: SizedBox(
              width: 70,
              height: 28,
              child: TextField(
                enableInteractiveSelection: false,
                enabled: _isSwitched && !_manualBetActive,
                controller: _switchController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.aviatorBodyMediumPrimary,
                decoration: InputDecoration(
                  suffixText: "x",
                  suffixStyle: TextStyle(
                    color: AppColors.aviatorSixteenthColor,
                  ),
                  filled: true,
                  fillColor: AppColors.aviatorFifteenthColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 6,
                  ),
                  border: _borderStyle(),
                  errorText: _autoCashoutError,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && _autoCashoutError != null) {
                    setState(() => _autoCashoutError = null);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  //! MANUAL BET
  Widget _manualBetButton() {
    return CustomBetButton(
      index: widget.index,
      amountController: _amountController,
      onBetPlaced: () => setState(() => _manualBetActive = true),
      onBetFinished: () => setState(() => _manualBetActive = false),
      //   switchController: _switchController,
    );
  }

  //! AUTO BET
  Widget _autoBetButton() {
    return CustomBetButton(
      index: widget.index,
      amountController: _autoAmountController,
      switchController: _isSwitched ? _switchController : null,
      autoPlayState: _autoPlayState,
      onAutoPlayUpdate: (roundsPlayed, lastWinAmount) {
        setState(() {
          _autoPlayState = _autoPlayState.copyWith(
            roundsPlayed: roundsPlayed,
            lastWinAmount: lastWinAmount,
          );
        });
        _saveAutoPlayState();
      },
      onAutoPlayStop: _stopAutoPlay,
      shouldContinueAutoPlay: _shouldContinueAutoPlay,
      onBetPlaced: () => setState(() => _manualBetActive = true),
      onBetFinished: () => setState(() => _manualBetActive = false),
    );
  }
}
