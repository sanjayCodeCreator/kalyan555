import 'dart:developer';

import 'package:sm_project/features/drawer/saved_bank_notifier.dart';
import 'package:sm_project/features/reusubility_widget/background_wrapper.dart';
import 'package:sm_project/utils/filecollection.dart';

class SavedBankAccount extends ConsumerStatefulWidget {
  const SavedBankAccount({super.key});

  @override
  ConsumerState<SavedBankAccount> createState() => _SavedBankAccountState();
}

class _SavedBankAccountState extends ConsumerState<SavedBankAccount> {
  final GlobalKey<FormState> _savedBankAccount = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedBankNotifierProvider.notifier).setData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final refWatch = ref.watch(savedBankNotifierProvider).value;
    final refRead = ref.read(savedBankNotifierProvider.notifier);

    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xfff0f0f0),
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            "Saved Bank Account",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          leading: InkWell(
            onTap: () {
              context.pop();
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _savedBankAccount,
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      CustomTextFormField(
                        labelText: "Bank Name",
                        hintText: 'Please enter Account Bank Name',
                        controller: refWatch?.bankNameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter bank name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextFormField(
                        labelText: "Account Holder Name",
                        hintText: 'Please Account Holder Name',
                        controller: refWatch?.accountHolderController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter holder name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextFormField(
                        labelText: "Account Number",
                        hintText: 'Please enter Account Number',
                        controller: refWatch?.acountNumberController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter account number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextFormField(
                        labelText: "Re Enter Account Number",
                        obscureText: !refWatch!.obsecureText,
                        hintText: 'Please Re Enter Account Number',
                        controller: refWatch.reAcountNumberController,
                        suffixIcon: InkWell(
                            onTap: () {
                              refRead.changeObsecureText();
                            },
                            child: Icon(refWatch.obsecureText
                                ? Icons.remove_red_eye
                                : Icons.visibility_off)),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter re account number';
                          } else if (value !=
                              refWatch.acountNumberController.text) {
                            return 'Account number does not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      CustomTextFormField(
                        labelText: "IFSC Code",
                        hintText: 'Please enter IFSC Code',
                        controller: refWatch.ifscController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter IFSC code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      InkWell(
                        onTap: () {
                          if (!_savedBankAccount.currentState!.validate()) {
                            log('Form is not valid');
                          } else {
                            refRead.savedBank(context);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(25, 12, 25, 12),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(15)),
                          child: const Text('Save',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: whiteBackgroundColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ))),
      ),
    );
  }
}
