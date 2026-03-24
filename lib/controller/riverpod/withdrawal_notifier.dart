import 'dart:developer';

import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/create_transaction_model.dart';
import 'package:sm_project/controller/model/get_particular_player_model.dart';
import 'package:sm_project/controller/model/get_setting_model.dart' as setting;
import 'package:sm_project/controller/model/profile_update_model.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

final getWithdrawalNotifierProvider =
    AsyncNotifierProvider.autoDispose<GetWithdrawalNotifier, GetWithdrawalMode>(
        () {
  return GetWithdrawalNotifier();
});

class GetWithdrawalMode {
  final Data? userDgetParticularUserData =
      UserParticularPlayer.getParticularUserData();

  TextEditingController amountController = TextEditingController();

  setting.GetSettingModel? getSettingModel = setting.GetSettingModel();
  int? leftPoints;

  TextEditingController upiController = TextEditingController();

  final List<String> paymentMethods = ['phonepe', 'gpay', 'paytm', 'bank'];

  String? selectedPaymentMethod;

  String? validationError;
}

class GetWithdrawalNotifier
    extends AutoDisposeAsyncNotifier<GetWithdrawalMode> {
  final GetWithdrawalMode _outputMode = GetWithdrawalMode();

  void setDropDown(String value) {
    _outputMode.selectedPaymentMethod = value;
    state = AsyncData(_outputMode);
  }

  void clearValidationError() {
    _outputMode.validationError = null;
    state = AsyncData(_outputMode);
  }

  void setValidationError(String error) {
    _outputMode.validationError = error;
    state = AsyncData(_outputMode);
  }

  void setData() {
    _outputMode.upiController.text = ref
            .watch(getParticularPlayerNotifierProvider)
            .value
            ?.getParticularPlayerModel
            ?.data
            ?.upiNumber ??
        "";
  }

  Future<void> getSavedUserData(BuildContext context, Map<String, dynamic> body,
      bool isPhonpe, bool isgpay) async {
    try {
      EasyLoading.show(status: 'Loading...');

      // Map<String, dynamic> body = {
      //   'google_pay_no': _outputMode.googlePayNumberController.text
      // };

      log(body.toString());
      ProfileUpdateModel? response = await ApiService().postProfileUpdate(body);
      if (response?.status == 'success') {
        EasyLoading.dismiss();
        toast(response?.message ?? '');
        await ApiService().getParticularUserData();
        Navigator.of(context).pop();
      } else {
        EasyLoading.dismiss();
        toast(response?.message ?? '');
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'editProfileApi');
    }
    state = AsyncData(_outputMode);
  }

  // Withdrawal API HIT

  Future<void> submitWithdrawalApi(BuildContext context) async {
    try {
      if (_outputMode.selectedPaymentMethod == null ||
          _outputMode.selectedPaymentMethod!.isEmpty) {
        toast('Please select payment mode');
        return;
      }

      EasyLoading.show(status: 'Loading...');

      // Store values before async operations to avoid ref issues
      // Get userId from current state (don't use watch inside async)
      final userId = ref
              .read(getParticularPlayerNotifierProvider)
              .value
              ?.getParticularPlayerModel
              ?.data
              ?.sId ??
          '';

      Map<String, dynamic> body = {
        "user_id": userId,
        'amount': _outputMode.amountController.text,
        'transfer_type': 'withdrawal',
        "type": "mobile",
        'note': 'withdraw request',
        'withdraw_type': _outputMode.selectedPaymentMethod,
      };

      log(body.toString());

      _outputMode.getSettingModel = await ApiService().getSettingModel();
      final amount = int.tryParse(_outputMode.amountController.text);

      if (amount == null) {
        EasyLoading.dismiss();
        toast('Invalid amount');
        return;
      }

      if (amount < (_outputMode.getSettingModel?.data?.withdraw?.min ?? 0)) {
        EasyLoading.dismiss();
        toast(
            'Minimum withdrawal ${_outputMode.getSettingModel?.data?.withdraw?.min ?? 0}');
      } else if (amount >
          (_outputMode.getSettingModel?.data?.withdraw?.max ?? 0)) {
        EasyLoading.dismiss();
        toast(
            'Maximum withdrawal ${_outputMode.getSettingModel?.data?.withdraw?.max ?? 0}');
      } else {
        if (amount <= (_outputMode.leftPoints ?? 0)) {
          CreateTransactionModel? response =
              await ApiService().postCreateTransaction(body);

          if (response?.status == 'success') {
            EasyLoading.dismiss();
            if (context.mounted) {
              ref
                  .read(homeNotifierProvider.notifier)
                  .getParticularPlayerModel(context);
            }
            toast(response?.message ?? '');
            if (context.mounted) {
              context.pushReplacementNamed(RouteNames.homeScreen);
            }
          } else {
            EasyLoading.dismiss();
            toast(response?.message ?? '');
          }
        } else {
          EasyLoading.dismiss();
          toast('Insufficient balance');
        }
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'submitWithdrawalApi');
    }
  }

  Future<void>? getSettingModelData(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Loading...');
      _outputMode.getSettingModel = await ApiService().getSettingModel();
      if (_outputMode.getSettingModel?.status == "success") {
        EasyLoading.dismiss();
      } else if (_outputMode.getSettingModel?.status == "failure") {
        EasyLoading.dismiss();
        toast('Something went wrong');
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'getSettingModelData');
    }
    state = AsyncData(_outputMode);
  }

  void showAlertDialog(BuildContext context, bool isPhonpe, bool isgpay) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isPhonpe == true
              ? 'Enter PhonePe Number'
              : isgpay == true
                  ? 'Enter GooglePay Number'
                  : 'Enter Paytm Number'),
          content: TextFormField(
            controller: isPhonpe == true
                ? _outputMode.upiController
                : isgpay == true
                    ? _outputMode.upiController
                    : _outputMode.upiController,
            decoration: InputDecoration(
              labelText: isPhonpe == true
                  ? 'Enter PhonePe Number'
                  : isgpay == true
                      ? 'Enter GooglePay Number'
                      : 'Enter Paytm Number',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (isPhonpe == true) {
                  if (_outputMode.upiController.text.isEmpty) {
                    toast('Please enter phonepe number');
                  } else if ((_outputMode.upiController.text.length) < 10 ||
                      (_outputMode.upiController.text.length) > 10) {
                    toast('Phonepe number must be 10 digit');
                  } else {
                    Map<String, dynamic> body = {
                      'upi_number': _outputMode.upiController.text,
                      "id": ref
                              .watch(getParticularPlayerNotifierProvider)
                              .value
                              ?.getParticularPlayerModel
                              ?.data
                              ?.sId ??
                          "",
                    };
                    getSavedUserData(context, body, true, false);
                  }
                } else if (isgpay == true) {
                  if (_outputMode.upiController.text.isEmpty) {
                    toast('Please enter gpay number');
                  } else if ((_outputMode.upiController.text.length) < 10 ||
                      (_outputMode.upiController.text.length) > 10) {
                    toast('Gpay number must be 10 digit');
                  } else {
                    Map<String, dynamic> body = {
                      'upi_number': _outputMode.upiController.text,
                      "id": ref
                              .watch(getParticularPlayerNotifierProvider)
                              .value
                              ?.getParticularPlayerModel
                              ?.data
                              ?.sId ??
                          "",
                    };
                    getSavedUserData(context, body, false, true);
                  }
                } else if (isPhonpe == false && isgpay == false) {
                  if (_outputMode.upiController.text.isEmpty) {
                    toast('Please enter paytm number');
                  } else if ((_outputMode.upiController.text.length) < 10 ||
                      (_outputMode.upiController.text.length) > 10) {
                    toast('Paytm number must be 10 digit');
                  } else {
                    Map<String, dynamic> body = {
                      'upi_number': _outputMode.upiController.text,
                      "id": ref
                              .watch(getParticularPlayerNotifierProvider)
                              .value
                              ?.getParticularPlayerModel
                              ?.data
                              ?.sId ??
                          "",
                    };
                    getSavedUserData(context, body, false, false);
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  // Check if withdrawal is off for current day
  bool isWithdrawalOffToday() {
    if (_outputMode.getSettingModel?.data?.withdrawlOffDay == null) {
      return false;
    }

    final withdrawlOffDay = _outputMode.getSettingModel!.data!.withdrawlOffDay!;
    final now = DateTime.now();
    final currentDay = now.weekday; // 1 = Monday, 7 = Sunday

    switch (currentDay) {
      case 1: // Monday
        return withdrawlOffDay.monday ?? false;
      case 2: // Tuesday
        return withdrawlOffDay.tuesday ?? false;
      case 3: // Wednesday
        return withdrawlOffDay.wednesday ?? false;
      case 4: // Thursday
        return withdrawlOffDay.thursday ?? false;
      case 5: // Friday
        return withdrawlOffDay.friday ?? false;
      case 6: // Saturday
        return withdrawlOffDay.saturday ?? false;
      case 7: // Sunday
        return withdrawlOffDay.sunday ?? false;
      default:
        return false;
    }
  }

  // Get current day name for display
  String getCurrentDayName() {
    final now = DateTime.now();
    final currentDay = now.weekday;

    switch (currentDay) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  // Show beautiful withdrawal off day popup
  void showWithdrawalOffDayPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3A4CA8), Color(0xFF0D1333)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.access_time,
                    size: 48,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                const Text(
                  'Withdrawal Unavailable',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Message
                Text(
                  'Withdrawals are currently unavailable on ${getCurrentDayName()}s.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Additional Info
                Text(
                  'Please try again on another day or contact support for assistance.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Action Buttons
                Row(
                  children: [
                    // OK Button
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.white, Colors.white],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0D1333),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  build() {
    _outputMode.leftPoints =
        _outputMode.userDgetParticularUserData?.wallet ?? 0;
    return _outputMode;
  }
}
