import 'dart:developer';
import 'package:sm_project/controller/model/transaction_history_model.dart';
import 'package:sm_project/utils/filecollection.dart';

final getTransactionHistoryNotifierProvider = AsyncNotifierProvider.autoDispose<
    TransactionHistoryNotifier, TransactionHistoryMode>(() {
  return TransactionHistoryNotifier();
});

class TransactionHistoryMode {
  TransactionHistoryModel? transactionHistoryModel = TransactionHistoryModel();
}

class TransactionHistoryNotifier
    extends AutoDisposeAsyncNotifier<TransactionHistoryMode> {
  final TransactionHistoryMode _outputMode = TransactionHistoryMode();

  // GetTransactionHistoryModel user

  void getTransactionHistoryModel() async {
    try {
      EasyLoading.show(status: 'Loading...');
      _outputMode.transactionHistoryModel =
          await ApiService().getBidsHistoryTransaction();
      if (_outputMode.transactionHistoryModel?.status == "success") {
        EasyLoading.dismiss();
      } else if (_outputMode.transactionHistoryModel?.status == "failure") {
        EasyLoading.dismiss();
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'getParticularPlayerModel');
    }
    state = AsyncData(_outputMode);
  }

  @override
  build() {
    // getTransactionHistoryModel();
    return _outputMode;
  }
}
