import 'dart:developer';

import 'package:flutter_upi_india/flutter_upi_india.dart';
import 'package:sm_project/utils/filecollection.dart';

final jackpotPaymentNotifierProvider = AsyncNotifierProvider.autoDispose<
    JackpotPaymentNotifier, JackpotPaymentData>(() {
  return JackpotPaymentNotifier();
});

class JackpotPaymentNotifier
    extends AutoDisposeAsyncNotifier<JackpotPaymentData> {
  JackpotPaymentData jackpotPaymentData = JackpotPaymentData(
    selectedQuantityMutliplier: 1,
    balanceFields: [
      10,
      50,
      100,
      1000,
    ],
    selectedBalanceField: 10,
    quantity: TextEditingController(text: "1"),
    quantityMultiplier: [
      1,
      5,
      10,
      20,
      50,
      100,
    ],
    totalAmount: 10,
  );

  updateQuanityMultiplier(int quantityMultiplier) {
    jackpotPaymentData.selectedQuantityMutliplier = quantityMultiplier;
    jackpotPaymentData.quantity.text = quantityMultiplier.toString();
    updateTotalAmount();
  }

  updateBalanceField(int balanceField) {
    jackpotPaymentData.selectedBalanceField = balanceField;
    updateTotalAmount();
  }

  updateTotalAmount() {
    jackpotPaymentData.totalAmount = (jackpotPaymentData.selectedBalanceField) *
        (int.tryParse(jackpotPaymentData.quantity.text) ?? 0);
    state = AsyncData(jackpotPaymentData);
  }

  quantityIncrement() {
    log("Working");
    jackpotPaymentData.quantity.text =
        ((int.tryParse(jackpotPaymentData.quantity.text) ?? 0) + 1).toString();
    updateTotalAmount();
  }

  quantityDecrement() {
    if ((int.tryParse(jackpotPaymentData.quantity.text) ?? 0) > 1) {
      jackpotPaymentData.quantity.text =
          ((int.tryParse(jackpotPaymentData.quantity.text) ?? 0) - 1)
              .toString();
      updateTotalAmount();
    }
  }

  // FIX: Parameter updated to ApplicationMeta
  updateUpiApp(ApplicationMeta? upiApp) {
    jackpotPaymentData.app = upiApp;
    state = AsyncData(jackpotPaymentData);
  }


  @override
  build() {
    return jackpotPaymentData;
  }
}

class JackpotPaymentData {
  int selectedBalanceField;
  TextEditingController quantity;
  List<int> balanceFields;
  List<int> quantityMultiplier;
  int selectedQuantityMutliplier;
  int totalAmount;
  ApplicationMeta? app;
  JackpotPaymentData({
    required this.balanceFields,
    required this.selectedBalanceField,
    required this.quantity,
    required this.quantityMultiplier,
    required this.selectedQuantityMutliplier,
    required this.totalAmount,
    this.app,
  });
}
