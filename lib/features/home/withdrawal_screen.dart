import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/get_particular_player_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/controller/riverpod/withdrawal_notifier.dart';
import 'package:sm_project/features/drawer/saved_bank_account.dart';
import 'package:sm_project/features/withdrawal_deposit_leaderboard/vertical_leaderboard_text.dart';
import 'package:sm_project/utils/app_utils.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:url_launcher/url_launcher.dart';

class Withdrawal extends ConsumerStatefulWidget {
  const Withdrawal({super.key});

  @override
  ConsumerState<Withdrawal> createState() => _WithdrawalState();
}

class _WithdrawalState extends ConsumerState<Withdrawal> {
  final Data? userDgetParticularUserData =
      UserParticularPlayer.getParticularUserData();

  void launchWhatsApp(String number, String message) async {
    var whatsappUrl =
        Uri.parse("https://wa.me/$number&text=${Uri.encodeComponent(message)}");
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else {
        toast('WhatsApp is not installed');
      }
    } catch (e) {
      toast('Could not launch WhatsApp');
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(getWithdrawalNotifierProvider.notifier)
          .getSettingModelData(context);
      ref
          .read(getParticularPlayerNotifierProvider.notifier)
          .getParticularPlayerModel(context: context)
          .then((value) {
        ref.read(getWithdrawalNotifierProvider.notifier).setData();

        // Check if withdrawal is off for today after data is loaded
        Future.delayed(const Duration(milliseconds: 500), () {
          final withdrawalNotifier =
              ref.read(getWithdrawalNotifierProvider.notifier);
          if (!withdrawalNotifier.isWithdrawalOffToday()) {
            withdrawalNotifier.showWithdrawalOffDayPopup(context);
          }
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF4CAF50);

    return Scaffold(
        backgroundColor: whiteBackgroundColor,
        appBar: AppBar(
          backgroundColor: darkBlue,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: context.canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      size: 18, color: Colors.white),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    }
                  },
                )
              : null,
          title: Text(
            "Withdraw",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          actions: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(walletLogo, width: 20, color: whiteBackgroundColor),
                const SizedBox(width: 10),
                Text('₹${userDgetParticularUserData?.wallet ?? '0'}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    )),
                const SizedBox(width: 15),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 12),
            // Green Timing Banner
            Consumer(builder: (context, ref, child) {
              final refWatch = ref.watch(getWithdrawalNotifierProvider);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF27717a),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Text(
                  'Withdraw Timings: ${convert24HrTo12Hr(refWatch.value?.getSettingModel?.data?.withdrawOpen ?? '08:00')} to ${convert24HrTo12Hr(refWatch.value?.getSettingModel?.data?.withdrawClose ?? '10:00')}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            // Red Days Banner
            const TextCycleWidget(filter: TextCycleFilter.withdrawal),

            Expanded(
              child: Container(
                color: whiteBackgroundColor,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Consumer(builder: (context, ref, child) {
                      final refWatch = ref.watch(getWithdrawalNotifierProvider);
                      final refRead =
                          ref.read(getWithdrawalNotifierProvider.notifier);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            'Withdraw point from your Wallet.',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Amount Input
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextFormField(
                              controller: refWatch.value?.amountController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Withdraw Points',
                                hintStyle: GoogleFonts.poppins(
                                  color: Colors.grey.shade400,
                                  fontSize: 16,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: darkBlue,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.5,
                                  ),
                                ),
                                focusedErrorBorder: const OutlineInputBorder(),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Minimum Amount Text, Maximum Amount Text, Left Points Text
                          Consumer(builder: (context, ref, child) {
                            final refWatch =
                                ref.watch(getWithdrawalNotifierProvider);
                            final minAmount = refWatch.value?.getSettingModel
                                    ?.data?.withdraw?.min ??
                                1000;
                            final maxAmount = refWatch.value?.getSettingModel
                                    ?.data?.withdraw?.max ??
                                100000;
                            final leftPoints = refWatch.value?.leftPoints ?? 0;
                            final errorMessage =
                                refWatch.value?.validationError ?? '';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (errorMessage.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: Colors.red.shade700, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          errorMessage,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            );
                          }),

                          const SizedBox(height: 24),

                          // Select Method Title
                          Text(
                            'Select Method',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Payment Method Radio List
                          _buildPaymentMethodRadio(
                            context: context,
                            image: 'assets/images/gpay.png',
                            name: 'Google Pay',
                            value: 'Google Pay',
                            selectedValue:
                                refWatch.value?.selectedPaymentMethod ?? '',
                            onTap: () {
                              refRead.setDropDown('Google Pay');
                              refRead.showAlertDialog(context, false, true);
                            },
                          ),

                          _buildPaymentMethodRadio(
                            context: context,
                            image: 'assets/images/paytm.png',
                            name: 'Paytm',
                            value: 'Paytm',
                            selectedValue:
                                refWatch.value?.selectedPaymentMethod ?? '',
                            onTap: () {
                              refRead.setDropDown('Paytm');
                              refRead.showAlertDialog(context, false, false);
                            },
                          ),

                          _buildPaymentMethodRadio(
                            context: context,
                            image: 'assets/images/phonepe.png',
                            name: 'Phone Pay',
                            value: 'Phone Pay',
                            selectedValue:
                                refWatch.value?.selectedPaymentMethod ?? '',
                            onTap: () {
                              refRead.setDropDown('Phone Pay');
                              refRead.showAlertDialog(context, true, false);
                            },
                          ),

                          _buildPaymentMethodRadio(
                            context: context,
                            image: 'assets/images/deposit1.png',
                            name: 'Bank Account',
                            value: 'Bank Account',
                            selectedValue:
                                refWatch.value?.selectedPaymentMethod ?? '',
                            onTap: () {
                              refRead.setDropDown('Bank Account');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SavedBankAccount(),
                                ),
                              );
                            },
                          ),

                          _buildPaymentMethodRadio(
                            context: context,
                            image: 'assets/images/WhatsApp_icon 1.png',
                            name: 'Whatsapp',
                            value: 'Whatsapp',
                            selectedValue:
                                refWatch.value?.selectedPaymentMethod ?? '',
                            onTap: () {
                              refRead.setDropDown('Whatsapp');
                              log('${refWatch.value?.getSettingModel?.data?.whatsapp}');
                              launchWhatsApp(
                                refWatch.value?.getSettingModel?.data
                                        ?.whatsapp ??
                                    '',
                                'Hi, I need help with my withdrawal',
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          // Withdrawal Notice
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              refWatch.value?.getSettingModel?.data
                                      ?.withdrawalText ??
                                  '',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Submit Button
                          InkWell(
                            onTap: () async {
                              // Get notifier once at the start
                              final notifier = ref
                                  .read(getWithdrawalNotifierProvider.notifier);

                              // Clear previous validation error
                              notifier.clearValidationError();

                              // Get current values
                              final currentState =
                                  ref.read(getWithdrawalNotifierProvider);
                              final amountText =
                                  currentState.value?.amountController.text ??
                                      '';
                              final selectedMethod =
                                  currentState.value?.selectedPaymentMethod ??
                                      '';
                              final upiNumber =
                                  currentState.value?.upiController.text ?? '';
                              final minAmount = currentState.value
                                      ?.getSettingModel?.data?.withdraw?.min ??
                                  1000;
                              final maxAmount = currentState.value
                                      ?.getSettingModel?.data?.withdraw?.max ??
                                  100000;
                              final leftPoints =
                                  currentState.value?.leftPoints ?? 0;

                              // Validation
                              if (amountText.isEmpty) {
                                notifier
                                    .setValidationError('Please enter amount');
                                toast('Please enter amount');
                                return;
                              }

                              if (selectedMethod.isEmpty) {
                                notifier.setValidationError(
                                    'Please select payment method');
                                toast('Please select payment method');
                                return;
                              }

                              // Check if payment method requires UPI and UPI is empty
                              if (selectedMethod != 'Bank Account' &&
                                  selectedMethod != 'Whatsapp' &&
                                  upiNumber.isEmpty) {
                                notifier.setValidationError(
                                    'Please enter UPI number');
                                toast('Please enter UPI number');
                                return;
                              }

                              final amount = int.tryParse(amountText);
                              if (amount == null) {
                                notifier.setValidationError('Invalid amount');
                                toast('Invalid amount');
                                return;
                              }

                              if (amount < minAmount) {
                                notifier.setValidationError(
                                    'Minimum amount is ₹$minAmount');
                                toast('Minimum withdrawal ₹$minAmount');
                                return;
                              }

                              if (amount > maxAmount) {
                                notifier.setValidationError(
                                    'Maximum amount is ₹$maxAmount');
                                toast('Maximum withdrawal ₹$maxAmount');
                                return;
                              }

                              if (amount > leftPoints) {
                                notifier
                                    .setValidationError('Insufficient balance');
                                toast('Insufficient balance');
                                return;
                              }

                              // All validations passed, submit
                              await notifier.submitWithdrawalApi(context);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: darkBlue,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryGreen.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: Text(
                                'Submit',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildPaymentMethodRadio({
    required BuildContext context,
    required String image,
    required String name,
    required String value,
    required String selectedValue,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? darkBlue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? darkBlue : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: darkBlue,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Image.asset(
              image,
              fit: BoxFit.contain,
              width: 30,
            ),
            const SizedBox(width: 12),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chooseNumber(
      BuildContext context, String? number, TextEditingController? controller) {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: Container(
                height: 50,
                decoration: const BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10))),
                child: Center(
                    child: Text(number.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: whiteBackgroundColor))))),
        Expanded(
          flex: 4,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
                color: whiteBackgroundColor,
                border: Border.all(),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10))),
            width: MediaQuery.of(context).size.width * 0.3,
            child: TextFormField(
              textAlignVertical: TextAlignVertical.center,
              textAlign: TextAlign.center,
              controller: controller,
              cursorColor: darkBlue,
              maxLines: 1,
              style: const TextStyle(
                  fontSize: 16, color: textColor, fontWeight: FontWeight.w500),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 15),
                  isDense: true,
                  hintStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none),
            ),
          ),
        )
      ],
    );
  }
}
