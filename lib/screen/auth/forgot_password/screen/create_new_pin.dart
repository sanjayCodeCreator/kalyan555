import 'dart:developer';

import 'package:sm_project/screen/auth/forgot_password/forgot_notifier/create_new_pin.dart';
import 'package:sm_project/utils/filecollection.dart';

class CreateNewPin extends StatelessWidget {
  final String? mobileNumber;
  final GlobalKey<FormState> _formCreatePinKey = GlobalKey<FormState>();
  CreateNewPin({super.key, this.mobileNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
            child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 20, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppBackICon(),
                        const Text('Create new PIN',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            )),
                        const SizedBox(height: 10),
                        const Text(
                            "Your new PIN must be unique from those previously used.",
                            style: TextStyle(color: Color(0xff9E9E9E))),
                        Consumer(builder: (context, ref, child) {
                          final refWatch =
                              ref.watch(createNewPinNotifierProvider);
                          final refRead =
                              ref.read(createNewPinNotifierProvider.notifier);

                          return Form(
                              key: _formCreatePinKey,
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 30, 0, 20),
                                decoration: BoxDecoration(
                                    color: whiteBackgroundColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("New Pin"),
                                      CustomTextFormField(
                                          controller: refWatch
                                              .value?.pinCreateController,
                                          keyboardType: TextInputType.text,
                                          prefixIcon: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Image.asset(lockLogo,
                                                  height: 20, width: 20)),
                                          hintText: 'Enter Pin',
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter Pin';
                                            } else if (value.length < 4 ||
                                                value.length > 4) {
                                              return 'Pin must be 4 digit';
                                            }
                                            return null;
                                          }),
                                      const SizedBox(height: 20),
                                      const Text("Confirm New Pin"),
                                      CustomTextFormField(
                                          controller: refWatch.value
                                              ?.confirmPinCreateController,
                                          keyboardType: TextInputType.text,
                                          prefixIcon: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Image.asset(lockLogo,
                                                  height: 20, width: 20)),
                                          hintText: 'Enter Confirm Pin',
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter Pin';
                                            } else if (refWatch
                                                    .value
                                                    ?.pinCreateController
                                                    .text !=
                                                value) {
                                              return 'Pin is not match';
                                            }
                                            return null;
                                          }),
                                      const SizedBox(height: 35),
                                      buttonSizedBox(
                                          color: whiteBackgroundColor,
                                          text: 'Create Pin',
                                          textColor: whiteBackgroundColor,
                                          onTap: () {
                                            if (!_formCreatePinKey.currentState!
                                                .validate()) {
                                              log('Form is not valid');
                                            } else {
                                              refRead.createNewPin(context);
                                            }
                                          }),
                                    ]),
                              ));
                        })
                      ],
                    )))));
  }
}
