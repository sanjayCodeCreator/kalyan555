import 'package:image_picker/image_picker.dart';
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/features/home/home_api.dart';
import 'package:sm_project/utils/filecollection.dart';

final transactionNotifierProvider = AsyncNotifierProvider.autoDispose<
    TransactionNotifier, TransactionNotifierModel>(() {
  return TransactionNotifier();
});

class TransactionNotifier
    extends AutoDisposeAsyncNotifier<TransactionNotifierModel> {
  TransactionNotifierModel transactionModel = TransactionNotifierModel(
      amountController: TextEditingController(text: ""));

  pickImage() async {
    final result = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (result != null) {
      transactionModel.file = result;
      state = AsyncData(transactionModel);
    }
  }

  updateAmount(String amount) {
    transactionModel.amount = amount;
  }

  sumbmitData() async {
    if (transactionModel.file == null) {
      toast("Select Transaction Image");
      return;
    }
    if (transactionModel.amount == null) {
      toast("Please enter amount");
      return;
    }
    if (transactionModel.amount?.trim().isEmpty ?? true) {
      toast("Please enter amount");
      return;
    }
    EasyLoading.show();
    await ref
        .read(getParticularPlayerNotifierProvider.notifier)
        .getParticularPlayerModel();
    final result = await HomeApi.uploadTransactionDetails(
        userId: ref
                .watch(getParticularPlayerNotifierProvider)
                .value
                ?.getParticularPlayerModel
                ?.data
                ?.sId ??
            "",
        fileName: transactionModel.file?.name ?? "",
        filePath: transactionModel.file?.path ?? "",
        amount: transactionModel.amount ?? "");
    if (result) {
      toast("Transaction Uploaded Successfully");
      transactionModel.file = null;
      transactionModel.amountController.clear();
      state = AsyncData(transactionModel);
    }
    EasyLoading.dismiss();
  }

  @override
  TransactionNotifierModel build() {
    return transactionModel;
  }
}

class TransactionNotifierModel {
  XFile? file;
  String? amount;
  TextEditingController amountController;
  TransactionNotifierModel({
    this.file,
    this.amount,
    required this.amountController,
  });
}
